module AzureMoveDefenseCases
  class Cases < AzureAbilityFixture::Scenario
    def run
      [[:COUNTER,:TACKLE,:WATERGUN],[:MIRRORCOAT,:WATERGUN,:TACKLE]].each do |stance,matching,other|
        battle(:NONE,:NONE,user_species: :SHUCKLE,foe_species: :BLISSEY)
        @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
        assert(move(stance).pbEffect(@user,@user)>=0,"#{stance} did not activate")
        effect=stance==:COUNTER ? PBEffects::CounterStance : PBEffects::MirrorCoatBuff
        equal(5,@user.effects[effect])
        previous=@foe.hp
        assert(hit(other,@foe,@user)>0,"#{other} failed to hit")
        equal(previous,@foe.hp)
        damage=hit(matching,@foe,@user)
        assert(damage>0,"#{matching} failed to hit")
        equal(previous-[damage/4,1].max,@foe.hp)
        5.times { round }
        equal(0,@user.effects[effect])
      end

      battle(:NONE,:NONE,user_species: :SHUCKLE,foe_species: :BLISSEY)
      counterpoise=move(:POWERSHIFT)
      equal(2,counterpoise.priority)
      equal(2,@battle.pbMovePriority(@user,counterpoise,@user))
      defense=@user.pbCalcDefense
      assert(counterpoise.pbEffect(@user,@user)>=0,"Counterpoise did not activate")
      equal(defense*2,@user.pbCalcDefense)
      equal(0,@user.stages[PBStats::DEFENSE])
      round
      assert(@user.effects[PBEffects::PowerTrick],"Counterpoise did not swap Attack and Defense")
      equal(@user.attack,@user.pbCalcDefense)
      assert(!@user.effects[PBEffects::Counterpoise],"Temporary Defense boost did not end")

      battle(:NONE,:NONE,user_moves: [:THUNDERCLAP,:SUCKERPUNCH],foe_moves: [:TACKLE,:SWORDSDANCE])
      thunder_clap=move(:THUNDERCLAP)
      @battle.pbRegisterMove(@foe.index,1,false)
      assert(thunder_clap.pbMoveFailed(@user,@foe),"Thunder Clap must fail against a queued status move")
      @battle.pbRegisterMove(@foe.index,0,false)
      assert(!thunder_clap.pbMoveFailed(@user,@foe),"Thunder Clap must keep its existing attack condition")
      sucker_punch=move(:SUCKERPUNCH)
      equal(1,sucker_punch.priority)
      assert(sucker_punch.isPunchingMove?,"Sucker Punch must use punching boosts like Jet Punch")
      @battle.pbRegisterMove(@foe.index,1,false)
      assert(!sucker_punch.pbMoveFailed(@user,@foe),"Sucker Punch must work against a queued status move")

      {215=>:SLEEPPOWDER,237=>:MUDSLAP,481=>:SANDATTACK,558=>:WATERGUN}.each do |old_id,replacement|
        saved_move=PBMove.allocate
        saved_move.instance_variable_set(:@id,old_id)
        saved_move.instance_variable_set(:@ppup,0)
        saved_move.instance_variable_set(:@pp,2)
        reloaded=Marshal.load(Marshal.dump(saved_move))
        equal(PBMoves.const_get(replacement),reloaded.id)
        equal(2,reloaded.pp)
        assert(!PBMoveData.exists?(old_id),"Retired move #{old_id} has active battle data")
      end
    end
  end

  def self.run
    Cases.new.run
  end
end
