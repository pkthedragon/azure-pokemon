module AzureCatalogAbilities
  GASTRO_ACID_EXEMPT=[:MULTITYPE,:COMATOSE,:SCHOOLING,:RKSSYSTEM].freeze
  GAS_EXEMPT=[:NEUTRALIZINGGAS,:STANCECHANGE,:SCHOOLING].freeze
  SPECIES={
    FORECAST: :CASTFORM, FLOWERGIFT: :CHERRIM, MULTITYPE: :ARCEUS,
    ZENMODE: :DARMANITAN, STANCECHANGE: :AEGISLASH, SCHOOLING: :WISHIWASHI,
    RKSSYSTEM: :SILVALLY, SHIELDSDOWN: :MINIOR, DISGUISE: :MIMIKYU,
    POWERCONSTRUCT: :ZYGARDE, GULPMISSILE: :CRAMORANT,
    HUNGERSWITCH: :MORPEKO, ICEFACE: :EISCUE, COMMANDER: :TATSUGIRI,
    ZEROTOHERO: :PALAFIN, BATTLEBOND: :GRENINJA
  }.freeze
  ENTRY_WEATHER={
    DRIZZLE: PBWeather::RAINDANCE, DROUGHT: PBWeather::SUNNYDAY,
    SANDSTREAM: PBWeather::SANDSTORM, SNOWWARNING: PBWeather::HAIL
  }.freeze
  WEATHER_SPEED={
    SWIFTSWIM: PBWeather::RAINDANCE, CHLOROPHYLL: PBWeather::SUNNYDAY,
    SANDRUSH: PBWeather::SANDSTORM, SLUSHRUSH: PBWeather::HAIL
  }.freeze
  ENTRY_STATS={
    INTREPIDSWORD: PBStats::ATTACK, DAUNTLESSSHIELD: PBStats::DEFENSE
  }.freeze
  ENTRY_TERRAIN={
    ELECTRICSURGE: PBEffects::ElectricTerrain, GRASSYSURGE: PBEffects::GrassyTerrain,
    MISTYSURGE: PBEffects::MistyTerrain, PSYCHICSURGE: PBEffects::PsychicTerrain
  }.freeze
  ABSORPTION={
    VOLTABSORB: :THUNDERSHOCK, WATERABSORB: :WATERGUN, DRYSKIN: :WATERGUN,
    FLASHFIRE: :EMBER, MOTORDRIVE: :THUNDERSHOCK, LIGHTNINGROD: :THUNDERSHOCK,
    STORMDRAIN: :WATERGUN, SAPSIPPER: :ABSORB, EARTHEATER: :MUDSHOT,
    WELLBAKEDBODY: :EMBER, WINDRIDER: :GUST, DAMP: :EMBER,
    SOUNDPROOF: :HYPERVOICE, BULLETPROOF: :ENERGYBALL, ARMORTAIL: :QUICKATTACK, LEVITATE: :MUDSHOT
  }.freeze
  STATUS_IMMUNITY={
    INSOMNIA: [:pbCanSleep?], IMMUNITY: [:pbCanPoison?,:pbCanParalyze?],
    WATERBUBBLE: [:pbCanBurn?], SWEETVEIL: [:pbCanSleep?], PASTELVEIL: [:pbCanPoison?]
  }.freeze
  TRIGGERS={
    ANGERSHELL: :anger_shell, ELECTROMORPHOSIS: :charge_when_hit, WINDPOWER: :charge_from_wind,
    TOXICDEBRIS: :toxic_debris, HOSPITALITY: :hospitality,
    SUPERSWEETSYRUP: :supersweet_syrup, QUARKDRIVE: :quark_drive,
    PROTOSYNTHESIS: :protosynthesis, NATURALCURE: :natural_cure, REGENERATOR: :regenerator,
    SPEEDBOOST: :speed_boost, TRACE: :trace, MOTORDRIVE: :motor_drive,
    EARTHEATER: :earth_eater, WELLBAKEDBODY: :well_baked_body, WINDRIDER: :wind_rider
  }.freeze

  class Scenario < AzureAbilityFixture::Scenario
    def open_ability(name, **options)
      battle(name,:NONE,user_species: SPECIES.fetch(name,:RATTATA),
        user_moves: [:TACKLE,:WATERGUN,:QUICKATTACK,:RECOVER], **options)
      @user.hp=@user.totalhp
    end

    def lifecycle(name,id)
      open_ability(name,foe_moves: [:GASTROACID])
      equal(id,@user.ability)
      assert(@user.hasWorkingAbility(name),"Registered ability did not work on its active Pokémon")
      hit(:GASTROACID,@foe,@user)
      exempt=GASTRO_ACID_EXEMPT.include?(name)
      equal(!exempt,@user.effects[PBEffects::GastroAcid])
      equal(exempt,@user.hasWorkingAbility(name))
      party=@battle.pbParty(@user.index)
      party.push(pokemon(:NONE,@battle.player,[:TACKLE]))
      @battle.pbRecallAndReplace(@user.index,party.length-1)
      @battle.pbRecallAndReplace(@user.index,0)
      equal(false,@user.effects[PBEffects::GastroAcid])
      equal(id,@user.ability)
      assert(@user.hasWorkingAbility(name),"Ability did not return after its Pokémon switched in")
      "id=#{id} gastro_acid=#{exempt ? 'immune' : 'suppressed'} switch_out_in=restored"
    end

    def natural_eligibility(name,id,candidate_slots)
      candidate_slots.each do |species,slot|
        mon=PokeBattle_Pokemon.new(species,50,nil,false)
        mon.form=0
        mon.setAbility(slot)
        next unless PBAbilityData.canonical_id(mon.ability)==id
        battle(:NONE,:NONE)
        @battle.pbParty(@user.index)[0]=mon
        @user.pbInitialize(mon,0,false)
        equal(id,@user.ability)
        assert(@user.hasWorkingAbility(name),"Native ability did not work in battle")
        return "species=#{species} ability_slot=#{slot} form=0 active=true"
      end
      nil
    end

    def gas(name)
      open_ability(name,ally: :NONE,foe_ally: :NEUTRALIZINGGAS,outer_ally: :NONE,outer_foe: :NONE)
      entry(@foe_ally)
      equal(GAS_EXEMPT.include?(name),@user.hasWorkingAbility(name))
      party=@battle.pbParty(@foe_ally.index)
      party.push(pokemon(:NONE,@battle.opponent,[:TACKLE]))
      @battle.pbRecallAndReplace(@foe_ally.index,party.length-1)
      assert(@user.abilityWorks?,"Ability did not return after opposing Neutralizing Gas left")
      "triple gas=#{GAS_EXEMPT.include?(name) ? 'immune' : 'suppressed'} gas_switch_out=restored"
    end

    def ambient(name,suppress)
      open_ability(name,ally: :NONE,foe_ally: :NONE)
      @user.pbSuppressAbility if suppress
      @user.hp=@user.totalhp/2
      @user.item=PBItems::SITRUSBERRY
      @foe.item=PBItems::ORANBERRY
      @user.effects[PBEffects::Blinded]=1
      @foe.effects[PBEffects::Blinded]=1
      @user.type1=@user.type2=PBTypes::NORMAL unless SPECIES.key?(name)
      @foe.type1=@foe.type2=PBTypes::NORMAL
      result={}
      @battle.pbOnActiveOne(@user)
      result[:entry]=snapshot
      @user.pbAbilityCureCheck
      @user.pbBerryCureCheck(true)
      result[:held_berry]=snapshot
      @user.pbUseMove([1,0,@user.moves[0],@foe.index]) unless @user.isFainted? || @foe.isFainted?
      result[:contact_output]=snapshot
      @foe.pbUseMove([1,0,@foe.moves[0],@user.index]) unless @user.isFainted? || @foe.isFainted?
      result[:contact_input]=snapshot
      unless @user.isFainted? || @foe.isFainted?
        hit(:WATERGUN,@user,@foe)
        hit(:THUNDERSHOCK,@foe,@user)
        hit(:HYPERVOICE,@foe,@user) unless @user.isFainted?
      end
      result[:type_and_sound]=snapshot
      round if @battle.decision==0 && [@user,@foe,@ally,@foe_ally].none?(&:isFainted?)
      result[:round_end]=snapshot
      result
    end

    def snapshot
      beings=[@user,@foe,@ally,@foe_ally].map do |battler|
        flags=[PBEffects::Attract,PBEffects::Blinded,PBEffects::Charge,PBEffects::Confusion,
          PBEffects::Disable,PBEffects::FlashFire,PBEffects::Flinch,PBEffects::FocusEnergy,
          PBEffects::HealBlock,PBEffects::MultiTurn,PBEffects::PerishSong,
          PBEffects::Substitute,PBEffects::Toxic,PBEffects::Yawn].map { |effect| battler.effects[effect] }
        [battler.hp,battler.status,battler.statusCount,battler.type1,battler.type2,
          battler.form,battler.ability,battler.item,battler.stages.dup,battler.pbSpeed,flags]
      end
      terrain=[PBEffects::ElectricTerrain,PBEffects::GrassyTerrain,PBEffects::MistyTerrain,
        PBEffects::PsychicTerrain].map { |effect| @battle.field.effects[effect] }
      [@battle.pbWeather,$fefieldeffect,$fecounter,terrain,beings]
    end

    def weather_entry(name,weather)
      open_ability(name)
      entry
      equal(weather,@battle.pbWeather)
      @battle.weather=0
      @user.pbSuppressAbility
      entry
      equal(0,@battle.pbWeather)
      "entry weather=#{weather} blocked_by_suppression"
    end

    def weather_speed(name,weather)
      open_ability(name)
      normal=@user.pbSpeed
      @battle.weather=weather
      @battle.weatherduration=5
      boosted=@user.pbSpeed
      assert(boosted>normal,"Expected increased Speed in weather #{weather}, got #{normal} to #{boosted}")
      @user.pbSuppressAbility
      equal(normal,@user.pbSpeed)
      "speed=#{normal}->#{boosted} weather=#{weather} blocked_by_suppression"
    end

    def entry_stat(name,stat)
      open_ability(name)
      equal(0,@user.stages[stat])
      entry
      assert(@user.stages[stat]>0,"Expected an increase in stat #{stat} on entry")
      "entry stat=#{stat} stage=#{@user.stages[stat]}"
    end

    def terrain_entry(name,effect)
      open_ability(name)
      entry
      equal(5,@battle.field.effects[effect])
      open_ability(name)
      @user.item=PBItems::AMPLIFIELDROCK
      $fefieldeffect=8
      entry
      equal(8,@battle.field.effects[effect])
      equal(8,$fefieldeffect)
      "terrain=#{effect} base_turns=5 extended_turns=8 existing_field=8"
    end

    def absorption(name,attack)
      open_ability(name)
      @user.type1=@user.type2=PBTypes::NORMAL
      @user.hp=@user.totalhp/2
      @user.effects[PBEffects::Blinded]=1
      @foe.moves[0]=move(attack,@foe)
      original=@user.hp
      @foe.pbUseMove([1,0,@foe.moves[0],@user.index])
      open=[original-@user.hp,0].max
      @user.pbSuppressAbility
      @user.hp=@user.totalhp
      @user.effects[PBEffects::Blinded]=1
      original=@user.hp
      @foe.pbUseMove([1,0,@foe.moves[0],@user.index])
      blocked=original-@user.hp
      [open==0 && blocked>0,"attack=#{attack} expected_active_hp_loss=0 expected_suppressed_hp_loss=positive active_hp_loss=#{open} suppressed_hp_loss=#{blocked}"]
    end

    def status_immunity(name,check)
      open_ability(name)
      active=@user.public_send(check,false)
      @user.pbSuppressAbility
      suppressed=@user.public_send(check,false)
      [!active && suppressed,"status_route=#{check} expected_active=false expected_suppressed=true active=#{active} suppressed=#{suppressed}"]
    end

    def switch_holder
      party=@battle.pbParty(@user.index)
      original=party.first
      party.push(pokemon(:NONE,@battle.player,[:TACKLE]))
      @battle.pbRecallAndReplace(@user.index,party.length-1)
      original
    end

    def anger_shell(name)
      open_ability(name)
      @user.hp=@user.totalhp/2+1
      hit(:TACKLE,@foe,@user)
      stages=[PBStats::ATTACK,PBStats::SPATK,PBStats::SPEED,PBStats::DEFENSE,PBStats::SPDEF].map { |stat| @user.stages[stat] }
      assert(@user.hp<@user.totalhp/2,"Tackle did not cross the threshold")
      equal([1,1,1,-1,-1],stages)
      open_ability(name)
      @user.hp=@user.totalhp/2
      hit(:WATERGUN,@foe,@user)
      equal(0,@user.stages[PBStats::ATTACK])
      open_ability(name)
      @user.hp=@user.totalhp/2+1
      @user.pbSuppressAbility
      hit(:TACKLE,@foe,@user)
      equal(0,@user.stages[PBStats::ATTACK])
      [true,"crossing_half stages=#{stages.inspect}; blocked when already below half or suppressed"]
    end

    def charge_when_hit(name)
      open_ability(name)
      damage=hit(:TACKLE,@foe,@user)
      assert(damage>0 && @user.effects[PBEffects::Charge],"An actual hit must charge the holder")
      @user.moves[0]=move(:THUNDERSHOCK)
      @user.pbUseMove([1,0,@user.moves[0],@foe.index])
      equal(false,@user.effects[PBEffects::AbilityCharge])
      equal(false,@user.effects[PBEffects::Charge])
      open_ability(name)
      @user.pbSuppressAbility
      hit(:TACKLE,@foe,@user)
      equal(false,@user.effects[PBEffects::Charge])
      [true,"tackle_damage=#{damage}; boost consumed by one Electric attack; suppressed hit uncharged"]
    end

    def charge_from_wind(name)
      open_ability(name)
      damage=hit(:GUST,@foe,@user)
      assert(damage>0 && @user.effects[PBEffects::Charge],"Gust must charge the holder")
      open_ability(name,ally: :NONE)
      hit(:TACKLE,@foe,@user)
      equal(false,@user.effects[PBEffects::Charge])
      equal(0,move(:TAILWIND,@ally).pbEffect(@ally,nil,0,nil,false))
      equal(true,@user.effects[PBEffects::Charge])
      [true,"gust_damage=#{damage}; charge from wind or ally Tailwind; no charge from Tackle"]
    end

    def toxic_debris(name)
      open_ability(name)
      damage=hit(:TACKLE,@foe,@user)
      assert(damage>0,"Tackle must damage the holder")
      equal(1,@foe.pbOwnSide.effects[PBEffects::ToxicSpikes])
      hit(:WATERGUN,@foe,@user)
      equal(2,@foe.pbOwnSide.effects[PBEffects::ToxicSpikes])
      hit(:WATERGUN,@foe,@user)
      equal(2,@foe.pbOwnSide.effects[PBEffects::ToxicSpikes])
      [true,"physical and special hits scatter Spikes up to two layers"]
    end

    def hospitality(name)
      open_ability(name,ally: :NONE,foe_ally: :NONE)
      initial=@ally.totalhp/2
      @ally.hp=initial
      entry
      healed=@ally.hp
      equal(initial+@ally.totalhp/4,healed)
      @ally.hp=initial
      @ally.effects[PBEffects::HealBlock]=2
      entry
      equal(initial,@ally.hp)
      [true,"partner_hp=#{initial}->#{healed}; Heal Block prevented healing"]
    end

    def supersweet_syrup(name)
      open_ability(name,ally: :NONE,foe_ally: :NONE)
      entry
      stages=[@foe,@foe_ally].map { |foe| foe.stages[PBStats::EVASION] }
      [stages.all? { |stage| stage<0 },"expected_opposing_evasion=negative stages=#{stages.inspect}"]
    end

    def use_test_attack(name)
      @foe.moves[0]=move(name,@foe)
      @foe.pbUseMove([1,0,@foe.moves[0],@user.index])
    end

    def motor_drive(name)
      open_ability(name)
      use_test_attack(:THUNDERSHOCK)
      equal(1,@user.stages[PBStats::SPEED])
      equal(@user.totalhp,@user.hp)
      equal(0,@battle.pbRoughDamage(@foe.moves[0],@foe,@user,100,40))
      @user.pbSuppressAbility
      assert(@battle.pbRoughDamage(@foe.moves[0],@foe,@user,100,40)>0,"AI must see suppressed Electric immunity")
      [true,"Speed rose; engine and AI recognize working and suppressed immunity"]
    end

    def earth_eater(name)
      open_ability(name)
      initial=@user.totalhp/2
      @user.hp=initial
      use_test_attack(:MUDSHOT)
      equal(initial+@user.totalhp/4,@user.hp)
      @user.hp=initial
      @user.effects[PBEffects::HealBlock]=2
      use_test_attack(:MUDSHOT)
      equal(initial,@user.hp)
      [true,"Ground healed 1/4; Heal Block left immunity intact"]
    end

    def well_baked_body(name)
      open_ability(name)
      use_test_attack(:EMBER)
      equal(2,@user.stages[PBStats::DEFENSE])
      equal(0,@user.stages[PBStats::SPDEF])
      equal(@user.totalhp,@user.hp)
      assert_draws_single_attacks(name,:EMBER,:DEFENSE)
      [true,"Fire immunity and +2 Defense; redirects reachable single targets in doubles"]
    end

    def wind_rider(name)
      open_ability(name,ally: :NONE)
      use_test_attack(:GUST)
      equal(@user.totalhp,@user.hp)
      equal(1,@user.stages[PBStats::ATTACK])
      equal(1,@user.stages[PBStats::SPATK])
      open_ability(name,ally: :NONE)
      equal(0,move(:TAILWIND,@ally).pbEffect(@ally,nil,0,nil,false))
      equal(1,@user.stages[PBStats::ATTACK])
      equal(1,@user.stages[PBStats::SPATK])
      assert_draws_single_attacks(name,:GUST,:ATTACK,triples: true)
      [true,"Wind immunity or ally Tailwind activates both offenses; redirects reachable single targets in triples"]
    end

    def assert_draws_single_attacks(name,attack,stat,triples: false)
      options=triples ? {outer_ally: :NONE,outer_foe: :NONE} : {}
      open_ability(name,ally: :NONE,foe_ally: :NONE,**options)
      @foe.moves[0]=move(attack,@foe)
      choice=[1,0,@foe.moves[0],@ally.index]
      @foe.pbUseMove(choice)
      equal(@ally.totalhp,@ally.hp)
      equal(@user.totalhp,@user.hp)
      assert(@user.stages[PBStats.const_get(stat)]>0,"Redirected move did not activate the held ability")
      @user.pbSuppressAbility
      @foe.pbUseMove(choice)
      assert(@ally.hp<@ally.totalhp,"Suppression did not restore the original target")
    end

    def quark_drive(name)
      activation_stat(name,:electric_terrain)
    end

    def protosynthesis(name)
      activation_stat(name,:sun)
    end

    def activation_stat(name,context)
      results=[context,:booster_energy].to_h do |trigger|
        open_ability(name)
        @user.speed=@user.attack+@user.defense+@user.spatk+@user.spdef
        baseline=@user.pbSpeed
        case trigger
        when :electric_terrain
          @battle.field.effects[PBEffects::ElectricTerrain]=5
        when :sun
          @battle.weather=PBWeather::SUNNYDAY
          @battle.weatherduration=5
        when :booster_energy
          @user.item=PBItems::BOOSTERENERGY
        end
        entry
        boosted=@user.pbSpeed
        equal((baseline*1.5).floor,boosted)
        if trigger==:booster_energy
          equal(0,@user.item)
          equal(PBItems::BOOSTERENERGY,@user.pokemon.itemRecycle)
        else
          @battle.field.effects[PBEffects::ElectricTerrain]=0
          @battle.weather=0
          equal(baseline,@user.pbSpeed)
        end
        @user.pbSuppressAbility
        equal(baseline,@user.pbSpeed)
        [trigger,[baseline,boosted,@user.item]]
      end
      [results.values.all? { |baseline,active,_item| active>baseline },"expected_speed_increase=true speed_before_after_and_item=#{results.inspect}"]
    end

    def natural_cure(name)
      open_ability(name)
      @user.status=PBStatuses::BURN
      original=switch_holder
      [original.status==0,"expected_switch_out_status=0 status=#{original.status}"]
    end

    def regenerator(name)
      open_ability(name)
      initial=@user.totalhp/2
      @user.hp=initial
      original=switch_holder
      [original.hp>initial,"expected_switch_out_healing=true hp=#{initial}->#{original.hp}"]
    end

    def speed_boost(name)
      open_ability(name)
      turn(:TACKLE,:TACKLE)
      stage=@user.stages[PBStats::SPEED]
      [stage>0,"expected_speed_stage=positive actual=#{stage}"]
    end

    def trace(name)
      open_ability(name)
      @foe.ability=PBAbilities::STURDY
      entry
      [@user.hasWorkingAbility(:STURDY),"expected_ability=#{PBAbilities::STURDY} actual=#{@user.ability}"]
    end
  end

  def self.run(audit)
    %w[AzureAbilityCustomCases AzureAbilityMiddleCases AzureAbilityTailCases].each do |name|
      load File.join(__dir__,name+".rb")
    end
    fixtures=AzureAbilityFixture.instance_variable_get(:@cases)
    entries=audit.catalog(:ability,PBAbilities)
    sources=audit.source_entries(:ability).to_h
    symbols=entries.to_h
    source_ids=sources.values
    fixtures_by_id=fixtures.keys.map { |name| symbols[name] }
    natural_slots=Hash.new { |hash,id| hash[id]=[] }
    PBSpeciesData.each do |species|
      [species.abilities[0],species.abilities[1],species.hidden_ability].each_with_index do |ability,slot|
        next if !ability || ability<=0
        natural_slots[PBAbilityData.canonical_id(ability)] << [species.id,slot]
      end
    end
    sources.each do |symbol,id|
      if !symbols.key?(symbol) || PBAbilityData.canonical_id(symbols[symbol])!=PBAbilityData.canonical_id(id)
        audit.record(:ability,symbol,:mismatch,:registry,"PBS id=#{id}; runtime constant=#{symbols[symbol].inspect}")
      end
    end
    entries.each_with_index do |(symbol,value),index|
      Graphics.update if index%10==0
      srand(134)
      id=PBAbilityData.canonical_id(value)
      primary=sources.key?(symbol) ? symbol : sources.key(id)
      audit.check(:ability,symbol,:registry) do
        data=PBAbilityData.get(id)
        raise "Localized name or description is blank" if data.name.to_s.empty? || data.description.to_s.empty?
        "runtime_id=#{value} canonical_id=#{id} PBS=#{primary || 'unlisted'}"
      end
      if !sources.key?(symbol)
        status=source_ids.include?(id) ? :skip : :gap
        audit.record(:ability,symbol,status,:mechanic,primary ? "symbolic alias of #{primary}" : "no PBS entry for runtime ID #{id}")
      else
        run_routes(audit,symbol,id,fixtures_by_id.include?(id))
        native_eligibility(audit,symbol,id,natural_slots[id])
      end
      next unless fixtures.key?(symbol)
      audit.check(:ability,symbol,:bespoke_regression) do
        AzureAbilityFixture.setup_new_game
        srand(134)
        AzureAbilityFixture::Scenario.new.instance_exec(&fixtures.fetch(symbol))
        "registered ability-specific assertions"
      end
    end
  end

  def self.run_routes(audit,symbol,id,has_fixture)
    audit.check(:ability,symbol,:lifecycle) { Scenario.new.lifecycle(symbol,id) }
    audit.check(:ability,symbol,:neutralizing_gas) { Scenario.new.gas(symbol) }
    has_spec=has_fixture || ENTRY_WEATHER.key?(symbol) || WEATHER_SPEED.key?(symbol) ||
      ENTRY_STATS.key?(symbol) || ENTRY_TERRAIN.key?(symbol) || ABSORPTION.key?(symbol) ||
      STATUS_IMMUNITY.key?(symbol) || TRIGGERS.key?(symbol)
    audit.check(:ability,symbol,:battle_probe) do
      srand(134)
      active=Scenario.new.ambient(symbol,false)
      srand(134)
      suppressed=Scenario.new.ambient(symbol,true)
      phases=active.keys.select { |phase| active[phase]!=suppressed[phase] }
      if phases.empty? && !has_spec
        audit.record(:ability,symbol,:gap,:ability_specific,"no effect isolated by generic entry, berry, physical, elemental, sound or round probes")
      end
      "changed_phases=#{phases.empty? ? 'none' : phases.join(',')}"
    end
    if (effect=ENTRY_WEATHER[symbol])
      audit.check(:ability,symbol,:weather_entry) { Scenario.new.weather_entry(symbol,effect) }
    end
    if (effect=WEATHER_SPEED[symbol])
      audit.check(:ability,symbol,:weather_speed) { Scenario.new.weather_speed(symbol,effect) }
    end
    if (effect=ENTRY_STATS[symbol])
      audit.check(:ability,symbol,:entry_stat) { Scenario.new.entry_stat(symbol,effect) }
    end
    if (effect=ENTRY_TERRAIN[symbol])
      audit.check(:ability,symbol,:terrain_entry) { Scenario.new.terrain_entry(symbol,effect) }
    end
    if (effect=ABSORPTION[symbol])
      outcome(audit,symbol,:incoming_immunity) { Scenario.new.absorption(symbol,effect) }
    end
    Array(STATUS_IMMUNITY[symbol]).each do |check|
      outcome(audit,symbol,"status_#{check}") { Scenario.new.status_immunity(symbol,check) }
    end
    if (trigger=TRIGGERS[symbol])
      outcome(audit,symbol,trigger) { Scenario.new.public_send(trigger,symbol) }
    end
  end

  def self.outcome(audit,symbol,route)
    passed,detail=yield
    audit.record(:ability,symbol,passed ? :pass : :mismatch,route,detail)
  rescue StandardError, ScriptError => error
    audit.record(:ability,symbol,:error,route,"#{error.class}: #{error.message.lines.first} at #{error.backtrace.first}")
  end

  def self.native_eligibility(audit,symbol,id,candidates)
    result=Scenario.new.natural_eligibility(symbol,id,candidates)
    if result
      audit.record(:ability,symbol,:pass,:native_eligibility,result)
    else
      audit.record(:ability,symbol,:gap,:native_eligibility,"no verified base-form slot; ability executed separately through a held ability assignment")
    end
  rescue StandardError, ScriptError => error
    audit.record(:ability,symbol,:error,:native_eligibility,"#{error.class}: #{error.message.lines.first} at #{error.backtrace.first}")
  end
end
