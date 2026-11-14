module AzureMoveTailCases
  class Cases < AzureAbilityFixture::Scenario
    def run
      test_yawn
      test_secondaries
      test_gravity
      test_poison
      test_variable_damage
      test_authored_moves
    end

    def test_yawn
      battle(:NONE,:NONE,ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      attack=move(:YAWN)
      equal(PBTargets::BothSides,attack.target)
      assert(attack.pbEffect(@user,nil)>=0,"Yawn did not go off")
      assert(attack.pbEffect(@user,nil)<0,"Yawn must not reset existing drowsiness")
      @battle.eachActiveBattlerIndex do |index|
        equal(2,@battle.battlers[index].effects[PBEffects::Yawn])
      end
      round
      @battle.eachActiveBattlerIndex do |index|
        equal(0,@battle.battlers[index].status)
      end
      round
      @battle.eachActiveBattlerIndex do |index|
        battler=@battle.battlers[index]
        equal(PBStatuses::SLEEP,battler.status)
        equal(2,battler.statusCount)
      end

      [:HYPNOSIS,:LOVELYKISS,:SING,:SLEEPPOWDER,:SPORE].each do |name|
        battle(:NONE,:NONE)
        assert(move(name).pbEffect(@user,@foe)>=0,"#{name} did not apply drowsiness")
        equal(2,@foe.effects[PBEffects::Yawn])
        equal(0,@foe.status)
      end
      battle(:NONE,:NONE,foe_species: :BULBASAUR)
      assert(move(:SPORE).pbEffect(@user,@foe)<0,"Spore affected a Grass-type")
      equal(0,@foe.effects[PBEffects::Yawn])
      battle(:NONE,:NONE)
      @foe.effects[PBEffects::NightmareAura]=true
      assert(move(:HYPNOSIS,@foe).pbEffect(@foe,@user)>=0,"Nightmare did not affect Hypnosis")
      equal(PBStatuses::SLEEP,@user.status)
      equal(2,@user.statusCount)
    end

    def test_secondaries
      battle(:NONE,:NONE,user_species: :PIDGEY,foe_species: :BLISSEY)
      sky_attack=move(:SKYATTACK)
      assert(sky_attack.pbTwoTurnAttack(@user,true),"Sky Attack has no charge turn")
      assert(sky_attack.hasHighCriticalRate?,"Sky Attack lost its high critical-hit rate")
      @user.effects[PBEffects::TwoTurnAttack]=sky_attack.id
      assert(!sky_attack.pbTwoTurnAttack(@user,true),"Sky Attack did not finish charging")
      @user.effects[PBEffects::TwoTurnAttack]=0
      assert(secondary(sky_attack),"Sky Attack failed to lower Speed")
      equal(-1,@foe.stages[PBStats::SPEED])
      assert(!@foe.effects[PBEffects::Flinch],"Sky Attack still flinches")

      iron_bash=move(:DOUBLEIRONBASH)
      equal(2,iron_bash.pbNumHits(@user))
      assert(iron_bash.pbIsMultiHit && iron_bash.isContactMove?,"Double Iron Bash lost its contact multihit behavior")
      assert(secondary(iron_bash),"Double Iron Bash did not lower Defense")
      equal(-1,@foe.stages[PBStats::DEFENSE])

      snore=move(:SNORE)
      assert(snore.pbCanUseWhileAsleep?,"Snore is blocked while sleeping")
      assert(snore.pbMoveFailed(@user,@foe),"Snore works while awake")
      @user.status=PBStatuses::SLEEP
      assert(!snore.pbMoveFailed(@user,@foe),"Snore failed while asleep")
      assert(secondary(snore),"Snore did not lower Special Defense")
      equal(-1,@foe.stages[PBStats::SPDEF])
      assert(!@foe.effects[PBEffects::Flinch],"Snore still flinches")

      {
        FIREFANG: PBStatuses::BURN,
        ICEFANG: PBStatuses::FROZEN,
        THUNDERFANG: PBStatuses::PARALYSIS,
        POISONFANG: PBStatuses::POISON
      }.each do |name,status|
        battle(:NONE,:NONE)
        fang=move(name)
        equal(10,fang.addlEffect)
        rolls=[9,10]
        @battle.define_singleton_method(:pbRandom) { |_limit| rolls.shift }
        @battle.pbWithStatChangeSource([:move,fang.id]) do
          fang.pbApplyAdditionalEffects(@user,@foe,fang.addlEffect)
        end
        equal(status,@foe.status)
        equal(0,@foe.stages[PBStats::DEFENSE])
        @foe.status=0
        rolls.push(10,9)
        @battle.pbWithStatChangeSource([:move,fang.id]) do
          fang.pbApplyAdditionalEffects(@user,@foe,fang.addlEffect)
        end
        equal(0,@foe.status)
        equal(-1,@foe.stages[PBStats::DEFENSE])
      end
    end

    def test_gravity
      battle(:NONE,:NONE,foe_species: :PIDGEY)
      gravity=move(:GRAVITY)
      @battle.define_singleton_method(:pbRandom) { |_limit| 80 }
      tackle=move(:TACKLE)
      inaccurate=move(:HORNDRILL)
      equal(50,inaccurate.accuracy)
      assert(!inaccurate.pbAccuracyCheck(@user,@foe),"Accuracy probe failed before Gravity")
      assert(@foe.isAirborne?,"Flying foe should start airborne")
      gravity.pbEffect(@user,nil)
      equal(4,@battle.field.effects[PBEffects::Gravity])
      assert(!@foe.isAirborne?,"Gravity did not ground a Flying foe")
      @battle.define_singleton_method(:pbRandom) { |_limit| 70 }
      assert(inaccurate.pbAccuracyCheck(@user,@foe),"Gravity did not raise 50 accuracy to 75")
      @battle.define_singleton_method(:pbRandom) { |_limit| 75 }
      assert(!inaccurate.pbAccuracyCheck(@user,@foe),"Gravity boosted accuracy more than 1.5x")
      assert(tackle.pbAccuracyCheck(@user,@foe),"Tackle should hit under Gravity")
    end

    def test_poison
      battle(:NONE,:NONE,user_species: :PIKACHU)
      toxic=move(:TOXIC)
      equal(PBTargets::User,@user.pbTarget(toxic))
      assert(toxic.pbEffect(@user,@user)>=0,"First Toxic failed to change typing")
      equal(PBTypes::POISON,@user.type1)
      equal(PBTypes::POISON,@user.type2)
      equal(PBTargets::SingleNonUser,@user.pbTarget(toxic))
      assert(toxic.pbEffect(@user,@foe)>=0,"Poison-type Toxic did not poison")
      equal(PBStatuses::POISON,@foe.status)
      equal(1,@foe.statusCount)

      battle(:NONE,:NONE,ally: :NONE,outer_ally: :NONE,outer_foe: :MAGICBOUNCE)
      barbs=move(:TOXICSPIKES)
      assert(barbs.pbEffect(@user,nil)>=0,"Poison Barbs did not deploy")
      equal(1,@user.pbOwnSide.effects[PBEffects::ToxicSpikes])
      equal(0,@foe.pbOwnSide.effects[PBEffects::ToxicSpikes])
    end

    def test_variable_damage
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE)
      bide=move(:BIDE)
      equal(-4,bide.priority)
      equal(60,bide.pbBaseDamage(60,@user,@foe))
      assert(hit(:TACKLE,@foe_ally,@user)>0,"Direct hit for Bide did not land")
      equal(120,bide.pbBaseDamage(60,@user,@foe))
      round
      equal(60,bide.pbBaseDamage(60,@user,@foe))
      @user.pbReduceHP(1)
      equal(120,bide.pbBaseDamage(60,@user,@foe))

      battle(:NONE,:LEVITATE,foe_species: :RATTATA,ally: :NEUTRALIZINGGAS,foe_ally: :NONE)
      twister=move(:TWISTER)
      equal(40,twister.pbBaseDamage(40,@user,@foe))
      @ally.ability=PBAbilities::BALLFETCH
      equal(80,twister.pbBaseDamage(40,@user,@foe))
      @battle.field.effects[PBEffects::Gravity]=4
      equal(40,twister.pbBaseDamage(40,@user,@foe))
      @foe.effects[PBEffects::SkyDrop]=true
      equal(80,twister.pbBaseDamage(40,@user,@foe))
    end

    def test_authored_moves
      battle(:NONE,:NONE)
      [:AIRSLASH,:MOUNTAINGALE,:CUT].each do |name|
        attack=move(name)
        assert(attack.hasHighCriticalRate?,"#{name} does not have a high critical-hit rate")
        equal(0,attack.addlEffect)
      end
      {FLASHCANNON: 20,DAZZLINGGLEAM: 20,NIGHTDAZE: 30}.each do |name,chance|
        attack=move(name)
        equal(chance,attack.addlEffect)
        assert(attack.pbAdditionalEffect(@user,@foe),"#{name} did not blind")
        @foe.effects[PBEffects::Blinded]=0
      end
      equal(90,move(:STRENGTH).basedamage)
      equal(50,move(:STEAMROLLER).basedamage)
    end

    def secondary(attack)
      @battle.pbWithStatChangeSource([:move,attack.id]) do
        attack.pbAdditionalEffect(@user,@foe)
      end
    end
  end

  def self.run
    Cases.new.run
  end
end
