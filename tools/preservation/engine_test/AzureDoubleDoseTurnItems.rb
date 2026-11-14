module AzureDoubleDoseTurnItems
  module Checks
    def activate_double_dose(battler=@user)
      equal(0,move(:DOUBLEDOSE,battler).pbEffect(battler,battler))
    end

    def equip(item,battler=@user)
      battler.item=PBItems.const_get(item)
      battler.pokemon.itemInitial=battler.item
      return battler.item
    end

    def consumed(item,battler=@user)
      equal(0,battler.item)
      equal(item,battler.pokemon.itemRecycle)
      equal(0,battler.pokemon.itemInitial)
      equal(PBStatuses::POISON,battler.status)
    end
  end

  def self.test(suite,item,&check)
    suite.test(item) do
      extend Checks
      instance_exec(&check)
    end
  end

  def self.register(suite)
    { BERRYJUICE: 40, ORANBERRY: 20, SITRUSBERRY: :half, ENIGMABERRY: :half,
      FIGYBERRY: :two_thirds, WIKIBERRY: :two_thirds, MAGOBERRY: :two_thirds,
      AGUAVBERRY: :two_thirds, IAPAPABERRY: :two_thirds }.each do |symbol,recovery|
      test(suite,symbol) do
        battle(:NONE,:NONE,outer_ally: :NONE,foe_species: :SNORLAX)
        id=equip(symbol,@outer_ally)
        holder=@outer_ally
        activate_double_dose
        holder.hp=1
        holder.damagestate.typemod=8
        holder.pbBerryCureCheck
        amount=case recovery
               when :half then holder.totalhp/2
               when :two_thirds then holder.totalhp*2/3
               else recovery
               end
        equal(1+amount,holder.hp)
        consumed(id,holder)
      end
    end

    { CHERIBERRY: :PARALYSIS, CHESTOBERRY: :SLEEP, PECHABERRY: :POISON,
      RAWSTBERRY: :BURN, ASPEARBERRY: :FROZEN, LEVIABERRY: :CRUSHED,
      LUMBERRY: :SLEEP }.each do |symbol,condition|
      test(suite,symbol) do
        battle(:NONE)
        id=equip(symbol)
        activate_double_dose
        @user.status=PBStatuses.const_get(condition)
        @user.pbBerryCureCheck
        equal(PBStatuses::POISON,@user.status)
        equal(id,@user.item)
        @user.status=PBStatuses.const_get(condition)
        @user.pbBerryCureCheck
        consumed(id)
      end
    end

    { LIECHIBERRY: PBStats::ATTACK, GANLONBERRY: PBStats::DEFENSE,
      SALACBERRY: PBStats::SPEED, PETAYABERRY: PBStats::SPATK,
      APICOTBERRY: PBStats::SPDEF }.each do |symbol,stat|
      test(suite,symbol) do
        battle(:NONE)
        id=equip(symbol)
        activate_double_dose
        @user.hp=1
        @user.pbBerryCureCheck
        equal(2,@user.stages[stat])
        consumed(id)
      end
    end

    test(suite,:LANSATBERRY) do
      battle(:NONE)
      id=equip(:LANSATBERRY)
      activate_double_dose
      @user.hp=1
      @user.pbBerryCureCheck
      equal(4,@user.effects[PBEffects::FocusEnergy])
      consumed(id)
    end

    test(suite,:STARFBERRY) do
      battle(:CHEEKPOUCH)
      id=equip(:STARFBERRY)
      activate_double_dose
      @user.hp=@user.totalhp-10
      @user.pbBerryCureCheck
      equal(@user.totalhp-10,@user.hp)
      equal(id,@user.item)
      @user.hp=1
      @user.pbBerryCureCheck
      equal(3,@user.stages.compact.max)
      equal(1+@user.totalhp/3,@user.hp)
      consumed(id)
    end

    test(suite,:PERSIMBERRY) do
      battle(:NONE)
      activate_double_dose
      id=equip(:PERSIMBERRY)
      2.times do
        @user.effects[PBEffects::Confusion]=3
        @user.pbBerryCureCheck
        equal(0,@user.effects[PBEffects::Confusion])
      end
      consumed(id)
    end

    test(suite,:LEPPABERRY) do
      battle(:NONE,user_moves: [:TACKLE])
      activate_double_dose
      id=equip(:LEPPABERRY)
      @user.pbSetPP(@user.moves.first,0)
      @user.pbBerryCureCheck
      equal(20,@user.moves.first.pp)
      equal(20,@user.pokemon.moves.first.pp)
      consumed(id)
    end

    test(suite,:HOPOBERRY) do
      battle(:NOGUARD,:NONE,user_moves: [:TACKLE,:GROWL],foe_species: :SNORLAX)
      activate_double_dose
      id=equip(:HOPOBERRY)
      @user.moves.first(2).each { |known| @user.pbSetPP(known,0) }
      hit(:STRUGGLE)
      equal([4,4],@user.pokemon.moves.first(2).map(&:pp))
      consumed(id)
    end

    test(suite,:WHITEHERB) do
      battle(:NONE,:INTIMIDATE)
      activate_double_dose
      id=equip(:WHITEHERB)
      entry(@foe)
      equal(0,@user.stages[PBStats::ATTACK])
      equal(id,@user.item)
      @user.stages[PBStats::SPATK]=-2
      @user.pbBerryCureCheck
      equal(0,@user.stages[PBStats::SPATK])
      consumed(id)
    end

    test(suite,:MIRRORHERB) do
      battle(:NONE,:NONE,user_moves: [:CELEBRATE],foe_moves: [:DRAGONDANCE])
      id=equip(:MIRRORHERB)
      activate_double_dose
      turn(:CELEBRATE,:DRAGONDANCE)
      equal([1,1],@foe.stages.values_at(PBStats::ATTACK,PBStats::SPEED))
      equal([2,2],@user.stages.values_at(PBStats::ATTACK,PBStats::SPEED))
      consumed(id)

      battle(:NONE,:NONE,user_moves: [:DRAGONDANCE],foe_moves: [:CELEBRATE])
      id=equip(:MIRRORHERB,@foe)
      @foe.effects[PBEffects::Embargo]=3
      turn(:DRAGONDANCE,:CELEBRATE)
      equal(id,@foe.item)
      equal(0,@foe.stages[PBStats::ATTACK])
      @foe.effects[PBEffects::Embargo]=0
      @user.stages[PBStats::ATTACK]=0
      @user.stages[PBStats::SPEED]=0
      turn(:DRAGONDANCE,:CELEBRATE)
      equal([1,1],@foe.stages.values_at(PBStats::ATTACK,PBStats::SPEED))
      equal(0,@foe.item)
      equal(0,@foe.status)
    end

    test(suite,:MENTALHERB) do
      battle(:NONE)
      activate_double_dose
      id=equip(:MENTALHERB)
      @user.effects[PBEffects::Taunt]=3
      @user.pbBerryCureCheck
      equal(id,@user.item)
      equal(0,@user.effects[PBEffects::Taunt])
      @user.effects[PBEffects::Disable]=2
      @user.pbBerryCureCheck
      equal(0,@user.effects[PBEffects::Disable])
      consumed(id)
    end

    test(suite,:ADRENALINEORB) do
      battle(:NONE,:INTIMIDATE)
      activate_double_dose
      id=equip(:ADRENALINEORB)
      entry(@foe)
      equal(2,@user.stages[PBStats::SPEED])
      consumed(id)
    end

    test(suite,:ROOMSERVICE) do
      battle(:NONE,:NONE,ally: :NONE)
      activate_double_dose
      id=equip(:ROOMSERVICE,@ally)
      move(:TRICKROOM).pbEffect(@user,@foe)
      equal(-2,@ally.stages[PBStats::SPEED])
      consumed(id,@ally)
      equip(:ROOMSERVICE,@ally)
      move(:TRICKROOM).pbEffect(@user,@foe)
      equal(id,@ally.item)
      equal(-2,@ally.stages[PBStats::SPEED])
    end

    test(suite,:BLUNDERPOLICY) do
      battle(:NONE,:NONE,user_moves: [:FIREBLAST],foe_moves: [:CELEBRATE])
      activate_double_dose
      id=equip(:BLUNDERPOLICY)
      @battle.define_singleton_method(:pbRandom) { |limit| limit-1 }
      @user.stages[PBStats::ACCURACY]=-3
      turn(:FIREBLAST,:CELEBRATE)
      assert(@scene.messages.any? { |message| message.include?("attack grazed") },"Expected an accuracy graze")
      equal(3,@user.stages[PBStats::SPEED])
      consumed(id)

      battle(:NONE,:NONE,user_moves: [:SWEETKISS],foe_moves: [:CELEBRATE])
      id=equip(:BLUNDERPOLICY)
      @battle.define_singleton_method(:pbRandom) { |limit| limit-1 }
      @user.stages[PBStats::ACCURACY]=-3
      turn(:SWEETKISS,:CELEBRATE)
      equal(2,@user.stages[PBStats::SPEED])
      equal(0,@user.item)
      equal(id,@user.pokemon.itemRecycle)
      equal(0,@user.status)
    end

    test(suite,:COCONBERRY) do
      battle(:NONE,:NOGUARD,ally: :NONE)
      activate_double_dose
      id=equip(:COCONBERRY,@ally)
      @ally.pbBerryCureCheck
      shield=@ally.totalhp*2/3
      equal(shield,@ally.pbShieldHP)
      consumed(id,@ally)

      @ally.pbApplyShield(10)
      @ally.pbPrepareMoveDamageState
      move(:TACKLE,@foe).pbReduceHPDamage(shield-5,@foe,@ally)
      equal(@ally.totalhp,@ally.hp)
      equal(15,@ally.pbShieldHP)
      @ally.pbCureStatus(false)
      round
      equal(10,@ally.pbShieldHP)
    end

    test(suite,:FORCED_BERRY_USE) do
      battle(:NONE,:NONE,ally: :NONE,outer_foe: :NONE)
      activate_double_dose
      id=equip(:ORANBERRY,@user)
      equip(:ORANBERRY,@ally)
      equip(:ORANBERRY,@foe)
      @user.hp=@user.totalhp-22
      @ally.hp=@ally.totalhp-22
      @foe.hp=@foe.totalhp-22
      @ally.effects[PBEffects::Embargo]=3
      equal(0,move(:TEATIME).pbEffect(@user,@foe))
      equal(@user.totalhp-2,@user.hp)
      equal(@foe.totalhp-12,@foe.hp)
      equal(@ally.totalhp-22,@ally.hp)
      equal(id,@ally.item)
      consumed(id)
      equal(0,@foe.status)
      equal(0,@foe.item)
      @ally.effects[PBEffects::Embargo]=0
      equal(0,move(:STUFFCHEEKS,@ally).pbEffect(@ally,@ally))
      equal(@ally.totalhp-2,@ally.hp)
      equal(2,@ally.stages[PBStats::DEFENSE])
      consumed(id,@ally)
    end

    test(suite,:CUSTAPBERRY) do
      battle(:NONE,:NONE,user_species: :SHUCKLE,user_moves: [:TACKLE],foe_moves: [:TACKLE])
      @battle.pbRegisterMove(@user.index,0,false)
      @battle.pbRegisterMove(@foe.index,0,false)
      activate_double_dose
      id=equip(:CUSTAPBERRY)
      @user.hp=2
      assert(@user.pbCustapBerry,"The first dose did not activate")
      equal(@user,@battle.pbPriority(false,true).first)
      equal(id,@user.item)
      assert(@user.pbCustapBerry,"The second dose did not activate")
      equal(@user,@battle.pbPriority(false,true).first)
      consumed(id)
    end

    test(suite,:ITEM_SUPPRESSION_AND_EXPIRY) do
      battle(:NONE,:UNNERVE,ally: :IMMUNITY,outer_ally: :NONE)
      activate_double_dose
      first=equip(:ORANBERRY,@ally)
      @ally.hp=1
      @ally.pbBerryCureCheck
      equal(first,@ally.item)
      @foe.ability=PBAbilities::BALLFETCH
      @battle.field.effects[PBEffects::MagicRoom]=3
      @ally.pbBerryCureCheck
      equal(first,@ally.item)
      @battle.field.effects[PBEffects::MagicRoom]=0
      @ally.pbBerryCureCheck
      equal(21,@ally.hp)
      equal(0,@ally.status)
      second=equip(:PERSIMBERRY,@outer_ally)
      @outer_ally.effects[PBEffects::Confusion]=2
      @outer_ally.pbBerryCureCheck
      equal(second,@outer_ally.item)
      @outer_ally.pbCureStatus(false)
      5.times { round }
      equal(0,@outer_ally.item)
      equal(second,@outer_ally.pokemon.itemRecycle)
      equal(0,@outer_ally.status)
      @foe.item=PBItems::ORANBERRY
      @foe.hp=1
      @foe.pbBerryCureCheck
      equal(11,@foe.hp)
      equal(0,@foe.status)
    end

    test(suite,:DOSE_TRANSFER) do
      battle(:NONE,:NONE,ally: :NONE)
      activate_double_dose
      id=equip(:PERSIMBERRY,@user)
      @user.effects[PBEffects::Confusion]=2
      @user.pbBerryCureCheck
      equal(id,@user.item)
      equal(0,move(:BESTOW).pbEffect(@user,@ally))
      equal(0,@user.item)
      equal(id,@ally.item)
      @ally.effects[PBEffects::Confusion]=2
      @ally.pbBerryCureCheck
      equal(0,@ally.effects[PBEffects::Confusion])
      equal(0,@ally.item)
      equal(id,@ally.pokemon.itemRecycle)
      equal(PBStatuses::POISON,@ally.status)
    end
  end
end
