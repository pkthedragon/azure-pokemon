module AzureTributeChargeCases
  def self.run(audit)
    AzureCatalogTributes.probe(audit,:SPOOKYTRIBUTE,"charge-continuation") do |test|
      test.configure(:SPOOKYTRIBUTE,:EEVEE,:TACKLE,foe_move: :TACKLE)
      user,foe=test.user,test.foe
      user.speed=300
      original_pp=user.moves[0].pp
      initial_hp=[user.hp,foe.hp]
      test.attack_turn
      test.equal(initial_hp,[user.hp,foe.hp])
      test.assert(pbSpookyTributeVanished?(user),"The holder did not charge in shadow")
      test.advance_round
      test.attack_turn
      test.assert(foe.hp<initial_hp[1],"The charged move did not strike on turn two")
      test.equal(0,user.effects[PBEffects::SpookyTribute])
      test.equal(original_pp-1,user.moves[0].pp)
      "incoming attack missed the charging holder; two turns used one PP"
    end

    AzureCatalogTributes.probe(audit,:SPOOKYTRIBUTE,"native-charge") do |test|
      test.configure(:SPOOKYTRIBUTE,:EEVEE,:METEORBEAM,foe_species: :MILOTIC)
      user,foe=test.user,test.foe
      initial_hp=foe.hp
      test.attack_turn
      test.equal(initial_hp,foe.hp)
      test.equal(1,user.stages[PBStats::SPATK])
      test.assert(pbSpookyTributeVanished?(user),"Meteor Beam omitted shadow charge")
      test.advance_round
      test.attack_turn
      test.equal(1,user.stages[PBStats::SPATK])
      test.assert(foe.hp<initial_hp,"Meteor Beam failed to release on the second turn")
      "Meteor Beam retained its native charge boost and struck after the shadow turn"
    end

    AzureCatalogTributes.probe(audit,:SPOOKYTRIBUTE,"fixed-damage-release") do |test|
      test.configure(:SPOOKYTRIBUTE,:GASTLY,:NIGHTSHADE,foe_species: :MILOTIC)
      test.foe.type1=test.foe.type2=PBTypes::WATER
      initial_hp=test.foe.hp
      test.attack_turn
      test.equal(initial_hp,test.foe.hp)
      test.advance_round
      test.attack_turn
      test.assert(initial_hp-test.foe.hp==75,"Night Shade dealt #{initial_hp-test.foe.hp} HP. #{test.scene.messages.join(' / ')}")
      "level-50 Night Shade released for 75 HP after charging"
    end

    AzureCatalogTributes.probe(audit,:SPOOKYTRIBUTE,"status-move-release") do |test|
      test.configure(:SPOOKYTRIBUTE,:EEVEE,:SWORDSDANCE)
      test.attack_turn
      test.equal(0,test.user.stages[PBStats::ATTACK])
      test.assert(pbSpookyTributeVanished?(test.user),"The status move did not enter shadow")
      test.advance_round
      test.attack_turn
      test.equal(2,test.user.stages[PBStats::ATTACK])
      "Swords Dance charged in shadow, then raised Attack by its usual two stages"
    end

    AzureCatalogTributes.probe(audit,:MISMAGIUS,"spooky-hex-hit-restoration") do |test|
      test.configure(:SPOOKYTRIBUTE,:MISMAGIUS,:HEATWAVE,format: :double)
      user,foe,other_foe=test.user,test.foe,test.foe_ally
      previous=[foe.type1,foe.type2,foe.ability]
      test.attack_turn
      [foe,other_foe].each do |target|
        test.equal([PBTypes::PSYCHIC,PBTypes::PSYCHIC,PBAbilities::OWNTEMPO],[target.type1,target.type2,target.ability])
        test.equal(user.index,target.effects[PBEffects::MeanLook])
      end
      foe.pbReduceHP(1)
      test.equal(PBAbilities::OWNTEMPO,foe.ability)
      test.hit(:TACKLE,test.ally,foe)
      test.equal(previous,[foe.type1,foe.type2,foe.ability])
      test.equal(-1,foe.effects[PBEffects::MeanLook])
      test.equal(PBAbilities::OWNTEMPO,other_foe.ability)
      "both targets were hexed; residual HP loss preserved the hex and a direct hit broke it"
    end

    AzureCatalogTributes.probe(audit,:MISMAGIUS,"spooky-triple-shift-and-suppression") do |test|
      test.configure(:SPOOKYTRIBUTE,:MISMAGIUS,:TACKLE,format: :triple)
      user,foe,battle=test.user,test.foe,test.battle_state
      foe.ability=PBAbilities::NEUTRALIZINGGAS
      test.attack_turn
      test.assert(!battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS),"Hex failed to suspend Neutralizing Gas")
      old_lane=user.index
      test.assert(battle.pbShiftBattlers(old_lane,test.ally.index,move_swap: true),"Source could not shift lanes")
      test.equal(user.index,foe.effects[PBEffects::MeanLook])
      test.hit(:TACKLE,test.ally,foe)
      test.equal(-1,foe.effects[PBEffects::MeanLook])
      test.assert(battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS),"Breaking the hex did not restore Neutralizing Gas")
      "breaking the hex released the shifted source's trap and restored its target's global ability"
    end

    AzureCatalogTributes.probe(audit,:SKELEDIRGE,"spooky-charge-healing") do |test|
      test.configure(:SPOOKYTRIBUTE,:SKELEDIRGE,:TACKLE)
      user=test.user
      user.hp=user.totalhp/2
      prior=user.hp
      test.attack_turn
      test.equal(prior+(user.totalhp*0.3).floor,user.hp)
      "healed 30% maximum HP on the charge turn"
    end

    AzureCatalogTributes.probe(audit,:DUSKNOIR,"spooky-defense-drain") do |test|
      test.configure(:SPOOKYTRIBUTE,:DUSKNOIR,:TACKLE)
      user,foe=test.user,test.foe
      foe.stages[PBStats::SPDEF]=-6
      test.attack_turn
      test.equal([-1,-6],foe.stages.values_at(PBStats::DEFENSE,PBStats::SPDEF))
      test.equal([1,0],user.stages.values_at(PBStats::DEFENSE,PBStats::SPDEF))
      "transferred only the defensive stage the target lost"
    end

    AzureCatalogTributes.probe(audit,:DRIFBLIM,"spooky-fire-and-burn") do |test|
      attack=test.configure(:SPOOKYTRIBUTE,:DRIFBLIM,:TACKLE)
      user=test.user
      test.equal(PBTypes::FIRE,attack.pbType(attack.type,user,test.foe))
      test.attack_turn
      test.equal(PBStatuses::BURN,user.status)
      "became a Fire-type attack and burned Drifblim on charge"
    end

    AzureCatalogTributes.probe(audit,:CLAYDOL_MYSTIC,"spooky-disable") do |test|
      test.configure(:SPOOKYTRIBUTE,:CLAYDOL,:TACKLE,form: 1,foe_move: :TACKLE)
      test.user.speed=300
      test.foe.lastMoveUsed=PBMoves::TACKLE
      test.attack_turn
      test.equal(4,test.foe.effects[PBEffects::Disable])
      test.equal(PBMoves::TACKLE,test.foe.effects[PBEffects::DisableMove])
      "disabled the target's previous move on charge"
    end

    AzureCatalogTributes.probe(audit,:DRACOTRIBUTE,"item-suppression-and-pp") do |test|
      test.configure(:DRACOTRIBUTE,:EEVEE,:TACKLE,foe_species: :MILOTIC)
      user,battle=test.user,test.battle_state
      original=user.moves[0]
      user.pokemon.tributeDracoMove=PBMoves::THUNDERBOLT
      battle.field.effects[PBEffects::MagicRoom]=2
      test.assert(!battle.pbCanDracoTribute?(user.index),"Draco was available in Magic Room")
      battle.field.effects[PBEffects::MagicRoom]=0
      test.assert(battle.pbRegisterDracoTribute(user.index,true),"Draco could not initialize after Magic Room")
      test.equal(PBMoves::THUNDERBOLT,user.moves[0].id)
      alternate=user.moves[0]
      test.attack_turn
      test.equal(alternate.totalpp-1,user.pokemon.tributeDracoPP)
      test.equal(original.totalpp,original.pp)
      test.assert(user.moves[0].equal?(original),"Original slot was not restored")
      "restored availability after suppression and kept independent PP"
    end

    AzureCatalogTributes.probe(audit,:DRACOTRIBUTE,"queued-item-suppression") do |test|
      test.configure(:DRACOTRIBUTE,:EEVEE,:TACKLE)
      user,foe,battle=test.user,test.foe,test.battle_state
      original=user.moves[0]
      user.pokemon.tributeDracoMove=PBMoves::THUNDERBOLT
      battle.pbRegisterDracoTribute(user.index,true)
      test.assert(battle.pbRegisterMove(user.index,0,false),"Could not queue Draco")
      alternate=user.moves[0]
      initial_hp=foe.hp
      battle.field.effects[PBEffects::MagicRoom]=2
      user.pbProcessTurn(battle.choices[user.index])
      test.equal(initial_hp,foe.hp)
      test.equal(alternate.totalpp,alternate.pp)
      test.assert(user.moves[0].equal?(original),"Suppressed Draco did not restore slot one")
      "an earlier same-turn suppression canceled the selected alternate without spending PP"
    end

    AzureCatalogTributes.probe(audit,:DRACOTRIBUTE,"native-charge-pp") do |test|
      test.configure(:DRACOTRIBUTE,:EEVEE,:TACKLE,foe_species: :MILOTIC)
      user,foe,battle=test.user,test.foe,test.battle_state
      original=user.moves[0]
      user.pokemon.tributeDracoMove=PBMoves::METEORBEAM
      battle.pbRegisterDracoTribute(user.index,true)
      alternate=user.moves[0]
      initial_hp=foe.hp
      test.attack_turn
      test.assert(user.moves[0].equal?(alternate),"Draco lost its queued charge")
      test.equal(initial_hp,foe.hp)
      test.advance_round
      test.attack_turn
      test.assert(foe.hp<initial_hp,"Draco failed to finish its queued charge")
      test.equal(alternate.totalpp-1,user.pokemon.tributeDracoPP)
      test.assert(user.moves[0].equal?(original),"Original slot was not restored after a charge move")
      "the registered alternate survived both phases and used one PP"
    end

    AzureCatalogTributes.probe(audit,:DRACOTRIBUTE,"production-ai-score") do |test|
      test.configure(nil,:EEVEE,:CELEBRATE,foe_species: :PASSIMIAN,foe_move: :TACKLE)
      user,foe,battle=test.user,test.foe,test.battle_state
      test.equip(:DRACOTRIBUTE,foe)
      foe.pokemon.tributeDracoMove=PBMoves::CLOSECOMBAT
      battle.pbBuildMoveScores(foe.index)
      battle.pbChooseMoves(foe.index)
      test.equal(PBMoves::CLOSECOMBAT,battle.choices[foe.index][2].id)
      initial_hp=user.hp
      foe.pbProcessTurn(battle.choices[foe.index])
      test.assert(user.hp<initial_hp,"The AI's selected alternate did not execute")
      test.equal(PBMoves::TACKLE,foe.moves[0].id)
      "AI scored and selected the stronger alternate, then restored its ordinary slot"
    end

    AzureCatalogTributes.probe(audit,:DRUDDIGON,"draco-harsh-sun-stab") do |test|
      move=test.configure(:DRACOTRIBUTE,:DRUDDIGON,:TACKLE)
      battle=test.battle_state
      battle.weather=PBWeather::SUNNYDAY
      test.assert(!move.draco_tribute_stab?(test.user),"Ordinary sun activated the override")
      battle.field.effects[PBEffects::HarshSunlight]=true
      test.assert(move.draco_tribute_stab?(test.user),"Harsh sun did not activate the override")
      "harsh sunlight grants STAB; ordinary sunlight leaves it unchanged"
    end

    AzureCatalogTributes.probe(audit,:FLYGON,"draco-sandstorm-extension") do |test|
      test.configure(:DRACOTRIBUTE,:FLYGON,:TACKLE)
      battle=test.battle_state
      test.attack_turn
      test.equal(0,battle.weather)
      test.advance_round
      battle.weather=PBWeather::SANDSTORM
      battle.weatherduration=4
      test.attack_turn
      test.equal(6,battle.weatherduration)
      "extended active sand two turns and left clear weather clear"
    end

    AzureCatalogTributes.probe(audit,:GOODRA,"draco-type-duration") do |test|
      test.configure(:DRACOTRIBUTE,:GOODRA,:WATERPULSE)
      user=test.user
      original=[user.type1,user.type2]
      test.attack_turn
      test.assert(user.pbHasType?(:WATER),"Goodra did not gain the move type")
      2.times { test.advance_round }
      test.assert(user.pbHasType?(:WATER),"Goodra lost the type early")
      test.advance_round
      test.equal(original,[user.type1,user.type2])
      "added the move type for two following turns and restored the original types"
    end

    AzureCatalogTributes.probe(audit,:TURTONATOR,"draco-defense-stat") do |test|
      move=test.configure(:DRACOTRIBUTE,:TURTONATOR,:TACKLE)
      user=test.user
      user.stages[PBStats::DEFENSE]=2
      test.equal([user.defense,5,4096],move.apply_tribute_attack_modifiers(user,1,3,4096,test.foe))
      "Draco attack used Defense and Defense stages"
    end

    AzureCatalogTributes.probe(audit,:DRAPION_MYSTIC,"draco-self-drop-transfer") do |test|
      test.configure(:DRACOTRIBUTE,:DRAPION,:CLOSECOMBAT,form: 1,foe_species: :TANGROWTH)
      user,foe=test.user,test.foe
      user.attack=50
      user.ability=PBAbilities::CONTRARY
      test.attack_turn
      test.equal([1,1],user.stages.values_at(PBStats::DEFENSE,PBStats::SPDEF))
      test.equal([-1,-1],foe.stages.values_at(PBStats::DEFENSE,PBStats::SPDEF))
      "copied Close Combat's drops to the foe while Contrary boosted the user"
    end
  end
end
