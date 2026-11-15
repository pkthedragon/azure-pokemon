module AzureTributeAICases
  def self.estimate(scenario,move=scenario.user.moves[0])
    scenario.battle_state.pbRoughDamage(move,scenario.user,scenario.foe,100,move.basedamage)
  end

  def self.run(audit)
    AzureCatalogTributes.probe(audit,:TRIBUTE_AI,"damage-prediction-and-suppression") do |scenario|
      scenario.configure(nil,:EEVEE,:TACKLE)
      ordinary=estimate(scenario)
      estimates={}
      [:NULLTRIBUTE,:BLANKTRIBUTE,:FISTTRIBUTE,:FLAMETRIBUTE,:IRONTRIBUTE].each do |item|
        scenario.equip(item)
        damage=estimate(scenario)
        raise "#{item} was ignored in AI damage: #{ordinary} -> #{damage}" if damage<=ordinary
        estimates[item]=damage
      end
      scenario.equip(:FLAMETRIBUTE)
      scenario.user.turncount=1
      raise "Used Flame Tribute after its entry turn" unless estimate(scenario)==ordinary
      scenario.equip(:NULLTRIBUTE)
      scenario.battle_state.field.effects[PBEffects::MagicRoom]=3
      raise "Ignored Magic Room item suppression" unless estimate(scenario)==ordinary
      "ordinary=#{ordinary} #{estimates.inspect}; entry and Magic Room suppression verified"
    end
    AzureCatalogTributes.probe(audit,:TRIBUTE_AI,"pixie-damage-and-score") do |scenario|
      scenario.configure(nil,:DEDENNE,:GROWL)
      raise "A normal status move dealt predicted damage" unless estimate(scenario)==0
      scenario.equip(:PIXIETRIBUTE)
      move=scenario.user.moves[0]
      damage=estimate(scenario)
      score=scenario.battle_state.pbAIRoughDamagePercentForTarget(move,scenario.user,scenario.foe,100)
      raise "Pixie status move still looks non-damaging to the AI" unless damage>0 && score==damage*100/scenario.foe.hp
      "AI predicts #{damage} HP damage (#{score}% of the target's HP)"
    end
    AzureCatalogTributes.probe(audit,:TRIBUTE_AI,"offense-override-and-speed-ratio") do |scenario|
      scenario.configure(nil,:ZEBSTRIKA,:TACKLE)
      scenario.user.attack=45
      scenario.user.spatk=180
      scenario.equip(:FISTTRIBUTE)
      physical=estimate(scenario)
      scenario.equip(:MINDTRIBUTE)
      special=estimate(scenario)
      raise "Mind did not use the stronger Sp. Atk: #{physical} / #{special}" unless special>physical*2
      scenario.equip(:ZAPTRIBUTE)
      scenario.user.speed=scenario.foe.speed
      equal_speed=estimate(scenario)
      scenario.user.speed=scenario.foe.speed*4
      faster=estimate(scenario)
      raise "Zebstrika ignored Electro Ball speed tiers: #{equal_speed} / #{faster}" unless faster>equal_speed*2
      "Attack/Sp. Atk predictions #{physical}/#{special}, speed tiers #{equal_speed}/#{faster}"
    end
    AzureCatalogTributes.probe(audit,:TRIBUTE_AI,"heroic-type-and-accuracy") do |scenario|
      scenario.configure(nil,:DELCATTY,:TACKLE,foe_species: :MISMAGIUS)
      raise "Unmodified Tackle hit Ghost" unless estimate(scenario)==0
      scenario.equip(:BLANKTRIBUTE)
      raise "AI ignored Delcatty's Ghost matchup" unless estimate(scenario)>0
      scenario.configure(nil,:LEAVANNY,:WATERGUN,foe_species: :GROWLITHE)
      normal=estimate(scenario)
      scenario.equip(:INSECTTRIBUTE)
      inverse=estimate(scenario)
      raise "AI ignored Leavanny's inverse matchup #{normal} / #{inverse}" unless inverse>0 && normal>=3*inverse
      scenario.battle_state.field.effects[PBEffects::BlueShift]=3
      raise "AI double-counted Blue Shift with Leavanny" unless estimate(scenario)==normal
      scenario.configure(:MINDTRIBUTE,:VICTINI,:DYNAMICPUNCH)
      move=scenario.user.moves[0]
      accuracy=scenario.battle_state.pbRoughAccuracy(move,scenario.user,scenario.foe,100)
      raise "AI ignored Victini's guaranteed accuracy: #{accuracy}" unless accuracy==100
      "Delcatty can hit a Ghost, Leavanny reverses Water vs Fire with Blue Shift parity, and Victini cannot miss"
    end
  end
end
