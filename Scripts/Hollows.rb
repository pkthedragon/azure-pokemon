#===============================================================================
# Hollow encounter system
# Call from events with: pbStartHollow(hollow_id)
#===============================================================================
module PBHollow
  #---------------------------------------------------------------------------
  # CONFIG
  #---------------------------------------------------------------------------

  # Item used to bait hollows if the party has no scent move
  GOURMET_TREAT = :GOURMETTREAT

  # List of moves that count as "scent moves".
  # Replace / add whatever you want here.
  SCENT_MOVES = [
    :SWEETSCENT,
    :AROMATHERAPY
    # :SCENTSPRAY, :FLOWERSCENT, etc…
  ]

  # each value is an array of entries:
  #   [:pokemon, :SPECIES, level, chance]              # no special move
  #   [:pokemon, :SPECIES, level, chance, :EGGMOVE]    # with extra move
  #   [:item,    :ITEM,    0,     chance]
  #
  # chance is a weight (usually sum to 100 but doesn't *have* to).
  HOLLOW_DATA = {
    [1, 1] => {
      :day => [
        [:pokemon, :WIGLETT, 5, 75, :MEMENTO],
        [:pokemon, :CLOBBOPUS, 5, 25, :SOAK]
      ],
      :night => [
        [:pokemon, :KRABBY, 5, 75, :AGILITY],
        [:pokemon, :CLOBBOPUS, 5, 25, :SOAK]
      ]
    },

    [18, 1] => {
      :any => [
        [:pokemon, :YUNGOOS, 9, 75, :FIREFANG],
        [:pokemon, :DIGLETT, 9, 25, :HEADBUTT]
      ]
    },
	
	[26, 1] => {
      :any => [
        [:pokemon, :RATTATA, 12, 75, :FLAMEWHEEL],
        [:pokemon, :ZIGZAGOON, 12, 25, :PURSUIT]
      ]
    },

    [32, 1] => {
      :any => [
        [:pokemon, :CASCOON, 15, 75, :LOCKON],
        [:pokemon, :NOIBAT, 15, 25, :SNATCH]
      ]
    },

    [34, 1] => {
      :any => [
        [:pokemon, :CASCOON, 15, 75, :ELECTROWEB],
        [:pokemon, :CROAGUNK, 15, 25, :SNATCH]
      ]
    },
	
	[35, 1] => {
      :any => [
        [:pokemon, :EKANS, 18, 100, :POISONFANG]
      ]
    },
	
	[19, 1] => {
      :any => [
        [:pokemon, :HOOTHOOT, 12, 75, :SUPERSONIC],
        [:pokemon, :VENONAT, 12, 25, :MORNINGSUN]
      ]
    },
	
	[55, 1] => {
      :any => [
        [:pokemon, :DIGLETT, 15, 75, :SLASH],
        [:pokemon, :ZUBAT, 15, 25, :QUICKATTACK]
      ]
    },	
	
    [054, 1] => {
      :day => [
        [:pokemon, :WIGLETT, 20, 75, :MEMENTO],
        [:pokemon, :CLOBBOPUS, 20, 25, :SOAK]
      ],
      :night => [
        [:pokemon, :KRABBY, 20, 75, :AGILITY],
        [:pokemon, :CLOBBOPUS, 20, 25, :SOAK]
      ]
    },
  }

  #---------------------------------------------------------------------------
  # Helper – fetch data for this map/hollow
  #---------------------------------------------------------------------------
  def self.data_for(map_id, hollow_id)
    HOLLOW_DATA[[map_id, hollow_id]]
  end
end

#===============================================================================
# Internal helpers
#===============================================================================

# Does any party member know a scent move?
def pbHollowHasScentMove?
  return false if !$Trainer
  $Trainer.party.any? do |pkmn|
    next false if pkmn.nil?
    pkmn.moves.compact.any? do |m|
      PBHollow::SCENT_MOVES.any? { |sym| m.id == getID(PBMoves, sym) }
    end
  end
end

# Consume a Gourmet Treat (asks first). Returns true if actually used.
def pbConsumeGourmetTreatForHollow
  treat_id = getID(PBItems, PBHollow::GOURMET_TREAT)
  return false if !$PokemonBag.pbHasItem?(treat_id)
  return false unless Kernel.pbConfirmMessage(
    _INTL("Use a {1} to lure something out of the hollow?",
          PBItems.getName(treat_id))
  )
  $PokemonBag.pbDeleteItem(treat_id)
  Kernel.pbMessage(_INTL("\\me[Use item]{1} was used.", PBItems.getName(treat_id)))
  return true
end

# Check requirement + handle messages & item usage
# Returns true if the hollow should actually roll an encounter.
def pbCanTriggerHollow?
  # Scent move takes priority and does NOT consume an item
  if pbHollowHasScentMove?
    Kernel.pbMessage(_INTL(
      "A sweet scent from your party drifts into the hollow..."
    ))
    return true
  end

  # Otherwise, see if we can use a Gourmet Treat
  if pbConsumeGourmetTreatForHollow
    Kernel.pbMessage(_INTL(
      "You leave the treat by the hollow and wait..."
    ))
    return true
  end

  Kernel.pbMessage(_INTL(
    "It feels like something is watching from inside..." \
    "Maybe a special treat or a scented move would draw it out."
  ))
  return false
end

# Choose an entry from a weighted list
def pbChooseWeightedEntry(list)
  total = list.inject(0) { |s, e| s + (e[3] || 0) }
  return list[0] if total <= 0
  r = rand(total)
  list.each do |entry|
    r -= entry[3] || 0
    return entry if r < 0
  end
  return list[0]
end

# Pick the correct encounter list for time of day
def pbHollowEncounterListForTime(data_hash)
  # Prefer day/night if present, else :any
  if defined?(PBDayNight)
    if PBDayNight.isNight? && data_hash[:night]
      return data_hash[:night]
    elsif PBDayNight.isDay? && data_hash[:day]
      return data_hash[:day]
    end
  end
  # Fallback
  return data_hash[:any] || data_hash[:day] || data_hash[:night]
end

#===============================================================================
# Main entry point for events
#===============================================================================
# Call: pbStartHollow(hollow_id, map_id=nil)
#  - hollow_id: any integer you use in your map’s hollows (1, 2, 3…)
#  - map_id:    optional; defaults to current map
# Returns true if something happened (battle or item), false otherwise.
#===============================================================================
def pbStartHollow(hollow_id, map_id = nil)
  map_id ||= $game_map.map_id

  data = PBHollow.data_for(map_id, hollow_id)
  if !data
    Kernel.pbMessage(_INTL("This hollow seems empty..."))
    return false
  end

  # Check requirements (scent move or Gourmet Treat)
  return false unless pbCanTriggerHollow?

  list = pbHollowEncounterListForTime(data)
  if !list || list.empty?
    Kernel.pbMessage(_INTL("Nothing answered your call..."))
    return false
  end

 entry = pbChooseWeightedEntry(list)
  entry_type, symbol, level, chance, egg_move = entry

  case entry_type
  when :pokemon
    species_id = getID(PBSpecies, symbol)
    level = 1 if !level || level <= 0
    if egg_move
      $hollowEggMove = egg_move
    else
      $hollowEggMove = nil
    end
    Kernel.pbMessage(_INTL("Something bursts out of the hollow!"))
    pbWildBattle(species_id, level)
    $hollowEggMove = nil
  when :item
    item_id = getID(PBItems, symbol)
    Kernel.pbMessage(_INTL("Something drops out of the hollow..."))
    pbReceiveItem(item_id)
  else
    Kernel.pbMessage(_INTL("The hollow rustles faintly, then goes quiet."))
  end

  return true
end
