module AzureMoveMiddleCases
  class Cases < AzureAbilityFixture::Scenario
    def run
      battle(:NONE,:NONE)
      @foe.hp=1
      hit(:PAYDAY)
      equal(3,@user.stages[PBStats::SPATK])

      battle(:GRENADIER,:NONE,ally: :NONE,foe_ally: :NONE)
      @ally.hp=1
      amount=@ally.totalhp*3/4
      hit(:EGGBOMB,@user,@ally)
      equal(1+amount,@ally.hp)
      assert(hit(:EGGBOMB)>0,"Egg Bomb must damage an opponent")
      assert(!@foe.effects[PBEffects::Foresight],"Egg Bomb must not identify a target")

      battle(:NONE,:NONE)
      assert(hit(:MINIMIZE,@user,@foe)==0,"Minimize must be usable on an opponent")
      equal(-1,@foe.stages[PBStats::DEFENSE])
      equal(-1,@foe.stages[PBStats::SPDEF])
      hit(:MINIMIZE,@user,@user)
      equal(2,@user.stages[PBStats::EVASION])
      targets=[]
      @user.pbFindUser([1,0,move(:MINIMIZE),@user.index],targets)
      equal([@user],targets)

      battle(:NONE,:HYPERCUTTER,ally: :NONE,foe_ally: :CLEARBODY)
      hit(:GROWL)
      equal(0,@foe.stages[PBStats::ATTACK])
      equal(-1,@foe.stages[PBStats::SPATK])
      hit(:GROWL,@user,@foe_ally)
      equal(0,@foe_ally.stages[PBStats::ATTACK])
      equal(0,@foe_ally.stages[PBStats::SPATK])
      @foe_ally.pbSuppressAbility
      hit(:GROWL,@user,@foe_ally)
      equal(-1,@foe_ally.stages[PBStats::ATTACK])
      equal(-1,@foe_ally.stages[PBStats::SPATK])

      battle(:NONE,:NONE,user_species: :CHARIZARD)
      hit(:BURNUP)
      assert(!@user.pbHasType?(:FIRE) && @user.pbHasType?(:FLYING),"Burn Up must remove only Fire")
      @battle.instance_variable_set(:@turncount,1)
      assert(!@user.pbHasType?(:FIRE),"Burn Up must persist through the next turn")
      round
      assert(@user.pbHasType?(:FIRE),"Burn Up must expire")

      battle(:NONE,:NONE,foe_species: :PIDGEY)
      rolling=move(:ROLLINGKICK)
      normal=rolling.pbTypeModifier(PBTypes::FIGHTING,@user,@foe)
      @battle.weather=PBWeather::RAINDANCE
      equal(normal,rolling.pbTypeModifier(PBTypes::FIGHTING,@user,@foe))
      @battle.field.effects[PBEffects::HeavyRain]=true
      actual=rolling.pbTypeModifier(PBTypes::FIGHTING,@user,@foe)
      assert(actual==8,"Heavy rain Rolling Thunder should be super effective (#{rolling.class}, weather #{@battle.pbWeather}, electric #{rolling.pbTypeModifier(PBTypes::ELECTRIC,@user,@foe)}, actual #{actual})")

      battle(:NONE,:NONE)
      hit(:HARDEN,@user,@user)
      @battle.instance_variable_set(:@turncount,1)
      assert(!move(:FROSTBREATH,@foe).pbIsCritical?(@foe,@user),"Harden must prevent guaranteed crits next turn")
      @battle.instance_variable_set(:@turncount,2)
      assert(move(:FROSTBREATH,@foe).pbIsCritical?(@foe,@user),"Harden must expire after one protected turn")
      hit(:WITHDRAW,@user,@user)
      @battle.instance_variable_set(:@turncount,3)
      assert(move(:FROSTBREATH,@foe).pbIsCritical?(@foe,@user),"Withdraw must not grant Harden's effect")

      battle(:NONE,:NONE,user_moves: [:FOCUSENERGY,:TACKLE],foe_moves: [:TACKLE])
      hit(:FOCUSENERGY,@user,@user)
      equal(2,@user.effects[PBEffects::FocusEnergy])
      assert(!@user.effects[PBEffects::Endure],"Focus Energy does not grant Endure")
      @battle.instance_variable_set(:@turncount,1)
      @user.effects[PBEffects::Flinch]=true
      turn(:TACKLE,:TACKLE)
      assert(@foe.hp<@foe.totalhp,"Focus Energy must prevent next-turn flinch")

      battle(:NONE,:NONE,user_moves: [:RAGE,:RETURN],foe_moves: [:TACKLE])
      turn(:RAGE,:TACKLE)
      equal(1,@user.stages[PBStats::ATTACK])
      equal(1,@user.stages[PBStats::SPATK])
      assert(@user.effects[PBEffects::FeverPitchBoost],"Fever Pitch must ready a boost")
      turn(:RETURN,:TACKLE)
      assert(!@user.effects[PBEffects::FeverPitchBoost],"The next eligible move must expend Fever Pitch")
    end
  end

  def self.run
    Cases.new.run
  end
end
