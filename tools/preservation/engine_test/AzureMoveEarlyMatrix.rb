module AzureMoveEarlyMatrix
  TAGS={
    piercing: PBStuff::PIERCINGMOVE, slashing: PBStuff::SLASHINGMOVE,
    bomb: PBStuff::BOMBMOVE, cannon: PBStuff::CANNONMOVE,
    kicking: PBStuff::KICKINGMOVE, bludgeon: PBStuff::BLUDGEONINGMOVE,
    wind: PBStuff::WINDMOVE
  }.freeze

  module Checks
    def early_setup(name,ability=:NOGUARD,target_ability=:NONE,foe_species: :CHANSEY,**options)
      battle(ability,target_ability,user_moves: [name],foe_moves: [:CELEBRATE],
        foe_species: foe_species,**options)
    end

    def early_roll(value)
      @battle.define_singleton_method(:pbRandom) { |limit| value % limit }
    end

    def early_data(name,type,category,power,accuracy,*tags)
      attack=move(name)
      equal(PBTypes.const_get(type),attack.type)
      equal(power,attack.basedamage)
      equal(accuracy,attack.accuracy)
      equal(2,PBMoveData.new(attack.id).category) if category==:status
      assert(attack.pbIsPhysical?(attack.type),"Expected physical #{name}") if category==:physical
      assert(attack.pbIsSpecial?(attack.type),"Expected special #{name}") if category==:special
      tags.each do |tag|
        flagged=case tag
        when :sound then attack.isSoundBased?
        when :contact then attack.isContactMove?
        when :punching then attack.isPunchingMove?
        when :high_crit then attack.hasHighCriticalRate?
        else TAGS.fetch(tag).include?(attack.id)
        end
        assert(flagged,"#{name} is missing #{tag}")
      end
      return attack
    end

    def early_hit(name)
      assert(hit(name)>0,"#{name} did not damage the target")
    end

    def early_use(name,target=@foe)
      move_id=PBMoves.const_get(name)
      index=@user.moves.index { |attack| attack.id==move_id }
      assert(index,"#{name} not found in party")
      assert(@battle.pbRegisterMove(@user.index,index,false),"Could not select #{name}")
      @battle.pbRegisterTarget(@user.index,target.index)
      @battle.pbAttackPhase
    end

    def early_stat_effect(stat,stage)
      equal(stage,@foe.stages[stat])
    end
  end

  def self.test(suite,name,&check)
    suite.test(name) do
      extend Checks
      instance_exec(&check)
    end
  end

  def self.register(suite)
    late_hit_group={
      SHEERCOLD: [:ICE,:special,[],PBStatuses::FROZEN],
      FISSURE: [:GROUND,:physical,[],PBEffects::MeanLook],
      HORNDRILL: [:ROCK,:physical,[:piercing],PBStatuses::CRUSHED],
      GUILLOTINE: [:DARK,:physical,[:slashing],PBEffects::ThroatChop],
      INFERNO: [:FIRE,:special,[],PBStatuses::BURN],
      ZAPCANNON: [:ELECTRIC,:special,[:bomb,:cannon],PBStatuses::PARALYSIS],
      DYNAMICPUNCH: [:FIGHTING,:physical,[:punching],PBEffects::Confusion]
    }
    late_hit_group.each do |name,(type,category,tags,effect)|
      test(suite,name) do
        early_setup(name,:NONE,foe_species: :SNORLAX)
        attack=early_data(name,type,category,120,50,*tags)
        early_roll(99)
        @user.level=59
        equal(false,attack.pbAccuracyCheck(@user,@foe))
        @user.level=60
        equal(true,attack.pbAccuracyCheck(@user,@foe))
        @user.level=50
        early_roll(0)
        equal(true,attack.pbAccuracyCheck(@user,@foe))
        early_hit(name)
        case name
        when :FISSURE
          equal(@user.index,@foe.effects[effect])
        when :GUILLOTINE,:DYNAMICPUNCH
          equal(3,@foe.effects[effect])
        else
          equal(effect,@foe.status)
        end
      end
    end

    {
      BARRAGE: [:NORMAL,25,:special,:bomb],
      FURYATTACK: [:FLYING,18,:physical,:piercing],
      SPIKECANNON: [:STEEL,18,:physical,:piercing],
      DOUBLESLAP: [:FAIRY,18,:physical],
      ARMTHRUST: [:FIGHTING,18,:physical],
      FURYSWIPES: [:NORMAL,18,:physical],
      ROCKBLAST: [:ROCK,25,:physical],
      COMETPUNCH: [:FLYING,25,:physical,:punching],
      PINMISSILE: [:BUG,25,:physical,:piercing],
      ICICLESPEAR: [:ICE,25,:physical,:piercing],
      TAILSLAP: [:NORMAL,25,:physical],
      BULLETSEED: [:GRASS,25,:physical,:bomb]
    }.each do |name,(type,power,category,tag)|
      test(suite,name) do
        early_setup(name,:SKILLLINK)
        attack=early_data(name,type,category,power,90,*[tag].compact)
        assert(attack.pbIsMultiHit,"#{name} is not a multihit move")
        equal(5,attack.pbNumHits(@user))
        early_roll(0)
        early_use(name)
        assert(@foe.hp<@foe.totalhp,"#{name} failed to deal damage")
        assert(@scene.messages.include?("Hit 5 times!"),"#{name} did not strike five times")
        early_setup(name,:NONE)
        early_roll(0)
        early_use(name)
        assert(@scene.messages.include?("Hit 3 times!"),"#{name} did not strike three times")
      end
    end

    test(suite,:TWINEEDLE) do
      early_setup(:TWINEEDLE)
      attack=early_data(:TWINEEDLE,:BUG,:physical,30,90,:piercing)
      equal(20,attack.addlEffect)
      early_roll(0)
      early_use(:TWINEEDLE)
      assert(@scene.messages.include?("Hit 2 times!"),"Expected both Twineedle hits")
      equal(PBStatuses::POISON,@foe.status)
    end
    test(suite,:TRIPLEKICK) do
      early_setup(:TRIPLEKICK)
      attack=early_data(:TRIPLEKICK,:FIGHTING,:physical,20,90,:kicking)
      attack.pbOnStartUse(@user)
      equal([20,40,60],3.times.map { attack.pbBaseDamage(20,@user,@foe) })
      early_roll(0)
      early_use(:TRIPLEKICK)
      assert(@scene.messages.include?("Hit 3 times!"),"Expected three successful Triple Kick hits")
    end

    {
      SMOG: [:POISON,:special,[],PBStatuses::POISON],
      POISONSTING: [:POISON,:physical,[:piercing],PBStatuses::POISON],
      LICK: [:GHOST,:physical,[],PBStatuses::PARALYSIS],
      CONSTRICT: [:NORMAL,:physical,[],PBStats::SPEED],
      DRAGONPULSE: [:DRAGON,:special,[],PBStats::ATTACK]
    }.each do |name,(type,category,tags,effect)|
      test(suite,name) do
        target=name==:LICK ? :LAPRAS : :CHANSEY
        battle(:NOGUARD,:NONE,foe_species: target)
        attack=early_data(name,type,category,name==:DRAGONPULSE ? 90 : name==:CONSTRICT ? 40 : 35,100,*tags)
        equal(30,attack.addlEffect)
        early_roll(0)
        early_hit(name)
        if [:CONSTRICT,:DRAGONPULSE].include?(name)
          early_stat_effect(effect,-1)
        else
          equal(effect,@foe.status)
        end
      end
    end

    test(suite,:ASTONISH) do
      battle(:NOGUARD,:NONE,foe_species: :LAPRAS)
      attack=early_data(:ASTONISH,:GHOST,:physical,40,100)
      early_roll(0)
      baseline=attack.pbCalcDamage(@user,@foe)
      party=@battle.pbParty(@foe.index)
      replacement=pokemon(:NONE,@battle.opponent,[:CELEBRATE],:LAPRAS)
      party.push(replacement)
      @battle.pbReplace(@foe.index,1)
      equal(6144,attack.pbBaseDamageMultiplier(4096,@user,@foe))
      assert(attack.pbCalcDamage(@user,@foe)>baseline,"Astonish did not gain power after a switch")
      early_hit(:ASTONISH)
      assert(!@foe.effects[PBEffects::Flinch],"Astonish kept its prior flinch effect")
    end
    test(suite,:SLAM) do
      early_setup(:SLAM)
      attack=early_data(:SLAM,:NORMAL,:physical,80,100,:bludgeon)
      early_roll(0)
      baseline=attack.pbCalcDamage(@user,@foe)
      @foe.lastRoundMoved=@battle.turncount
      equal(120,attack.pbBaseDamage(80,@user,@foe))
      assert(attack.pbCalcDamage(@user,@foe)>baseline,"Slam did not gain power after the target moved")
    end
    [:WRAP,:BIND].each do |name|
      test(suite,name) do
        early_setup(name)
        early_data(name,name==:WRAP ? :NORMAL : :POISON,:physical,
          name==:WRAP ? 20 : 35,name==:WRAP ? 100 : 90)
        early_roll(0)
        early_hit(name)
        equal(@user.index,@foe.effects[PBEffects::MultiTurnUser])
        equal(5,@foe.effects[PBEffects::MultiTurn])
        old_hp=@foe.hp
        round
        equal(@foe.totalhp/8,old_hp-@foe.hp)
        @foe.pbClearMultiTurn
        @user.item=PBItems::BINDINGBAND
        early_hit(name)
        old_hp=@foe.hp
        round
        equal(@foe.totalhp/6,old_hp-@foe.hp)
      end
    end

    {
      SUBMISSION: [:FIGHTING,PBStatuses::CRUSHED],
      WILDCHARGE: [:ELECTRIC,PBStatuses::PARALYSIS],
      TAKEDOWN: [:NORMAL,0]
    }.each do |name,(type,status)|
      test(suite,name) do
        early_setup(name,foe_species: :SNORLAX)
        attack=early_data(name,type,:physical,100,100)
        equal(status==0 ? 0 : 10,attack.addlEffect)
        early_roll(0)
        old_hp=@user.hp
        damage=hit(name)
        assert(damage>0,"#{name} did not damage the target")
        equal([(damage+2)/4,1].max,old_hp-@user.hp)
        equal(status,@foe.status)
        early_setup(name,:ROCKHEAD,foe_species: :SNORLAX)
        early_roll(0)
        early_hit(name)
        equal(@user.totalhp,@user.hp)
      end
    end

    test(suite,:SUPERCELLSLAM) do
      early_setup(:SUPERCELLSLAM,:NONE)
      early_data(:SUPERCELLSLAM,:ELECTRIC,:physical,130,80)
      early_roll(99)
      equal(0,hit(:SUPERCELLSLAM))
      equal(@user.totalhp-@user.totalhp/2,@user.hp)
      equal(@foe.totalhp,@foe.hp)
      early_setup(:SUPERCELLSLAM)
      early_hit(:SUPERCELLSLAM)
      equal(@user.totalhp,@user.hp)
    end

    {
      MEGAPUNCH: [80,100,:punching], MEGAKICK: [120,80,:kicking]
    }.each do |name,(power,accuracy,tag)|
      test(suite,name) do
        early_setup(name)
        attack=early_data(name,:NORMAL,:physical,power,accuracy,tag)
        early_roll(0)
        ordinary=attack.pbCalcDamage(@user,@foe)
        @user.effects[PBEffects::LaserFocus]=1
        critical=attack.pbCalcDamage(@user,@foe)
        assert(@foe.damagestate.critical,"#{name} was not critical")
        equal(2.0,attack.pbCriticalDamageMultiplier)
        assert((critical-ordinary*2).abs<=2,"#{ordinary} damage yielded #{critical} on a critical hit")
      end
    end
    {
      PECK: [:FLYING,40,:piercing], HORNATTACK: [:BUG,65,:piercing],
      DRAGONCLAW: [:DRAGON,90], XSCISSOR: [:BUG,80,:slashing,:high_crit],
      DRILLPECK: [:FLYING,80,:piercing,:high_crit], DRILLRUN: [:GROUND,80,:piercing,:high_crit]
    }.each do |name,(type,power,*tags)|
      test(suite,name) do
        early_setup(name)
        early_data(name,type,:physical,power,100,*tags)
        early_roll(0)
        early_hit(name)
        equal(tags.include?(:high_crit),@foe.damagestate.critical)
      end
    end

    {SUPERSONIC: [:NORMAL,[:sound]],CONFUSERAY: [:GHOST,[]]}.each do |name,(type,tags)|
      test(suite,name) do
        early_setup(name)
        early_data(name,type,:status,0,100,*tags)
        early_use(name)
        equal(3,@foe.effects[PBEffects::Confusion])
      end
    end
    test(suite,:ENCHANT) do
      early_setup(:ENCHANT)
      early_data(:ENCHANT,:FAIRY,:status,0,90)
      early_use(:ENCHANT)
      equal(@user.index,@foe.effects[PBEffects::Attract])
      equal(3,@foe.effects[PBEffects::AttractTurns])
      2.times { round }
      equal(@user.index,@foe.effects[PBEffects::Attract])
      round
      equal(-1,@foe.effects[PBEffects::Attract])

      early_setup(:ENCHANT,:NOGUARD,foe_species: :DITTO)
      assert(@battle.pbGetMoveScore(move(:ENCHANT),@user,@foe,PBTrainerAI.minimumSkill)>0,
        "The AI rejected a valid genderless target for Enchant")
      @foe.item=PBItems::DESTINYKNOT
      @user.item=PBItems::DESTINYKNOT
      early_use(:ENCHANT)
      equal(@user.index,@foe.effects[PBEffects::Attract])
      equal(@foe.index,@user.effects[PBEffects::Attract])
      equal(3,@user.effects[PBEffects::AttractTurns])

      early_setup(:ENCHANT,:OBLIVIOUS,foe_species: :DITTO)
      @foe.item=PBItems::DESTINYKNOT
      early_roll(0)
      early_use(:ENCHANT)
      equal(@user.index,@foe.effects[PBEffects::Attract])
      equal(-1,@user.effects[PBEffects::Attract])

      wormadam=pokemon(:NONE,@battle.player,[:CELEBRATE],:WORMADAM)
      wormadam.instance_variable_set(:@form,3)
      assert(wormadam.isCompatibleWithMove?(PBMoves::ENCHANT),"Mystic Wormadam could not learn Enchant")
      assert(!wormadam.isCompatibleWithMove?(PBMoves::CELEBRATE),"Mystic Wormadam could learn an unlisted move")
    end
    test(suite,:SWEETKISS) do
      early_setup(:SWEETKISS)
      early_data(:SWEETKISS,:FAIRY,:status,0,80)
      early_use(:SWEETKISS)
      equal(PBStatuses::PARALYSIS,@foe.status)
      equal(0,@foe.effects[PBEffects::Confusion])
    end

    test(suite,:STOCKPILE) do
      early_setup(:STOCKPILE)
      attack=early_data(:STOCKPILE,:POISON,:status,0,0)
      early_use(:STOCKPILE,@user)
      equal(1,@user.effects[PBEffects::Stockpile])
      equal(1,@user.stages[PBStats::DEFENSE])
      equal(1,@user.stages[PBStats::SPDEF])
      2.times { equal(0,attack.pbEffect(@user,@user,0,nil,false)) }
      equal(-1,attack.pbEffect(@user,@user,0,nil,false))
      equal(3,@user.effects[PBEffects::Stockpile])
    end
    test(suite,:SPITUP) do
      early_setup(:SPITUP)
      attack=early_data(:SPITUP,:POISON,:special,60,0)
      equal(60,attack.pbBaseDamage(60,@user,@foe))
      equal(30,attack.addlEffect)
      equal(0,move(:STOCKPILE).pbEffect(@user,@user,0,nil,false))
      equal(120,attack.pbBaseDamage(60,@user,@foe))
      early_roll(0)
      early_use(:SPITUP)
      assert(@foe.hp<@foe.totalhp,"Spit Up did not hit")
      equal(0,@user.effects[PBEffects::Stockpile])
      early_stat_effect(PBStats::SPDEF,-1)
    end
    test(suite,:SWALLOW) do
      early_setup(:SWALLOW)
      early_data(:SWALLOW,:POISON,:status,0,0)
      @user.hp=1
      early_use(:SWALLOW,@user)
      equal(1+@user.totalhp/2,@user.hp)
      early_setup(:SWALLOW)
      equal(0,move(:STOCKPILE).pbEffect(@user,@user,0,nil,false))
      @user.hp=1
      early_use(:SWALLOW,@user)
      equal(1+@user.totalhp*3/4,@user.hp)
      equal(0,@user.effects[PBEffects::Stockpile])
    end
    test(suite,:ATTACKORDER) do
      early_setup(:ATTACKORDER)
      attack=early_data(:ATTACKORDER,:BUG,:physical,30,100,:sound)
      equal(30,attack.pbBaseDamage(30,@user,@foe))
      @user.stages[PBStats::EVASION]=2
      @user.stages[PBStats::ACCURACY]=-1
      equal(90,attack.pbBaseDamage(30,@user,@foe))
      early_roll(0)
      early_hit(:ATTACKORDER)
    end
    test(suite,:DEFENDORDER) do
      [0,15].each do |field|
        early_setup(:DEFENDORDER)
        attack=early_data(:DEFENDORDER,:BUG,:status,0,0,:sound)
        equal(1,@battle.pbMovePriority(@user,attack,@user))
        $fefieldeffect=field
        early_use(:DEFENDORDER,@user)
        expected=field==15 ? 2 : 1
        equal(expected,@user.stages[PBStats::DEFENSE])
        equal(expected,@user.stages[PBStats::SPDEF])
      end
    end
    test(suite,:HEALORDER) do
      [0,15].each do |field|
        early_setup(:HEALORDER)
        heal=early_data(:HEALORDER,:BUG,:status,0,0,:sound)
        @user.hp=1
        @user.stages[PBStats::SPEED]=2
        @user.stages[PBStats::EVASION]=1
        @user.stages[PBStats::ATTACK]=-3
        $fefieldeffect=field
        expected=@user.totalhp*62/100
        expected=expected*4/3 if field==15
        equal(expected,heal.pbHealingAmount(@user))
        early_use(:HEALORDER,@user)
        equal(1+expected,@user.hp)
      end
    end
    test(suite,:RAZORWIND) do
      battle(:NONE,:NONE,ally: :WINDRIDER,foe_ally: :NONE,outer_ally: :WINDPOWER,
        outer_foe: :NONE,user_moves: [:RAZORWIND])
      early_data(:RAZORWIND,:NORMAL,:special,80,100,:wind,:high_crit)
      early_roll(0)
      early_use(:RAZORWIND)
      [@user,@ally,@outer_ally].each { |battler| equal(1,battler.stages[PBStats::SPEED]) }
      equal(1,@ally.stages[PBStats::ATTACK])
      equal(1,@ally.stages[PBStats::SPATK])
      equal(true,@outer_ally.effects[PBEffects::Charge])
      equal(@foe.totalhp,@foe.hp)
      @battle.instance_variable_set(:@turncount,1)
      @battle.pbAttackPhase
      assert(@foe.hp<@foe.totalhp,"Charged Razor Wind did not hit on turn two")
      equal(1,@ally.stages[PBStats::SPEED])
      early_setup(:RAZORWIND)
      @user.item=PBItems::POWERHERB
      early_use(:RAZORWIND)
      assert(@foe.hp<@foe.totalhp,"Power Herb did not make Razor Wind immediate")
      equal(0,@user.item)
    end
    {CIRCLETHROW: :FIGHTING,DRAGONTAIL: :DRAGON,POISONTAIL: :POISON}.each do |name,type|
      test(suite,name) do
        early_setup(name,foe_species: :SNORLAX)
        attack=early_data(name,type,:physical,60,90)
        equal(-6,@battle.pbMovePriority(@user,attack,@foe))
        equal(name==:POISONTAIL ? 60 : 90,attack.pbBaseDamage(60,@user,@foe))
        early_hit(name)
        equal(name==:POISONTAIL ? PBStatuses::POISON : 0,@foe.status)
        equal(false,@foe.forcedSwitch)
        party=@battle.pbParty(@foe.index)
        party.push(pokemon(:NONE,@battle.opponent,[:CELEBRATE]))
        equal(60,attack.pbBaseDamage(60,@user,@foe))
        early_use(name)
        equal(1,@foe.pokemonIndex)
      end
    end
    {DRAGONBREATH: :DRAGON,FROSTBREATH: :ICE}.each do |name,type|
      test(suite,name) do
        early_setup(name)
        early_data(name,type,:special,60,90,:contact)
        early_roll(99)
        early_hit(name)
        equal(true,@foe.damagestate.critical)
        early_setup(name,:NOGUARD,:SHELLARMOR)
        early_hit(name)
        equal(false,@foe.damagestate.critical)
      end
    end
  end
end
