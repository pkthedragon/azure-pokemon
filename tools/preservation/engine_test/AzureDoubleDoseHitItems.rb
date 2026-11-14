module AzureDoubleDoseHitItems
  module Checks
    def activate_hit_item(holder,item)
      holder.item=PBItems.const_get(item)
      holder.pokemon.itemInitial=holder.item
      holder.pbOwnSide.effects[PBEffects::DoubleDose]=5
      @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
    end

    def assert_hit_item_consumed(holder,item)
      equal(0,holder.item)
      equal(PBItems.const_get(item),holder.pokemon.itemRecycle)
      equal(0,holder.pokemon.itemInitial)
      equal(PBStatuses::POISON,holder.status)
    end

    def assert_doubled_hit_stat_item(item,attack,stat)
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      activate_hit_item(@foe,item)
      assert(hit(attack)>0,"#{attack} did not land")
      equal(2,@foe.stages[stat])
      assert_hit_item_consumed(@foe,item)
      equal(0,@user.status)
    end

    def assert_doubled_hit_damage_berry(item,attack)
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      activate_hit_item(@foe,item)
      assert(hit(attack)>0,"#{attack} did not land")
      equal(@user.totalhp-@user.totalhp/4,@user.hp)
      assert_hit_item_consumed(@foe,item)
      equal(0,@user.status)
    end
  end

  def self.register(suite)
    AzureAbilityFixture::Scenario.include(Checks)

    suite.test(:AIRBALLOON) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      activate_hit_item(@foe,:AIRBALLOON)
      @foe.effects[PBEffects::Substitute]=@foe.totalhp
      hit(:TACKLE)
      equal(PBItems::AIRBALLOON,@foe.item)
      equal(0,@foe.status)
      @foe.effects[PBEffects::Substitute]=0
      assert(hit(:TACKLE)>0,"Tackle did not land")
      assert_hit_item_consumed(@foe,:AIRBALLOON)
    end

    suite.test(:ABSORBBULB) { assert_doubled_hit_stat_item(:ABSORBBULB,:WATERGUN,PBStats::SPATK) }
    suite.test(:CELLBATTERY) { assert_doubled_hit_stat_item(:CELLBATTERY,:SHOCKWAVE,PBStats::ATTACK) }
    suite.test(:SNOWBALL) { assert_doubled_hit_stat_item(:SNOWBALL,:ICESHARD,PBStats::ATTACK) }
    suite.test(:LUMINOUSMOSS) { assert_doubled_hit_stat_item(:LUMINOUSMOSS,:WATERGUN,PBStats::SPDEF) }
    suite.test(:KEEBERRY) { assert_doubled_hit_stat_item(:KEEBERRY,:TACKLE,PBStats::DEFENSE) }
    suite.test(:MARANGABERRY) { assert_doubled_hit_stat_item(:MARANGABERRY,:WATERGUN,PBStats::SPDEF) }
    suite.test(:JABOCABERRY) { assert_doubled_hit_damage_berry(:JABOCABERRY,:TACKLE) }
    suite.test(:ROWAPBERRY) { assert_doubled_hit_damage_berry(:ROWAPBERRY,:WATERGUN) }

    suite.test(:WEAKNESSPOLICY) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      @foe.type1=PBTypes::FIRE
      @foe.type2=PBTypes::FIRE
      activate_hit_item(@foe,:WEAKNESSPOLICY)
      assert(hit(:TACKLE)>0,"Neutral attack did not land")
      equal(PBItems::WEAKNESSPOLICY,@foe.item)
      equal(0,@foe.status)
      assert(hit(:WATERGUN)>0,"Super-effective attack did not land")
      equal([3,3],@foe.stages.values_at(PBStats::ATTACK,PBStats::SPATK))
      assert_hit_item_consumed(@foe,:WEAKNESSPOLICY)
    end

    suite.test(:THROATSPRAY) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      activate_hit_item(@user,:THROATSPRAY)
      assert(hit(:SONICSCREAM)>0,"Sound attack did not land")
      equal(2,@user.stages[PBStats::SPATK])
      assert_hit_item_consumed(@user,:THROATSPRAY)
    end

    suite.test(:REDCARD) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      activate_hit_item(@foe,:REDCARD)
      @battle.party1.push(pokemon(:NONE,$Trainer,[:TACKLE]))
      attack=move(:TACKLE)
      damage=attack.pbEffect(@user,@foe)
      assert(damage>0,"Tackle did not land")
      @user.pbEffectsOnDealingDamage(attack,@user,@foe,damage,@foe.hp+damage)
      assert(@user.forcedSwitch,"Red Card did not queue a switch for the attacker")
      assert_hit_item_consumed(@foe,:REDCARD)
      equal(0,@user.status)
    end

    suite.test(:EJECTBUTTON) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      activate_hit_item(@foe,:EJECTBUTTON)
      assert(hit(:TACKLE)>0,"Tackle did not land")
      equal(PBItems::EJECTBUTTON,@foe.item)
      equal(0,@foe.status)
      @battle.party2.push(pokemon(:NONE,@battle.opponent,[:TACKLE]))
      attack=move(:TACKLE)
      damage=attack.pbEffect(@user,@foe)
      @user.pbEffectsOnDealingDamage(attack,@user,@foe,damage,@foe.hp+damage)
      assert(@foe.userSwitch,"Eject Button did not queue a switch for its holder")
      assert_hit_item_consumed(@foe,:EJECTBUTTON)
    end

    suite.test(:EJECTPACK) do
      battle(:NONE,:NONE,foe_species: :SNORLAX)
      activate_hit_item(@foe,:EJECTPACK)
      held_pokemon=@foe.pokemon
      @battle.party2.push(pokemon(:NONE,@battle.opponent,[:TACKLE]))
      assert(hit(:MUDSLAP)>0,"Mud Slap did not land")
      equal(-1,@foe.stages[PBStats::ACCURACY])
      assert(@foe.userSwitch,"Eject Pack did not queue a switch for its holder")
      assert_hit_item_consumed(@foe,:EJECTPACK)
      equal(PBStatuses::POISON,held_pokemon.status)
    end
  end
end
