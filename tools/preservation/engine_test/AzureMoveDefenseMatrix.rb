module AzureMoveDefenseMatrix
  def self.register(suite)
    { MIRRORCOAT: [PBEffects::MirrorCoatBuff,:WATERGUN,:TACKLE],
      COUNTER: [PBEffects::CounterStance,:TACKLE,:WATERGUN] }.each do |stance,(effect,matching,other)|
      suite.test(stance) do
        battle(:NONE,:MAGICGUARD,outer_ally: :NONE,outer_foe: :NONE,
               user_species: :SHUCKLE,foe_species: :BLISSEY)
        @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
        hit(stance,@user,@user)
        equal(5,@user.effects[effect])
        assert(@battle.pbShiftBattlers(@user.index,@ally.index),"The stance holder could not shift")
        equal(5,@user.effects[effect])
        equal(0,@ally.effects[effect])

        hp=@foe.hp
        assert(hit(matching,@foe,@user)>0,"The matching attack missed")
        equal(hp,@foe.hp)
        @foe.pbSuppressAbility
        assert(hit(other,@foe,@user)>0,"The other attack category missed")
        equal(hp,@foe.hp)

        @user.effects[PBEffects::Substitute]=@user.totalhp/4
        hit(matching,@foe,@user)
        assert(@user.damagestate.substitute,"The attack did not hit the substitute")
        equal(hp,@foe.hp)
        @user.effects[PBEffects::Substitute]=0
        @user.hp=@user.totalhp
        damage=hit(matching,@foe,@user)
        assert(damage>0,"The matching attack missed after ability suppression")
        equal(hp-[damage/4,1].max,@foe.hp)

        round
        equal(4,@user.effects[effect])
        hit(stance,@user,@user)
        equal(4,@user.effects[effect])
        4.times { round }
        equal(0,@user.effects[effect])
      end
    end

    suite.test(:POWERSHIFT) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE,user_species: :SHUCKLE,foe_species: :CRESSELIA,
             user_moves: [:POWERSHIFT],foe_moves: [:QUICKATTACK,:WATERGUN])
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
      physical=hit(:QUICKATTACK,@foe,@user)
      @user.hp=@user.totalhp
      special=hit(:WATERGUN,@foe,@user)
      @user.hp=@user.totalhp
      matrix_shot=hit(:MATRIXSHOT,@foe,@user)
      body_press=hit(:BODYPRESS,@user,@foe)
      @user.hp=@user.totalhp
      choices=@battle.choices
      assert(@battle.pbRegisterMove(@user.index,0,false),"Counterpoise could not be queued")
      assert(@battle.pbRegisterMove(@foe.index,0,false),"Quick Attack could not be queued")
      @battle.pbRegisterTarget(@user.index,@user.index)
      @battle.pbRegisterTarget(@foe.index,@user.index)
      equal(2,@battle.pbMovePriority(@user,choices[@user.index][2],@user))
      equal(1,@battle.pbMovePriority(@foe,choices[@foe.index][2],@user))
      @battle.pbAttackPhase
      assert(@user.effects[PBEffects::Counterpoise],"Counterpoise failed during the attack phase")
      assert(@user.totalhp-@user.hp<physical,"Quick Attack landed before Defense doubled")
      @user.hp=@user.totalhp
      equal(special,hit(:WATERGUN,@foe,@user))
      @user.hp=@user.totalhp
      equal(matrix_shot,hit(:MATRIXSHOT,@foe,@user))
      @foe.hp=@foe.totalhp
      assert(hit(:BODYPRESS,@user,@foe)>body_press,"Body Press missed the temporary Defense boost")
      equal(0,@user.stages[PBStats::DEFENSE])
      round
      equal(@user.attack,@user.pbCalcDefense)

      @user.hp=@user.totalhp
      swapped_physical=hit(:QUICKATTACK,@foe,@user)
      @user.hp=@user.totalhp
      equal(matrix_shot,hit(:MATRIXSHOT,@foe,@user))
      @user.hp=@user.totalhp
      hit(:POWERSHIFT,@user,@user)
      equal(@user.attack*2,@user.pbCalcDefense)
      assert(hit(:QUICKATTACK,@foe,@user)<swapped_physical,"The active swap bypassed doubled Defense")
      round
      equal(@user.defense,@user.pbCalcDefense)
    end
  end
end
