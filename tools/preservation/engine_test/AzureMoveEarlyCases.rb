module AzureMoveEarlyCases
  class Scenarios < AzureAbilityFixture::Scenario
    def accuracy_and_secondaries
      {
        SHEERCOLD: PBStatuses::FROZEN, FISSURE: PBEffects::MeanLook,
        HORNDRILL: PBStatuses::CRUSHED, GUILLOTINE: PBEffects::ThroatChop,
        INFERNO: PBStatuses::BURN, ZAPCANNON: PBStatuses::PARALYSIS,
        DYNAMICPUNCH: PBEffects::Confusion
      }.each do |name,effect|
        battle(:NONE,:NONE,foe_species: :CHANSEY)
        attack=move(name)
        @battle.define_singleton_method(:pbRandom) { |_limit| 99 }
        @user.level=59
        equal(false,attack.pbAccuracyCheck(@user,@foe))
        @user.level=60
        equal(true,attack.pbAccuracyCheck(@user,@foe))
        @user.level=50
        @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
        equal(true,attack.pbAccuracyCheck(@user,@foe))
        assert(attack.pbAdditionalEffect(@user,@foe),"#{name} failed to apply its additional effect")
        if name==:FISSURE
          equal(@user.index,@foe.effects[effect])
        elsif [:GUILLOTINE,:DYNAMICPUNCH].include?(name)
          equal(3,@foe.effects[effect])
        else
          equal(effect,@foe.status)
        end
      end
    end

    def multi_hit
      %i[BARRAGE FURYATTACK SPIKECANNON DOUBLESLAP ARMTHRUST FURYSWIPES ROCKBLAST
         COMETPUNCH PINMISSILE ICICLESPEAR TAILSLAP BULLETSEED].each do |name|
        battle(:NONE)
        attack=move(name)
        assert(attack.pbIsMultiHit,"#{name} should be a multi-hit move")
        numbers=(0...8).map do |roll|
          @battle.define_singleton_method(:pbRandom) { |_limit| roll }
          attack.pbNumHits(@user)
        end
        equal([2,3,4,5],numbers.uniq)
      end
      battle(:NONE)
      equal(2,move(:TWINEEDLE).pbNumHits(@user))
      kick=move(:TRIPLEKICK)
      kick.pbOnStartUse(@user)
      equal([20,40,60],3.times.map { kick.pbBaseDamage(kick.basedamage,@user,@foe) })
    end

    def damage_and_phazing
      battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
      equal(0xBB8,move(:MEGAPUNCH).function)
      equal(2.0,move(:MEGAPUNCH).pbCriticalDamageMultiplier)
      equal(2.0,move(:MEGAKICK).pbCriticalDamageMultiplier)
      [:SUBMISSION,:WILDCHARGE,:TAKEDOWN].each do |name|
        battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
        old_hp=@user.hp
        damage=hit(name)
        assert(damage>0,"#{name} did not hit")
        equal([(damage+2)/4,1].max,old_hp-@user.hp)
      end
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      tail=move(:DRAGONTAIL)
      equal(90,tail.pbBaseDamage(60,@user,@foe))
      party=@battle.pbParty(@foe.index)
      party.push(pokemon(:NONE,@battle.opponent,[:PROTECT]))
      equal(60,tail.pbBaseDamage(60,@user,@foe))
      equal(60,move(:CIRCLETHROW).pbBaseDamage(60,@user,@foe))
      equal(60,move(:POISONTAIL).pbBaseDamage(60,@user,@foe))
      astonish=move(:ASTONISH)
      equal(4096,astonish.pbBaseDamageMultiplier(4096,@user,@foe))
      @battle.pbReplace(@foe.index,1)
      equal(6144,astonish.pbBaseDamageMultiplier(4096,@user,@foe))
    end

    def crash
      [:SUPERCELLSLAM,:ROCKCLIMB].each do |name|
        battle(:NONE,:NONE,foe_species: :SNORLAX)
        @battle.define_singleton_method(:pbRandom) { |limit| limit-1 }
        equal(0,hit(name))
        equal(@user.totalhp-@user.totalhp/2,@user.hp)
        equal(@foe.totalhp,@foe.hp)
      end
    end

    def timed_enchant
      battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
      enchant=move(:ENCHANT)
      equal(0,enchant.pbEffect(@user,@foe,0,nil,false))
      equal(@user.index,@foe.effects[PBEffects::Attract])
      equal(3,@foe.effects[PBEffects::AttractTurns])
      2.times { round }
      equal(@user.index,@foe.effects[PBEffects::Attract])
      round
      equal(-1,@foe.effects[PBEffects::Attract])
    end

    def stockpiles_and_wind
      battle(:NOGUARD,:NONE,user_species: :SNORLAX,foe_species: :SNORLAX)
      stockpile=move(:STOCKPILE)
      spit_up=move(:SPITUP)
      swallow=move(:SWALLOW)
      equal(60,spit_up.pbBaseDamage(60,@user,@foe))
      3.times { equal(0,stockpile.pbEffect(@user,@user,0,nil,false)) }
      equal(-1,stockpile.pbEffect(@user,@user,0,nil,false))
      equal(120,spit_up.pbBaseDamage(60,@user,@foe))
      assert(hit(:SPITUP)>0,"Spit Up did not hit")
      equal(2,@user.effects[PBEffects::Stockpile])
      @user.hp=1
      equal(0,swallow.pbEffect(@user,@user,0,nil,false))
      equal(1+(@user.totalhp*3/4),@user.hp)
      equal(1,@user.effects[PBEffects::Stockpile])
      battle(:NONE,:NONE,ally: :WINDRIDER,foe_ally: :NONE,
             outer_ally: :WINDPOWER,outer_foe: :NONE,user_moves: [:RAZORWIND])
      assert(@battle.pbRegisterMove(@user.index,0,false),"Could not select Razor Wind")
      @battle.pbAttackPhase
      [@user,@ally,@outer_ally].each { |battler| equal(1,battler.stages[PBStats::SPEED]) }
      equal(1,@ally.stages[PBStats::ATTACK])
      equal(1,@ally.stages[PBStats::SPATK])
      equal(true,@outer_ally.effects[PBEffects::Charge])
      [@foe,@foe_ally,@outer_foe].each { |battler| equal(battler.totalhp,battler.hp) }
    end
  end

  def self.run
    cases=%i[accuracy_and_secondaries multi_hit damage_and_phazing crash timed_enchant stockpiles_and_wind]
    cases.each do |name|
      AzureAbilityFixture.setup_new_game
      srand(134)
      Scenarios.new.public_send(name)
    rescue StandardError => error
      raise RuntimeError,"#{name}: #{error.message}",error.backtrace
    end
    return cases.length
  end
end
