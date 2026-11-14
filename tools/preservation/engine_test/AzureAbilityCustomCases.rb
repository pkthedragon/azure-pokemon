module AzureAbilityFixture
  class Scenario
    def custom_damage(name, user=@user, target=@foe)
      srand(14142)
      move(name,user).pbCalcDamage(user,target,PokeBattle_Move::NOCRITICAL)
    end

    def custom_compare(name, holder, ability, factor, user=@user, target=@foe)
      previous=holder.ability
      holder.ability=0
      base=custom_damage(name,user,target)
      holder.ability=PBAbilities.const_get(ability)
      actual=custom_damage(name,user,target)
      assert(base>0,"#{name} needs positive baseline damage")
      assert((actual-base*factor).abs<=2,"#{name} dealt #{actual} with #{ability}; expected #{factor} x #{base}")
    ensure
      holder.ability=previous
    end

    def custom_hp(battler, amount)
      battler.hp=amount
    end

    def custom_type(battler, type)
      battler.type1=type
      battler.type2=type
    end

    def custom_convert(ability, name, type)
      battle(ability,:NONE)
      custom_type(@user,PBTypes::NORMAL)
      custom_type(@foe,PBTypes::NORMAL)
      attack=move(name)
      equal(type,attack.pbType(attack.type,@user,@foe))
      baseline=custom_damage(name)
      @user.ability=0
      attack=move(name)
      attack.type=type
      srand(14142)
      unboosted=attack.pbCalcDamage(@user,@foe,PokeBattle_Move::NOCRITICAL)
      assert((baseline-unboosted*1.2).abs<=2,"converted move power should be 1.2x (#{baseline} vs. #{unboosted})")
    end

    def custom_use_regular(name,user=@user,target=@foe)
      idx=user.moves.index { |known| known && known.id==PBMoves.const_get(name) }
      raise "#{name} is missing from move set" unless idx
      choice=[1,idx,move(name,user),target.index]
      @battle.choices[user.index]=choice
      user.pbUseMove(choice)
    end

  end

  test(:AMBIDEXTROUS) do
    battle(:AMBIDEXTROUS,:NONE)
    custom_type(@user,PBTypes::NORMAL)
    custom_compare(:WATERGUN,@user,:AMBIDEXTROUS,1.3)
    custom_compare(:TACKLE,@user,:AMBIDEXTROUS,1.0)
  end

  test(:HEADSTRONG) do
    battle(:NONE,:NONE,ally: :HEADSTRONG)
    custom_type(@foe,PBTypes::GHOST)
    assert(custom_damage(:TACKLE)>0,"the ally should bypass Ghost immunity")
    @ally.ability=0
    equal(0,custom_damage(:TACKLE))
    @ally.ability=PBAbilities::HEADSTRONG
    @foe.ability=PBAbilities::LEVITATE
    assert(custom_damage(:MUDSLAP)>0,"the ally should bypass Levitate")
  end

  test(:ERRATIC) do
    battle(:ERRATIC,:NONE)
    hit(:TACKLE)
    assert(@foe.effects[PBEffects::Confusion]>0,"the damaging hit must confuse")
  end

  test(:ELDRITCH) do
    battle(:ELDRITCH,:NONE,ally: :NONE,foe_ally: :NONE)
    entry
    [@ally,@foe,@foe_ally].each { |battler| assert(battler.effects[PBEffects::Blinded]>0,"slot #{battler.index} was not blinded") }
    assert(@user.effects[PBEffects::Blinded]<=0,"Eldritch blinded the holder")
  end

  test(:LACERATE) { custom_convert(:LACERATE,:TACKLE,PBTypes::STEEL) }
  test(:IMMOLATE) { custom_convert(:IMMOLATE,:TACKLE,PBTypes::FIRE) }
  test(:BRUTALIZE) { custom_convert(:BRUTALIZE,:TACKLE,PBTypes::FIGHTING) }
  test(:ESOTERIC) do
    battle(:ESOTERIC,:NONE)
    equal(@user.spatk*2,@user.pbAbilitySpecialAttack)
    assert(custom_damage(:WATERGUN)>0,"the doubled stat must be usable by an actual attack")
    custom_compare(:TACKLE,@user,:ESOTERIC,1.0)
  end

  test(:PERPETUAL) do
    battle(:PERPETUAL,:NONE)
    move(:TAILWIND).pbEffect(@user,@user,0,nil,false)
    equal(7,@user.pbOwnSide.effects[PBEffects::Tailwind])
    move(:GRAVITY).pbEffect(@user,@user,0,nil,false)
    equal(7,@battle.field.effects[PBEffects::Gravity])
    move(:REFLECT).pbEffect(@user,@user,0,nil,false)
    equal(7,@user.pbOwnSide.effects[PBEffects::Reflect])
  end

  test(:CARETAKER) do
    battle(:CARETAKER,:NONE,ally: :NONE)
    custom_hp(@ally,@ally.totalhp/2)
    custom_hp(@user,@user.totalhp/2)
    ally_hp=@ally.hp
    holder_hp=@user.hp
    round
    equal(ally_hp+[@ally.totalhp/8,1].max,@ally.hp)
    equal(holder_hp,@user.hp)
  end

  test(:SUNBATHE) do
    battle(:SUNBATHE,:NONE)
    custom_hp(@user,@user.totalhp/2)
    before=@user.hp
    round
    equal(before,@user.hp)
    @battle.weather=PBWeather::SUNNYDAY
    @battle.weatherduration=5
    round
    equal(before+@user.totalhp/8,@user.hp)
  end

  test(:ICEBREAKER) do
    battle(:ICEBREAKER,:NONE)
    @battle.weather=PBWeather::HAIL
    @battle.weatherduration=5
    custom_compare(:ICEBEAM,@user,:ICEBREAKER,1.3)
    custom_compare(:ROCKSMASH,@user,:ICEBREAKER,1.3)
    @battle.weather=0
    custom_compare(:ICEBEAM,@user,:ICEBREAKER,1.0)
  end

  test(:HYDROPLANE) do
    battle(:HYDROPLANE,:NONE)
    @battle.weather=PBWeather::RAINDANCE
    @battle.weatherduration=5
    custom_compare(:TACKLE,@user,:HYDROPLANE,1.5)
    custom_compare(:WATERGUN,@user,:HYDROPLANE,1.0)
    before=@user.hp
    round
    equal(before-@user.totalhp/8,@user.hp)
  end

  test(:BLOODTHIRSTY) do
    battle(:BLOODTHIRSTY,:NONE)
    custom_hp(@user,@user.totalhp/2)
    before=@user.hp
    hit(:WATERGUN)
    equal(before,@user.hp)
    hit(:TACKLE)
    assert(@user.hp>before,"contact damage should restore HP")
  end

  test(:FROSTPOINT) do
    battle(:FROSTPOINT,:NONE)
    custom_hp(@user,1)
    hit(:TACKLE,@foe,@user)
    equal(PBStatuses::FROZEN,@foe.status)
    battle(:FROSTPOINT,:NONE)
    custom_hp(@user,1)
    hit(:WATERGUN,@foe,@user)
    equal(0,@foe.status)
  end

  test(:IMPERVIOUS) do
    battle(:IMPERVIOUS,:NONE)
    [:LOWKICK,:FIREPUNCH,:BITE].each do |name|
      hit(name,@foe,@user)
      equal(@user.totalhp,@user.hp)
    end
    hit(:TACKLE,@foe,@user)
    assert(@user.hp<@user.totalhp,"Impervious blocked an unlisted contact move")
  end

  test(:HEATSINK) do
    battle(:HEATSINK,:NONE)
    custom_hp(@user,@user.totalhp/2)
    before=@user.hp
    hit(:EMBER,@foe,@user)
    equal(before+@user.totalhp/4,@user.hp)
  end

  test(:SCAVENGER) do
    battle(:SCAVENGER,:NONE)
    custom_hp(@user,@user.totalhp/2)
    custom_hp(@foe,1)
    before=@user.hp
    hit(:TACKLE)
    equal(before+@user.totalhp/4,@user.hp)
  end

  test(:GRENADIER) do
    battle(:GRENADIER,:NONE)
    [:ENERGYBALL,:SEEDBOMB,:EXPLOSION].each { |name| custom_compare(name,@user,:GRENADIER,1.5) }
    custom_compare(:TACKLE,@user,:GRENADIER,1.0)
  end

  test(:PINPOINT) do
    battle(:PINPOINT,:NONE)
    custom_compare(:HORNATTACK,@user,:PINPOINT,1.5)
    custom_compare(:TACKLE,@user,:PINPOINT,1.0)
  end

  test(:REVERB) do
    battle(:REVERB,:NONE)
    @foe.spdef*=3
    before=@foe.hp
    hit(:SNARL)
    original=before-@foe.hp
    assert(original>0,"the original sound move missed")
    before=@foe.hp
    equal(-1,@foe.stages[PBStats::SPATK])
    # A move source contributes to the stat cap once. Clear the stage to verify
    # that the same secondary effect runs on the echo within that cap.
    @foe.stages[PBStats::SPATK]=0
    assert(@user.effects[PBEffects::ReverbEcho].key?(PBMoves::SNARL),"the original sound move was not queued")
    @battle.pbAttackPhase
    echo_damage=before-@foe.hp
    assert(echo_damage>0 && echo_damage<original,"the echo should deal reduced damage (#{echo_damage} vs. #{original})")
    equal(-1,@foe.stages[PBStats::SPATK])
    assert(@user.effects[PBEffects::ReverbEcho].empty?,"the echo queued itself")

    battle(:REVERB,:NONE,user_moves: [:SPLASH],foe_moves: [:SPLASH])
    @user.speed=80
    @foe.speed=100
    @foe.spdef*=3
    @user.instance_variable_set(:@name,"Echo User")
    @foe.instance_variable_set(:@name,"Echo Target")
    @battle.define_singleton_method(:pbRandom) { |_max| 1 }
    @user.effects[PBEffects::ReverbEcho][PBMoves::NATURESCALL]=[@foe.index]
    turn(:SPLASH,:SPLASH)
    equal(PBStatuses::PARALYSIS,@foe.status)
    user_move=@scene.messages.index { |message| message.include?("Echo User used") }
    foe_move=@scene.messages.index { |message| message.include?("Echo Target used") }
    assert(user_move && foe_move && user_move<foe_move,
           "Reverb paralysis was applied too late to affect turn order")

    battle(:REVERB,:NONE)
    @foe.spdef*=3
    hit(:ROUND)
    @foe.item=PBItems::NORMALGEM
    hit(:TRICK,@foe,@user)
    equal(PBItems::NORMALGEM,@user.item)
    @user.pbResolveReverbEchoes
    equal(0,@user.item)

    battle(:REVERB,:NONE,user_moves: [:HYPERVOICE],ally: :NONE,foe_ally: :NONE)
    @foe.spdef=@foe_ally.spdef=110
    @user.spatk=50
    @battle.define_singleton_method(:pbRandom) { |max| max-1 }
    hp=[@foe.hp,@foe_ally.hp]
    custom_use_regular(:HYPERVOICE)
    damage=[hp[0]-@foe.hp,hp[1]-@foe_ally.hp]
    assert(damage[0]>0 && damage[0]==damage[1],"Hyper Voice must hit both foes once. HP lost: #{damage.inspect}")
    equal([@foe.index,@foe_ally.index],@user.effects[PBEffects::ReverbEcho][PBMoves::HYPERVOICE])

    @foe.hp=@foe.totalhp
    @foe_ally.hp=@foe_ally.totalhp
    @foe.item=PBItems::FOCUSSASH
    @foe_ally.item=PBItems::FOCUSSASH
    @foe_ally.effects[PBEffects::Embargo]=1
    @user.spatk=1200
    @user.pbResolveReverbEchoes
    equal(1,@foe.hp)
    equal(0,@foe.item)
    equal(0,@foe_ally.hp)
    equal(PBItems::FOCUSSASH,@foe_ally.item)

    battle(:REVERB,:NONE,user_moves: [:HYPERVOICE],outer_ally: :NONE,outer_foe: :NONE)
    @user.spatk=50
    @battle.define_singleton_method(:pbRandom) { |max| max-1 }
    custom_use_regular(:HYPERVOICE)
    equal([@foe.index,@foe_ally.index],@user.effects[PBEffects::ReverbEcho][PBMoves::HYPERVOICE])
    assert(@battle.pbShiftBattlers(@user.index,@outer_ally.index),"failed to shift the echo user")
    before=[@foe.hp,@foe_ally.hp,@outer_foe.hp]
    @user.pbResolveReverbEchoes
    equal(before[0],@foe.hp)
    assert(@foe_ally.hp<before[1],"the echo did not hit the original target still in range")
    equal(before[2],@outer_foe.hp)
  end

  test(:BEACON) do
    battle(:BEACON,:NONE)
    [:POWERGEM,:AURORABEAM].each { |name| custom_compare(name,@user,:BEACON,1.5) }
    custom_compare(:TACKLE,@user,:BEACON,1.0)
  end

  test(:VISIONARY) do
    battle(:VISIONARY,:NONE)
    @user.spatk=@user.attack*2
    with_ability=custom_damage(:TACKLE)
    @user.ability=0
    @user.attack=@user.spatk
    equal(with_ability,custom_damage(:TACKLE))
  end

  test(:HALCYON) do
    battle(:HALCYON,:QUICKDRAW)
    quick=move(:QUICKATTACK,@foe)
    equal(0,@battle.pbMovePriority(@foe,quick,@user,true))
    counter=move(:COUNTER,@foe)
    equal(counter.priority,@battle.pbMovePriority(@foe,counter,@user,false))
    @user.effects[PBEffects::GastroAcid]=true
    equal(2,@battle.pbMovePriority(@foe,quick,@user,true))
    @user.effects[PBEffects::GastroAcid]=false
    unguarded=custom_damage(:QUICKATTACK,@foe,@user)
    @user.pbOwnSide.effects[PBEffects::QuickGuard]=1
    equal(unguarded,custom_damage(:QUICKATTACK,@foe,@user))
    @user.effects[PBEffects::GastroAcid]=true
    assert(custom_damage(:QUICKATTACK,@foe,@user)<unguarded,"Quick Guard must reduce restored priority damage")
  end

  test(:MANAECHOES) do
    battle(:MANAECHOES,:NONE)
    before=@foe.hp
    main_damage=hit(:WATERGUN)
    equal(main_damage+@user.totalhp/8,before-@foe.hp)
    before=@foe.hp
    main_damage=hit(:TACKLE)
    equal(main_damage,before-@foe.hp)
  end

  test(:EXECUTIONER) do
    battle(:EXECUTIONER,:NONE)
    custom_hp(@foe,@foe.totalhp/2)
    custom_compare(:TACKLE,@user,:EXECUTIONER,1.5)
    custom_hp(@foe,@foe.totalhp/2+1)
    custom_compare(:TACKLE,@user,:EXECUTIONER,1.0)
  end

  {ASCETIC: :ABSORB, WATERLOGGED: :WATERGUN, INCENDIARY: :EMBER}.each do |ability,name|
    test(ability) do
      battle(ability,:NONE)
      custom_compare(name,@user,ability,1.5)
      custom_compare(name,@user,ability,0.5,@foe,@user)
    end
  end

  test(:NATURALSHROUD) do
    battle(:NATURALSHROUD,:NONE)
    custom_compare(:TACKLE,@user,:NATURALSHROUD,1.0,@foe,@user)
    @battle.field.effects[PBEffects::GrassyTerrain]=5
    [:TACKLE,:WATERGUN].each { |name| custom_compare(name,@user,:NATURALSHROUD,2.0/3,@foe,@user) }
  end

  test(:INSULATED) do
    battle(:INSULATED,:NONE)
    [:THUNDERBOLT,:ICEBEAM].each { |name| custom_compare(name,@user,:INSULATED,0.5,@foe,@user) }
    custom_compare(:TACKLE,@user,:INSULATED,1.0,@foe,@user)
  end

  test(:EVENTHORIZON) do
    battle(:EVENTHORIZON,:NONE)
    @foe.effects[PBEffects::MagnetRise]=3
    @battle.field.effects[PBEffects::Gravity]=2
    entry
    equal(8,@battle.field.effects[PBEffects::Gravity])
    equal(0,@foe.effects[PBEffects::MagnetRise])
  end

  test(:ABYSSAL) do
    battle(:ABYSSAL,:NONE)
    assert(!@user.pbCanCrush?(false),"the holder should be immune to crushing")
    @battle.field.effects[PBEffects::Gravity]=5
    hit(:TACKLE)
    equal(PBStatuses::CRUSHED,@foe.status)
  end

  test(:PITCHBLACK) do
    battle(:PITCHBLACK,:NONE)
    hit(:BITE,@foe,@user)
    equal(@user.totalhp,@user.hp)
    equal(1,@user.stages[PBStats::DEFENSE])
    equal(1,@user.stages[PBStats::SPDEF])
  end

  test(:BIGBODY) do
    battle(:BIGBODY,:NONE)
    custom_compare(:TACKLE,@user,:BIGBODY,0.5,@foe,@user)
    equal(10,@user.pbAdjustAbilityRecoilCrashDamage(20))
    equal(1,@user.pbAdjustAbilityRecoilCrashDamage(1))
    $fefieldeffect=1
    equal(0,@user.pbAdjustAbilityRecoilCrashDamage(20))
  end

  test(:HASTE) do
    battle(:HASTE,:NONE,user_moves: [:SPLASH],foe_moves: [:SPLASH])
    entry
    equal(2,@user.stages[PBStats::SPEED])
    turn(:SPLASH,:SPLASH)
    equal(1,@user.stages[PBStats::SPEED])
    turn(:SPLASH,:SPLASH)
    equal(0,@user.stages[PBStats::SPEED])
    turn(:SPLASH,:SPLASH)
    equal(0,@user.stages[PBStats::SPEED])

    battle(:HASTE,:NEUTRALIZINGGAS,ally: :DRIZZLE,foe_ally: :NEUTRALIZINGGAS,
      outer_ally: :INTIMIDATE,outer_foe: :NONE)
    @battle.pbOnActiveAll
    equal(0,@battle.pbWeather)
    equal(0,@user.stages[PBStats::SPEED])
    assert(!@foe.abilitynulled,"Gas should not suppress itself")
    assert(@user.abilitynulled,"Gas should suppress Haste immediately")
    @foe.hp=0
    @foe.pbFaint
    equal(0,@user.stages[PBStats::SPEED])
    assert(@foe_ally.hasWorkingAbility(:NEUTRALIZINGGAS),"The other Gas source must stay active")
    assert(!@scene.messages.any? { |message| message.include?("Gas wore off") },
      "Gas should not announce restoration while another source is active")
    @foe_ally.hp=0
    @foe_ally.pbFaint
    assert(!@user.abilitynulled,"The last Gas holder's knockout should restore Haste")
    equal(2,@user.stages[PBStats::SPEED])
    equal(PBWeather::RAINDANCE,@battle.pbWeather)
    equal(-1,@outer_foe.stages[PBStats::ATTACK])
    equal(1,@scene.messages.count { |message| message.include?("Gas wore off") })
    @foe_ally.pbFaint
    equal(1,@scene.messages.count { |message| message.include?("Gas wore off") })

    battle(:HASTE,:NEUTRALIZINGGAS,ally: :NONE,foe_ally: :NONE)
    @battle.pbOnActiveAll
    enemy=@battle.pbParty(@foe.index)
    owner=@battle.pbGetOwner(@foe.index)
    enemy.push(pokemon(:NEUTRALIZINGGAS,owner,[:TACKLE]))
    enemy.push(pokemon(:DUSTDEVIL,owner,[:TACKLE]))
    assert(@battle.pbRegisterSwitch(@foe.index,2),"Couldn't register the replacement Gas holder")
    @battle.pbAttackPhase
    equal(0,@user.stages[PBStats::SPEED])
    assert(@user.abilitynulled,"Replacing one Gas holder with another must not resume abilities")
    assert(@battle.pbRegisterSwitch(@foe.index,3),"Couldn't register Dust Devil")
    @battle.pbAttackPhase
    equal(2,@user.stages[PBStats::SPEED])
    equal(PBWeather::SANDSTORM,@battle.pbWeather)
    equal(1,@scene.messages.count { |message| message.include?("Gas wore off") })
    equal(1,@scene.messages.count { |message| message.include?("Dust Devil whipped up") })

    battle(:HASTE,:NEUTRALIZINGGAS,ally: :NONE,foe_ally: :NONE)
    @battle.pbOnActiveAll
    hit(:GASTROACID,@ally,@foe)
    assert(@foe.abilitynulled,"Gastro Acid should suppress the last Gas holder")
    equal(2,@user.stages[PBStats::SPEED])
    equal(1,@scene.messages.count { |message| message.include?("Gas wore off") })

    battle(:HASTE,:NEUTRALIZINGGAS,ally: :NONE,foe_ally: :NONE,
      outer_ally: :NONE,outer_foe: :NONE)
    @battle.pbOnActiveAll
    @battle.pbParty(@foe.index).push(pokemon(:NEUTRALIZINGGAS,@battle.opponent,[:SPLASH],:KOFFING))
    @foe.hp=0
    @foe.pbFaint
    equal(2,@user.stages[PBStats::SPEED])
    assert(!@battle.pbPriority(true,true).include?(@foe),"The turn order should omit the KO'd lane")
    @battle.pbSwitch
    equal(PBSpecies::KOFFING,@foe.species)
    assert(@user.abilitynulled,"The replacing Gas holder should suppress Haste again")
    equal(2,@scene.messages.count { |message| message.include?("Neutralizing Gas fills the area") })

    battle(:HASTE,:NEUTRALIZINGGAS,ally: :NONE,foe_ally: :NONE,
      outer_ally: :NONE,outer_foe: :NONE)
    @foe.item=PBItems::LEFTOVERS
    @foe.stages[PBStats::DEFENSE]=2
    @battle.pbOnActiveAll
    assert(hit(:BINDINGWORD,@ally,@foe)>0,"Binding Word did not hit")
    assert(@foe.abilitynulled,"Binding Word should suppress the last Gas holder")
    assert(!@foe.hasWorkingItem(:LEFTOVERS),"Binding Word should suppress the holder's item")
    equal(0,@foe.stages[PBStats::DEFENSE])
    equal(2,@user.stages[PBStats::SPEED])
    assert(@battle.pbShiftBattlers(@ally.index,@outer_ally.index),"The binding source could not shift")
    equal(@ally.index,@foe.effects[PBEffects::MultiTurnUser])
    assert(@foe.abilitynulled,"Shifting the binding source should keep Gas suppressed")
    @ally.hp=0
    @ally.pbFaint
    assert(@foe.hasWorkingAbility(:NEUTRALIZINGGAS),"The binding source fainting should restore Gas")
    assert(@foe.hasWorkingItem(:LEFTOVERS),"The binding source fainting should restore the holder's item")
    assert(@user.abilitynulled,"Restored Gas should suppress Haste immediately")
    equal(2,@foe.stages[PBStats::DEFENSE])

    battle(:HASTE,:NEUTRALIZINGGAS,ally: :NONE,foe_ally: :NONE)
    @foe.item=PBItems::LEFTOVERS
    @foe.stages[PBStats::DEFENSE]=-1
    @battle.pbOnActiveAll
    hit(:BINDINGWORD,@ally,@foe)
    @foe.effects[PBEffects::MultiTurn]=1
    round
    assert(@foe.hasWorkingAbility(:NEUTRALIZINGGAS),"Binding Word expiring should restore Gas")
    assert(@foe.hasWorkingItem(:LEFTOVERS),"Binding Word expiring should restore the holder's item")
    assert(@user.abilitynulled,"Restored Gas should suppress Haste immediately")
    equal(-1,@foe.stages[PBStats::DEFENSE])

    battle(:HASTE,:NEUTRALIZINGGAS,ally: :NONE,foe_ally: :NONE)
    @battle.pbOnActiveAll
    hit(:BINDINGWORD,@ally,@foe)
    party=@battle.pbParty(@ally.index)
    party.push(pokemon(:NONE,@battle.pbGetOwner(@ally.index),[:SPLASH]))
    assert(@battle.pbRegisterSwitch(@ally.index,2),"The binding source could not switch")
    @battle.pbAttackPhase
    assert(@foe.hasWorkingAbility(:NEUTRALIZINGGAS),"The binding source switching should restore Gas")
    assert(@user.abilitynulled,"Gas should suppress abilities during the switch phase")

    battle(:HASTE,:NONE,ally: :NONE,foe_ally: :NONE,
      outer_ally: :NONE,outer_foe: :MAGICGUARD)
    @user.item=PBItems::BINDINGBAND
    assert(hit(:BINDINGWORD,@user,@foe)>0,"Banded Binding Word missed")
    assert(hit(:BINDINGWORD,@ally,@foe_ally)>0,"Unbanded Binding Word missed")
    @outer_foe.effects[PBEffects::MultiTurn]=1
    @outer_foe.effects[PBEffects::MultiTurnAttack]=PBMoves::FIRESPIN
    @outer_foe.effects[PBEffects::MultiTurnUser]=@outer_ally.index
    banded_hp=@foe.hp
    unbanded_hp=@foe_ally.hp
    guarded_hp=@outer_foe.hp
    round
    equal(banded_hp-@foe.totalhp/6,@foe.hp)
    equal(unbanded_hp-@foe_ally.totalhp/8,@foe_ally.hp)
    equal(guarded_hp,@outer_foe.hp)
    equal(0,@outer_foe.effects[PBEffects::MultiTurn])
    equal(0,@outer_foe.effects[PBEffects::MultiTurnAttack])

    @foe_ally.effects[PBEffects::MultiTurn]=1
    @foe_ally.speed=@foe.speed+50
    banded_hp=@foe.hp
    round
    equal(0,@foe_ally.effects[PBEffects::MultiTurn])
    equal(banded_hp-@foe.totalhp/6,@foe.hp)

    battle(:HASTE,:NEUTRALIZINGGAS,ally: :NONE,foe_ally: :NONE)
    @foe.item=PBItems::LEFTOVERS
    @foe.stages[PBStats::DEFENSE]=2
    @battle.pbOnActiveAll
    hit(:BINDINGWORD,@ally,@foe)
    @foe.shieldCount=1
    @foe.shieldsBroken=[]
    @battle.pbShieldEffects(@foe,{:effectClear=>true})
    assert(@foe.hasWorkingAbility(:NEUTRALIZINGGAS),"Shield effect clearing should restore Gas")
    assert(@foe.hasWorkingItem(:LEFTOVERS),"Shield effect clearing should restore the holder's item")
    assert(@user.abilitynulled,"Gas restored by shield effect clearing should suppress Haste")
    equal(2,@foe.stages[PBStats::DEFENSE])
  end

  test(:LIMINAL) do
    battle(:LIMINAL,:NONE,user_moves: [:SPLASH,:TACKLE])
    custom_use_regular(:SPLASH)
    assert(@user.effects[PBEffects::LiminalAttackBoost],"using a status move did not queue the attack boost")
    baseline=custom_damage(:TACKLE)
    before=@foe.hp
    srand(14142)
    custom_use_regular(:TACKLE)
    assert(before-@foe.hp>baseline,"the queued boost did not apply")
    equal(1,@battle.pbMovePriority(@user,move(:SPLASH),@user))
    custom_use_regular(:SPLASH)
    equal(0,@battle.pbMovePriority(@user,move(:SPLASH),@user))
  end

  test(:SERAPHIC) do
    battle(:SERAPHIC,:NONE)
    custom_compare(:TACKLE,@user,:SERAPHIC,0.7,@foe,@user)
    hit=move(:TACKLE,@foe)
    hit.basedamage=100
    srand(14142)
    shielded=hit.pbCalcDamage(@foe,@user,PokeBattle_Move::NOCRITICAL)
    @user.ability=0
    srand(14142)
    equal(shielded,hit.pbCalcDamage(@foe,@user,PokeBattle_Move::NOCRITICAL))
  end

  test(:HYPNOTIC) do
    battle(:HYPNOTIC,:NONE,ally: :NONE,foe_ally: :NONE)
    entry
    [@foe,@foe_ally].each do |target|
      assert(target.effects[PBEffects::Confusion]>0,"entry did not confuse target #{target.index}")
      equal(@user.index,target.effects[PBEffects::Attract])
    end
    equal(-1,@ally.effects[PBEffects::Attract])
  end

  test(:STONYSPIRIT) do
    battle(:STONYSPIRIT,:NONE,ally: :NONE)
    custom_compare(:ROCKTHROW,@user,:STONYSPIRIT,1.5)
    custom_compare(:ROCKTHROW,@user,:STONYSPIRIT,1.5,@ally)
    custom_compare(:TACKLE,@user,:STONYSPIRIT,1.0,@ally)
  end

  test(:WARPOET) do
    battle(:WARPOET,:NONE)
    @user.attack=@user.spatk*2
    unboosted=custom_damage(:HYPERVOICE)
    @user.ability=0
    assert(unboosted>custom_damage(:HYPERVOICE),"sound attack did not use the higher Attack stat")
    @user.ability=PBAbilities::WARPOET
    @user.stages[PBStats::ATTACK]=1
    attack_stage=custom_damage(:HYPERVOICE)
    @user.stages[PBStats::SPATK]=1
    assert(attack_stage>unboosted && custom_damage(:HYPERVOICE)>attack_stage,"both offensive stages must apply")
  end

  test(:AFTERLIFE) do
    battle(:AFTERLIFE,:NONE)
    @foe.attack*=12
    hit(:TACKLE,@foe,@user)
    assert(@user.isFainted?,"full-HP holder must be knocked out for this case")
    equal(-1,@foe.stages[PBStats::DEFENSE])
    equal(-1,@foe.stages[PBStats::SPDEF])
    battle(:AFTERLIFE,:NONE)
    custom_hp(@user,1)
    hit(:TACKLE,@foe,@user)
    equal(PBStatuses::PARALYSIS,@foe.status)
    equal(0,@foe.stages[PBStats::DEFENSE])
  end

  test(:KEYHOLDER) do
    battle(:KEYHOLDER,:NONE,user_moves: [:TACKLE],foe_moves: [:TACKLE,:WATERGUN])
    entry
    assert(@user.effects[PBEffects::Imprison],"entry did not set Imprison")
    assert(!@battle.pbCanChooseMove?(@foe.index,0,false),"shared move remained usable")
    assert(@battle.pbCanChooseMove?(@foe.index,1,false),"unshared move became unusable")
  end

  test(:TIMETWISTER) do
    battle(:TIMETWISTER,:NONE)
    original_hp=@user.hp
    @battle.pbAttackPhase
    custom_hp(@user,@user.totalhp/3)
    @user.status=PBStatuses::BURN
    @user.stages[PBStats::DEFENSE]=-1
    round
    equal(original_hp,@user.hp)
    equal(0,@user.status)
    equal(0,@user.stages[PBStats::DEFENSE])
  end

  test(:DIVINEWINDS) { custom_convert(:DIVINEWINDS,:GUST,PBTypes::DRAGON) }

  test(:DEEPFREEZE) do
    battle(:DEEPFREEZE,:NONE)
    equal(-1,@battle.pbMovePriority(@foe,move(:QUICKATTACK,@foe),@user))
    equal(0,@battle.pbMovePriority(@foe,move(:WATERGUN,@foe),@user))
  end

  test(:HARVESTMOON) do
    battle(:HARVESTMOON,:NONE)
    entry
    assert(@battle.field.effects[PBEffects::GrassyTerrain]>0,"Harvest Moon did not establish Grassy Terrain")
    custom_compare(:TACKLE,@user,:HARVESTMOON,1.5)
    custom_compare(:WATERGUN,@user,:HARVESTMOON,1.0)
  end

  test(:DUSTDEVIL) do
    battle(:DUSTDEVIL,:NONE)
    entry
    equal(PBWeather::SANDSTORM,@battle.weather)
    custom_compare(:WATERGUN,@user,:DUSTDEVIL,1.5)
    custom_compare(:TACKLE,@user,:DUSTDEVIL,1.0)
    battle(:DUSTDEVIL,:NONE)
    @user.item=PBItems::SMOOTHROCK
    @user.effects[PBEffects::FriskLock]=1
    entry
    equal(5,@battle.weatherduration)
    battle(:DUSTDEVIL,:NONE)
    @user.item=PBItems::SMOOTHROCK
    entry
    equal(8,@battle.weatherduration)
  end
end
