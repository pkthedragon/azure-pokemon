module AzureCustomMovesNew
  def self.register(suite)
    suite.test(:PYRETICRITUAL) do
      battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
      @user.hp=10
      damage=hit(:PYRETICRITUAL)
      assert(damage>0,"Pyretic Ritual failed to hit")
      equal(10+(damage+1)/2,@user.hp)
      assert(PBStuff::DANCEMOVE.include?(PBMoves::PYRETICRITUAL),"Pyretic Ritual lacks Dance")
    end

    suite.test(:ABSOLUTEZERO) do
      battle(:NOGUARD,:NONE,ally: :NONE,foe_ally: :NONE,foe_species: :SNORLAX,
             user_moves: [:TACKLE],foe_moves: [:QUICKATTACK,:TACKLE])
      assert(hit(:ABSOLUTEZERO)>0,"Absolute Zero failed to hit")
      equal(@battle.turncount+1,@foe.effects[PBEffects::AbsoluteZeroTurn])
      @battle.instance_variable_set(:@turncount,@battle.turncount+1)
      @battle.eachActiveBattlerIndex { |index| @battle.pbRegisterMove(index,0,false) }
      equal(@foe,@battle.pbPriority(false,true).first)
      @battle.pbRegisterMove(@foe.index,1,false)
      equal(@foe,@battle.pbPriority(false,true).last)
    end

    suite.test(:MASSHYSTERIA) do
      battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
      hit(:MASSHYSTERIA)
      equal([-1,-1,3],[@user.stages[PBStats::DEFENSE],@user.stages[PBStats::SPDEF],@foe.effects[PBEffects::Confusion]])
    end

    suite.test(:ETHEREALCLOAK) do
      battle(:NONE,:NONE,ally: :NONE)
      @ally.pbApplyGrievousWounds(3)
      equal(0,move(:ETHEREALCLOAK).pbEffect(@user,@user))
      equal(0,@ally.effects[PBEffects::Wounded])
      assert(!@ally.pbApplyGrievousWounds(3),"A protected ally was wounded")
      @ally.hp=1
      equal(15,@ally.pbRecoverHP(10))
      5.times { round }
      assert(@ally.pbApplyGrievousWounds(3),"Cloak lasted longer than five turns")
    end

    suite.test(:KISSOFDEATH) do
      battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
      hit(:KISSOFDEATH)
      assert(@foe.effects[PBEffects::Curse],"The full-HP target went uncursed")
      @user.hp=1
      @foe.hp=1
      hit(:KISSOFDEATH)
      equal(1+@user.totalhp*2/3,@user.hp)
    end

    suite.test(:CLOUDKILL) do
      battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
      hit(:CLOUDKILL)
      equal([1,-1],[@user.stages[PBStats::SPEED],@foe.stages[PBStats::SPEED]])
      @foe.hp=@foe.totalhp
      @user.status=PBStatuses::POISON
      hit(:CLOUDKILL)
      equal([-1,-1],[@foe.stages[PBStats::DEFENSE],@foe.stages[PBStats::SPDEF]])
    end

    suite.test(:RITEOFSPRING) do
      battle(:NOGUARD,:NONE,ally: :NOGUARD,foe_species: :SNORLAX)
      @user.hp=10
      hit(:RITEOFSPRING)
      equal(@user,@foe.pbRiteOfSpringSource)
      amount=hit(:TACKLE,@ally,@foe)
      equal(10+[amount*3/10,1].max,@user.hp)
      @user.hp=0
      equal(nil,@foe.pbRiteOfSpringSource)
    end

    suite.test(:SLOUGHRAY) do
      battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
      hit(:SLOUGHRAY)
      equal([-1,-1],[@user.stages[PBStats::DEFENSE],@foe.stages[PBStats::SPDEF]])
    end

    suite.test(:TIDALSCOUR) do
      battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
      hp=@user.hp
      damage=hit(:TIDALSCOUR)
      equal(hp-[damage/4,1].max,@user.hp)
      equal(PBStatuses::CRUSHED,@foe.status)
    end

    suite.test(:ABRADINGGALE) do
      battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
      assert(move(:ABRADINGGALE).hasHighCriticalRate?,"Missing high critical rate")
      hit(:ABRADINGGALE)
      equal(PBStatuses::CRUSHED,@foe.status)
    end

    suite.test(:NEUROTOXIN) do
      battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
      @foe.status=PBStatuses::POISON
      hit(:NEUROTOXIN)
      equal(PBStatuses::PARALYSIS,@foe.status)
    end

    suite.test(:CALMINGWAKE) do
      battle(:NOGUARD,:NONE,user_species: :SHUCKLE,foe_species: :CRESSELIA,
             user_moves: [:CALMINGWAKE],foe_moves: [:TACKLE])
      turn(:CALMINGWAKE,:TACKLE)
      equal(@foe.totalhp,@foe.hp)
      @user.effects[PBEffects::Confusion]=2
      turn(:CALMINGWAKE,:TACKLE)
      equal(0,@user.effects[PBEffects::Confusion])
      assert(@foe.hp<@foe.totalhp,"Confusion prevented Calming Wake")
    end

    suite.test(:REFRACTINGSTRIKE) do
      battle(:NONE,:NONE,outer_foe: :NONE)
      attack=move(:REFRACTINGSTRIKE)
      equal(PBTargets::SingleNonUser,@user.pbTarget(attack))
      @foe.pbOwnSide.effects[PBEffects::Reflect]=5
      equal(PBTargets::AllOpposing,@user.pbTarget(attack))
      equal(120,attack.pbBaseDamage(80,@user,@foe))
      equal(50,attack.pbScaleTargetDamage(100,@user,@foe))
      @battle.weather=PBWeather::SUNNYDAY
      @battle.field.effects[PBEffects::HarshSunlight]=true
      equal(100,attack.pbScaleTargetDamage(100,@user,@foe))
    end

    suite.test(:DOUBLEDOSE) do
      battle(:NONE,:NONE,ally: :NONE)
      move(:DOUBLEDOSE).pbEffect(@user,@user)
      @ally.item=PBItems::ORANBERRY
      @ally.hp=1
      @ally.pbBerryCureCheck
      equal(21,@ally.hp)
      equal(PBStatuses::POISON,@ally.status)
      equal(0,@ally.item)
      @user.item=PBItems::THROATSPRAY
      hit(:HYPERVOICE)
      equal(2,@user.stages[PBStats::SPATK])
      equal(PBStatuses::POISON,@user.status)
    end

    suite.test(:UNDERTOW) do
      battle(:NONE,:NONE)
      attack=move(:UNDERTOW)
      3.times { equal(0,attack.pbEffect(@user,@foe)) }
      equal(-1,attack.pbEffect(@user,@foe))
      @battle.pbOnActiveOne(@foe)
      equal(PBStatuses::CRUSHED,@foe.status)
      equal(2,@foe.pbOwnSide.effects[PBEffects::Undertow])
    end

    suite.test(:ECHOPLASM) do
      battle(:NOGUARD,:NONE,user_species: :MISDREAVUS,foe_species: :SHUCKLE)
      assert(hit(:ECHOPLASM)>0,"Echoplasm failed to damage a neutral target")
      equal([-1,-1],[@user.stages[PBStats::DEFENSE],@user.stages[PBStats::SPDEF]])
    end

    suite.test(:INQUISITION) do
      battle(:NOGUARD,:NONE,foe_species: :SNORLAX,user_moves: [:INQUISITION,:TACKLE],foe_moves: [:CELEBRATE])
      turn(:INQUISITION,:CELEBRATE)
      equal([1,-1],[@user.stages[PBStats::SPDEF],@foe.stages[PBStats::SPDEF]])
      assert(@user.effects[PBEffects::Inquisition],"Next contact attack was not armed")
      turn(:TACKLE,:CELEBRATE)
      assert(!@user.effects[PBEffects::Inquisition],"Contact attack did not consume the boost")
    end

    suite.test(:DATAMINE) do
      battle(:NOGUARD,:NONE,user_species: :ALAKAZAM,foe_species: :SNORLAX)
      attack=move(:DATAMINE)
      assert(attack.pbIsSpecial?(attack.type),"Datamine should use the higher Special Attack")
      hit(:DATAMINE)
      equal([1,-1],[@user.stages[PBStats::ATTACK],@foe.stages[PBStats::ATTACK]])
    end
  end
end
