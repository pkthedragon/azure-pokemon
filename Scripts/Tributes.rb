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
  :PIXITRIBUTE    # 10
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
  _INTL("Pixie Tribute")
]

TRIBUTE_UNLOCK_SWITCH = {
  :NULLTRIBUTE   => 1000,
  :MEADOWTRIBUTE => 1001,
  :SPLASHTRIBUTE => 1002,
  :FLAMETRIBUTE  => 1003,
  :BLANKTRIBUTE  => 1004,
  :FISTTRIBUTE   => 1005,
  :MINDTRIBUTE   => 1006,
  :ZAPTRIBUTE    => 1007,
  :ICICLETRIBUTE => 1008,
  :DREADTRIBUTE  => 1009,
  :PIXITRIBUTE   => 1010
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
