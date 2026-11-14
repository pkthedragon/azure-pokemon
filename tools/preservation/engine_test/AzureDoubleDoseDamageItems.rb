module AzureDoubleDoseDamageItems
  GEM_MOVES={
    NORMALGEM: :TACKLE, FIREGEM: :EMBER, WATERGEM: :WATERGUN,
    ELECTRICGEM: :THUNDERSHOCK, GRASSGEM: :ABSORB, ICEGEM: :POWDERSNOW,
    FIGHTINGGEM: :ROCKSMASH, POISONGEM: :POISONSTING, GROUNDGEM: :MUDSLAP,
    FLYINGGEM: :GUST, PSYCHICGEM: :CONFUSION, BUGGEM: :STRUGGLEBUG,
    ROCKGEM: :ROCKTHROW, GHOSTGEM: :LICK, DRAGONGEM: :TWISTER,
    DARKGEM: :BITE, STEELGEM: :METALCLAW, FAIRYGEM: :FAIRYWIND
  }.freeze

  STANDARD_RESISTANCE_CASES={
    CHOPLEBERRY: [:ROCKSMASH,:SNORLAX], COBABERRY: [:GUST,:TANGELA],
    KEBIABERRY: [:POISONSTING,:TANGELA], SHUCABERRY: [:MUDSLAP,:RAPIDASH],
    CHARTIBERRY: [:ROCKTHROW,:TALONFLAME], TANGABERRY: [:STRUGGLEBUG,:ESPEON],
    KASIBBERRY: [:LICK,:SLOWBRO], BABIRIBERRY: [:METALCLAW,:SUDOWOODO],
    OCCABERRY: [:EMBER,:TANGELA], PASSHOBERRY: [:WATERGUN,:RAPIDASH],
    RINDOBERRY: [:ABSORB,:GOLDUCK], WACANBERRY: [:THUNDERSHOCK,:GOLDUCK],
    PAYAPABERRY: [:CONFUSION,:MACHOKE], YACHEBERRY: [:POWDERSNOW,:TANGELA],
    HABANBERRY: [:TWISTER,:DRAGONAIR], COLBURBERRY: [:BITE,:ESPEON],
    ROSELIBERRY: [:FAIRYWIND,:DRAGONAIR], CHILANBERRY: [:TACKLE,:SNORLAX]
  }.freeze

  DUAL_RESISTANCE_CASES={
    CORNNBERRY: [:WATERGUN,:ABSORB], MAGOSTBERRY: [:TACKLE,:CONFUSION],
    RABUTABERRY: [:METALCLAW,:THUNDERSHOCK], NOMELBERRY: [:GUST,:POWDERSNOW],
    SPELONBERRY: [:TWISTER,:EMBER], PAMTREBERRY: [:POISONSTING,:MUDSLAP],
    WATMELBERRY: [:STRUGGLEBUG,:FAIRYWIND], DURINBERRY: [:ROCKSMASH,:ROCKTHROW],
    BELUEBERRY: [:BITE,:LICK]
  }.freeze

  module Helpers
    def damage_item_hold(holder,item)
      holder.item=PBItems.const_get(item)
      holder.pokemon.itemInitial=holder.item
    end

    def damage_item_activate(holder)
      move(:DOUBLEDOSE,holder).pbEffect(holder,holder)
    end

    def damage_item_consumed(holder,item,status=PBStatuses::POISON)
      equal(0,holder.item)
      equal(PBItems.const_get(item),holder.pokemon.itemRecycle)
      equal(0,holder.pokemon.itemInitial)
      equal(status,holder.status)
    end

    def resistance_damage(item,move_name,species,doubled)
      battle(:NOGUARD,:NONE,foe_species: species)
      @user.attack=@user.spatk=125
      @foe.defense=@foe.spdef=110
      damage_item_hold(@foe,item)
      damage_item_activate(@foe) if doubled
      @battle.define_singleton_method(:pbRandom) { |limit| limit-1 }
      result=hit(move_name)
      damage_item_consumed(@foe,item,doubled ? PBStatuses::POISON : 0)
      return result
    end

    def field_seed_case(item,field,stat,effect=nil)
      battle(:NONE,:NONE)
      $fefieldeffect=field
      damage_item_hold(@user,item)
      damage_item_activate(@user)
      @battle.seedCheck
      equal(2,@user.stages[stat])
      equal(effect[1],@user.effects[effect[0]]) if effect
      damage_item_consumed(@user,item)
    end
  end

  def self.register(suite)
    AzureAbilityFixture::Scenario.include(Helpers)

    suite.test(:MICLEBERRY) do
      battle(:NONE,:NONE)
      @user.hp=@user.totalhp/4
      @user.stages[PBStats::ACCURACY]=-1
      damage_item_hold(@user,:MICLEBERRY)
      damage_item_activate(@user)
      # Fire Blast accuracy: 85 * (2/3) * 1.2 = 68 normally, 79.33 under Double Dose.
      @battle.define_singleton_method(:pbRandom) { |_limit| 75 }
      assert(move(:FIREBLAST).pbAccuracyCheck(@user,@foe),"The doubled Micle boost should allow this accuracy roll")
      damage_item_consumed(@user,:MICLEBERRY)
    end

    STANDARD_RESISTANCE_CASES.each do |item,(attack,species)|
      suite.test(item) do
        normal=resistance_damage(item,attack,species,false)
        doubled=resistance_damage(item,attack,species,true)
        assert((normal-doubled*2).abs<=1,"Double Dose should apply two #{item} reductions (#{normal} vs. #{doubled})")
      end
    end

    DUAL_RESISTANCE_CASES.each do |item,attacks|
      suite.test(item) do
        attacks.each do |attack|
          normal=resistance_damage(item,attack,:SLOWBRO,false)
          doubled=resistance_damage(item,attack,:SLOWBRO,true)
          assert(doubled<normal && (doubled-(normal*0.75).round).abs<=1,
            "Double Dose should apply two #{item} reductions against #{attack} (#{normal} vs. #{doubled})")
        end
      end
    end

    suite.test(:DURIABERRY) do
      battle(:NOGUARD,:NONE,foe_species: :SLOWBRO)
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
      damage_item_hold(@user,:DURIABERRY)
      normal=hit(:WATERGUN)
      @foe.hp=@foe.totalhp
      damage_item_hold(@user,:DURIABERRY)
      damage_item_activate(@user)
      doubled=hit(:WATERGUN)
      assert(doubled>=normal*2,"Double Dose should apply two Duria boosts")
      damage_item_consumed(@user,:DURIABERRY)
    end

    suite.test(:FURRABERRY) do
      battle(:NOGUARD,:NONE)
      damage_item_hold(@foe,:FURRABERRY)
      damage_item_activate(@foe)
      equal(0,hit(:QUICKATTACK))
      equal(PBItems::FURRABERRY,@foe.item)
      equal(PBStatuses::POISON,@foe.status)
      assert(hit(:TACKLE)>0,"A normal-priority attack should leave the second dose available")
      equal(PBItems::FURRABERRY,@foe.item)
      equal(0,hit(:QUICKATTACK))
      damage_item_consumed(@foe,:FURRABERRY)
      assert(hit(:QUICKATTACK)>0,"Two priority blocks should exhaust the berry")
    end

    GEM_MOVES.each do |item,attack|
      suite.test(item) do
        battle(:NOGUARD,:NONE,user_moves: [attack],foe_moves: [:CELEBRATE],foe_species: :SLOWBRO)
        @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
        damage_item_hold(@user,item)
        damage_item_activate(@user)
        turn(attack,:CELEBRATE)
        assert(@foe.hp<@foe.totalhp,"#{attack} should deal damage")
        damage_item_consumed(@user,item)
      end
    end

    suite.test(:GEM_SPREAD) do
      battle(:NOGUARD,:NONE,user_moves: [:DOUBLEDOSE,:TACKLE],foe_moves: [:CELEBRATE],
        foe_species: :SNORLAX)
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
      damage_item_hold(@user,:NORMALGEM)
      turn(:TACKLE,:CELEBRATE)
      normal=@foe.totalhp-@foe.hp
      damage_item_consumed(@user,:NORMALGEM,0)

      @foe.hp=@foe.totalhp
      damage_item_hold(@user,:NORMALGEM)
      turn(:DOUBLEDOSE,:CELEBRATE)
      turn(:TACKLE,:CELEBRATE)
      assert(@foe.totalhp-@foe.hp>normal,"Double Dose should increase the gem's power bonus")
      damage_item_consumed(@user,:NORMALGEM)

      battle(:NOGUARD,:NONE,user_moves: [:SURF],foe_species: :SNORLAX,foe_ally: :NONE)
      @ally.item=PBItems::WATERGEM
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
      damage_item_hold(@user,:WATERGEM)
      damage_item_activate(@user)
      assert(@battle.pbRegisterMove(@user.index,0,false),"Could not queue Surf")
      @battle.pbAttackPhase
      assert(@foe.hp<@foe.totalhp && @foe_ally.hp<@foe_ally.totalhp,"Surf should hit both opponents")
      equal(1,@scene.messages.count { |message| message.include?("Water Gem strengthened") })
      equal(PBItems::WATERGEM,@ally.item)
      damage_item_consumed(@user,:WATERGEM)
    end

    suite.test(:ELEMENTALSEED) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE)
      $fefieldeffect=1
      damage_item_hold(@user,:ELEMENTALSEED)
      damage_item_hold(@ally,:ELEMENTALSEED)
      damage_item_activate(@user)
      @ally.effects[PBEffects::Embargo]=2
      @battle.seedCheck
      equal(2,@user.stages[PBStats::DEFENSE])
      equal(true,@user.effects[PBEffects::Charge])
      damage_item_consumed(@user,:ELEMENTALSEED)
      equal(PBItems::ELEMENTALSEED,@ally.item)
      equal(0,@ally.stages[PBStats::DEFENSE])
      equal(0,@ally.status)
      @ally.effects[PBEffects::Embargo]=0
      @battle.seedCheck
      equal(2,@ally.stages[PBStats::DEFENSE])
      damage_item_consumed(@ally,:ELEMENTALSEED)
    end

    suite.test(:MAGICALSEED) do
      field_seed_case(:MAGICALSEED,4,PBStats::SPDEF,[PBEffects::MagicCoat,true])
    end

    suite.test(:SYNTHETICSEED) do
      field_seed_case(:SYNTHETICSEED,18,PBStats::SPDEF,[PBEffects::MagnetRise,16])
    end

    suite.test(:TELLURICSEED) do
      field_seed_case(:TELLURICSEED,15,PBStats::ATTACK,[PBEffects::SpikyShield,true])
    end

    suite.test(:RIFTSEED) do
      battle(:NONE,:NONE)
      damage_item_hold(@user,:RIFTSEED)
      damage_item_activate(@user)
      @battle.seedCheck
      equal(PBItems::RIFTSEED,@user.item)
      equal(0,@user.status)
      $fefieldeffect=39
      @user.attack=500
      @battle.seedCheck
      equal(2,@user.stages[PBStats::ATTACK])
      damage_item_consumed(@user,:RIFTSEED)
    end

    suite.test(:FOCUSBAND) do
      battle(:NONE,:NONE)
      damage_item_hold(@user,:FOCUSBAND)
      damage_item_activate(@user)
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
      @user.pbPrepareMoveDamageState
      @user.damagestate.typemod=4
      move(:TACKLE,@foe).pbReduceHPDamage(@user.hp+20,@foe,@user)
      equal(1,@user.hp)
      equal(PBItems::FOCUSBAND,@user.item)
      equal(0,@user.pokemon.itemRecycle)
      equal(0,@user.status)
    end
  end
end
