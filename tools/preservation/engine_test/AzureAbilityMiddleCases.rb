module AzureAbilityFixture
  module MiddleCases
    def ability_damage(move_name, user=@user, target=@foe)
      move(move_name,user).pbCalcDamage(user,target,PokeBattle_Move::NOCRITICAL)
    end

    def ability_damage_without(move_name, owner, user=@user, target=@foe)
      previous_ability=owner.ability
      owner.ability=0
      ability_damage(move_name,user,target)
    ensure
      owner.ability=previous_ability
    end

    def ability_weather(weather)
      @battle.weather=weather
      @battle.weatherduration=5
    end

    def ability_loaf_check(move_name)
      tackle=move(move_name)
      @user.pbTryUseMove([1,0,tackle,@foe.index],tackle,[])
    end

    def absorb_ability(ability, move_name, stats)
      battle(:NONE,ability)
      starting_hp=@foe.hp
      hit(move_name)
      equal(starting_hp,@foe.hp)
      equal([1,1],stats.map { |stat| @foe.stages[stat] })
    end
  end
  Scenario.include(MiddleCases)

  test(:STALL) do
    battle(:STALL,:NONE,user_moves: [:QUICKATTACK])
    @battle.pbRegisterMove(@user.index,0,false)
    @battle.pbRegisterMove(@foe.index,0,false)
    @battle.pbRegisterTarget(@user.index,@foe.index)
    @battle.pbRegisterTarget(@foe.index,@user.index)
    equal(@user.index,@battle.pbPriority.last.index)
    @foe.status=PBStatuses::BURN
    before=@foe.hp
    @battle.pbEndOfRoundWithStall
    equal(before-2*(@foe.totalhp/16),@foe.hp)
  end

  test(:OWNTEMPO) do
    battle(:OWNTEMPO)
    @user.item=PBItems::METRONOME
    equal(0,@user.pbNextRepeatCount(PBMoves::TACKLE))
    @user.lastMoveUsed=PBMoves::TACKLE
    @user.effects[PBEffects::Metronome]=0
    equal(1,@user.pbNextRepeatCount(PBMoves::TACKLE))
    assert((1.32-@user.pbRepeatDamageMultiplier(1)).abs<0.0001,
           "Own Tempo and Metronome did not stack")
    @user.effects[PBEffects::Metronome]=1
    assert(ability_damage(:TACKLE)>ability_damage_without(:TACKLE,@user),
           "a repeated attack received no Own Tempo boost")
  end

  test(:KEENEYE) do
    battle(:KEENEYE)
    entry
    assert(@user.effects[PBEffects::LaserFocus]>0,"Laser Focus was not applied")
    assert(@foe.effects[PBEffects::LockOn]>0,"Lock-On was not applied")
    equal(@user.index,@foe.effects[PBEffects::LockOnPos])
    assert(!@user.pbCanReduceStatStage?(PBStats::ACCURACY,false),"accuracy can be lowered")

    battle(:KEENEYE,:NONE,outer_ally: :NONE,outer_foe: :NONE)
    assert(@battle.pbShiftBattlers(@user.index,@outer_ally.index),"Keen Eye could not shift to the outer lane")
    entry
    equal(@user.index,@outer_foe.effects[PBEffects::LockOnPos])
    assert(@battle.pbRegisterShift(@user.index,@ally.index),"could not queue Keen Eye's shift")
    @battle.pbAttackPhase
    equal(2,@user.index)
    equal(@user.index,@outer_foe.effects[PBEffects::LockOnPos])
    bench=pokemon(:NONE,$Trainer,[:TACKLE])
    $Trainer.party.push(bench)
    assert(@battle.pbRecallAndReplace(@user.index,3),"could not switch out the Lock-On source")
    equal(0,@outer_foe.effects[PBEffects::LockOn])
    equal(-1,@outer_foe.effects[PBEffects::LockOnPos])
  end

  test(:INSOMNIA) do
    battle(:INSOMNIA)
    assert(!@user.pbCanSleep?(false),"Insomnia can fall asleep")
    assert(!move(:SOLARBEAM).pbTwoTurnAttack(@user,true),"Solar Beam still has to charge")
    @user.ability=0
    assert(move(:SOLARBEAM).pbTwoTurnAttack(@user,true),"control Solar Beam did not charge")
  end

  test(:LIQUIDOOZE) do
    battle(:NONE,:LIQUIDOOZE)
    @user.hp=@user.totalhp*3/4
    before=@user.hp
    hit(:GIGADRAIN)
    assert(@user.hp<before,"Giga Drain did not reverse healing")
    assert(@user.effects[PBEffects::Wounded]>0,"Giga Drain did not wound the attacker")
    battle(:NONE,:LIQUIDOOZE)
    @foe.status=PBStatuses::SLEEP
    @foe.statusCount=2
    @user.hp=@user.totalhp*3/4
    before=@user.hp
    hit(:DREAMEATER)
    assert(@user.hp<before,"Dream Eater did not reverse healing")
    assert(@user.effects[PBEffects::Wounded]>0,"Dream Eater did not wound the attacker")
    battle(:NONE,:LIQUIDOOZE)
    @user.hp=@user.totalhp*3/4
    before=@user.hp
    hit(:STRENGTHSAP)
    assert(@user.hp<before,"Strength Sap did not reverse healing")
    battle(:NONE,:LIQUIDOOZE)
    before=@user.hp
    @foe.effects[PBEffects::LeechSeed]=@user.index
    round
    assert(@user.hp<before,"Leech Seed did not reverse healing")
  end

  test(:SPIRITED) do
    battle(:SPIRITED)
    assert(ability_damage(:AERIALACE)>ability_damage_without(:AERIALACE,@user),
           "Aerial Ace did not gain damage")
    equal(ability_damage_without(:TACKLE,@user),ability_damage(:TACKLE))
  end

  test(:ILLUMINATE) do
    battle(:ILLUMINATE)
    entry
    equal(1,@user.stages[PBStats::ACCURACY])
    assert(!@user.pbCanBlind?(false),"Illuminate can be blinded")
    encounters=PokemonEncounters.new
    encounter_type=EncounterTypes::Land
    density=[]
    density[encounter_type]=10
    slots=[]
    slots[encounter_type]=EncounterTypes::EnctypeChances[encounter_type].map { [PBSpecies::RATTATA,50,50] }
    encounters.instance_variable_set(:@density,density)
    encounters.instance_variable_set(:@enctypes,slots)
    encounters.clearStepCount
    tries=400
    srand(1184)
    with_ability=tries.times.count { !encounters.pbGenerateEncounter(encounter_type).nil? }
    encounters.clearStepCount
    @user.pokemon.abilityoverride=PBAbilities::BALLFETCH
    srand(1184)
    without_ability=tries.times.count { !encounters.pbGenerateEncounter(encounter_type).nil? }
    assert(with_ability>without_ability,"Illuminate did not attract more wild Pokémon")
  end

  test(:OBLIVIOUS) do
    battle(:OBLIVIOUS)
    assert(!@user.pbCanConfuse?(false),"Oblivious can be confused")
    assert(!@user.pbCanAttract?(@foe,false),"Oblivious can be infatuated")
    hit(:TAUNT,@foe,@user)
    hit(:TORMENT,@foe,@user)
    equal(0,@user.effects[PBEffects::Taunt])
    equal(false,@user.effects[PBEffects::Torment])
    battle(:OBLIVIOUS,:NONE,ally: :NONE,foe_ally: :NONE)
    @foe_ally.effects[PBEffects::FollowMe]=true
    pair=[@user,@foe]
    @user.pbChangeTarget(move(:TACKLE),pair,[@foe])
    equal(@foe,pair[1])
  end

  test(:STEADFAST) do
    battle(:STEADFAST)
    @user.effects[PBEffects::Flinch]=true
    assert(!ability_loaf_check(:TACKLE),"flinch did not stop the attack")
    equal(1,@user.stages[PBStats::SPEED])
    @foe.effects[PBEffects::Protect]=true
    hit(:TACKLE)
    equal(2,@user.stages[PBStats::SPEED])
  end

  test(:WONDERSKIN) do
    battle(:NONE,:WONDERSKIN)
    before=@user.hp
    hit(:HYPERVOICE)
    equal(before-@user.totalhp/8,@user.hp)
    hit(:TACKLE)
    equal(before-@user.totalhp/8,@user.hp)

    battle(:NONE,:WONDERSKIN,user_moves: [:HYPERVOICE],ally: :NONE,foe_ally: :NONE)
    @user.hp=1
    second_foe_hp=@foe_ally.hp
    @user.pbUseMove([1,0,@user.moves[0],-1])
    assert(@user.isFainted?,"Wonder Skin should knock out the spread move's user")
    equal(second_foe_hp,@foe_ally.hp)
  end

  test(:DAMP) do
    battle(:NONE,:DAMP)
    starting_hp=@foe.hp
    starting_user_hp=@user.hp
    hit(:FLAMETHROWER)
    equal(starting_hp,@foe.hp)
    explosion=move(:EXPLOSION)
    assert(!explosion.pbOnStartUse(@user),"Damp did not block Explosion")
    equal(starting_user_hp,@user.hp)
  end

  test(:LIMBER) do
    battle(:LIMBER)
    with_ability=ability_damage(:TACKLE,@foe,@user)
    without_ability=ability_damage_without(:TACKLE,@user,@foe,@user)
    assert(with_ability<without_ability,"entry damage was not reduced")
    side=@user.pbOwnSide
    side.effects[PBEffects::Spikes]=3
    side.effects[PBEffects::StealthRock]=true
    side.effects[PBEffects::ToxicSpikes]=2
    side.effects[PBEffects::StickyWeb]=true
    before=@user.hp
    @battle.pbOnActiveOne(@user)
    equal(before,@user.hp)
    equal(0,@user.status)
    equal(0,@user.stages[PBStats::SPEED])
  end

  test(:STATIC) do
    battle(:NONE,:STATIC)
    hit(:TACKLE)
    equal(0,@user.status)
    @foe.hp=1
    hit(:TACKLE)
    equal(PBStatuses::PARALYSIS,@user.status)
    battle(:NONE,:STATIC)
    @foe.hp=1
    hit(:HYPERVOICE)
    equal(0,@user.status)
  end

  test(:FLAMEBODY) do
    battle(:NONE,:FLAMEBODY)
    hit(:TACKLE)
    equal(0,@user.status)
    @foe.hp=1
    hit(:TACKLE)
    equal(PBStatuses::BURN,@user.status)
    battle(:NONE,:FLAMEBODY)
    @foe.hp=1
    hit(:HYPERVOICE)
    equal(0,@user.status)
  end

  test(:IMMUNITY) do
    battle(:IMMUNITY)
    assert(!@user.pbCanPoison?(false),"Immunity permits poison")
    assert(!@user.pbCanParalyze?(false),"Immunity permits paralysis")
    @user.ability=0
    assert(@user.pbCanPoison?(false),"control could not be poisoned")
    assert(@user.pbCanParalyze?(false),"control could not be paralyzed")

    battle(:IMMUNITY,:NONE,user_moves: [:SUBSTITUTE],ally: :NONE,foe_ally: :NONE,
      outer_ally: :NONE,outer_foe: :NONE)
    assert(@battle.pbShiftBattlers(@user.index,@outer_ally.index),"Immunity could not shift to the outer slot")
    hit(:BINDINGWORD,@foe_ally,@user)
    assert(@user.pbCanPoison?(false),"Binding Word should let poison through Immunity")
    @user.status=PBStatuses::POISON
    assert(@battle.pbRegisterMove(@user.index,0,false),"Could not select Substitute")
    @battle.pbAttackPhase
    assert(@user.effects[PBEffects::Substitute]>0,"Substitute was not used")
    assert(@user.hasWorkingAbility(:IMMUNITY),"Substitute did not end Binding Word")
    equal(0,@user.status)
  end

  test(:HEATPROOF) do
    battle(:NONE,:HEATPROOF)
    assert(!@foe.pbCanBurn?(false),"Heatproof permits burn")
    assert(ability_damage(:FLAMETHROWER)<ability_damage_without(:FLAMETHROWER,@foe),
           "Fire damage was not reduced")
    equal(ability_damage_without(:TACKLE,@foe),ability_damage(:TACKLE))
  end

  test(:ANGERPOINT) do
    battle(:ANGERPOINT,:NONE,user_moves: [:GROWL,:TACKLE])
    assert(!@battle.pbCanChooseMove?(@user.index,0,false),"Anger Point can choose Growl")
    assert(@battle.pbCanChooseMove?(@user.index,1,false),"Anger Point cannot choose Tackle")
    assert(ability_damage(:TACKLE)>ability_damage_without(:TACKLE,@user),
           "Anger Point did not increase attack damage")
  end

  test(:POWEROFALCHEMY) do
    battle(:POWEROFALCHEMY,:STURDY,ally: :NONE,foe_ally: :LEVITATE)
    @foe.hp=0
    @foe.pbFaint
    equal(PBAbilities::STURDY,@user.ability)
    @foe_ally.hp=0
    @foe_ally.pbFaint
    equal(PBAbilities::LEVITATE,@user.ability)
    battle(:POWEROFALCHEMY)
    @battle.lastFaintedEnemyAbility[@user.index&1]=PBAbilities::LEVITATE
    entry
    equal(PBAbilities::LEVITATE,@user.ability)
  end

  test(:RECEIVER) do
    battle(:RECEIVER,:NONE,ally: :STURDY,foe_ally: :NONE)
    @ally.hp=0
    @ally.pbFaint
    equal(PBAbilities::STURDY,@user.ability)
    battle(:RECEIVER)
    @battle.lastFaintedAllyAbility[@user.index&1]=PBAbilities::LEVITATE
    entry
    equal(PBAbilities::LEVITATE,@user.ability)
  end

  test(:LIGHTNINGROD) do
    absorb_ability(:LIGHTNINGROD,:THUNDERSHOCK,[PBStats::ATTACK,PBStats::SPATK])
    battle(:MOLDBREAKER,:NONE,user_moves: [:THUNDERSHOCK],ally: :NONE,foe_ally: :LIGHTNINGROD)
    hp=@foe_ally.hp
    @user.pbUseMove([1,0,@user.moves[0],@foe.index])
    assert(@foe_ally.hp<hp,"Mold Breaker did not bypass Lightning Rod on the redirected target")
    equal(0,@foe_ally.stages[PBStats::SPATK])
    equal(false,@foe_ally.moldbroken)
    battle(:NONE,:NONE,user_moves: [:THUNDERSHOCK],ally: :LIGHTNINGROD,foe_ally: :NONE)
    @foe_ally.effects[PBEffects::FollowMe]=true
    hp=@foe_ally.hp
    @user.pbUseMove([1,0,@user.moves[0],@foe.index])
    assert(@foe_ally.hp<hp,"Follow Me should override Lightning Rod redirection")
    assert(@scene.messages.none? { |message| message.include?("Lightning Rod") || message.include?("Lightningrod") },
      "Follow Me was announced as Lightning Rod redirection")
  end

  test(:STORMDRAIN) do
    absorb_ability(:STORMDRAIN,:WATERGUN,[PBStats::ATTACK,PBStats::SPATK])
    battle(:NONE,:NONE,user_moves: [:MUDDYWATER],ally: :STORMDRAIN,foe_ally: :NONE)
    @foe_ally.hp=0
    @battle.weather=PBWeather::RAINDANCE
    hp=@foe.hp
    @user.pbUseMove([1,0,@user.moves[0],@foe.index])
    assert(@foe.hp<hp,"Storm Drain redirected a spread move with one surviving target")
    equal(0,@ally.stages[PBStats::SPATK])
    battle(:NONE,:NONE,user_moves: [:WATERGUN],ally: :NONE,foe_ally: :NONE,outer_foe: :STORMDRAIN)
    hp=@foe.hp
    @user.pbUseMove([1,0,@user.moves[0],@foe.index])
    assert(@foe.hp<hp,"Storm Drain drew in a move that could not reach its lane")
    equal(0,@outer_foe.stages[PBStats::SPATK])
    @foe_ally.ability=PBAbilities::STORMDRAIN
    @outer_foe.ability=PBAbilities::NEUTRALIZINGGAS
    hp=@foe.hp
    @user.pbUseMove([1,0,@user.moves[0],@foe.index])
    assert(@foe.hp<hp,"A suppressed Storm Drain redirected the move")
    equal(0,@foe_ally.stages[PBStats::SPATK])

    battle(:NONE,:NEUTRALIZINGGAS,user_moves: [:MUDDYWATER],ally: :NONE,foe_ally: :STORMDRAIN)
    @foe.hp=1
    hp=@foe_ally.hp
    @user.pbUseMove([1,0,@user.moves[0],-1])
    assert(@foe.isFainted?,"The first hit of the spread move must remove Neutralizing Gas")
    equal(hp,@foe_ally.hp)
    equal(1,@foe_ally.stages[PBStats::SPATK])
  end

  test(:JUSTIFIED) do
    absorb_ability(:JUSTIFIED,:BITE,[PBStats::ATTACK,PBStats::SPATK])
  end

  test(:SAPSIPPER) do
    absorb_ability(:SAPSIPPER,:ABSORB,[PBStats::ATTACK,PBStats::SPATK])
  end

  test(:MAGMAARMOR) do
    absorb_ability(:MAGMAARMOR,:WATERGUN,[PBStats::DEFENSE,PBStats::SPDEF])
  end

  test(:BADDREAMS) do
    battle(:BADDREAMS)
    entry
    assert(@user.effects[PBEffects::NightmareAura],"Nightmare was not invoked on entry")
  end

  test(:POISONPOINT) do
    battle(:POISONPOINT)
    hit(:TACKLE)
    equal(PBStatuses::POISON,@foe.status)
    battle(:NONE,:POISONPOINT)
    hit(:TACKLE)
    equal(PBStatuses::POISON,@user.status)
    battle(:POISONPOINT)
    hit(:HYPERVOICE)
    equal(0,@foe.status)
  end

  test(:INNERFOCUS) do
    battle(:INNERFOCUS)
    @user.effects[PBEffects::Flinch]=true
    assert(ability_loaf_check(:TACKLE),"flinch stopped Inner Focus")
    equal(false,@user.effects[PBEffects::Flinch])
    battle(:INNERFOCUS,:NONE,ally: :NONE,foe_ally: :LIGHTNINGROD)
    pair=[@user,@foe]
    @user.pbChangeTarget(move(:THUNDERSHOCK),pair,[@foe])
    equal(@foe,pair[1])
  end

  test(:CORROSION) do
    battle(:CORROSION,:NONE,user_moves: [:TOXIC,:SLUDGE],user_species: :EKANS)
    @foe.type1=@foe.type2=PBTypes::STEEL
    start=@foe.hp
    @user.pbUseMove([1,0,@user.moves[0],@foe.index])
    equal(PBStatuses::POISON,@foe.status)
    @user.pbUseMove([1,1,@user.moves[1],@foe.index])
    assert(@foe.hp<start,"Poison damage did not hit Steel")
    battle(:CORROSION,:NONE,user_moves: [:TOXIC],user_species: :EKANS,ally: :NONE,foe_ally: :NONE)
    @foe_ally.type1=@foe_ally.type2=PBTypes::STEEL
    @foe_ally.effects[PBEffects::FollowMe]=true
    @user.pbUseMove([1,0,@user.moves[0],@foe.index])
    equal(0,@foe.status)
    equal(PBStatuses::POISON,@foe_ally.status)
    assert(!@foe_ally.corroded,"Corrosion persisted after the move")
  end

  test(:EARLYBIRD) do
    battle(:EARLYBIRD)
    before=@user.pbSpeed
    @user.status=PBStatuses::SLEEP
    @user.statusCount=1
    assert(ability_loaf_check(:TACKLE),"the waking user did not get its turn")
    equal(0,@user.status)
    equal(before*2,@user.pbSpeed)
  end

  test(:RUNAWAY) do
    battle(:RUNAWAY,:NONE,wild: true)
    @user.effects[PBEffects::MeanLook]=@foe.index
    assert(@battle.pbCanSwitch?(@user.index,-1,false),"Run Away could not escape trapping")
    assert(move(:PURSUIT,@foe).pbMoveFailed(@foe,@user),"Pursuit can target Run Away")
    assert(@battle.pbCanRun?(@user.index),"Run Away could not flee a wild fight")

    battle(:RUNAWAY,:NONE,foe_moves: [:PURSUIT],ally: :NONE,foe_ally: :NONE)
    outgoing=@ally.pokemon
    starting_hp=outgoing.hp
    runner=@user.pokemon
    runner_hp=runner.hp
    $Trainer.party.push(pokemon(:NONE,$Trainer,[:TACKLE]))
    equal(true,@battle.pbRegisterSwitch(@ally.index,2))
    equal(true,@battle.pbRegisterMove(@foe.index,0))
    @battle.pbAttackPhase
    assert(outgoing.hp<starting_hp,"Untargeted Pursuit missed the actual switcher")
    equal(runner_hp,runner.hp)
  end

  test(:PICKUP) do
    battle(:PICKUP)
    @foe.item=PBItems::ORANBERRY
    @foe.hp=1
    hit(:TACKLE)
    equal(PBItems::ORANBERRY,@user.item)
    equal(0,@foe.item)
    @user.pokemon.setItem(0)
    srand(1200)
    100.times do
      Kernel.pbPickup(@user.pokemon)
      break if @user.pokemon.item>0
    end
    assert(@user.pokemon.item>0,"field Pickup did not yield an item")
  end

  test(:PICKPOCKET) do
    battle(:PICKPOCKET)
    @foe.item=PBItems::ORANBERRY
    hit(:HYPERVOICE,@foe,@user)
    equal(PBItems::ORANBERRY,@user.item)
    equal(0,@foe.item)
    equal(2,@user.stages[PBStats::SPEED])
  end

  test(:MAGICIAN) do
    battle(:MAGICIAN)
    assert(ability_damage(:TACKLE)>ability_damage_without(:TACKLE,@user),
           "an itemless target did not take boosted damage")
    @foe.item=PBItems::ORANBERRY
    hit(:TACKLE)
    equal(PBItems::ORANBERRY,@user.item)
    equal(0,@foe.item)
  end

  test(:TRUANT) do
    battle(:TRUANT)
    @user.turncount=1
    @user.hp=1
    round
    assert(@user.effects[PBEffects::Truant],"round did not toggle Truant")
    before=@user.hp
    assert(!ability_loaf_check(:TACKLE),"Truant did not skip the turn")
    equal(before+@user.totalhp/3,@user.hp)
  end

  test(:HUNGERSWITCH) do
    battle(:HUNGERSWITCH,:NONE,user_species: :MORPEKO)
    @user.pokemon.form=0
    @user.form=0
    @user.pokemon.abilityoverride=PBAbilities::HUNGERSWITCH
    @user.hp=@user.totalhp*3/4
    before=@user.hp
    amount=@user.totalhp/8
    round
    equal(1,@user.form)
    equal(before+amount,@user.hp)
    speed=@user.pbSpeed
    @user.ability=0
    assert(speed>=1.49*@user.pbSpeed,"Hangry form did not boost Speed")
  end

  test(:CLOUDNINE) do
    battle(:CLOUDNINE)
    ability_weather(PBWeather::RAINDANCE)
    equal(0,@battle.pbWeather)
    assert(!@battle.pbWithStatChangeSource([:move,PBMoves::SWORDSDANCE]) { @foe.pbCanIncreaseStatStage?(PBStats::ATTACK,false) },
           "Cloud Nine permits stat raises")
    $fefieldeffect=9
    @user.stages[PBStats::ATTACK]=-1
    round
    equal(-1,@user.stages[PBStats::ATTACK])
    @user.ability=0
    equal(PBWeather::RAINDANCE,@battle.pbWeather)
    assert(@battle.pbWithStatChangeSource([:move,PBMoves::SWORDSDANCE]) { @foe.pbCanIncreaseStatStage?(PBStats::ATTACK,false) },
           "control stat could not rise")

    battle(:CLOUDNINE,:PRIMORDIALSEA)
    entry(@foe)
    entry(@user)
    equal(0,@battle.pbWeather)
    equal(true,@battle.field.effects[PBEffects::HeavyRain])
    @user.ability=0
    equal(PBWeather::RAINDANCE,@battle.pbWeather)

    battle(:CLOUDNINE)
    ability_weather(PBWeather::SANDSTORM)
    $fefieldeffect=7
    $febackup=7
    round
    equal(7,$fefieldeffect)
  end

  {
    WATERVEIL: [PBWeather::RAINDANCE,PBStats::SPDEF,:HYPERVOICE],
    SANDVEIL: [PBWeather::SANDSTORM,PBStats::DEFENSE,:TACKLE],
    SNOWVEIL: [PBWeather::HAIL,PBStats::SPDEF,:HYPERVOICE],
    FLOWERVEIL: [PBWeather::SUNNYDAY,PBStats::DEFENSE,:TACKLE]
  }.each do |ability, (weather,stat,move_name)|
    test(ability) do
      battle(:NONE,ability)
      ability_weather(weather)
      equal(1.5,@foe.pbWeatherDefenseMultiplier(stat))
      assert(ability_damage(move_name)<ability_damage_without(move_name,@foe),
             "correct weather did not reduce damage")
      @battle.weather=0
      equal(1.0,@foe.pbWeatherDefenseMultiplier(stat))
    end
  end

  {HYDRATION: PBWeather::RAINDANCE, LEAFGUARD: PBWeather::SUNNYDAY}.each do |ability, weather|
    test(ability) do
      battle(ability)
      ability_weather(weather)
      @user.status=PBStatuses::POISON
      @user.stages[PBStats::ATTACK]=-1
      @user.stages[PBStats::DEFENSE]=1
      round
      equal(0,@user.status)
      equal(0,@user.stages[PBStats::ATTACK])
      equal(1,@user.stages[PBStats::DEFENSE])
    end
  end

  test(:BATTLEARMOR) do
    battle(:NONE,:BATTLEARMOR,user_moves: [:QUICKATTACK])
    @battle.pbRegisterMove(@user.index,0,false)
    @battle.pbRegisterMove(@foe.index,0,false)
    @battle.pbRegisterTarget(@user.index,@foe.index)
    @battle.pbRegisterTarget(@foe.index,@user.index)
    equal(@foe.index,@battle.pbPriority.last.index)
    assert(ability_damage(:TACKLE)<ability_damage_without(:TACKLE,@foe),
           "the last battler did not get Battle Armor's reduction")
  end

  test(:RIVALRY) do
    battle(:RIVALRY)
    @user.gender=@foe.gender=0
    assert(ability_damage(:TACKLE)>ability_damage_without(:TACKLE,@user),
           "same-gender target damage was not boosted")
    @foe.gender=1
    assert(ability_damage(:TACKLE,@foe,@user)<ability_damage_without(:TACKLE,@user,@foe,@user),
           "different-gender incoming damage was not reduced")
  end

  test(:TOXICBOOST) do
    battle(:TOXICBOOST)
    @user.status=PBStatuses::POISON
    assert(ability_damage(:HYPERVOICE)>ability_damage_without(:HYPERVOICE,@user),
           "a special move did not gain the poison boost")
    before=@user.hp
    round
    equal(before,@user.hp)
  end

  test(:KLUTZ) do
    battle(:KLUTZ,:NONE,user_moves: [:GROWL,:TACKLE])
    @user.item=PBItems::LEFTOVERS
    @battle.pbOnActiveOne(@user)
    assert(!@user.itemWorks?,"first turn did not suppress the item")
    @user.item=PBItems::ASSAULTVEST
    assert(@battle.pbCanChooseMove?(@user.index,0,false),"suppressed Assault Vest blocked a status move")
    @battle.instance_variable_set(:@turncount,@battle.turncount+1)
    assert(@user.hasWorkingItem(:ASSAULTVEST),"item stayed suppressed after its entry turn")
    assert(!@battle.pbCanChooseMove?(@user.index,0,false),"active Assault Vest allowed a status move")

    battle(:KLUTZ)
    @user.item=PBItems::SAFETYGOGGLES
    @battle.pbOnActiveOne(@user)
    ability_weather(PBWeather::SANDSTORM)
    hp=@user.hp
    round
    equal(hp-@user.totalhp/16,@user.hp)
    @battle.instance_variable_set(:@turncount,@battle.turncount+1)
    hp=@user.hp
    round
    equal(hp,@user.hp)

    battle(:KLUTZ)
    @user.item=PBItems::SAFETYGOGGLES
    @battle.pbOnActiveOne(@user)
    hit(:SPORE,@foe,@user)
    equal(2,@user.effects[PBEffects::Yawn])
  end
end
