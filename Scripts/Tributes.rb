TRIBUTE_ITEMS = [
  :NULLTRIBUTE,   # 0
  :MEADOWTRIBUTE, # 1
  :SPLASHTRIBUTE, # 2
  :FLAMETRIBUTE,  # 3
  :BLANKTRIBUTE,  # 4
  :FISTTRIBUTE,   # 5
  :MINDTRIBUTE,   # 6
  :ZAPTRIBUTE,    # 7
  :ICICLETRIBUTE, # 8
  :DREADTRIBUTE,  # 9
  :SPOOKYTRIBUTE    # 10
]

TRIBUTE_NAMES = [
  _INTL("Null Tribute"),
  _INTL("Meadow Tribute"),
  _INTL("Splash Tribute"),
  _INTL("Flame Tribute"),
  _INTL("Blank Tribute"),
  _INTL("Fist Tribute"),
  _INTL("Mind Tribute"),
  _INTL("Zap Tribute"),
  _INTL("Icicle Tribute"),
  _INTL("Dread Tribute"),
  _INTL("Spooky Tribute")
]

TRIBUTE_UNLOCK_SWITCH = {
  :NULLTRIBUTE   => 1751,
  :MEADOWTRIBUTE => 1752,
  :SPLASHTRIBUTE => 1753,
  :FLAMETRIBUTE  => 1754,
  :BLANKTRIBUTE  => 1755,
  :FISTTRIBUTE   => 1756,
  :MINDTRIBUTE   => 1757,
  :ZAPTRIBUTE    => 1758,
  :ICICLETRIBUTE => 1759,
  :DREADTRIBUTE  => 1760,
  :SPOOKYTRIBUTE   => 1761
}

def pbTributeItemIDs
  if !defined?(@tribute_item_ids) || !@tribute_item_ids
    @tribute_item_ids = TRIBUTE_ITEMS.map { |sym| getID(PBItems, sym) }
  end
  return @tribute_item_ids
end

def pbTributeIndexFromID(item_id)
  return pbTributeItemIDs.index(item_id)
end

def pbTributeUnlockedItem?(item_sym)
  switch_id = TRIBUTE_UNLOCK_SWITCH[item_sym]
  return false if !switch_id
  return $game_switches[switch_id]
end

def pbUnlockTributeItem(item_sym)
  switch_id = TRIBUTE_UNLOCK_SWITCH[item_sym]
  return if !switch_id
  $game_switches[switch_id] = true
end

def pbBuildUnlockedTributeLists(current_item_sym = nil)
  names = []
  items = []

  TRIBUTE_ITEMS.each_with_index do |it, i|
    next unless pbTributeUnlockedItem?(it)
    names << TRIBUTE_NAMES[i]
    items << it
  end

  if current_item_sym && !items.include?(current_item_sym)
    idx = TRIBUTE_ITEMS.index(current_item_sym)
    if idx
      names.unshift(TRIBUTE_NAMES[idx])
      items.unshift(current_item_sym)
    end
  end

  names << _INTL("Cancel")
  return [names, items]
end

# Heroic Pokemon System
# Each tribute has ~5 heroic Pokemon that amplify its effect in unique ways
# Format: { tribute_symbol => { species_symbol => { form: X, effect: proc } } }
#
# The effect proc receives (pokemon, battle) and can modify behavior
# Return a hash with keys like :healing_multiplier, :additional_effect, etc.

HEROIC_POKEMON = {
  :MEADOWTRIBUTE => {
    :TANGROWTH => {
      :form => 1,  # Heroic Tangrowth uses form 1
      :description => "Healing becomes 2x during harsh sunlight instead of 1.3x",
      # Effect returns modifiers that the healing code can check
      :effect => proc { |pokemon, battle|
        next {} if !battle
        # Check for harsh sunlight
        if battle.pbWeather == PBWeather::SUNNYDAY
          next { :healing_multiplier => 2.0 }  # 2x instead of standard 1.3x
        end
        next {}
      }
    }
    # Add 4 more heroic Pokemon for Meadow Tribute here
    # Example:
    # :VENUSAUR => {
    #   :form => 1,
    #   :description => "Healing also removes status conditions",
    #   :effect => proc { |pokemon, battle|
    #     next { :cure_status => true }
    #   }
    # }
  }
  # Add more tributes here (SPLASHTRIBUTE, FLAMETRIBUTE, etc.)
  # :SPLASHTRIBUTE => {
  #   :BLASTOISE => { ... },
  #   ...
  # }
}

# Check if a Pokemon is currently in a heroic form
def pbIsHeroicPokemon?(pokemon)
  return false if !pokemon
  species_sym = getConstantName(PBSpecies, pokemon.species) rescue nil
  return false if !species_sym

  HEROIC_POKEMON.each do |tribute_sym, pokemon_list|
    next if !pokemon_list[species_sym.to_sym]
    heroic_data = pokemon_list[species_sym.to_sym]
    if isConst?(pokemon.item, PBItems, tribute_sym) && pokemon.form == heroic_data[:form]
      return true
    end
  end
  return false
end

# Get the heroic form number for a Pokemon holding a tribute
# Returns nil if the combination doesn't create a heroic form
def pbGetHeroicForm(pokemon)
  return nil if !pokemon
  species_sym = getConstantName(PBSpecies, pokemon.species) rescue nil
  return nil if !species_sym

  HEROIC_POKEMON.each do |tribute_sym, pokemon_list|
    next if !pokemon_list[species_sym.to_sym]
    if isConst?(pokemon.item, PBItems, tribute_sym)
      return pokemon_list[species_sym.to_sym][:form]
    end
  end
  return nil
end

# Get which tribute makes this Pokemon heroic (if any)
def pbGetHeroicTribute(pokemon)
  return nil if !pokemon
  species_sym = getConstantName(PBSpecies, pokemon.species) rescue nil
  return nil if !species_sym

  HEROIC_POKEMON.each do |tribute_sym, pokemon_list|
    next if !pokemon_list[species_sym.to_sym]
    if isConst?(pokemon.item, PBItems, tribute_sym)
      return tribute_sym
    end
  end
  return nil
end

# Get the heroic effect modifiers for a Pokemon
# Returns a hash with effect modifiers, or empty hash if not heroic
def pbGetHeroicEffect(pokemon, battle)
  return {} if !pokemon
  species_sym = getConstantName(PBSpecies, pokemon.species) rescue nil
  return {} if !species_sym

  HEROIC_POKEMON.each do |tribute_sym, pokemon_list|
    heroic_data = pokemon_list[species_sym.to_sym]
    next if !heroic_data

    if isConst?(pokemon.item, PBItems, tribute_sym) &&
       pokemon.form == heroic_data[:form] &&
       heroic_data[:effect]
      return heroic_data[:effect].call(pokemon, battle)
    end
  end
  return {}
end
