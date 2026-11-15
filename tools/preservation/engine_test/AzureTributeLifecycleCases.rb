module AzureTributeLifecycleCases
  def self.reserve(scenario)
    battle=scenario.battle_state
    scenario.scene.define_singleton_method(:partyBetweenKO1) { |_opposing=true| }
    party=battle.pbParty(scenario.user.index)
    party.push(scenario.pokemon(:NONE,$Trainer,[:CELEBRATE],:EEVEE))
    return party.length-1
  end

  def self.run(audit)
    AzureCatalogTributes.probe(audit,:MEADOWTRIBUTE,"tangrowth-registry-form") do |test|
      test.configure(:MEADOWTRIBUTE,:TANGROWTH,:RECOVER,form: 1)
      pokemon=test.user.pokemon
      test.equal(1,pokemon.form)
      test.equal(:TANGROWTH,pbGetHeroicKey(test.user))
      pokemon.setItem(0)
      test.equal(0,pokemon.form)
      test.equal(nil,pbGetHeroicKey(pokemon))
      "Meadow selected and released form 1 through the shared registry"
    end

    AzureCatalogTributes.probe(audit,:STONETRIBUTE,"alolan-golem-survival") do |test|
      test.configure(:STONETRIBUTE,:GOLEM,:TACKLE,form: 1,foe_move: :EARTHQUAKE)
      last_slot=reserve(test)
      user=test.user
      battle=test.battle_state
      test.equal(:GOLEM_ALOLAN,pbGetHeroicKey(user))
      user.hp=5
      test.equal(4,test.strike(test.foe,user))
      test.equal(1,user.hp)
      battle.pbReplace(user.index,last_slot)
      battle.pbReplace(user.index,0)
      user.pbReduceHP(user.hp)
      user.pbFaint
      test.equal(0,user.hp)
      "first lethal hit endured, second lethal hit fainted after switching"
    end

    AzureCatalogTributes.probe(audit,:STONETRIBUTE,"alolan-golem-survival-suppression") do |test|
      test.configure(:STONETRIBUTE,:GOLEM,:TACKLE,form: 1,foe_move: :EARTHQUAKE)
      user=test.user
      field=test.battle_state.field
      field.effects[PBEffects::MagicRoom]=3
      user.hp=5
      test.strike(test.foe,user)
      test.equal(0,user.hp)
      test.equal(nil,test.battle_state.pbTributeOnceUsed?(user.pokemon,:stone_survival))
      "Magic Room prevented survival and left the use unspent"
    end

    AzureCatalogTributes.probe(audit,:STONETRIBUTE,"rampardos-one-priority") do |test|
      move=test.configure(:STONETRIBUTE,:RAMPARDOS,:TACKLE)
      last_slot=reserve(test)
      user=test.user
      battle=test.battle_state
      test.equal(1,move.priority)
      test.attack_turn
      test.equal(0,move.priority)
      battle.pbReplace(user.index,last_slot)
      battle.pbReplace(user.index,0)
      test.equal(0,user.moves[0].priority)
      "initial attack gained priority, switching did not reset the use"
    end

    AzureCatalogTributes.probe(audit,:ICICLETRIBUTE,"cryogonal-hail-priority") do |test|
      move=test.configure(:ICICLETRIBUTE,:CRYOGONAL,:RECOVER)
      test.equal(0,move.priority)
      test.battle_state.weather=PBWeather::HAIL
      test.equal(99,move.priority)
      "inscribed status move goes first during hail"
    end

    AzureCatalogTributes.probe(audit,:ICICLETRIBUTE,"jynx-blinks-before-move") do |test|
      test.configure(:ICICLETRIBUTE,:JYNX,:SCARYFACE)
      foe=test.foe
      foe.stages[PBStats::SPEED]=3
      foe.effects[PBEffects::Ingrain]=true
      test.attack_turn
      test.equal(-2,foe.stages[PBStats::SPEED])
      test.equal(false,foe.effects[PBEffects::Ingrain])
      "target's previous stage and Ingrain cleared before Scary Face"
    end

    AzureCatalogTributes.probe(audit,:ICICLETRIBUTE,"dewgong-quarter-heal") do |test|
      test.configure(:ICICLETRIBUTE,:DEWGONG,:GROWL)
      user=test.user
      user.hp=user.totalhp/2
      initial=user.hp
      test.attack_turn
      test.equal(initial+user.totalhp/4,user.hp)
      "healed one quarter maximum HP after the status move"
    end

    AzureCatalogTributes.probe(audit,:ICICLETRIBUTE,"status-bypass-stays-in-move") do |test|
      move=test.configure(:ICICLETRIBUTE,:EEVEE,:TAILWIND,foe_species: :REGISTEEL)
      battle=test.battle_state
      foe=test.foe
      user=test.user
      foe.item=PBItems::TOXICORB
      foe.pokemon.setItem(PBItems::TOXICORB)
      foe.pbOwnSide.effects[PBEffects::Safeguard]=5
      user.pbUseMove([1,0,move,-1])
      test.equal(move.id,battle.lastMoveUsed)
      test.equal(false,foe.pbIcicleTributeBypassActive?)
      test.advance_round
      test.equal(0,foe.status)
      "last-move state did not bypass Steel typing or Safeguard for Toxic Orb"
    end

    AzureCatalogTributes.probe(audit,:ICICLETRIBUTE,"articuno-duration-source-and-hail") do |test|
      test.configure(:ICICLETRIBUTE,:ARTICUNO,:REFLECT)
      last_slot=reserve(test)
      user=test.user
      foe=test.foe
      battle=test.battle_state
      foe.pbOwnSide.effects[PBEffects::LightScreen]=4
      test.attack_turn
      test.advance_round
      test.equal(3,foe.pbOwnSide.effects[PBEffects::LightScreen])
      9.times { test.advance_round }
      test.assert(user.pbOwnSide.effects[PBEffects::Reflect]>0,"Reflect expired while Articuno was active")
      battle.weather=PBWeather::HAIL
      battle.weatherduration=4
      battle.pbReplace(user.index,last_slot)
      test.advance_round
      test.assert(user.pbOwnSide.effects[PBEffects::Reflect]>0,"Reflect expired in hail after switching")
      battle.weatherduration=1
      test.advance_round
      test.equal(0,battle.weather)
      test.equal(0,user.pbOwnSide.effects[PBEffects::Reflect])
      "Reflect survived its usual duration and an Articuno switch in hail, then expired normally"
    end

    AzureCatalogTributes.probe(audit,:ICICLETRIBUTE,"articuno-trick-room-duration") do |test|
      test.configure(:ICICLETRIBUTE,:ARTICUNO,:TRICKROOM)
      last_slot=reserve(test)
      battle=test.battle_state
      test.attack_turn
      7.times { test.advance_round }
      test.assert(battle.trickroom>0,"Trick Room expired while its Articuno was active")
      battle.pbReplace(test.user.index,last_slot)
      test.advance_round
      test.equal(0,battle.trickroom)
      "field duration ended after the source switched out without hail"
    end

    AzureCatalogTributes.probe(audit,:ICICLETRIBUTE,"articuno-magic-room-self-suppression") do |test|
      test.configure(:ICICLETRIBUTE,:ARTICUNO,:MAGICROOM)
      battle=test.battle_state
      test.attack_turn
      test.equal(false,test.user.hasWorkingItem(:ICICLETRIBUTE))
      7.times { test.advance_round }
      test.assert(battle.field.effects[PBEffects::MagicRoom]>0,"Magic Room suppressed its own extension")
      "Magic Room tracked its eligible item at cast time"
    end

    AzureCatalogTributes.probe(audit,:ICICLETRIBUTE,"mystic-quaquaval-one-turn-protection") do |test|
      test.configure(:ICICLETRIBUTE,:QUAQUAVAL,:GROWL,form: 1)
      user=test.user
      test.equal(:QUAQUAVAL_MYSTIC,pbGetHeroicKey(user))
      test.attack_turn
      test.equal(0.7,user.effects[PBEffects::TributeProtection])
      test.advance_round
      test.equal(0,user.effects[PBEffects::TributeProtection])
      "0.7 damage multiplier was cleared at the turn boundary"
    end

    AzureCatalogTributes.probe(audit,:TOXICTRIBUTE,"muk-delayed-revival") do |test|
      test.configure(:TOXICTRIBUTE,:MUK,:TAILWIND)
      reserve(test)
      pokemon=test.user.pokemon
      test.attack_turn
      test.equal(0,pokemon.hp)
      2.times do
        test.advance_round
        test.equal(0,pokemon.hp)
      end
      test.advance_round
      test.equal(pokemon.totalhp/2,pokemon.hp)
      "regular Muk fainted and revived in reserve after two following turns"
    end

    AzureCatalogTributes.probe(audit,:TOXICTRIBUTE,"mystic-muk-heal-and-defense-ticks") do |test|
      test.configure(:TOXICTRIBUTE,:MUK,:SCARYFACE,form: 3)
      reserve(test)
      user=test.user
      foe=test.foe
      pokemon=user.pokemon
      test.equal(:MUK_MYSTIC,pbGetHeroicKey(user))
      foe.hp=foe.totalhp/2
      initial=foe.hp
      heal=foe.totalhp/8
      test.attack_turn
      test.equal([1,1],foe.stages.values_at(PBStats::DEFENSE,PBStats::SPDEF))
      test.advance_round
      test.equal(initial,foe.hp)
      test.advance_round
      test.equal(initial+heal,foe.hp)
      test.advance_round
      test.equal(initial+heal*2,foe.hp)
      test.equal(0,pokemon.hp)
      test.advance_round
      test.equal([-2,-2],foe.stages.values_at(PBStats::DEFENSE,PBStats::SPDEF))
      test.equal(nil,foe.effects[PBEffects::TributeMukMystic])
      "two delayed 12.5% heals, then the target's defenses dropped by three stages"
    end

    AzureCatalogTributes.probe(audit,:TOXICTRIBUTE,"crobat-only-extends-cast-duration") do |test|
      test.configure(:TOXICTRIBUTE,:CROBAT,:TAILWIND)
      reserve(test)
      test.foe.pbOwnSide.effects[PBEffects::Reflect]=3
      player_side=test.user.pbOwnSide
      test.attack_turn
      test.equal(7,player_side.effects[PBEffects::Tailwind])
      test.equal(3,test.foe.pbOwnSide.effects[PBEffects::Reflect])
      "Tailwind lasts seven turns; an existing opposing Reflect remained unchanged"
    end

    AzureCatalogTributes.probe(audit,:TOXICTRIBUTE,"revavroom-all-opponents") do |test|
      test.configure(:TOXICTRIBUTE,:REVAVROOM,:TAILWIND,format: :triple)
      reserve(test)
      user=test.user
      user.stages[PBStats::ATTACK]=-2
      user.stages[PBStats::SPEED]=-1
      test.attack_turn
      [test.foe,test.foe_ally,test.outer_foe].each do |foe|
        test.equal(-3,foe.stages[PBStats::ACCURACY])
        test.equal(PBStatuses::POISON,foe.status)
        test.equal(1,foe.statusCount)
      end
      "all three opposing lanes lost three Accuracy stages and were badly poisoned"
    end

    AzureCatalogTributes.probe(audit,:TOXICTRIBUTE,"tentacruel-toxic-spikes") do |test|
      test.configure(:TOXICTRIBUTE,:TENTACRUEL,:TAILWIND)
      reserve(test)
      test.attack_turn
      test.equal(1,test.foe.pbOwnSide.effects[PBEffects::ToxicSpikes])
      "inscribed status move set one Toxic Spikes layer"
    end
  end
end
