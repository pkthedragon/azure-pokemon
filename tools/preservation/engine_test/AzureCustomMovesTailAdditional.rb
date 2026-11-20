module AzureCustomMovesTailAdditional
  def self.register(suite)
    suite.test(:SLEETSTORM) do
      battle(:NONE,:NONE,user_moves: [:SLEETSTORM],ally: :NONE,foe_ally: :NONE)
      sequence=[0,29,0,30]
      @battle.define_singleton_method(:pbRandom) do |limit|
        limit==100 ? (sequence.shift || 30) : 1 % limit
      end
      equal(30,move(:SLEETSTORM).addlEffect)
      @user.pbUseMove([1,0,@user.moves[0],@foe.index])
      assert(@foe.hp<@foe.totalhp && @foe_ally.hp<@foe_ally.totalhp,"Sleet Storm did not hit both foes")
      equal([0,PBStatuses::FROZEN],[@foe.status,@foe_ally.status].sort)
      equal(@ally.totalhp,@ally.hp)
    end

    suite.test(:SLOBBER) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      assert(PBStuff::WHIPMOVE.include?(move(:SLOBBER).id),"Slobber lost Whip")
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
      assert(hit(:SLOBBER)>0,"Slobber did not deal damage")
      equal([-1,-1],[@foe.stages[PBStats::SPEED],@foe.stages[PBStats::ACCURACY]])
    end

    suite.test(:SONICSCREAM) do
      battle(:NONE,:NONE)
      scream=move(:SONICSCREAM)
      @battle.define_singleton_method(:pbRandom) { |limit| limit==100 ? 89 : 1 % limit }
      assert(scream.isSoundBased?,"Sonic Scream lost sound")
      baseline=scream.pbCalcDamage(@user,@foe,PokeBattle_Move::NOCRITICAL)
      @foe.stages[PBStats::EVASION]=3
      assert(scream.pbAccuracyCheck(@user,@foe),"Sonic Scream did not ignore Evasion")
      @foe.stages[PBStats::SPDEF]=3
      equal(baseline,scream.pbCalcDamage(@user,@foe,PokeBattle_Move::NOCRITICAL))
      @foe.stages[PBStats::SPDEF]=-3
      equal(baseline,scream.pbCalcDamage(@user,@foe,PokeBattle_Move::NOCRITICAL))
    end

    suite.test(:SOULJAVELIN) do
      battle(:SKILLLINK,:NONE,user_moves: [:SOULJAVELIN],foe_species: :SNORLAX)
      javelin=move(:SOULJAVELIN)
      @foe.type1=PBTypes::WATER
      @foe.type2=PBTypes::WATER
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
      assert(javelin.pbIsMultiHit && PBStuff::PIERCINGMOVE.include?(javelin.id),
             "Soul Javelin lost Piercing or multihit behavior")
      equal(5,javelin.pbNumHits(@user))
      @user.pbUseMove([1,0,@user.moves[0],@foe.index])
      assert(@scene.messages.any? { |message| message.include?("Hit 5 times!") },"Soul Javelin did not hit five times with Skill Link")
      @user.ability=PBAbilities::BALLFETCH
      equal(3,javelin.pbNumHits(@user))
      @user.item=PBItems::LOADEDDICE
      equal(5,javelin.pbNumHits(@user))
    end

    suite.test(:SOULSIPHON) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      @foe.type1=PBTypes::GROUND
      @foe.type2=PBTypes::GROUND
      @user.hp=1
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
      damage=hit(:SOULSIPHON)
      assert(damage>0,"Soul Siphon did not deal damage")
      equal(1+(damage+1)/2,@user.hp)
    end

    suite.test(:STARDESTROYER) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      assert(move(:STARDESTROYER).isBeamMove?,"Star Destroyer lost Beam")
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
      assert(hit(:STARDESTROYER)>0,"Star Destroyer did not deal damage")
      equal(-2,@user.stages[PBStats::SPATK])
    end

    suite.test(:STOKE) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      stoke=move(:STOKE)
      assert(stoke.pbIsPhysical?(stoke.type) && stoke.isPunchingMove?,"Stoke lost physical Punching")
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
      assert(hit(:STOKE)>0,"Stoke did not deal damage")
      equal([0,1],[@user.stages[PBStats::ATTACK],@user.stages[PBStats::SPATK]])
    end

    suite.test(:STRATOSPHERE) do
      battle(:NONE,:NONE,user_moves: [:STRATOSPHERE])
      assert(PBStuff::WINDMOVE.include?(move(:STRATOSPHERE).id),"Stratosphere lost Wind")
      @user.hp=1
      @user.pbUseMove([1,0,@user.moves[0],@user.index])
      equal(1+@user.totalhp/2,@user.hp)
      @battle.weather=PBWeather::RAINDANCE
      @battle.weatherduration=5
      @user.hp=1
      @user.pbUseMove([1,0,@user.moves[0],@user.index])
      equal(1+@user.totalhp*2/3,@user.hp)
      @user.item=PBItems::UTILITYUMBRELLA
      @user.hp=1
      @user.pbUseMove([1,0,@user.moves[0],@user.index])
      equal(1+@user.totalhp/2,@user.hp)
    end

    suite.test(:THAUMATURGY) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      @battle.define_singleton_method(:pbRandom) { |_limit| 1 }
      assert(hit(:THAUMATURGY)>0,"Thaumaturgy did not deal damage")
      equal(@user.index,@foe.effects[PBEffects::Attract])
      equal(3,@foe.effects[PBEffects::AttractTurns])
      3.times { round }
      equal(-1,@foe.effects[PBEffects::Attract])
      equal(0,@foe.effects[PBEffects::AttractTurns])
    end

    suite.test(:WINDVORTEX) do
      battle(:NONE,:NONE,user_moves: [:WINDVORTEX],foe_moves: [:TACKLE],foe_species: :SNORLAX)
      vortex=move(:WINDVORTEX)
      assert(PBStuff::WINDMOVE.include?(vortex.id),"Wind Vortex lost Wind")
      equal(1,@battle.pbMovePriority(@user,vortex,@foe))
      @user.speed=1
      @foe.speed=100
      @foe.hp=1
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
      turn(:WINDVORTEX,:TACKLE)
      equal(0,@foe.hp)
      equal(@user.totalhp,@user.hp)
    end
  end
end
