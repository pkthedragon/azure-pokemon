module AzureDoubleDoseSurvival
  def self.register(suite)
    suite.test(:POWERHERB) do
      battle(:NOGUARD,:NONE,user_moves: [:DOUBLEDOSE,:RAZORWIND,:BRAINSTORM],
        foe_moves: [:CELEBRATE],foe_species: :LAPRAS)
      @user.item=PBItems::POWERHERB
      turn(:DOUBLEDOSE,:CELEBRATE)
      razor_wind=@user.moves.find { |attack| attack.id==PBMoves::RAZORWIND }
      equal(false,razor_wind.pbTwoTurnAttack(@user,true))
      equal(PBItems::POWERHERB,@user.item)
      equal(0,@user.status)
      equal(false,@user.pbConsumableHeldItemRepeat?(:POWERHERB))
      previous_hp=@foe.hp
      turn(:RAZORWIND,:CELEBRATE)
      assert(@foe.hp<previous_hp,"The first dose did not skip Razor Wind's charge")
      equal(PBStatuses::POISON,@user.status)
      equal(PBItems::POWERHERB,@user.item)
      equal(true,@user.pbConsumableHeldItemRepeat?(:POWERHERB))
      @user.pbCureStatus
      previous_hp=@foe.hp
      turn(:BRAINSTORM,:CELEBRATE)
      assert(@foe.hp<previous_hp,"The second dose did not skip Brainstorm's charge")
      equal(0,@user.effects[PBEffects::TwoTurnAttack])
      equal(0,@user.item)
      equal(PBItems::POWERHERB,@user.pokemon.itemRecycle)
      equal(PBStatuses::POISON,@user.status)

      battle(:NOGUARD,:NONE,user_moves: [:CELEBRATE],foe_species: :LAPRAS)
      move(:DOUBLEDOSE).pbEffect(@user,@user)
      @user.item=PBItems::POWERHERB
      @user.effects[PBEffects::TwoTurnAttack]=PBMoves::RAZORWIND
      equal(false,move(:RAZORWIND).pbTwoTurnAttack(@user))
      equal(false,@user.pbConsumableHeldItemRepeat?(:POWERHERB))
      equal(PBItems::POWERHERB,@user.item)
      equal(0,@user.status)

      @user.effects[PBEffects::TwoTurnAttack]=0
      @user.pokemon.itemInitial=PBItems::POWERHERB
      equal(false,move(:RAZORWIND).pbTwoTurnAttack(@user))
      equal(true,@user.pbConsumableHeldItemRepeat?(:POWERHERB))
      @battle.pbEndOfBattle
      equal(0,@user.pokemon.item)
    end

    suite.test(:FOCUSSASH) do
      battle(:NONE,:NONE,user_moves: [:CELEBRATE],foe_moves: [:TACKLE],foe_species: :RATTATA)
      move(:DOUBLEDOSE).pbEffect(@user,@user)
      @user.item=PBItems::FOCUSSASH
      hit=move(:TACKLE,@foe)
      @user.pbPrepareMoveDamageState
      @user.damagestate.typemod=4
      hit.pbReduceHPDamage(@user.hp+20,@foe,@user)
      equal(1,@user.hp)
      equal(PBStatuses::POISON,@user.status)
      equal(PBItems::FOCUSSASH,@user.item)
      equal(true,@user.pbCanActivateFocusSash?)
      hit.pbEffectMessages(@foe,@user)
      @user.pbCureStatus
      # Keep the same damage state to exercise repeated hits in a single move.
      hit.pbReduceHPDamage(20,@foe,@user,1)
      equal(1,@user.hp)
      equal(0,@user.item)
      equal(PBItems::FOCUSSASH,@user.pokemon.itemRecycle)
      equal(PBStatuses::POISON,@user.status)
      hit.pbEffectMessages(@foe,@user)
      hit.pbReduceHPDamage(20,@foe,@user,2)
      equal(0,@user.hp)
      equal(2,@scene.messages.count { |message| message.include?("hung on using its Focus Sash") })

      battle(:NONE,:NONE)
      @user.item=PBItems::FOCUSSASH
      @user.hp-=1
      equal(false,@user.pbCanActivateFocusSash?)
      @user.hp=@user.totalhp
      hit=move(:TACKLE,@foe)
      @user.pbPrepareMoveDamageState
      @user.damagestate.typemod=4
      hit.pbReduceHPDamage(@user.hp+20,@foe,@user)
      equal(1,@user.hp)
      equal(0,@user.item)
      equal(0,@user.status)

      battle(:NONE,:SKILLLINK,user_moves: [:CELEBRATE],foe_moves: [:BULLETSEED])
      move(:DOUBLEDOSE).pbEffect(@user,@user)
      @user.item=PBItems::FOCUSSASH
      @foe.attack=500
      @battle.define_singleton_method(:pbRandom) { |limit| 0 }
      turn(:CELEBRATE,:BULLETSEED)
      equal(0,@user.hp)
      equal(2,@scene.messages.count { |message| message.include?("hung on using its Focus Sash") })
    end
  end
end
