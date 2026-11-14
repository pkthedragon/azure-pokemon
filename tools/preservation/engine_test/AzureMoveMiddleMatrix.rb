module AzureMoveMiddleMatrix
  module Helpers
    def middle_choice(mon,move_name,target=mon)
      slot=mon.moves.index { |candidate| candidate.id==PBMoves.const_get(move_name) }
      assert(slot && @battle.pbRegisterMove(mon.index,slot,false),"Could not queue #{move_name}")
      @battle.pbRegisterTarget(mon.index,target.index)
    end

    def middle_stats(mon,stats)
      stats.each { |stat,value| equal(value,mon.stages[PBStats.const_get(stat)]) }
    end

    def middle_effect(move_name,user=@user,target=@foe)
      attack=move(move_name,user)
      @battle.lastMoveUsed=attack.id
      @battle.lastMoveUser=user.index
      @battle.pbWithStatChangeSource([:move,attack.id]) do
        attack.pbAdditionalEffect(user,target)
      end
    end

    def middle_damage(attack,user=@user,target=@foe)
      attack.pbCalcDamage(user,target,PokeBattle_Move::NOCRITICAL | PokeBattle_Move::NOWEIGHTING)
    end
  end

  def self.register(suite)
    AzureAbilityFixture::Scenario.include(Helpers)
    suite.test(:PAYDAY) do
      battle(:NOGUARD,:NONE)
      hit(:PAYDAY)
      assert(@foe.hp<@foe.totalhp && @foe.hp>0,"Pay Day should damage a healthy opponent")
      middle_stats(@user,SPATK: 0)
      @foe.hp=1
      hit(:PAYDAY)
      assert(@foe.isFainted?,"Pay Day must knock out the weakened opponent")
      middle_stats(@user,SPATK: 3)
    end

    suite.test(:LASTRESPECTS) do
      battle(:NOGUARD,:NONE,user_moves: [:LASTRESPECTS])
      attack=@user.moves.first
      assert(!attack.pbOnStartUse(@user),"Last Respects requires a fainted teammate")
      equal(0,@battle.pbBetterBaseDamage(attack,@user,@foe,100,attack.basedamage))
      [:PIKACHU,:MACHAMP].each do |species|
        pokemon_member=pokemon(:NONE,@battle.player,[:TACKLE],species)
        pokemon_member.hp=0
        @battle.player.party.push(pokemon_member)
      end
      assert(attack.pbOnStartUse(@user),"Fainted teammates should participate")
      equal(2,attack.pbNumHits(@user))
      expected=20+@battle.player.party[1].baseStats[PBStats::ATTACK]/10
      expected_second=20+@battle.player.party[2].baseStats[PBStats::ATTACK]/10
      equal(expected+expected_second,@battle.pbBetterBaseDamage(attack,@user,@foe,100,attack.basedamage))
      equal(expected,attack.pbBaseDamage(1,@user,@foe))
      equal(expected,attack.pbBaseDamage(1,@user,@foe))
      @foe.type1=@foe.type2=PBTypes::FIRE
      @foe.hp=@foe.totalhp
      middle_choice(@user,:LASTRESPECTS,@foe)
      @battle.pbAttackPhase
      assert(@scene.messages.any? { |message| message.include?("Hit 2 times") },"Last Respects should resolve both hits")
    end

    suite.test(:DIRECLAW) do
      battle(:NOGUARD,:NONE,foe_species: :SLOWBRO)
      attack=move(:DIRECLAW)
      assert(attack.hasHighCriticalRate?,"Dire Claw must retain its high critical-hit rate")
      equal(30,attack.addlEffect)
      outcomes=[]
      30.times do
        @foe.status=0
        @foe.statusCount=0
        middle_effect(:DIRECLAW)
        outcomes.push(@foe.status)
      end
      equal([PBStatuses::BURN,PBStatuses::PARALYSIS,PBStatuses::POISON].sort,outcomes.uniq.sort)
    end

    suite.test(:ROLLINGKICK) do
      battle(:NONE,:NONE,foe_species: :PIDGEY)
      rolling=move(:ROLLINGKICK)
      equal("Rolling Thunder",rolling.name)
      normal=rolling.pbTypeModifier(PBTypes::FIGHTING,@user,@foe)
      @battle.weather=PBWeather::RAINDANCE
      equal(normal,rolling.pbTypeModifier(PBTypes::FIGHTING,@user,@foe))
      @battle.field.effects[PBEffects::HeavyRain]=true
      equal(8,rolling.pbTypeModifier(PBTypes::FIGHTING,@user,@foe))
      middle_effect(:ROLLINGKICK)
      equal(PBStatuses::PARALYSIS,@foe.status)
    end

    { SPLASH: PBTypes::WATER, SANDATTACK: PBTypes::GROUND }.each do |move_name,type|
      suite.test(move_name) do
        battle(:NOGUARD,:NONE,user_moves: [move_name],ally: :NONE,outer_ally: :NONE,foe_ally: :NONE,outer_foe: :NONE)
        equal(type,@user.moves.first.type)
        equal(5,@battle.pbStatusDamage(@user.moves.first))
        @battle.eachActiveBattlerIndex do |index|
          battler=@battle.battlers[index]
          next if battler==@user
          middle_choice(battler,:TACKLE,@user)
        end
        middle_choice(@user,move_name)
        @battle.pbAttackPhase
        middle_stats(@user,ACCURACY: 0)
        [@foe,@ally,@foe_ally,@outer_ally,@outer_foe].each { |battler| middle_stats(battler,ACCURACY: -1) }
      end
    end

    suite.test(:SHARPEN) do
      battle(:NONE,:NONE)
      hit(:SHARPEN,@user,@user)
      middle_stats(@user,ATTACK: 1)
      equal(1,@user.effects[PBEffects::FocusEnergy])
    end

    suite.test(:FOCUSENERGY) do
      battle(:NONE,:NONE,user_moves: [:FOCUSENERGY,:TACKLE],foe_moves: [:TACKLE])
      hit(:FOCUSENERGY,@user,@user)
      equal(2,@user.effects[PBEffects::FocusEnergy])
      assert(!@user.effects[PBEffects::Endure],"Focus Energy does not grant Endure")
      @battle.instance_variable_set(:@turncount,1)
      @user.effects[PBEffects::Flinch]=true
      @user.status=PBStatuses::SLEEP
      @user.statusCount=3
      turn(:TACKLE,:TACKLE)
      assert(@foe.hp<@foe.totalhp,"Focus Energy must prevent next-turn immobilization")
      prior=@foe.hp
      @user.effects[PBEffects::Flinch]=true
      turn(:TACKLE,:TACKLE)
      equal(prior,@foe.hp)
    end

    suite.test(:MEDITATE) do
      battle(:NONE,:NONE)
      hit(:MEDITATE,@user,@user)
      middle_stats(@user,ATTACK: 1,SPDEF: 1,DEFENSE: 0)
    end

    suite.test(:TELEKINESIS) do
      battle(:NOGUARD,:INTIMIDATE)
      @foe.effects[PBEffects::Confusion]=3
      hit(:TELEKINESIS)
      equal(0,@foe.effects[PBEffects::Confusion])
      middle_stats(@user,ATTACK: -1)
      assert(@scene.messages.any? { |message| message.include?("telekinetically blinked") },"Telekinesis must blink")
      @foe.effects[PBEffects::Ingrain]=true
      @foe.effects[PBEffects::Confusion]=3
      hit(:TELEKINESIS)
      equal(3,@foe.effects[PBEffects::Confusion])
    end

    suite.test(:TAILWHIP) do
      battle(:NONE,:BIGPECKS,ally: :NONE,foe_ally: :NONE)
      hit(:TAILWHIP)
      middle_stats(@foe,DEFENSE: 0,SPDEF: -1)
      hit(:TAILWHIP,@user,@foe_ally)
      middle_stats(@foe_ally,DEFENSE: -1,SPDEF: -1)
    end

    suite.test(:GROWL) do
      battle(:NONE,:HYPERCUTTER,ally: :NONE,foe_ally: :CLEARBODY)
      hit(:GROWL)
      middle_stats(@foe,ATTACK: 0,SPATK: -1)
      hit(:GROWL,@user,@foe_ally)
      middle_stats(@foe_ally,ATTACK: 0,SPATK: 0)
      @foe_ally.pbSuppressAbility
      hit(:GROWL,@user,@foe_ally)
      middle_stats(@foe_ally,ATTACK: -1,SPATK: -1)
    end

    suite.test(:LEER) do
      battle(:NONE,:NONE)
      @foe.hp-=20
      @foe.item=PBItems::LEFTOVERS
      hit(:LEER)
      middle_stats(@foe,SPEED: -1,DEFENSE: 0)
      equal(3,@foe.effects[PBEffects::LeerBlock])
      hp=@foe.hp
      @foe.pbBerryCureCheck(true)
      equal(hp,@foe.hp)
    end

    suite.test(:DEFENSECURL) do
      battle(:NOGUARD,:NONE,user_moves: [:DEFENSECURL,:STEAMROLLER,:TACKLE])
      hit(:DEFENSECURL,@user,@user)
      middle_stats(@user,DEFENSE: 1)
      middle_choice(@user,:TACKLE,@foe)
      @battle.pbAttackPhase
      assert(@user.effects[PBEffects::DefenseCurl],"An ordinary move should preserve Defense Curl")
      @battle.instance_variable_set(:@turncount,1)
      middle_choice(@user,:STEAMROLLER,@foe)
      @foe.hp=@foe.totalhp
      @battle.pbAttackPhase
      first=@foe.damagestate.hplost
      assert(!@user.effects[PBEffects::DefenseCurl],"Momentum should expend Defense Curl")
      @battle.instance_variable_set(:@turncount,2)
      middle_choice(@user,:STEAMROLLER,@foe)
      @foe.hp=@foe.totalhp
      @battle.pbAttackPhase
      assert(first>@foe.damagestate.hplost,"Curl should strengthen the first Momentum attack")
    end

    suite.test(:HARDEN) do
      battle(:NONE,:NONE)
      hit(:HARDEN,@user,@user)
      middle_stats(@user,DEFENSE: 1)
      @battle.instance_variable_set(:@turncount,1)
      assert(!move(:FROSTBREATH,@foe).pbIsCritical?(@foe,@user),"Harden must prevent guaranteed crits next turn")
      @battle.instance_variable_set(:@turncount,2)
      assert(move(:FROSTBREATH,@foe).pbIsCritical?(@foe,@user),"Harden should expire")
    end

    suite.test(:WITHDRAW) do
      battle(:NONE,:NONE)
      equal(1,@battle.pbMovePriority(@user,move(:WITHDRAW)))
      hit(:WITHDRAW,@user,@user)
      middle_stats(@user,DEFENSE: 1)
      @battle.instance_variable_set(:@turncount,1)
      assert(move(:FROSTBREATH,@foe).pbIsCritical?(@foe,@user),"Withdraw must not grant Harden's effect")
    end

    suite.test(:FAKETEARS) do
      battle(:NONE,:NONE)
      hit(:FAKETEARS)
      middle_stats(@foe,SPATK: -1,SPDEF: -1,DEFENSE: 0)
    end

    suite.test(:HOWL) do
      battle(:NONE,:NONE,user_moves: [:HOWL],ally: :NONE,foe_ally: :NONE)
      @ally.moves[0]=move(:HOWL,@ally)
      @user.speed=200
      @ally.speed=50
      @foe.speed=100
      middle_choice(@user,:HOWL)
      middle_choice(@ally,:HOWL)
      middle_choice(@foe,:TACKLE,@user)
      @battle.pbAttackPhase
      middle_stats(@user,ATTACK: 1)
      middle_stats(@ally,ATTACK: 3)
      chain=@scene.messages.index { |message| message.include?("pack howled together") }
      foe_turn=@scene.messages.index { |message| message.include?("Tackle") }
      assert(chain && foe_turn && chain<foe_turn,"Allied Howl must chain before the faster opponent")
    end

    suite.test(:CAPTIVATE) do
      battle(:NONE,:NONE)
      hit(:CAPTIVATE)
      middle_stats(@foe,SPATK: -2)
    end

    suite.test(:FLASH) do
      battle(:NONE,:NONE)
      hit(:FLASH)
      middle_stats(@user,ACCURACY: 1)
      equal(1,@foe.effects[PBEffects::Blinded])
    end

    suite.test(:SMOKESCREEN) do
      battle(:NONE,:NONE)
      equal(PBTypes::FIRE,move(:SMOKESCREEN).type)
      hit(:SMOKESCREEN)
      middle_stats(@foe,ACCURACY: -2)
    end

    suite.test(:LOCKON) do
      battle(:NONE,:NONE,user_moves: [:LOCKON,:TACKLE],foe_moves: [:TACKLE],ally: :NONE,foe_ally: :NONE)
      hit(:LOCKON)
      assert(@user.effects[PBEffects::LockOnMove],"Lock-On should charge the user's next move")
      middle_choice(@user,:TACKLE,@foe_ally)
      @battle.pbAttackPhase
      assert(@foe_ally.damagestate.critical,"Lock-On must guarantee a critical hit against a different target")
      assert(!@user.effects[PBEffects::LockOnMove],"Lock-On must be consumed")
    end

    suite.test(:MINIMIZE) do
      battle(:NONE,:NONE)
      hit(:MINIMIZE,@user,@foe)
      middle_stats(@foe,DEFENSE: -1,SPDEF: -1)
      hit(:MINIMIZE,@user,@user)
      middle_stats(@user,EVASION: 2)
      targets=[]
      @user.pbFindUser([1,0,move(:MINIMIZE),@user.index],targets)
      equal([@user],targets)
    end

    suite.test(:BURNUP) do
      battle(:NONE,:NONE,user_species: :CHARIZARD)
      hit(:BURNUP)
      assert(!@user.pbHasType?(:FIRE) && @user.pbHasType?(:FLYING),"Burn Up must remove only Fire")
      @battle.instance_variable_set(:@turncount,1)
      assert(!@user.pbHasType?(:FIRE),"Burn Up must persist through the next turn")
      round
      assert(@user.pbHasType?(:FIRE),"Burn Up must expire")
    end

    suite.test(:RAGE) do
      battle(:NONE,:NONE,user_moves: [:RAGE,:RETURN,:TACKLE],foe_moves: [:TACKLE])
      equal(3,@battle.pbMovePriority(@user,@user.moves.first))
      turn(:RAGE,:TACKLE)
      middle_stats(@user,ATTACK: 1,SPATK: 1)
      assert(@user.effects[PBEffects::FeverPitchBoost],"Fever Pitch must ready a boost")
      turn(:TACKLE,:TACKLE)
      assert(@user.effects[PBEffects::FeverPitchBoost],"A fixed-power move should not expend Fever Pitch")
      turn(:RETURN,:TACKLE)
      assert(!@user.effects[PBEffects::FeverPitchBoost],"The next eligible move must expend Fever Pitch")
    end

    suite.test(:CAMOUFLAGE) do
      battle(:NONE,:NONE,user_species: :CHARIZARD,user_moves: [:CAMOUFLAGE,:TACKLE,:EMBER])
      $fefieldeffect=1
      hit(:CAMOUFLAGE,@user,@user)
      equal(PBTypes::ELECTRIC,@user.type1)
      equal(PBTypes::FLYING,@user.type2)
      equal(PBTypes::ELECTRIC,@user.moves[1].type)
      equal(PBTypes::FIRE,@user.moves[2].type)
    end

    suite.test(:EGGBOMB) do
      battle(:GRENADIER,:NONE,ally: :NONE,foe_ally: :NONE)
      @ally.hp=1
      amount=@ally.totalhp*3/4
      hit(:EGGBOMB,@user,@ally)
      equal(1+amount,@ally.hp)
      assert(hit(:EGGBOMB)>0,"Egg Bomb must damage an opponent")
      assert(!@foe.effects[PBEffects::Foresight],"Egg Bomb must not identify a target")
      battle(:NOGUARD,:NONE,ally: :NONE,foe_ally: :NONE)
      @ally.hp=1
      hit(:EGGBOMB,@user,@ally)
      equal(1+@ally.totalhp/2,@ally.hp)
    end

    { BONECLUB: [:ATTACK,20], OCTAZOOKA: [:ACCURACY,50], IRONTAIL: [:DEFENSE,30],
      GLACIATE: [:SPEED,100] }.each do |move_name,(stat,chance)|
      suite.test(move_name) do
        battle(:NONE,:NONE)
        attack=move(move_name)
        equal(chance,attack.addlEffect)
        middle_effect(move_name)
        middle_stats(@foe,stat=>-1)
        assert(attack.hasHighCriticalRate?,"Octazooka must retain high critical-hit rate") if move_name==:OCTAZOOKA
        if move_name==:BONECLUB
          assert(attack.id!=PBMoves::SPIKECANNON,"Bone Club and Spike Cannon must be separate moves")
          cubone=pokemon(:NONE,@battle.player,[:TACKLE],:CUBONE)
          marowak=pokemon(:NONE,@battle.player,[:TACKLE],:MAROWAK)
          assert(cubone.getMoveList.include?([7,attack.id]),"Cubone must learn Bone Club at level 7")
          assert(marowak.getMoveList.include?([1,attack.id]),"Marowak must be able to relearn Bone Club")
        end
      end
    end

    [:MAGNETBOMB,:VITALTHROW].each do |move_name|
      suite.test(move_name) do
        battle(:NONE,:NONE)
        attack=move(move_name)
        equal(-1,@battle.pbMovePriority(@user,attack))
        @user.stages[PBStats::ACCURACY]=-6
        @foe.stages[PBStats::EVASION]=6
        20.times { assert(attack.pbAccuracyCheck(@user,@foe),"#{move_name} cannot miss") }
      end
    end

    suite.test(:FLATTER) do
      battle(:NOGUARD,:NONE)
      equal(100,move(:FLATTER).accuracy)
      hit(:FLATTER)
      middle_stats(@foe,SPATK: 2)
      assert(@foe.effects[PBEffects::Confusion]>0,"Flatter still confuses")
    end

    suite.test(:SMELLINGSALTS) do
      battle(:NONE,:NONE)
      attack=move(:SMELLINGSALTS)
      @foe.status=PBStatuses::PARALYSIS
      equal(attack.basedamage*2,attack.pbBaseDamage(attack.basedamage,@user,@foe))
      hit(:SMELLINGSALTS)
      equal(0,@foe.status)
      @foe.status=PBStatuses::BURN
      equal(attack.basedamage,attack.pbBaseDamage(attack.basedamage,@user,@foe))
    end

    suite.test(:AQUATAIL) do
      battle(:NOGUARD,:NONE)
      attack=move(:AQUATAIL)
      assert(PBStuff::BLUDGEONINGMOVE.include?(attack.id),"Aqua Tail must be Bludgeoning")
      assert(hit(:AQUATAIL)>0,"Aqua Tail still deals damage")
      middle_stats(@foe,DEFENSE: 0)
    end

    suite.test(:WIDEGUARD) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE)
      surf=move(:SURF,@foe)
      tackle=move(:TACKLE,@foe)
      unguarded=middle_damage(surf,@foe,@user)
      normal=middle_damage(tackle,@foe,@user)
      hit(:WIDEGUARD,@user,@user)
      equal(5,@user.pbOwnSide.effects[PBEffects::WideGuard])
      guarded=middle_damage(surf,@foe,@user)
      assert((unguarded-guarded*2).abs<=1,"Wide Guard should halve spread damage")
      equal(normal,middle_damage(tackle,@foe,@user))
    end

    suite.test(:QUICKGUARD) do
      battle(:NONE,:NONE)
      quick=move(:QUICKATTACK,@foe)
      tackle=move(:TACKLE,@foe)
      unguarded=middle_damage(quick,@foe,@user)
      normal=middle_damage(tackle,@foe,@user)
      hit(:QUICKGUARD,@user,@user)
      equal(5,@user.pbOwnSide.effects[PBEffects::QuickGuard])
      guarded=middle_damage(quick,@foe,@user)
      assert((unguarded-guarded*2).abs<=1,"Quick Guard should halve priority damage")
      equal(normal,middle_damage(tackle,@foe,@user))
    end

    suite.test(:NIGHTMARE) do
      battle(:NONE,:NONE,user_moves: [:NIGHTMARE],foe_moves: [:HYPNOSIS])
      hit(:NIGHTMARE,@user,@user)
      assert(@user.effects[PBEffects::NightmareAura],"Nightmare must establish an aura")
      @foe.status=PBStatuses::SLEEP
      @foe.statusCount=2
      hp=@foe.hp
      round
      equal(hp-@foe.totalhp/8,@foe.hp)
      @user.hp=0
      @user.pbFaint
      hp=@foe.hp
      round
      equal(hp,@foe.hp)
    end

    suite.test(:PRESENT) do
      battle(:NONE,:NONE)
      4.times { hit(:PRESENT,@user,@user) }
      equal(3,@user.pbOwnSide.effects[PBEffects::Presents])
      equal(0,@foe.pbOwnSide.effects[PBEffects::Presents])
      @user.hp=1
      @battle.pbOnActiveOne(@user)
      equal(@user.totalhp,@user.hp)
      equal(0,@user.pbOwnSide.effects[PBEffects::Presents])
    end

    suite.test(:DARKVOID) do
      battle(:NOGUARD,:NONE,user_species: :DARKRAI,ally: :NONE,foe_ally: :NONE)
      attack=move(:DARKVOID)
      equal(100,attack.accuracy)
      equal(-1,attack.priority)
      equal(PBTargets::AllOpposing,@user.pbTarget(attack))
      assert(attack.pbOnStartUse(@user),"Darkrai can use Dark Void")
      assert(!attack.pbOnStartUse(@ally),"Unlisted species cannot use Dark Void")
      hit(:DARKVOID)
      equal(PBStatuses::SLEEP,@foe.status)
    end

    suite.test(:HEARTSTAMP) do
      battle(:NOGUARD,:NONE)
      attack=move(:HEARTSTAMP)
      @user.attack=200
      @user.spatk=100
      equal([200,0],attack.pbHigherOffensiveStat(@user))
      @user.stages[PBStats::SPATK]=4
      equal([100,4],attack.pbHigherOffensiveStat(@user))
      assert(attack.pbIsSpecial?(attack.type),"Heart Stamp remains special even when using Attack")
      @user.gender=0
      @foe.gender=1
      middle_effect(:HEARTSTAMP)
      equal(@user.index,@foe.effects[PBEffects::Attract])
      equal(3,@foe.effects[PBEffects::AttractTurns])
    end

    suite.test(:SUCKERPUNCH) do
      battle(:NOGUARD,:NONE,user_moves: [:SUCKERPUNCH],foe_moves: [:TAILWHIP])
      attack=@user.moves.first
      equal(1,attack.priority)
      assert(attack.isPunchingMove? || PBStuff::PUNCHINGMOVE.include?(attack.id),"Sucker Punch is a punching move")
      turn(:SUCKERPUNCH,:TAILWHIP)
      assert(@foe.hp<@foe.totalhp,"Sucker Punch must work against a status-move user")
    end
  end
end
