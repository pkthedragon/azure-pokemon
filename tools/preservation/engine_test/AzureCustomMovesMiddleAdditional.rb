module AzureCustomMovesMiddleAdditional
  module Helpers
    def custom_middle_secondary(move_name,chance)
      attack=move(move_name)
      equal(chance,attack.addlEffect)
      @battle.lastMoveUsed=attack.id
      @battle.lastMoveUser=@user.index
      @battle.pbWithStatChangeSource([:move,attack.id]) do
        assert(attack.pbAdditionalEffect(@user,@foe),"#{attack.name} must apply its secondary effect")
      end
    end
  end

  def self.register(suite)
    AzureAbilityFixture::Scenario.include(Helpers)

    suite.test(:PINCERGRIP) do
      battle(:NOGUARD,:NONE,foe_species: :BULBASAUR,ally: :NONE)
      @battle.pbParty(@foe.index).push(pokemon(:NONE,@battle.opponent,[:TACKLE]))
      equal(1,move(:PINCERGRIP).priority)
      assert(hit(:PINCERGRIP)>0,"Pincer Grip must deal damage")
      equal(@user.index,@foe.effects[PBEffects::MeanLook])
      assert(!@battle.pbCanSwitch?(@foe.index,2,false),"Pincer Grip must prevent switching")
      @user.hp=0
      @user.pbFaint
      equal(-1,@foe.effects[PBEffects::MeanLook])

      battle(:NOGUARD,:WONDERGUARD,foe_species: :CHARIZARD)
      equal(0,hit(:PINCERGRIP))
      equal(-1,@foe.effects[PBEffects::MeanLook])
    end

    suite.test(:POISONSWEEP) do
      battle(:NOGUARD,:NONE)
      assert(hit(:POISONSWEEP)>0,"Poison Sweep must deal damage")
      @foe.stages[PBStats::SPEED]=0
      custom_middle_secondary(:POISONSWEEP,30)
      equal(-1,@foe.stages[PBStats::SPEED])
    end

    suite.test(:RANCOR) do
      battle(:NOGUARD,:NONE)
      custom_middle_secondary(:RANCOR,70)
      equal(1,@user.stages[PBStats::ATTACK])
      equal(0,@foe.stages[PBStats::ATTACK])
    end

    suite.test(:RELICSHOT) do
      battle(:NOGUARD,:NONE)
      custom_middle_secondary(:RELICSHOT,20)
      equal(PBStatuses::CRUSHED,@foe.status)
      equal(0,@user.status)
    end

    suite.test(:RIPTIDE) do
      battle(:NOGUARD,:NONE,foe_species: :SLOWBRO)
      assert(hit(:RIPTIDE)>0,"Riptide must deal damage")
      @foe.stages[PBStats::SPEED]=0
      custom_middle_secondary(:RIPTIDE,30)
      equal(-1,@foe.stages[PBStats::SPEED])
    end

    suite.test(:SCAPESHIFT) do
      battle(:NOGUARD,:NONE)
      @foe.hp=101
      hit(:SCAPESHIFT)
      equal(51,@foe.hp)
      @foe.hp=1
      hit(:SCAPESHIFT)
      equal(1,@foe.hp)
    end

    suite.test(:SCRUTINIZE) do
      battle(:NOGUARD,:NONE)
      assert(move(:SCRUTINIZE).isBeamMove?,"Scrutinize is a Beam move")
      @foe.stages[PBStats::DEFENSE]=2
      @foe.stages[PBStats::SPATK]=-1
      @user.stages[PBStats::SPEED]=1
      assert(hit(:SCRUTINIZE)>0,"Scrutinize must deal damage")
      equal(0,@foe.stages[PBStats::DEFENSE])
      equal(0,@foe.stages[PBStats::SPATK])
      equal(1,@user.stages[PBStats::SPEED])
    end

    suite.test(:SERAPHSEMBRACE) do
      battle(:NOGUARD,:NONE)
      @user.gender=0
      @foe.gender=1
      custom_middle_secondary(:SERAPHSEMBRACE,10)
      equal(@user.index,@foe.effects[PBEffects::Attract])
      equal(3,@foe.effects[PBEffects::AttractTurns])
    end

    suite.test(:SHADOWBOX) do
      battle(:NOGUARD,:NONE,foe_species: :SLOWBRO)
      attack=move(:SHADOWBOX)
      assert(attack.isPunchingMove?,"Shadow Box is a Punching move")
      assert(!attack.isContactMove?,"Shadow Box does not make contact")
      custom_middle_secondary(:SHADOWBOX,10)
      equal(3,@foe.effects[PBEffects::Confusion])
    end

    suite.test(:SLASHANDBURN) do
      battle(:NOGUARD,:NONE)
      assert(PBStuff::SLASHINGMOVE.include?(PBMoves::SLASHANDBURN),"Slash and Burn is a Slashing move")
      custom_middle_secondary(:SLASHANDBURN,10)
      equal(PBStatuses::BURN,@foe.status)
    end
  end
end
