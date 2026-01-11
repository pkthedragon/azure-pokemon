# Returns the damage multiplier granted by repeated use of the Metronome item
# and the Own Tempo ability.
def pbTempoMultiplierFromRepeat(battler, item_works=true)
  return 1.0 if battler.nil?
  mult = 1.0
  met_count = (battler.respond_to?(:effects) && battler.effects) ? battler.effects[PBEffects::Metronome] : 0
  met_count ||= 0
  ability_active = battler.respond_to?(:hasWorkingAbility) ? battler.hasWorkingAbility(:OWNTEMPO) :
    (battler.respond_to?(:ability) && battler.ability == PBAbilities::OWNTEMPO)
  if ability_active
    mult *= [1.0 + met_count*0.1, 2.0].min
  end
  if item_works && battler.respond_to?(:item) && battler.item == PBItems::METRONOME
    mult *= (met_count>4) ? 2.0 : (1.0 + met_count*0.2)
  end
  return mult
end

# Determines if a battler can skip the usual charging turn for two-turn moves.
def pbHasQuickCharge(battler, item_works=true)
  return false if battler.nil?
  return true if battler.respond_to?(:hasWorkingAbility) && battler.hasWorkingAbility(:INSOMNIA)
  return (item_works && battler.respond_to?(:hasWorkingItem) && battler.hasWorkingItem(:POWERHERB))
end
