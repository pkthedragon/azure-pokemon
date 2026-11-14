module AzureMoveTailMatrix
  module BattleChecks
    def tail_roll(value)
      @battle.define_singleton_method(:pbRandom) { |limit| limit==100 ? value : [1,limit-1].max % limit }
    end

    def tail_use(name,user=@user,target=@foe)
      slot=user.moves.index { |known| known && known.id==PBMoves.const_get(name) }
      assert(slot,"#{user.name} does not know #{name}")
      user.pbUseMove([1,slot,user.moves[slot],target.index])
    end

    def tail_secondary(name,chance)
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      equal(chance,move(name).addlEffect)
      tail_roll(chance)
      assert(hit(name)>0,"#{name} did not hit at its secondary-effect cutoff")
      yield false
      tail_roll(chance-1)
      assert(hit(name)>0,"#{name} did not hit below its secondary-effect cutoff")
      yield true
      assert(!@foe.effects[PBEffects::Flinch],"#{name} applied a legacy flinch")
      assert(!PBStuff::FLINCHMOVE.include?(move(name).id),"AI still classifies #{name} as a flinch move")
    end

    def tail_stat_secondary(name,chance,stat,recipient)
      tail_secondary(name,chance) do |applied|
        battler=recipient==:user ? @user : @foe
        shift=recipient==:user ? 1 : -1
        equal(applied ? shift : 0,battler.stages[stat])
      end
    end

    def tail_crush_secondary(name,chance)
      tail_secondary(name,chance) { |applied| equal(applied ? PBStatuses::CRUSHED : 0,@foe.status) }
    end

    def tail_blind_secondary(name,chance)
      tail_secondary(name,chance) { |applied| equal(applied,@foe.effects[PBEffects::Blinded]>0) }
    end

    def tail_fang(name,status)
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      fang=move(name)
      equal(10,fang.addlEffect)
      [[9,10],[10,9]].each do |status_roll,defense_roll|
        @foe.hp=@foe.totalhp
        @foe.status=0
        @foe.stages[PBStats::DEFENSE]=0
        rolls=[0,status_roll,defense_roll]
        @battle.define_singleton_method(:pbRandom) do |limit|
          limit==100 ? (rolls.shift || 0) : 1 % limit
        end
        assert(hit(name)>0,"#{name} did not hit")
        equal(status_roll<10 ? status : 0,@foe.status)
        equal(defense_roll<10 ? -1 : 0,@foe.stages[PBStats::DEFENSE])
        assert(!@foe.effects[PBEffects::Flinch],"#{name} applied a legacy flinch")
      end
    end

    def tail_high_crit(name)
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      attack=move(name)
      assert(attack.hasHighCriticalRate?,"#{name} lost its critical-hit flag")
      equal(0,attack.addlEffect)
      @battle.define_singleton_method(:pbRandom) { |limit| limit==8 ? 0 : 1 % limit }
      assert(hit(name)>0,"#{name} did not hit")
      assert(@foe.damagestate.critical,"#{name} missed a legal high-crit roll")
      assert(!@foe.effects[PBEffects::Flinch],"#{name} applied a legacy flinch")
      assert(!PBStuff::FLINCHMOVE.include?(attack.id),"AI still classifies #{name} as a flinch move")
      attack
    end

    def tail_drowsy(name,immune)
      battle(:NONE,:NONE,user_moves: [name])
      tail_roll(0)
      immune.call(@foe)
      tail_use(name)
      equal(0,@foe.effects[PBEffects::Yawn])
      @foe.ability=PBAbilities::BALLFETCH
      @foe.item=0
      @foe.type1=PBTypes::NORMAL
      @foe.type2=PBTypes::NORMAL
      tail_use(name)
      equal(2,@foe.effects[PBEffects::Yawn])
      equal(0,@foe.status)
      round
      equal(0,@foe.status)
      round
      equal(PBStatuses::SLEEP,@foe.status)
    end

    def tail_power_crush(name)
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      attack=move(name)
      equal(120,attack.pbBaseDamage(attack.basedamage,@user,@foe))
      @foe.hp=@foe.totalhp/2
      equal(120*@foe.hp/@foe.totalhp,attack.pbBaseDamage(attack.basedamage,@user,@foe))
      @foe.hp=1
      assert(attack.pbBaseDamage(attack.basedamage,@user,@foe)>=1,"#{name} fell below one base power")
      @foe.hp=@foe.totalhp
      @foe.item=PBItems::PRESSURESUIT
      tail_roll(0)
      assert(hit(name)>0,"#{name} did not hurt a Pressure Suit holder")
      equal(0,@foe.status)
      @foe.hp=@foe.totalhp
      @foe.item=0
      assert(hit(name)>0,"#{name} did not hit after Pressure Suit was removed")
      equal(PBStatuses::CRUSHED,@foe.status)
    end
  end

  def self.register(suite)
    AzureAbilityFixture::Scenario.include(BattleChecks)

    suite.test(:TOXIC) do
      battle(:NONE,:NONE,user_moves: [:TOXIC],user_species: :PIKACHU)
      tail_roll(0)
      @foe.effects[PBEffects::Protect]=true
      tail_use(:TOXIC)
      equal(PBTypes::POISON,@user.type1)
      equal(PBTypes::POISON,@user.type2)
      equal(0,@foe.status)
      @foe.effects[PBEffects::Protect]=false
      tail_use(:TOXIC)
      equal(PBStatuses::POISON,@foe.status)
      equal(1,@foe.statusCount)
    end

    suite.test(:TOXICSPIKES) do
      battle(:NONE,:NONE,user_moves: [:TOXICSPIKES])
      tail_roll(0)
      equal("Poison Barbs",move(:TOXICSPIKES).name)
      tail_use(:TOXICSPIKES)
      tail_use(:TOXICSPIKES)
      equal(1,@foe.pbOwnSide.effects[PBEffects::ToxicSpikes])
      @foe.item=PBItems::HEAVYDUTYBOOTS
      @battle.pbOnActiveOne(@foe)
      equal(0,@foe.status)
      @foe.item=0
      @battle.pbOnActiveOne(@foe)
      equal(PBStatuses::POISON,@foe.status)
      equal(0,@foe.statusCount)
      @foe.status=0
      @foe.type1=PBTypes::GRASS
      @foe.type2=PBTypes::GRASS
      @battle.pbOnActiveOne(@foe)
      equal(PBStatuses::POISON,@foe.status)
      equal(1,@foe.statusCount)
      @foe.type1=PBTypes::POISON
      @battle.pbOnActiveOne(@foe)
      equal(0,@foe.pbOwnSide.effects[PBEffects::ToxicSpikes])
    end

    suite.test(:POISONFANG) do
      tail_fang(:POISONFANG,PBStatuses::POISON)
      fang=move(:POISONFANG)
      equal([65,95,PBTypes::POISON],[fang.basedamage,fang.accuracy,fang.type])
      assert(fang.pbIsPhysical?(fang.type),"Poison Fang is not physical")
      equal(0,@foe.statusCount)
    end

    suite.test(:FLASHCANNON) do
      tail_blind_secondary(:FLASHCANNON,20)
      equal(PBTypes::STEEL,move(:FLASHCANNON).type)
      battle(:NONE,:ILLUMINATE,foe_species: :SNORLAX)
      tail_roll(0)
      hit(:FLASHCANNON)
      assert(@foe.effects[PBEffects::Blinded]<=0,"Illuminate allowed blinding")
    end

    suite.test(:DAZZLINGGLEAM) do
      tail_blind_secondary(:DAZZLINGGLEAM,20)
      battle(:NONE,:NONE,ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      @ally.moves[0]=move(:DAZZLINGGLEAM,@ally)
      @foe_ally.ability=PBAbilities::DAZZLING
      tail_roll(0)
      tail_use(:DAZZLINGGLEAM,@ally)
      equal([true,false,true],[@foe,@foe_ally,@outer_foe].map { |foe| foe.effects[PBEffects::Blinded]>0 })
      assert(@user.effects[PBEffects::Blinded]<=0,"Dazzling Gleam hit an ally")
    end

    suite.test(:NIGHTDAZE) { tail_blind_secondary(:NIGHTDAZE,30) }

    suite.test(:GRAVITY) do
      battle(:NONE,:NONE,user_moves: [:GRAVITY],user_species: :SNORLAX,foe_species: :PIDGEY)
      tail_roll(70)
      inaccurate=move(:HORNDRILL)
      assert(!inaccurate.pbAccuracyCheck(@user,@foe),"Inaccurate move hit before Gravity")
      equal(1.0,move(:STOMP).pbGravityPowerMultiplier(@user,@foe))
      tail_use(:GRAVITY)
      equal(4,@battle.field.effects[PBEffects::Gravity])
      assert(!@foe.isAirborne?,"Gravity failed to ground Flying-type")
      @foe.item=PBItems::ANTIGRAVITYCORE
      assert(@foe.isAirborne?,"Antigravity Core failed in Gravity")
      assert(inaccurate.pbAccuracyCheck(@user,@foe),"Gravity failed to boost accuracy")
      equal(0.5,move(:WATERFALL).pbGravityPowerMultiplier(@user,@foe))
      equal(0.5,move(:QUICKATTACK).pbGravityPowerMultiplier(@user,@foe))
      equal(1.5,move(:BIDE).pbGravityPowerMultiplier(@user,@foe))
      equal(1.3,move(:STOMP,@foe).pbGravityPowerMultiplier(@foe,@user))
      4.times { round }
      equal(0,@battle.field.effects[PBEffects::Gravity])
    end

    suite.test(:LUCKYCHANT) do
      battle(:NONE,:NONE,user_moves: [:LUCKYCHANT],user_species: :SNORLAX,ally: :NONE)
      tail_roll(0)
      tail_use(:LUCKYCHANT)
      equal(5,@ally.pbOwnSide.effects[PBEffects::LuckyChant])
      @foe.effects[PBEffects::LaserFocus]=1
      hit(:BITE,@foe,@user)
      equal(0,@user.stages[PBStats::DEFENSE])
      assert(!@user.damagestate.critical,"Lucky Chant allowed a critical hit")
      5.times { round }
      hit(:BITE,@foe,@user)
      equal(-1,@user.stages[PBStats::DEFENSE])
      assert(@user.damagestate.critical,"Critical hit was blocked after Lucky Chant expired")
    end

    suite.test(:BIDE) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE)
      bide=move(:BIDE)
      equal([60,100,-4],[bide.basedamage,bide.accuracy,bide.priority])
      assert(PBStuff::MOMENTUMMOVE.include?(bide.id),"Bide lost its Momentum classification")
      equal(60,bide.pbBaseDamage(60,@user,@foe))
      tail_roll(0)
      assert(hit(:TACKLE,@foe_ally,@user)>0,"Bide user was not hurt by the other opponent")
      equal(120,bide.pbBaseDamage(60,@user,@foe))
      round
      equal(60,bide.pbBaseDamage(60,@user,@foe))
      @user.pbReduceHP(1)
      equal(120,bide.pbBaseDamage(60,@user,@foe))
    end

    suite.test(:AIRSLASH) { tail_high_crit(:AIRSLASH) }
    suite.test(:BITE) { tail_stat_secondary(:BITE,30,PBStats::DEFENSE,:foe) }
    suite.test(:DARKPULSE) { tail_stat_secondary(:DARKPULSE,30,PBStats::SPDEF,:foe) }

    suite.test(:DOUBLEIRONBASH) do
      battle(:NONE,:NONE,user_moves: [:DOUBLEIRONBASH],foe_species: :SNORLAX)
      bash=move(:DOUBLEIRONBASH)
      equal(2,bash.pbNumHits(@user))
      assert(bash.isContactMove?,"Double Iron Bash lost contact")
      rolls=[0,30,29]
      @battle.define_singleton_method(:pbRandom) do |limit|
        limit==100 ? (rolls.shift || 0) : 1 % limit
      end
      tail_use(:DOUBLEIRONBASH)
      equal(-1,@foe.stages[PBStats::DEFENSE])
      assert(@scene.messages.any? { |message| message.include?("Hit 2 times!") },"Double Iron Bash only hit once")
      assert(!@foe.effects[PBEffects::Flinch],"Double Iron Bash applied a legacy flinch")
    end

    suite.test(:DRAGONRUSH) { tail_stat_secondary(:DRAGONRUSH,30,PBStats::DEFENSE,:foe) }
    suite.test(:EXTRASENSORY) { tail_crush_secondary(:EXTRASENSORY,10) }

    suite.test(:FIERYWRATH) do
      tail_crush_secondary(:FIERYWRATH,20)
      battle(:NONE,:NONE,user_moves: [:FIERYWRATH],foe_ally: :NONE,ally: :NONE)
      @foe.item=PBItems::PRESSURESUIT
      tail_roll(0)
      tail_use(:FIERYWRATH)
      equal(0,@foe.status)
      equal(PBStatuses::CRUSHED,@foe_ally.status)
      equal(0,@ally.status)
    end

    suite.test(:FIREFANG) { tail_fang(:FIREFANG,PBStatuses::BURN) }
    suite.test(:HEADBUTT) { tail_stat_secondary(:HEADBUTT,30,PBStats::DEFENSE,:user) }
    suite.test(:HYPERFANG) { tail_stat_secondary(:HYPERFANG,10,PBStats::DEFENSE,:foe) }
    suite.test(:ICEFANG) { tail_fang(:ICEFANG,PBStatuses::FROZEN) }
    suite.test(:ICICLECRASH) { tail_crush_secondary(:ICICLECRASH,30) }
    suite.test(:IRONHEAD) { tail_stat_secondary(:IRONHEAD,30,PBStats::DEFENSE,:user) }
    suite.test(:MOUNTAINGALE) { tail_high_crit(:MOUNTAINGALE) }

    suite.test(:ROCKSLIDE) do
      tail_crush_secondary(:ROCKSLIDE,20)
      battle(:NONE,:NONE,user_moves: [:ROCKSLIDE],foe_ally: :NONE,ally: :NONE)
      @battle.field.effects[PBEffects::MistyTerrain]=3
      @foe_ally.type1=PBTypes::FLYING
      tail_roll(0)
      tail_use(:ROCKSLIDE)
      equal(0,@foe.status)
      equal(PBStatuses::CRUSHED,@foe_ally.status)
      equal(0,@ally.status)
    end

    suite.test(:SKYATTACK) do
      battle(:NONE,:NONE,user_moves: [:SKYATTACK],foe_species: :SNORLAX)
      equal(30,move(:SKYATTACK).addlEffect)
      assert(move(:SKYATTACK).hasHighCriticalRate?,"Sky Attack lost its high critical-hit rate")
      tail_roll(29)
      tail_use(:SKYATTACK)
      equal(PBMoves::SKYATTACK,@user.effects[PBEffects::TwoTurnAttack])
      equal(@foe.totalhp,@foe.hp)
      tail_use(:SKYATTACK)
      equal(-1,@foe.stages[PBStats::SPEED])
      assert(!@foe.effects[PBEffects::Flinch],"Sky Attack applied a legacy flinch")
      battle(:NONE,:NONE,user_moves: [:SKYATTACK],foe_species: :SNORLAX)
      tail_roll(29)
      @user.item=PBItems::POWERHERB
      tail_use(:SKYATTACK)
      equal(0,@user.item)
      equal(-1,@foe.stages[PBStats::SPEED])
    end

    suite.test(:SNORE) do
      battle(:NONE,:NONE,user_moves: [:SNORE],foe_species: :SNORLAX)
      tail_roll(0)
      tail_use(:SNORE)
      equal(@foe.totalhp,@foe.hp)
      @user.status=PBStatuses::SLEEP
      @user.statusCount=3
      tail_use(:SNORE)
      assert(@foe.hp<@foe.totalhp,"Snore did not hit while asleep")
      equal(-1,@foe.stages[PBStats::SPDEF])
      assert(!@foe.effects[PBEffects::Flinch],"Snore applied a legacy flinch")
    end

    suite.test(:STEAMROLLER) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      steamroller=move(:STEAMROLLER)
      equal([50,100],[steamroller.basedamage,steamroller.addlEffect])
      assert(PBStuff::MOMENTUMMOVE.include?(steamroller.id),"Steamroller lost its Momentum classification")
      tail_roll(99)
      assert(hit(:STEAMROLLER)>0,"Steamroller did not hit")
      equal(1,@user.stages[PBStats::SPEED])
      assert(!@foe.effects[PBEffects::Flinch],"Steamroller applied a legacy flinch")
    end

    suite.test(:STOMP) { tail_crush_secondary(:STOMP,30) }

    suite.test(:THUNDERFANG) do
      tail_fang(:THUNDERFANG,PBStatuses::PARALYSIS)
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      @foe.effects[PBEffects::Aftershock]=1
      @foe.effects[PBEffects::AftershockMove]=PBMoves::THUNDERFANG
      @foe.effects[PBEffects::AftershockUser]=@user.index
      rolls=[10,9]
      @battle.define_singleton_method(:pbRandom) do |limit|
        limit==100 ? (rolls.shift || 20) : 1 % limit
      end
      round
      equal(0,@foe.status)
      equal(-1,@foe.stages[PBStats::DEFENSE])
    end

    suite.test(:TRIPLEARROWS) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      arrows=move(:TRIPLEARROWS)
      assert(arrows.hasHighCriticalRate?,"Triple Arrows lost its high critical-hit rate")
      equal(30,arrows.addlEffect)
      [[29,50],[30,49]].each do |speed_roll,defense_roll|
        @foe.hp=@foe.totalhp
        @foe.stages[PBStats::SPEED]=0
        @foe.stages[PBStats::DEFENSE]=0
        rolls=[0,speed_roll,defense_roll]
        @battle.define_singleton_method(:pbRandom) do |limit|
          limit==100 ? (rolls.shift || 0) : 1 % limit
        end
        assert(hit(:TRIPLEARROWS)>0,"Triple Arrows did not hit")
        equal(speed_roll<30 ? -1 : 0,@foe.stages[PBStats::SPEED])
        equal(defense_roll<50 ? -1 : 0,@foe.stages[PBStats::DEFENSE])
      end
    end

    suite.test(:TWISTER) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      tail_roll(0)
      twister=move(:TWISTER)
      [:FLY,:BOUNCE,:SKYDROP].each do |airborne_move|
        @foe.hp=@foe.totalhp
        @foe.effects[PBEffects::TwoTurnAttack]=PBMoves.const_get(airborne_move)
        equal(80,twister.pbBaseDamage(40,@user,@foe))
        assert(hit(:TWISTER)>0,"Twister could not hit #{airborne_move}")
        assert(!@foe.effects[PBEffects::Flinch],"Twister applied a legacy flinch")
      end
      @foe.hp=@foe.totalhp
      @foe.effects[PBEffects::TwoTurnAttack]=PBMoves::DIG
      equal(0,hit(:TWISTER))
    end

    suite.test(:WATERFALL) { tail_stat_secondary(:WATERFALL,20,PBStats::SPEED,:foe) }
    suite.test(:ZENHEADBUTT) { tail_stat_secondary(:ZENHEADBUTT,30,PBStats::SPDEF,:user) }
    suite.test(:ZINGZAP) { tail_crush_secondary(:ZINGZAP,30) }
    suite.test(:CRUSHGRIP) { tail_power_crush(:CRUSHGRIP) }
    suite.test(:HARDPRESS) { tail_power_crush(:HARDPRESS) }

    suite.test(:VICEGRIP) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      grip=move(:VICEGRIP)
      equal([PBTypes::WATER,20,100,100],[grip.type,grip.basedamage,grip.accuracy,grip.addlEffect])
      assert(grip.pbIsPhysical?(grip.type),"Vice Grip is not physical")
      tail_roll(99)
      assert(hit(:VICEGRIP)>0,"Vice Grip did not hit")
      equal(PBStatuses::CRUSHED,@foe.status)
    end

    suite.test(:YAWN) do
      battle(:NONE,:NONE,user_moves: [:YAWN],ally: :NONE,outer_foe: :INSOMNIA)
      @foe_ally.status=PBStatuses::BURN
      tail_roll(0)
      tail_use(:YAWN)
      equal([2,2,2,0,2,0],@battle.battlers.map { |battler| battler.effects[PBEffects::Yawn] })
      round
      round
      equal([PBStatuses::SLEEP,PBStatuses::SLEEP,PBStatuses::SLEEP,PBStatuses::BURN,PBStatuses::SLEEP,0],
            @battle.battlers.map { |battler| battler.status })
    end

    suite.test(:LOVELYKISS) do
      tail_drowsy(:LOVELYKISS, ->(foe) { foe.ability=PBAbilities::INSOMNIA })
    end

    suite.test(:HYPNOSIS) do
      tail_drowsy(:HYPNOSIS, ->(foe) { foe.ability=PBAbilities::PURIFYINGSALT })
    end

    suite.test(:SLEEPPOWDER) do
      tail_drowsy(:SLEEPPOWDER, ->(foe) { foe.item=PBItems::SAFETYGOGGLES })
    end

    suite.test(:SING) do
      tail_drowsy(:SING, ->(foe) { foe.ability=PBAbilities::SOUNDPROOF })
    end

    suite.test(:SPORE) do
      tail_drowsy(:SPORE, ->(foe) { foe.type1=PBTypes::GRASS })
    end

    suite.test(:CUT) do
      cut=tail_high_crit(:CUT)
      equal([PBTypes::STEEL,60,100],[cut.type,cut.basedamage,cut.accuracy])
      assert(cut.pbIsPhysical?(cut.type) && PBStuff::SLASHINGMOVE.include?(cut.id),"Cut is not physical Slashing")
    end

    suite.test(:ROCKCLIMB) do
      battle(:NONE,:NONE,user_moves: [:ROCKCLIMB],foe_species: :SNORLAX)
      climb=move(:ROCKCLIMB)
      equal([PBTypes::ROCK,100,90],[climb.type,climb.basedamage,climb.accuracy])
      assert(climb.pbIsPhysical?(climb.type),"Rock Climb is not physical")
      tail_roll(90)
      tail_use(:ROCKCLIMB)
      equal(@user.totalhp-@user.totalhp/2,@user.hp)
      equal(@foe.totalhp,@foe.hp)
      @user.hp=@user.totalhp
      tail_roll(89)
      tail_use(:ROCKCLIMB)
      equal(@user.totalhp,@user.hp)
      assert(@foe.hp<@foe.totalhp,"Rock Climb did not hit below its accuracy cutoff")
    end

    suite.test(:STRENGTH) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      strength=move(:STRENGTH)
      equal([PBTypes::NORMAL,90,100],[strength.type,strength.basedamage,strength.accuracy])
      assert(strength.pbIsPhysical?(strength.type),"Strength is not physical")
      tail_roll(99)
      assert(hit(:STRENGTH)>0,"Strength did not hit at 100 accuracy")
    end
  end
end
