module AzureCompileBattleData
  OUTPUTS=%w[Data/moves.dat Data/pokmanitems.rxdata Data/metrics.dat Data/regionals.dat
    Data/evolutions.dat Data/dexdata.dat Data/eggEmerald.dat Data/attacksRS.rxdata
    Data/tm.dat Data/trainers.dat Data/encounters.dat Data/bossdata.dat
    Data/shadowmoves.dat Data/messages.dat Scripts/PBMoves.rb Scripts/PBItems.rb Scripts/PBSpecies.rb].freeze

  def self.run
    File.open(ENV.fetch("AZURE_BATTLE_SIMULATION_REPORT"),"wb") do |report|
      report.sync=true
      MessageTypes.loadMessageFile("Data/messages.dat")
      [[:moves,PBMoves,"PBMoves"],[:items,PBItems,"PBItems"],[:species,PBSpecies,"PBSpecies"]].each do |kind,namespace,script|
        report.puts("Compiling #{kind}")
        case kind
        when :moves then pbCompileMoves
        when :items then pbCompileItems
        when :species then pbCompilePokemonData
        end
        namespace.constants(false).each { |name| namespace.send(:remove_const,name) }
        load File.join("Scripts","#{script}.rb")
      end
      report.puts("Compiling dependent battle data")
      pbCompileMachines
      pbCompileTrainers
      pbCompileEncounters
      pbCompileBosses
      pbCompileShadowMoves
      MessageTypes.saveMessages
      reference=ENV["AZURE_BATTLE_REFERENCE_DATA"]
      compare_reference(reference,report) if reference && !reference.empty?
      OUTPUTS.each do |path|
        raise "Missing compiled output #{path}" if !File.file?(path)
        report.puts("OUTPUT #{path}")
      end
      report.puts("result=PASS")
    end
  end

  def self.compare_reference(reference,report)
    %w[moves.dat pokmanitems.rxdata dexdata.dat metrics.dat].each do |name|
      before=File.open(File.join(reference,name),"rb") { |file| Marshal.load(file) }
      after=File.open(File.join("Data",name),"rb") { |file| Marshal.load(file) }
      changes=(0...[before.length,after.length].max).select { |index| before[index]!=after[index] }
      report.puts("CHANGED #{name} rows=#{changes.join(',')}")
    end
    name="messages.dat"
    before=File.open(File.join(reference,name),"rb") { |file| Marshal.load(file) }
    after=File.open(File.join("Data",name),"rb") { |file| Marshal.load(file) }
    changes=(0...[before.length,after.length].max).select { |index| before[index]!=after[index] }
    report.puts("CHANGED #{name} categories=#{changes.join(',')}")
  end
end
