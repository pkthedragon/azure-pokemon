module AzureCatalogAudit
  SECTIONS={"species"=>["Species",:species,PBSpecies],"moves"=>["Moves",:move,PBMoves],
    "abilities"=>["Abilities",:ability,PBAbilities],"items"=>["Items",:item,PBItems],
    "teams"=>["Teams",:team,nil],"tributes"=>["Tributes",:tribute,nil]}.freeze

  def self.with_deadline(seconds)
    runner=Thread.current
    watchdog=Thread.new do
      sleep(seconds)
      note=runner.backtrace&.take(6)&.join(" <- ")
      runner.raise RuntimeError,"Battle exceeded #{seconds}s at #{note}"
    end
    yield
  ensure
    watchdog.kill if watchdog
  end

  class Audit
    def initialize(report,pbs)
      @report=report
      @pbs=pbs
      @counts=Hash.new(0)
    end

    def line(message)
      @report.puts(message)
    end

    def catalog(_kind,namespace)
      namespace.constants(false).filter_map do |symbol|
        next if !symbol.to_s.match?(/\A[A-Z][A-Za-z0-9_]*\z/)
        id=namespace.const_get(symbol,false)
        [symbol,id] if id.is_a?(Integer) && id>0
      end.sort_by { |symbol,id| [id,symbol.to_s] }
    end

    def source_entries(kind)
      if kind==:item
        return File.foreach(File.join(@pbs,"items.txt"),encoding: "bom|utf-8").filter_map do |line|
          match=line.match(/\A(\d+)\s*,\s*([A-Z][A-Z0-9_]*)\s*,/)
          [match[2].to_sym,match[1].to_i] if match
        end
      end
      key,filename={species: ["Species","pokemon.txt"],move: ["Move","moves.txt"],
        ability: ["Ability","abilities.txt"]}.fetch(kind)
      symbol=nil
      File.foreach(File.join(@pbs,filename),encoding: "bom|utf-8").filter_map do |line|
        section=line.match(/\A\[([A-Z][A-Za-z0-9_]*)\]/)
        symbol=section[1].to_sym if section
        match=line.match(/\ALegacy#{key}ID\s*=\s*(\d+)/)
        [symbol,match[1].to_i] if match && symbol
      end
    end

    def compare_source(kind,namespace)
      runtime=catalog(kind,namespace).to_h
      pbs=source_entries(kind)
      line("INVENTORY #{kind} pbs_rows=#{pbs.size} pbs_symbols=#{pbs.to_h.size} runtime_symbols=#{runtime.size} runtime_ids=#{runtime.values.uniq.size}")
      pbs.group_by(&:first).each do |symbol,rows|
        ids=rows.map(&:last).uniq
        effective=runtime[symbol]
        if kind==:ability && ids.length>1 && ids.all? { |id| PBAbilityData.canonical_id(id)==effective }
          record(kind,symbol,:skip,"legacy-save-id","pbs_ids=#{ids.join(',')} runtime_id=#{effective}")
        elsif !ids.include?(effective)
          record(kind,symbol,:mismatch,"source-registration","pbs_ids=#{ids.join(',')} runtime_id=#{effective || 'missing'}")
        elsif ids.size>1
          record(kind,symbol,:mismatch,"source-duplicate","pbs_ids=#{ids.join(',')} runtime_id=#{effective}")
        elsif rows.size>1
          record(kind,symbol,:skip,"source-duplicate","repeated_rows=#{rows.size} id=#{effective}")
        end
      end
      runtime.group_by(&:last).each do |id,rows|
        next if rows.size==1
        record(kind,id,:skip,"runtime-aliases",rows.map(&:first).join(','))
      end
      source=pbs.to_h
      runtime.each do |symbol,id|
        record(kind,symbol,:skip,"runtime-only","id=#{id}") if !source.key?(symbol)
      end
    end

    def record(kind,symbol,status,route,detail)
      @counts[[kind,status]]+=1
      message=detail.to_s[0,600].gsub(/[\r\n\t]+/," ").scrub
      line("#{status.to_s.upcase} #{kind} #{symbol} #{route} #{message}")
    end

    def check(kind,symbol,route)
      result=yield
      record(kind,symbol,:pass,route,result)
      result
    rescue StandardError, ScriptError => error
      record(kind,symbol,:error,route,"#{error.class}: #{error.message.to_s[0,260]} at #{error.backtrace&.first}")
      nil
    end

    def finish
      @counts.keys.map(&:first).uniq.each do |kind|
        totals=[:pass,:skip,:gap,:mismatch,:error].map { |status| "#{status}=#{@counts[[kind,status]]}" }
        line("SUMMARY #{kind} #{totals.join(' ')}")
      end
      totals=@counts.each_with_object(Hash.new(0)) { |((_,status),number),count| count[status]+=number }
      result=totals[:mismatch]+totals[:error]>0 ? "FAIL" : "PASS"
      line("result=#{result} errors=#{totals[:error]} mismatches=#{totals[:mismatch]} gaps=#{totals[:gap]}")
    end
  end

  def self.run(source,requested)
    $data_system=pbLoadRxData("Data/System")
    $mapinfos=pbCachedRxData("Data/MapInfos")
    $game_system=Game_System.new
    pbLoadAzureRuntimeData
    PBDebug.define_singleton_method(:logonerr) { |&block| block.call }
    $INTERNAL=false
    File.open(ENV.fetch("AZURE_BATTLE_SIMULATION_REPORT"),"wb") do |file|
      file.sync=true
      audit=Audit.new(file,ENV.fetch("AZURE_BATTLE_CATALOG_PBS"))
      selections=requested=="all" ? SECTIONS.values : [SECTIONS.fetch(requested)]
      audit.line("AZURE BATTLE CATALOG section=#{requested} ruby=#{RUBY_VERSION}")
      selections.each do |name,kind,namespace|
        seed=134+SECTIONS.keys.index(name.downcase)
        srand(seed)
        AzureAbilityFixture.setup_new_game
        audit.line("SECTION #{kind} seed=#{seed}")
        audit.compare_source(kind,namespace) if namespace
        audit.check(kind,"catalog","suite") do
          load File.join(source,"AzureCatalog#{name}.rb")
          Object.const_get("AzureCatalog#{name}",false).run(audit)
          "suite completed"
        end
      end
      audit.finish
    end
  end
end
