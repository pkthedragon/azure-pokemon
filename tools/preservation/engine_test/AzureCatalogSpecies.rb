load File.join(__dir__,"AzureBattleSimulation.rb") unless defined?(AzureBattleSimulation::Battle)

module AzureCatalogSpecies
  FORM_PROPERTIES=%w[type1 type2 getBaseStats ability getMoveList height weight dexEntry].freeze
  PLATES=[:FISTPLATE,:SKYPLATE,:TOXICPLATE,:EARTHPLATE,:STONEPLATE,:INSECTPLATE,:SPOOKYPLATE,:IRONPLATE,nil,
    :FLAMEPLATE,:SPLASHPLATE,:MEADOWPLATE,:ZAPPLATE,:MINDPLATE,:ICICLEPLATE,:DRACOPLATE,:DREADPLATE,:PIXIEPLATE].freeze
  MEMORIES=[:FIGHTINGMEMORY,:FLYINGMEMORY,:POISONMEMORY,:GROUNDMEMORY,:ROCKMEMORY,:BUGMEMORY,:GHOSTMEMORY,
    :STEELMEMORY,nil,:FIREMEMORY,:WATERMEMORY,:GRASSMEMORY,:ELECTRICMEMORY,:PSYCHICMEMORY,:ICEMEMORY,
    :DRAGONMEMORY,:DARKMEMORY,:FAIRYMEMORY].freeze
  ITEM_FORMS={GIRATINA: [nil,:GRISEOUSORB],GENESECT: [nil,:SHOCKDRIVE,:BURNDRIVE,:CHILLDRIVE,:DOUSEDRIVE],
    ZACIAN: [nil,:RUSTEDSWORD],ZAMAZENTA: [nil,:RUSTEDSHIELD],
    DIALGA: [nil,:ADAMANTCRYSTAL],PALKIA: [nil,:LUSTROUSGLOBE],TANGROWTH: [nil,:MEADOWTRIBUTE],
    OGERPON: [nil,nil,:WELLSPRINGMASK,:HEARTHFLAMEMASK,:CORNERSTONEMASK,nil,
      :WELLSPRINGMASK,:HEARTHFLAMEMASK,:CORNERSTONEMASK],
    ARCEUS: [nil,*PLATES],SILVALLY: [nil,*MEMORIES]}.freeze
  FORM_LIMITS={UNOWN: 27,FLABEBE: 4,FLOETTE: 4,FLORGES: 4,SHELLOS: 1,GASTRODON: 1,
    BASCULIN: 1,DEERLING: 3,SAWSBUCK: 3,SCATTERBUG: 19,SPEWPA: 19,VIVILLON: 9,MINIOR: 6}.freeze
  SCRIPT_FORMS={DEOXYS: [1,2,3,4]}.freeze
  SEASONAL_FORMS=[:DEERLING,:SAWSBUCK].freeze
  FIELD_FORM_MAX=63

  def self.reset_field(field=0)
    $fefieldeffect=field
    $febackup=field
    $fecounter=0
    $fetempfield=0
    $game_variables[699]=0
    $game_variables[702]=0
    $game_variables[704]=0
  end

  def self.art_forms(symbol_to_id)
    forms=Hash.new { |hash,id| hash[id]=Hash.new { |indices,form| indices[form]=[] } }
    ["Graphics/Battlers","Graphics/Icons"].each do |path|
      Dir.children(path).each do |name|
        match=name.match(/\A(?:icon)?(.+?)_(\d+)(?:_shadow)?\.(?:png|gif)\z/i)
        next if !match
        form=match[2].to_i
        next if form<=0
        prefix=match[1]
        id=if prefix.match?(/\A\d+[fsb]*\z/i)
          prefix.to_i
        else
          symbol_to_id[prefix.to_sym] || symbol_to_id[prefix.upcase.to_sym] ||
            symbol_to_id[prefix.sub(/[fsb]+\z/,"").upcase.to_sym]
        end
        next if !id || id<=0
        forms[id][form] << (path.end_with?("Battlers") ? "sprite" : "icon")
      end
    end
    return forms
  end

  def self.form_sources(id,symbol,mon,art)
    sources=art[id].transform_values(&:uniq)
    names=pbGetMessage(MessageTypes::FormNames,id).to_s.split(",",-1)
    names.each_with_index do |name,form|
      (sources[form]||=[]) << "name" if form>0 && !name.strip.empty?
    end
    FORM_LIMITS.fetch(symbol,0).times { |i| (sources[i+1]||=[]) << "indexed-variation" }
    SCRIPT_FORMS.fetch(symbol,[]).each { |form| (sources[form]||=[]) << "script" }
    raw=mon.clone
    raw.define_singleton_method(:form) { @form || 0 }
    raw.setAbility(0)
    handlers=FORM_PROPERTIES.filter_map { |property| MultipleForms.getFunction(id,property) }
    if !handlers.empty?
      raw.instance_variable_set(:@form,0)
      defaults=handlers.map { |handler| handler.call(raw) rescue nil }
      # Many regional handlers apply one property to every nonzero form. The
      # indexed art, names, item table and consecutive property changes bound
      # those handlers so that arbitrary form indices do not inflate coverage.
      seen_states=[defaults]
      1.upto([FIELD_FORM_MAX,sources.keys.max.to_i].max) do |form|
        raw.instance_variable_set(:@form,form)
        values=handlers.each_with_index.map { |handler,index| handler.call(raw) || defaults[index] rescue defaults[index] }
        next if values==defaults
        (sources[form]||=[]) << "property" if sources.key?(form) || !seen_states.include?(values)
        seen_states << values if !seen_states.include?(values)
      end
    end
    ITEM_FORMS.fetch(symbol,[]).each_with_index do |item,form|
      (sources[form]||=[]) << "item" if item && PBItems.const_defined?(item,false)
    end
    sources[0]=["base"]
    return sources.sort
  end

  def self.use_moves(pokemon,ids)
    pokemon.moves=ids.first(4).map { |id| PBMove.new(id) }
    pokemon.moves << PBMove.new(0) while pokemon.moves.size<4
  end

  def self.build(species,trainer,symbol,form)
    pokemon=PokeBattle_Pokemon.new(species,50,trainer,false)
    item=ITEM_FORMS.fetch(symbol,[])[form]
    pokemon.setItem(PBItems.const_get(item,false)) if item && PBItems.const_defined?(item,false)
    use_moves(pokemon,[PBMoves::SECRETSWORD]) if symbol==:KELDEO && form==1
    pokemon.form=form
    known=pokemon.getMoveList.filter_map do |level,move|
      move if level<=50 && move.is_a?(Integer) && move>0 && $pkmn_move[move]
    end.uniq.reverse
    known.unshift(PBMoves::SECRETSWORD) if symbol==:KELDEO && form==1
    known.unshift(PBMoves::CELEBRATE) if known.empty?
    use_moves(pokemon,known.uniq)
    pokemon.calcStats
    pokemon
  end

  def self.set_clock(symbol,form)
    month=SEASONAL_FORMS.include?(symbol) ? form+1 : 6
    $game_screen.define_singleton_method(:aGetTime) { Time.local(2026,month,1,12) }
  end

  class FormScene < AzureBattleSimulation::Scene
    attr_reader :entry,:turn_actions

    def initialize(report,scripted)
      super(report,{})
      @scripted=scripted
      @entry={}
      @turn_actions=0
    end

    def pbBeginCommandPhase
      if @battle.turncount==0
        @battle.eachActiveBattlerIndex do |index|
          battler=@battle.battlers[index]
          @entry[index]=[battler.real_species,battler.form,battler.pbCurrentTypes,battler.ability,battler.item]
        end
      end
      super if !@scripted
    end

    def pbChooseEnemyCommand(index)
      @turn_actions+=1
      return super if !@scripted
      battler=@battle.battlers[index]
      slot=battler.moves.each_index.find { |i| @battle.pbCanChooseMove?(index,i,false) }
      slot ? @battle.pbRegisterMove(index,slot,false) : @battle.pbAutoChooseMove(index,false)
    end

    def pbEndBattle(decision)
      super if !@scripted
    end
  end

  class FormBattle < AzureBattleSimulation::Battle
    def pbWait(_frames); end

    def pbCommandPhase
      if turncount>=turn_limit
        @limit_reached=true
        self.decision=5
        return
      end
      PokeBattle_Battle.instance_method(:pbCommandPhase).bind_call(self)
    end
  end

  class QuietReport
    def line(_message); end
  end

  def self.battle(player,opponent,active,turns,weather,report: QuietReport.new,scripted: true)
    scene=FormScene.new(report,scripted)
    $Trainer=player
    battle=FormBattle.new(scene,player.party,opponent.party,player,opponent)
    battle.setBattleMode(%w[single double triple].fetch(active-1))
    battle.controlPlayer=true
    battle.internalbattle=false
    battle.battlescene=false
    battle.turn_limit=turns
    battle.weather=weather
    battle.weatherduration=5 if weather>0
    yield battle if block_given?
    battle.pbStartBattle(true)
    return battle,scene
  end

  def self.environments(symbol,form)
    field=0
    weather=0
    if symbol==:CASTFORM
      weather=[0,PBWeather::SUNNYDAY,PBWeather::RAINDANCE,PBWeather::HAIL].fetch(form,0)
    elsif symbol==:CHERRIM && form==1
      weather=PBWeather::SUNNYDAY
    elsif symbol==:SILVALLY && form==9
      field=24
    elsif symbol==:ARCEUS && form==9
      field=35
    end
    return field,weather
  end

  def self.probe(audit,kind,symbol,species,form,sources)
    token=form==0 ? symbol : "#{symbol}:#{form}"
    audit.check(kind,token,"entry-and-turn") do
      field,weather=environments(symbol,form)
      reset_field(field)
      set_clock(symbol,form)
      player=PokeBattle_Trainer.new("Catalog species",0)
      opponent=PokeBattle_Trainer.new("Catalog control",0)
      $Trainer=player
      pokemon=build(species,player,symbol,form)
      control=PokeBattle_Pokemon.new(PBSpecies::SMEARGLE,60,opponent,false)
      use_moves(control,[PBMoves::CELEBRATE])
      player.party=[pokemon]
      opponent.party=[control]
      pokemon.hp=[1,pokemon.totalhp/4].max if symbol==:WISHIWASHI && form==0
      pokemon.hp=[1,pokemon.totalhp/3].max if (symbol==:MINIOR && form!=6) || (symbol==:DARMANITAN && [1,3].include?(form))
      pokemon.hp=[1,pokemon.totalhp/3].max if symbol==:ZYGARDE && form==2
      stored=pokemon.form
      types=[pokemon.type1,pokemon.type2].uniq
      stats=[pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.speed,pokemon.spatk,pokemon.spdef]
      raise "Invalid stats #{stats.inspect} or types #{types.inspect}" if stats.any? { |stat| !stat.is_a?(Numeric) || stat<=0 } ||
        types.any? { |type| !type.is_a?(Integer) || type<0 }
      engine,scene=AzureCatalogAudit.with_deadline(4) { battle(player,opponent,1,1,weather) }
      entry=scene.entry.fetch(0)
      raise "Expected species #{species}, entered #{entry.first}" if entry.first!=species
      if stored!=form || (entry[1]!=form && !(symbol==:TERAPAGOS && form==0 && entry[1]==1))
        audit.record(kind,token,:gap,"form-fixture","requested=#{form} party=#{stored} entry=#{entry[1]} field=#{field} weather=#{weather}")
      end
      if stored==entry[1] && types.sort!=entry[2].uniq.sort
        if entry[3]==PBAbilities::COLORCHANGE
          audit.record(kind,token,:pass,"battle-entry-type-change","Color Change applied Camouflage: #{types.inspect} -> #{entry[2].uniq.inspect}")
        else
          audit.record(kind,token,:mismatch,"battle-types","party=#{types.inspect} battle=#{entry[2].inspect} ability=#{entry[3]}")
        end
      end
      if symbol==:DEOXYS && form.between?(1,3)
        expected=[[50,180,20,150,180,20],[50,70,160,90,70,160],[50,95,90,180,95,90]][form-1]
        actual=pokemon.baseStats
        if actual!=expected
          audit.record(kind,token,:mismatch,"form-base-stats","earlier form handler=#{expected.join(',')} effective=#{actual.join(',')}")
        end
      end
      audit.record(kind,token,:gap,"battle-art","#{sources.join(',')} has no indexed battler sprite") if form>0 && !sources.include?("sprite")
      raise "No command phase completed" if scene.turn_actions==0
      "id=#{species} requested=#{form} entry=#{entry[1]} final=#{engine.battlers[0].form} " \
        "matched=#{stored==form && entry[1]==form} types=#{entry[2].join(',')} ability=#{entry[3]} " \
        "sources=#{sources.join(',')} turns=#{engine.turncount}"
    end
  end

  def self.run(audit)
    rows=audit.catalog(:species,PBSpecies)
    art=art_forms(rows.to_h)
    compiled_ids=PBSpeciesData.data.each_index.select { |id| id>0 && PBSpeciesData.data[id] }
    by_id=rows.group_by(&:last)
    (compiled_ids-by_id.keys).each do |id|
      name=PBSpecies.getName(id)
      audit.record(:species,id,:mismatch,"compiled-unmapped","compiled species #{name.inspect} has no generated species symbol")
      by_id[id]=[[name.to_s.empty? ? "ID#{id}".to_sym : name.upcase.to_sym,id]]
    end
    by_id.sort.each do |species,aliases|
      symbol=aliases.first.first
      compiled_name=PBSpecies.getName(species)
      if aliases.size>1
        audit.record(:species,species,:mismatch,"shared-species-id","#{aliases.map(&:first).join(',')} resolve to #{compiled_name.inspect}")
        actual=aliases.find { |alias_symbol,_| alias_symbol.to_s.casecmp?(compiled_name) }
        symbol=actual.first if actual
      end
      reset_field
      trainer=PokeBattle_Trainer.new("Catalog discovery",0)
      $Trainer=trainer
      forms=audit.check(:species,symbol,"form-discovery") do
        pokemon=PokeBattle_Pokemon.new(species,50,trainer,false)
        form_sources(species,symbol,pokemon,art).tap do |found|
          audit.line("FORMS #{symbol} #{found.map(&:first).join(',')}") if found.length>1
        end
      end
      probe(audit,:species,symbol,species,0,["base"])
      (forms || []).each do |form,sources|
        probe(audit,:form,symbol,species,form,sources) if form>0
      end
    end
    check_form_entry_triggers(audit)
    check_clean_cut(audit)
    check_species_id_migration(audit)
  end

  def self.check_species_id_migration(audit)
    audit.check(:species,:DEOXYS,"legacy-save-migration") do
      reset_field
      $Trainer=PokeBattle_Trainer.new("Legacy save",0)
      $PokemonStorage=PokemonStorage.new
      $game_system.remove_instance_variable(:@azure_distinct_deoxys_id)
      legacy=PokeBattle_Pokemon.new(PBSpecies::AGGRON,50,$Trainer,false)
      legacy.name="Orbit"
      legacy.instance_variable_set(:@form,1)
      stored=PokeBattle_Pokemon.new(PBSpecies::AGGRON,50,$Trainer,false)
      stored.name="Deoxys"
      stored.instance_variable_set(:@form,3)
      aggron=PokeBattle_Pokemon.new(PBSpecies::AGGRON,50,$Trainer,false)
      $Trainer.party=[legacy,aggron]
      $PokemonStorage[0,0]=stored
      loader=PokemonLoad.new(nil)
      loader.pbMigrateDeoxysSpeciesID
      raise "Old Deoxys party/box records did not migrate" if [legacy.species,stored.species]!=[PBSpecies::DEOXYS]*2
      raise "Named Aggron was migrated or nickname was lost" if aggron.species!=PBSpecies::AGGRON || legacy.name!="Orbit"
      raise "Migrated Deoxys forms or Pokédex entries changed" if [legacy.form,stored.form]!=[1,3] ||
        ![1,3].all? { |form| $Trainer.formseen[PBSpecies::DEOXYS][0][form] }
      aggron.name="Steel"
      loader.pbMigrateDeoxysSpeciesID
      raise "The migration ran twice" if aggron.species!=PBSpecies::AGGRON
      "old_id=#{PBSpecies::AGGRON} deoxys_id=#{PBSpecies::DEOXYS} party_and_box_forms_verified"
    end
  end

  def self.check_clean_cut(audit)
    audit.check(:form,:FURFROU,"party-icon-order") do
      reset_field
      $Trainer=PokeBattle_Trainer.new("Trim test",0)
      source_icons=[0,2,1,9,8,4,5,7,6,3]
      paths=source_icons.each_with_index.map do |art_form,form|
        pokemon=build(PBSpecies::FURFROU,$Trainer,:FURFROU,form)
        path=pbPokemonIconFile(pokemon)
        expected=art_form==0 ? "icon676.png" : "icon676_#{art_form}.png"
        raise "Furfrou form #{form} used #{path.inspect}, expected #{expected}" if File.basename(path.to_s)!=expected
        raise "Icon lookup changed the stored trim" if pokemon.form!=form
        File.basename(path)
      end
      paths.join(",")
    end
    [nil,:Attract,:Confusion,:CRUSHED,:ThroatChop,:POISON,:Yawn,:FROZEN,:BURN,:PARALYSIS].each_with_index do |effect,form|
      audit.check(:form,"FURFROU:#{form}","clean-cut") do
        reset_field
        player=PokeBattle_Trainer.new("Clean Cut",0)
        opponent=PokeBattle_Trainer.new("Catalog control",0)
        $Trainer=player
        pokemon=build(PBSpecies::FURFROU,player,:FURFROU,form)
        pokemon.makeFemale
        use_moves(pokemon,[PBMoves::CLEANCUT])
        target=PokeBattle_Pokemon.new(PBSpecies::SLAKING,100,opponent,false)
        target.makeMale
        use_moves(target,[PBMoves::CELEBRATE])
        player.party=[pokemon]
        opponent.party=[target]
        messages=[]
        trace=Object.new
        trace.define_singleton_method(:line) { |message| messages << message.to_s.gsub(/[[:space:]]+/," ") }
        engine,_scene=battle(player,opponent,1,1,0,report: trace) do |fixture|
          # Make the base form's 30% Speed roll reproducible and hit reliably.
          fixture.define_singleton_method(:pbRandom) { |_limit| 0 }
        end
        user,foe=engine.battlers
        value=case effect
        when nil then user.stages[PBStats::SPEED]>0
        when :Attract then foe.effects[PBEffects::Attract]>=0
        when :Yawn then foe.effects[PBEffects::Yawn]>0 || foe.status==PBStatuses::SLEEP
        when :Confusion,:ThroatChop then foe.effects[PBEffects.const_get(effect)]>0
        else foe.status==PBStatuses.const_get(effect)
        end
        if !value
          audit.record(:form,"FURFROU:#{form}",:mismatch,"clean-cut-effect", "expected=#{effect || :SPEED} #{messages.join(' / ')}")
        end
        "effect=#{effect || :SPEED} observed=#{value} foe_hp=#{foe.hp}"
      end
    end
  end

  def self.check_form_entry_triggers(audit)
    audit.check(:form,"TANGROWTH/MEADOWTRIBUTE","held-form") do
      reset_field
      player=PokeBattle_Trainer.new("Form trigger",0)
      $Trainer=player
      pokemon=build(PBSpecies::TANGROWTH,player,:TANGROWTH,0)
      AzureCatalogAudit.with_deadline(4) do
        pokemon.setItem(PBItems::MEADOWTRIBUTE)
        "resolved_form=#{pokemon.form}"
      end
    rescue SystemStackError => error
      raise RuntimeError,"Recursive form lookup: #{error.backtrace&.first}"
    end
    masks={WELLSPRINGMASK: PBTypes::WATER,HEARTHFLAMEMASK: PBTypes::FIRE,CORNERSTONEMASK: PBTypes::ROCK}
    masks.each do |item,secondary_type|
      audit.check(:form,"OGERPON/#{item}","held-mask-entry") do
        reset_field
        player=PokeBattle_Trainer.new("Form trigger",0)
        opponent=PokeBattle_Trainer.new("Catalog control",0)
        $Trainer=player
        pokemon=build(PBSpecies::OGERPON,player,:OGERPON,0)
        pokemon.setItem(PBItems.const_get(item,false))
        use_moves(pokemon,[PBMoves::IVYCUDGEL])
        player.party=[pokemon]
        control=PokeBattle_Pokemon.new(PBSpecies::SMEARGLE,60,opponent,false)
        use_moves(control,[PBMoves::CELEBRATE])
        opponent.party=[control]
        engine,scene=battle(player,opponent,1,1,0)
        entry=scene.entry.fetch(0)
        battler=engine.battlers[0]
        move=battler.moves[0]
        effective=move.pbType(move.type,battler,engine.battlers[1])
        if !entry[2].include?(secondary_type)
          audit.record(:form,"OGERPON/#{item}",:mismatch,"battle-typing",
            "expected secondary=#{secondary_type} entry_form=#{entry[1]} entry_types=#{entry[2].join(',')} Ivy Cudgel type=#{effective}")
        end
        "entry_form=#{entry[1]} Ivy Cudgel type=#{effective} turns=#{engine.turncount}"
      end
    end
    audit.check(:form,:TERAPAGOS,"tera-shift-entry") do
      reset_field
      player=PokeBattle_Trainer.new("Form trigger",0)
      opponent=PokeBattle_Trainer.new("Catalog control",0)
      $Trainer=player
      player.party=[build(PBSpecies::TERAPAGOS,player,:TERAPAGOS,0)]
      control=PokeBattle_Pokemon.new(PBSpecies::SMEARGLE,60,opponent,false)
      use_moves(control,[PBMoves::CELEBRATE])
      opponent.party=[control]
      engine,scene=battle(player,opponent,1,1,0)
      entry=scene.entry.fetch(0)
      if entry[1]!=1 || entry[3]!=PBAbilities::TERASHELL
        audit.record(:form,:TERAPAGOS,:mismatch,"tera-shift-entry",
          "expected Terastal form and Tera Shell; form=#{entry[1]} ability=#{PBAbilities.getName(entry[3])}")
      end
      raise "Base Terapagos did not reset when battle ended" if engine.battlers[0].pokemon.form!=0
      "turns=#{engine.turncount}"
    end
    audit.check(:form,:TERAPAGOS,"tera-shell-and-zero") do
      reset_field(1)
      player=PokeBattle_Trainer.new("Form trigger",0)
      opponent=PokeBattle_Trainer.new("Catalog control",0)
      $Trainer=player
      player.party=[build(PBSpecies::TERAPAGOS,player,:TERAPAGOS,1)]
      control=PokeBattle_Pokemon.new(PBSpecies::SMEARGLE,60,opponent,false)
      use_moves(control,[PBMoves::CELEBRATE])
      opponent.party=[control]
      engine,_scene=battle(player,opponent,1,1,0)
      holder,attacker=engine.battlers
      attack=PokeBattle_Move.pbFromPBMove(engine,PBMove.new(PBMoves::BRICKBREAK),attacker)
      full=attack.pbTypeModMessages(attack.type,attacker,holder)
      holder.hp-=1
      hurt=attack.pbTypeModMessages(attack.type,attacker,holder)
      raise "Tera Shell matchups full=#{full}, damaged=#{hurt}" if full!=2 || hurt<=4
      holder.form=2
      holder.pbUpdate(true)
      engine.weather=PBWeather::RAINDANCE
      engine.field.effects[PBEffects::Terrain]=3
      engine.field.effects[PBEffects::ElectricTerrain]=4
      $febackup=0
      holder.pbAbilitiesOnSwitchIn(true)
      raise "Teraform Zero did not clear the active layers" if engine.weather!=0 || $fefieldeffect!=0 ||
        engine.field.effects[PBEffects::ElectricTerrain]>0 || engine.field.effects[PBEffects::Terrain]>0
      "full_hp_matchup=#{full} chipped_matchup=#{hurt} weather_and_temporary_terrain_cleared"
    end
  end
end
