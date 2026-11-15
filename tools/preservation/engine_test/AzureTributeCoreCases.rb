module AzureTributeCoreCases
  CASES=[]

  def self.test(name,route,&block)
    CASES.push([name,route,block])
  end

  def self.run(audit)
    CASES.each do |name,route,block|
      AzureCatalogTributes.probe(audit,name,route) { |scenario| scenario.instance_exec(&block) }
    end
  end

  test(:NULL,"slot-and-suppression") do
    attack=configure(:NULLTRIBUTE,:EEVEE,:TACKLE,other_move: :QUICKATTACK)
    equal(130,attack.apply_tribute_damage_modifiers(user,foe,100))
    equal(100,user.moves[1].apply_tribute_damage_modifiers(user,foe,100))
    user.moves[0],user.moves[1]=user.moves[1],user.moves[0]
    equal(100,attack.apply_tribute_damage_modifiers(user,foe,100))
    current=user.moves[0]
    [PBEffects::Embargo,PBEffects::FriskLock].each do |effect|
      user.effects[effect]=1
      equal(100,current.apply_tribute_damage_modifiers(user,foe,100))
      user.effects[effect]=0
    end
    battle_state.field.effects[PBEffects::MagicRoom]=1
    equal(100,current.apply_tribute_damage_modifiers(user,foe,100))
    battle_state.field.effects[PBEffects::MagicRoom]=0
    equal(130,current.apply_tribute_damage_modifiers(user,foe,100))
  end

  test(:MEADOW,"healing") do
    attack=configure(:MEADOWTRIBUTE,:EEVEE,:RECOVER)
    equal(65,attack.apply_tribute_healing(user,50))
    user.hp=1
    attack_turn
    equal(1+((user.totalhp+1)/2*1.3).floor,user.hp)
  end

  test(:TANGROWTH,"harsh-sunlight") do
    attack=configure(:MEADOWTRIBUTE,:TANGROWTH,:RECOVER)
    equal(1,user.pokemon.form)
    battle_state.weather=PBWeather::SUNNYDAY
    equal(65,attack.apply_tribute_healing(user,50))
    battle_state.field.effects[PBEffects::HarshSunlight]=true
    equal(100,attack.apply_tribute_healing(user,50))
    battle_state.field.effects[PBEffects::MagicRoom]=1
    equal(50,attack.apply_tribute_healing(user,50))
  end

  test(:SIMISAGE,"grassy-terrain") do
    configure(:MEADOWTRIBUTE,:SIMISAGE,:SWORDSDANCE)
    attack_turn
    equal(2,battle_state.field.effects[PBEffects::GrassyTerrain])
  end

  test(:BELLOSSOM,"overheal-amount-and-expiry") do
    configure(:MEADOWTRIBUTE,:BELLOSSOM,:RECOVER)
    attack_turn
    shield=user.effects[PBEffects::TributeOverhealShield]
    expected=((user.totalhp+1)/2*1.3).floor
    equal(expected,shield[:hp])
    equal(0,user.pbReduceHP(11))
    equal(expected-11,shield[:hp])
    advance_round
    equal(shield,user.effects[PBEffects::TributeOverhealShield])
    advance_round
    equal(nil,user.effects[PBEffects::TributeOverhealShield])
  end

  test(:BELLOSSOM,"heals-and-shields-an-ally") do
    attack=configure(:MEADOWTRIBUTE,:BELLOSSOM,:HEALPULSE,format: :double)
    ally.hp-=20
    healed_amount=((ally.totalhp+1)/2*1.3).floor
    attack.pbEffect(user,ally,0,[],false)
    equal(ally.totalhp,ally.hp)
    equal(healed_amount-20,ally.effects[PBEffects::TributeOverhealShield][:hp])
    equal(nil,user.effects[PBEffects::TributeOverhealShield])
  end

  {CRADILY: [PBEffects::LeechSeed,0],BASTIODON: [PBEffects::Ingrain,true]}.each do |species,(effect,value)|
    test(species,"meadow-on-hit") do
      configure(:MEADOWTRIBUTE,species,:TACKLE,form: species==:BASTIODON ? 1 : 0)
      assert(strike>0,"Expected an inscribed hit")
      equal(value,foe.effects[effect])
    end
  end

  {EEVEE: 0.25,POLIWRATH: 0.75,SEAKING: 0.25,LUMINEON: 0.25}.each do |species,fraction|
    test(species,"splash-drain") do
      attack=configure(:SPLASHTRIBUTE,species,:TACKLE,format: :double)
      equal(fraction,attack.tribute_drain_fraction(user))
      user.hp-=45
      ally.hp-=45
      enemy_hp=foe_ally.hp
      ally_hp=ally.hp
      equal((40*fraction).floor,attack.pbApplyTributeDrain(user,foe,40))
      equal(enemy_hp-(species==:SEAKING ? 10 : 0),foe_ally.hp)
      equal(ally_hp+(species==:LUMINEON ? 10 : 0),ally.hp)
    end
  end

  {SIMIPOUR: [PBWeather::RAINDANCE,PBEffects::HeavyRain],SIMISEAR: [PBWeather::SUNNYDAY,PBEffects::HarshSunlight],
   ZAPDOS: [PBWeather::RAINDANCE,PBEffects::HeavyRain]}.each do |species,(weather,effect)|
    test(species,"two-turn-weather") do
      item={SIMIPOUR: :SPLASHTRIBUTE,SIMISEAR: :FLAMETRIBUTE,ZAPDOS: :ZAPTRIBUTE}.fetch(species)
      configure(item,species,:TACKLE)
      attack_turn
      equal(weather,battle_state.weather)
      equal(2,battle_state.weatherduration)
      equal(true,battle_state.field.effects[effect])
      equal(2,battle_state.field.effects[PBEffects::ElectricTerrain]) if species==:ZAPDOS
      advance_round
      equal(weather,battle_state.weather)
      advance_round
      equal(0,battle_state.weather)
      equal(false,battle_state.field.effects[effect])
    end
  end

  test(:PHIONE,"plus-and-minus") do
    attack=configure(:SPLASHTRIBUTE,:PHIONE,:TACKLE)
    strike
    equal(3,user.pbOwnSide.effects[PBEffects::PlusSignal])
    user.pbOwnSide.effects[PBEffects::MinusSignal]=2
    move_stat_source(attack) { attack.pbApplyTributeAdditionalEffect(user,foe) }
    equal([-1,-1],foe.stages.values_at(PBStats::DEFENSE,PBStats::SPDEF))
    equal([1,1],user.stages.values_at(PBStats::DEFENSE,PBStats::SPDEF))
  end

  test(:FLAME,"boost-on-entry") do
    attack=configure(:FLAMETRIBUTE,:EEVEE,:TACKLE)
    equal(150,attack.apply_tribute_damage_modifiers(user,foe,100))
    user.turncount=2
    equal(100,attack.apply_tribute_damage_modifiers(user,foe,100))
  end

  test(:ARCANINE,"heal-refreshes-once") do
    attack=configure(:FLAMETRIBUTE,:ARCANINE,:TACKLE)
    user.turncount=3
    user.hp-=16
    user.pbRecoverHP(8)
    attack.pbBeginTributeAttack(user)
    equal(150,attack.apply_tribute_damage_modifiers(user,foe,100))
    attack.pbEndTributeAttack
    equal(100,attack.apply_tribute_damage_modifiers(user,foe,100))
    user.pbRecoverHP(8)
    equal(150,attack.apply_tribute_damage_modifiers(user,foe,100))
  end

  test(:MAGMORTAR,"entry-drain") do
    attack=configure(:FLAMETRIBUTE,:MAGMORTAR,:TACKLE)
    equal(0.75,attack.tribute_drain_fraction(user))
    user.turncount=4
    equal(0,attack.tribute_drain_fraction(user))
  end

  test(:MOLTRES,"end-round-healing") do
    configure(:FLAMETRIBUTE,:MOLTRES,:TACKLE)
    user.hp=1
    attack_turn
    assert(user.effects[PBEffects::TributeMoltresSwitch],"Moltres did not queue its pivot")
    advance_round
    equal(1+user.totalhp/2,user.hp)
  end

  test(:GOODRA_MYSTIC,"burn-speed-and-ground") do
    configure(:FLAMETRIBUTE,:GOODRA,:TACKLE,form: 1)
    strike
    equal(PBStatuses::BURN,foe.status)
    equal(1,user.stages[PBStats::SPEED])
    assert(foe.pbOwnSide.effects[PBEffects::ScorchingGround]>0,"Ground was not scorched")
  end

  test(:BLANK,"type-and-damage") do
    attack=configure(:BLANKTRIBUTE,:EEVEE,:EMBER)
    equal(user.type1,attack.pbTypeBeforeAbilityConversion(attack.type,user,foe))
    equal(120,attack.apply_tribute_damage_modifiers(user,foe,100))
  end

  test(:DUBWOOL,"status-move-speed") do
    configure(:BLANKTRIBUTE,:DUBWOOL,:SWORDSDANCE)
    attack_turn
    equal(1,user.stages[PBStats::SPEED])
  end

  test(:DELCATTY,"matchup-scale") do
    attack=configure(:BLANKTRIBUTE,:DELCATTY,:TACKLE)
    equal(4,attack.pbTypeModifier(PBTypes::NORMAL,user,foe))
    foe.type1=foe.type2=PBTypes::GHOST
    equal(8,attack.pbTypeModifier(PBTypes::NORMAL,user,foe))
  end

  test(:WYRDEER,"higher-offense-lower-defense") do
    attack=configure(:BLANKTRIBUTE,:WYRDEER,:TACKLE)
    user.attack=50
    user.spatk=110
    foe.defense=101
    foe.spdef=61
    equal(110,attack.apply_tribute_attack_modifiers(user,1,3,100,foe)[0])
    equal(61,attack.apply_tribute_defense_modifiers(user,foe,1,3)[0])
  end

  test(:HELIOLISK,"weather-type") do
    attack=configure(:BLANKTRIBUTE,:HELIOLISK,:TACKLE)
    battle_state.weather=PBWeather::RAINDANCE
    equal(PBTypes::WATER,attack.pbTypeBeforeAbilityConversion(attack.type,user,foe))
    equal(150,attack.apply_tribute_damage_modifiers(user,foe,100))
  end

  test(:WIGGLYTUFF,"two-turn-screens") do
    configure(:BLANKTRIBUTE,:WIGGLYTUFF,:TACKLE)
    attack_turn
    equal(2,user.pbOwnSide.effects[PBEffects::Reflect])
    equal(2,user.pbOwnSide.effects[PBEffects::LightScreen])
  end

  {FISTTRIBUTE: :attack,MINDTRIBUTE: :spatk}.each do |item,stat|
    test(item,"offense-and-multiplier") do
      attack=configure(item,:EEVEE,:BITE)
      equal([user.public_send(stat),3,120],attack.apply_tribute_attack_modifiers(user,1,1,100,foe))
    end
  end

  test(:HARIYAMA,"paralyzes-faster-target") do
    attack=configure(:FISTTRIBUTE,:HARIYAMA,:TACKLE)
    user.speed=40
    foe.speed=110
    attack.pbApplyTributeAdditionalEffect(user,foe)
    equal(PBStatuses::PARALYSIS,foe.status)
  end

  test(:INFERNAPE,"all-positive-stages") do
    attack=configure(:FISTTRIBUTE,:INFERNAPE,:TACKLE)
    assert(!attack.isContactMove?,"Fist Infernape made contact")
    base=attack.pbCalcDamage(user,foe,PokeBattle_Move::NOCRITICAL)
    user.stages[PBStats::DEFENSE]=3
    user.stages[PBStats::SPDEF]=3
    assert(attack.pbCalcDamage(user,foe,PokeBattle_Move::NOCRITICAL)>base*2,"Infernape ignored positive stages")
  end

  test(:QUAQUAVAL,"spends-positive-stages") do
    attack=configure(:FISTTRIBUTE,:QUAQUAVAL,:TACKLE)
    user.stages[PBStats::ATTACK]=2
    user.stages[PBStats::DEFENSE]=-1
    equal(121,attack.apply_tribute_damage_modifiers(user,foe,100))
    attack_turn
    equal([0,-1],user.stages.values_at(PBStats::ATTACK,PBStats::DEFENSE))
  end

  {PASSIMIAN: :FISTTRIBUTE,ORANGURU: :MINDTRIBUTE}.each do |species,item|
    test(species,"round-style-chain") do
      attack=configure(item,species,:TACKLE,format: :double)
      equal(150,attack.apply_tribute_attack_modifiers(user,1,3,100,foe)[2])
      fired=[]
      ally.define_singleton_method(:pbProcessTurn) { |choice| fired.push(choice[2].id) }
      battle_state.pbRegisterMove(ally.index,0,false)
      equal(false,battle_state.pbTriggerTributeChain(user,attack))
      ally.moves[0]=move(:TACKLE,ally)
      battle_state.pbRegisterMove(ally.index,0,false)
      equal(true,battle_state.pbTriggerTributeChain(user,attack))
      equal([PBMoves::TACKLE],fired)
    end
  end

  test(:UNFEZANT_MYSTIC,"sex-specific-effects") do
    attack=configure(:FISTTRIBUTE,:UNFEZANT,:FOCUSBLAST,form: 1)
    user.gender=0
    equal(150,attack.apply_tribute_attack_modifiers(user,1,3,100,foe)[2])
    user.gender=1
    equal(120,attack.apply_tribute_attack_modifiers(user,1,3,100,foe)[2])
    foe.stages[PBStats::EVASION]=3
    20.times { assert(attack.pbAccuracyCheck(user,foe),"Mystic Unfezant missed") }
  end

  test(:MUSHARNA,"drowsy-foe") do
    attack=configure(:MINDTRIBUTE,:MUSHARNA,:TACKLE)
    foe.effects[PBEffects::Yawn]=1
    attack.pbApplyTributeAdditionalEffect(user,foe)
    equal(PBStatuses::SLEEP,foe.status)
    equal(2,foe.statusCount)
    equal(0,foe.effects[PBEffects::Yawn])
  end

  test(:HYPNO,"sleep-multiplier") do
    attack=configure(:MINDTRIBUTE,:HYPNO,:TACKLE)
    equal(120,attack.apply_tribute_attack_modifiers(user,1,3,100,foe)[2])
    foe.status=PBStatuses::SLEEP
    equal(200,attack.apply_tribute_attack_modifiers(user,1,3,100,foe)[2])
  end

  test(:UNOWN,"form-and-boost") do
    attack=configure(:MINDTRIBUTE,:UNOWN,:TACKLE)
    equal(0,user.form)
    attack_turn
    equal(1,user.form)
    equal(150,attack.apply_tribute_attack_modifiers(user,1,3,100,foe)[2])
  end

  test(:VICTINI,"guaranteed-crit-and-accuracy") do
    attack=configure(:MINDTRIBUTE,:VICTINI,:STONEEDGE)
    assert(attack.pbIsCritical?(user,foe),"A move without a secondary effect did not crit")
    foe.stages[PBStats::EVASION]=3
    15.times { assert(attack.pbAccuracyCheck(user,foe),"Victini missed") }
  end

  test(:ZAP,"additional-stage") do
    attack=configure(:ZAPTRIBUTE,:EEVEE,:POWERUPPUNCH)
    move_stat_source(attack) { user.pbIncreaseStat(PBStats::ATTACK,1,false,attack.id,user) }
    equal(2,user.stages[PBStats::ATTACK])
  end

  test(:ZEBSTRIKA,"speed-power") do
    attack=configure(:ZAPTRIBUTE,:ZEBSTRIKA,:TACKLE)
    foe.speed=50
    user.speed=35
    slow=attack.pbCalcDamage(user,foe,PokeBattle_Move::NOCRITICAL)
    user.speed=260
    fast=attack.pbCalcDamage(user,foe,PokeBattle_Move::NOCRITICAL)
    assert(fast>slow*2,"Speed did not affect damage")
  end

  test(:BOLTUND,"raises-lower-offense") do
    attack=configure(:ZAPTRIBUTE,:BOLTUND,:TACKLE)
    user.attack=50
    user.spatk=100
    move_stat_source(attack) { attack.pbApplyTributeAdditionalEffect(user,foe) }
    equal([2,0],user.stages.values_at(PBStats::ATTACK,PBStats::SPATK))
  end

  test(:ELECTIVIRE,"low-power-damage") do
    attack=configure(:ZAPTRIBUTE,:ELECTIVIRE,:TACKLE,other_move: :BODYSLAM)
    equal(200,attack.apply_tribute_damage_modifiers(user,foe,100))
    user.moves[0]=user.moves[1]
    equal(100,user.moves[0].apply_tribute_damage_modifiers(user,foe,100))
  end

  test(:DEDENNE_MYSTIC,"ice-type-and-damage") do
    attack=configure(:ZAPTRIBUTE,:DEDENNE,:TACKLE,form: 1)
    equal(PBTypes::ICE,attack.pbTypeBeforeAbilityConversion(attack.type,user,foe))
    equal(130,attack.apply_tribute_damage_modifiers(user,foe,100))
  end

  {EEVEE: 20,DEDENNE: 100,DACHSBUN: 80,FLORGES: 70,TOGEKISS: 70}.each do |species,power|
    test(species,"pixie-power-and-type") do
      attack=configure(:PIXIETRIBUTE,species,:SWORDSDANCE)
      equal(power,attack.pixie_tribute_power(user))
      equal(species==:DACHSBUN ? PBTypes::FIRE : user.type1,attack.pbTypeBeforeAbilityConversion(attack.type,user,foe))
      battle_state.field.effects[PBEffects::GrassyTerrain]=3
      equal(species==:FLORGES ? 1 : 0,attack.priority)
      attack_turn
      assert(foe.hp<foe.totalhp,"Pixie did not inflict damage")
      equal(2,user.stages[PBStats::ATTACK])
    end
  end

  test(:COMFEY,"replaces-healing-and-side-effects") do
    attack=configure(:PIXIETRIBUTE,:COMFEY,:RECOVER)
    user.hp=1
    expected=(((user.totalhp+1)/2)*120.0/user.totalhp).round
    equal(expected,attack.pixie_tribute_power(user))
    attack_turn
    equal(1,user.hp)
    assert(foe.hp<foe.totalhp,"Comfey did not inflict damage")
  end

  test(:COMFEY,"replaces-heal-move-prerequisite") do
    configure(:PIXIETRIBUTE,:COMFEY,:FERTILIZE)
    user.hp=1
    attack_turn
    assert(foe.hp<foe.totalhp,"Pixie attack was denied by Fertilize's prerequisite")
    equal(1,user.hp)
    equal(false,user.effects[PBEffects::Fertilize])
  end

  test(:SKY,"full-hp-priority") do
    attack=configure(:SKYTRIBUTE,:EEVEE,:TACKLE)
    equal(1,attack.priority)
    user.hp-=1
    equal(0,attack.priority)
    attack=configure(:SKYTRIBUTE,:EEVEE,:DOUBLEKICK)
    equal(0,attack.priority)
    attack=configure(:SKYTRIBUTE,:EEVEE,:BODYSLAM)
    equal(0,attack.priority)
  end

  test(:BRAVIARY,"ally-faint-turn") do
    attack=configure(:SKYTRIBUTE,:BRAVIARY,:TACKLE,format: :double)
    ally.hp=0
    ally.pbFaint
    equal(100,attack.apply_tribute_damage_modifiers(user,foe,100))
    battle_state.instance_variable_set(:@turncount,1)
    equal(200,attack.apply_tribute_damage_modifiers(user,foe,100))
    battle_state.instance_variable_set(:@turncount,2)
    equal(100,attack.apply_tribute_damage_modifiers(user,foe,100))
  end

  test(:DELIBIRD,"priority-presents") do
    configure(:SKYTRIBUTE,:DELIBIRD,:TACKLE)
    attack_turn
    equal(2,foe.pbOwnSide.effects[PBEffects::Presents])
  end

  test(:LEDIAN,"ko-boost") do
    configure(:SKYTRIBUTE,:LEDIAN,:TACKLE,format: :double)
    foe.hp=1
    attack_turn
    equal(3,user.stages[PBStats::ATTACK])
  end

  test(:UNFEZANT,"tailwind-and-roost") do
    configure(:SKYTRIBUTE,:UNFEZANT,:TACKLE,other_move: :ROOST)
    user.gender=0
    attack_turn
    equal(2,user.pbOwnSide.effects[PBEffects::Tailwind])
    user.gender=1
    user.moves[0].pbApplyTributeAfterMove(user,[foe],8)
    assert(user.effects[PBEffects::TributeRoostBoost],"Roost boost was not queued")
    user.hp=1
    user.moves[1].pbEffect(user,user,0,[],false)
    equal(1+((((user.totalhp+1)/2)*1.5).floor),user.hp)
    equal(false,user.effects[PBEffects::TributeRoostBoost])
  end

  test(:FEAROW,"lock-on") do
    attack=configure(:SKYTRIBUTE,:FEAROW,:TACKLE)
    attack.pbApplyTributeAdditionalEffect(user,foe)
    equal(2,foe.effects[PBEffects::LockOn])
    equal(user.index,foe.effects[PBEffects::LockOnPos])
  end

  test(:DREAD,"extra-stat-drop") do
    attack=configure(:DREADTRIBUTE,:EEVEE,:GROWL)
    move_stat_source(attack) { foe.pbReduceStat(PBStats::ATTACK,1,false,attack.id,user) }
    equal(-2,foe.stages[PBStats::ATTACK])
  end

  test(:DRAPION,"status-move-applies-heroic-effect") do
    configure(:DREADTRIBUTE,:DRAPION,:GROWL)
    attack_turn
    equal(-2,foe.stages[PBStats::ATTACK])
    equal(PBStatuses::POISON,foe.status)
    equal(user.index,foe.effects[PBEffects::MeanLook])
  end

  test(:ABSOL,"target-lowest-stat") do
    attack=configure(:DREADTRIBUTE,:ABSOL,:TACKLE)
    foe.spatk=31
    foe.stages[PBStats::SPATK]=-2
    equal([31,1],attack.apply_tribute_defense_modifiers(user,foe,1,3))
  end

  test(:MEOWSCARADA,"queues-switch") do
    attack=configure(:DREADTRIBUTE,:MEOWSCARADA,:TACKLE)
    battle_state.define_singleton_method(:pbCanChooseNonActive?) { |_index| true }
    attack.pbApplyTributeAfterMove(user,[foe],10)
    assert(user.userSwitch,"Meowscarada did not queue a pivot")
  end

  test(:DRAPION,"reduced-target-trap-and-poison") do
    attack=configure(:DREADTRIBUTE,:DRAPION,:TACKLE)
    attack.pbApplyTributeAdditionalEffect(user,foe)
    equal(0,foe.status)
    foe.stages[PBStats::SPEED]=-1
    attack.pbApplyTributeAdditionalEffect(user,foe)
    equal(PBStatuses::POISON,foe.status)
    equal(user.index,foe.effects[PBEffects::MeanLook])
  end

  test(:THIEVUL,"drains-stat-loss") do
    attack=configure(:DREADTRIBUTE,:THIEVUL,:TACKLE)
    foe.stages[PBStats::SPEED]=-2
    move_stat_source(attack) { attack.pbApplyTributeAdditionalEffect(user,foe) }
    equal(0,foe.stages[PBStats::SPEED])
    equal(2,user.stages[PBStats::SPEED])
  end

  test(:SKELEDIRGE_MYSTIC,"highest-stat-drop") do
    attack=configure(:DREADTRIBUTE,:SKELEDIRGE,:TACKLE,form: 1)
    foe.spatk=400
    move_stat_source(attack) { attack.pbApplyTributeAdditionalEffect(user,foe) }
    equal(-2,foe.stages[PBStats::SPATK])
  end

  test(:EARTH,"triple-all-other-lanes") do
    attack=configure(:EARTHTRIBUTE,:EEVEE,:TACKLE,format: :triple)
    equal(PBTargets::AllNonUsers,user.pbTarget(attack))
    assert(!attack.isContactMove?,"Earth-boosted move made contact")
    attack_turn
    [foe,ally,foe_ally,outer_ally,outer_foe].each do |recipient|
      assert(recipient.hp<recipient.totalhp,"Earth missed slot #{recipient.index}")
    end
  end

  test(:SANDSLASH,"spread-and-momentum") do
    momentum=PBStuff::MOMENTUMMOVE.filter_map { |id| getConstantName(PBMoves,id)&.to_sym }.first
    attack=configure(:EARTHTRIBUTE,:SANDSLASH,momentum,format: :triple)
    equal(100,attack.pbScaleTargetDamage(100,user,foe))
    equal(150,attack.apply_tribute_damage_modifiers(user,foe,100))
  end

  test(:TORTERRA,"heals-per-target") do
    configure(:EARTHTRIBUTE,:TORTERRA,:TACKLE,format: :double)
    user.hp=1
    attack_turn
    equal(1+3*(user.totalhp/4),user.hp)
  end

  test(:STUNFISK,"electric-type-loss-and-restoration") do
    attack=configure(:EARTHTRIBUTE,:STUNFISK,:TACKLE)
    original=[user.type1,user.type2]
    equal(150,attack.apply_tribute_damage_modifiers(user,foe,100))
    attack_turn
    equal(false,user.pbHasType?(:ELECTRIC))
    equal(100,attack.apply_tribute_damage_modifiers(user,foe,100))
    2.times { advance_round }
    equal(original,[user.type1,user.type2])
  end

  test(:CLAYDOL,"uses-special-defense") do
    attack=configure(:EARTHTRIBUTE,:CLAYDOL,:TACKLE)
    equal(user.spdef,attack.apply_tribute_attack_modifiers(user,1,3,100,foe)[0])
  end

  test(:CLAYDOL_MYSTIC,"registered-form-with-fallback-art") do
    configure(:SPOOKYTRIBUTE,:CLAYDOL,:TACKLE,form: 1)
    equal("Mystic",pbGetMessage(MessageTypes::FormNames,PBSpecies::CLAYDOL).split(",")[1])
    equal(1,user.form)
    equal(:CLAYDOL_MYSTIC,pbGetHeroicKey(user))
    equal("icon344.png",File.basename(pbPokemonIconFile(user.pokemon)))
  end

  test(:RAMPARDOS_MYSTIC,"trapped-target-boost") do
    attack=configure(:EARTHTRIBUTE,:RAMPARDOS,:TACKLE,form: 1)
    equal(100,attack.apply_tribute_damage_modifiers(user,foe,100))
    foe.effects[PBEffects::MeanLook]=user.index
    equal(150,attack.apply_tribute_damage_modifiers(user,foe,100))
  end

  test(:IRON,"last-priority-and-damage") do
    attack=configure(:IRONTRIBUTE,:EEVEE,:QUICKATTACK)
    equal(-99,battle_state.pbMovePriority(user,attack))
    equal(150,attack.apply_tribute_damage_modifiers(user,foe,100))
  end

  test(:ORTHWORM,"pivot-carries-exact-damage") do
    attack=configure(:IRONTRIBUTE,:ORTHWORM,:TACKLE)
    battle_state.define_singleton_method(:pbCanChooseNonActive?) { |_index| true }
    taken=user.totalhp*3/4
    user.effects[PBEffects::TributeDamageTaken]=taken
    attack.pbApplyTributeAfterMove(user,[foe],10)
    assert(user.userSwitch,"Orthworm did not queue its pivot")
    equal(taken,user.effects[PBEffects::TributeOrthwormShedHP])
  end

  test(:EMPOLEON,"selection-before-incoming-damage") do
    configure(:IRONTRIBUTE,:EMPOLEON,:TACKLE,foe_move: :TACKLE)
    recorded=[]
    guard=user
    tracker=Module.new do
      define_method(:pbCalcDamage) do |attacker,target,*args|
        recorded.push(guard.effects[PBEffects::TributeProtection]) if target==guard
        super(attacker,target,*args)
      end
    end
    foe.moves[0].extend(tracker)
    attack_turn
    equal([0.5],recorded)
  end

  test(:BASTIODON,"heals-half-damage-this-turn") do
    attack=configure(:IRONTRIBUTE,:BASTIODON,:TACKLE)
    user.hp-=48
    before=user.hp
    user.effects[PBEffects::TributeDamageTaken]=45
    attack.pbApplyTributeAfterMove(user,[foe],10)
    equal(before+22,user.hp)
  end

  test(:PROBOPASS,"selection-magnet-rise") do
    configure(:IRONTRIBUTE,:PROBOPASS,:TACKLE)
    attack_turn
    equal(5,user.effects[PBEffects::MagnetRise])
  end

  test(:MEOWSCARADA_MYSTIC,"lowest-hp-forced-switch") do
    attack=configure(:IRONTRIBUTE,:MEOWSCARADA,:TACKLE,form: 1)
    party=battle_state.pbParty(foe.index)
    [80,25].each do |hp|
      reserve=pokemon(:NONE,battle_state.pbGetOwner(foe.index),[:CELEBRATE],:EEVEE)
      reserve.hp=hp
      party.push(reserve)
    end
    attack.pbApplyTributeSelectionEffect(user,[foe])
    equal(2,foe.pokemonIndex)
    equal(true,foe.forcedSwitchEarlier)
  end

  test(:INSECT,"protect-and-accuracy") do
    attack=configure(:INSECTTRIBUTE,:EEVEE,:FOCUSBLAST,foe_move: :PROTECT)
    equal(false,attack.canProtectAgainst?)
    foe.stages[PBStats::EVASION]=3
    20.times { assert(attack.pbAccuracyCheck(user,foe),"Insect attack missed") }
    attack_turn
    assert(foe.hp<foe.totalhp,"Insect attack did not hit through Protect")
  end

  test(:SPIDOPS,"priority-and-forced-switch") do
    attack=configure(:INSECTTRIBUTE,:SPIDOPS,:QUICKATTACK)
    equal(0,attack.priority)
    party=battle_state.pbParty(foe.index)
    party.push(pokemon(:NONE,battle_state.pbGetOwner(foe.index),[:CELEBRATE],:EEVEE))
    attack.pbApplyTributeSelectionEffect(user,[foe])
    equal(1,foe.pokemonIndex)
    equal(true,foe.forcedSwitchEarlier)
  end

  test(:ARIADOS,"web-and-reduced-speed-boost") do
    attack=configure(:INSECTTRIBUTE,:ARIADOS,:TACKLE)
    strike
    assert(foe.pbOwnSide.effects[PBEffects::StickyWeb],"Sticky Web was not placed")
    foe.stages[PBStats::SPEED]=-1
    equal(150,attack.apply_tribute_damage_modifiers(user,foe,100))
  end

  test(:ARMALDO,"always-critical") do
    attack=configure(:INSECTTRIBUTE,:ARMALDO,:TACKLE)
    12.times { assert(attack.pbIsCritical?(user,foe),"A hit was not critical") }
  end

  test(:LEAVANNY,"inverse-weakness-and-immunity") do
    attack=configure(:INSECTTRIBUTE,:LEAVANNY,:TACKLE,foe_species: :GASTLY)
    equal(8,attack.pbTypeModifier(PBTypes::NORMAL,user,foe))
    foe.type1=foe.type2=PBTypes::ROCK
    equal(8,attack.pbTypeModifier(PBTypes::NORMAL,user,foe))
    foe.type1=foe.type2=PBTypes::NORMAL
    equal(4,attack.pbTypeModifier(PBTypes::NORMAL,user,foe))
  end

  test(:LEDIAN_MYSTIC,"maximum-roll") do
    attack=configure(:INSECTTRIBUTE,:LEDIAN,:TACKLE,form: 1)
    damage=(1..8).map do |seed|
      srand(seed)
      attack.pbCalcDamage(user,foe,PokeBattle_Move::NOCRITICAL)
    end
    equal(1,damage.uniq.size)
  end
end
