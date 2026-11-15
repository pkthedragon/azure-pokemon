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
  :STONETRIBUTE,  # 9
  :PIXIETRIBUTE,  # 10
  :SKYTRIBUTE,    # 11
  :SPOOKYTRIBUTE, # 12
  :DREADTRIBUTE,  # 13
  :EARTHTRIBUTE,  # 14
  :IRONTRIBUTE,   # 15
  :TOXICTRIBUTE,  # 16
  :INSECTTRIBUTE, # 17
  :DRACOTRIBUTE   # 18
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
  :STONETRIBUTE  => 1760,
  :PIXIETRIBUTE  => 1761,
  :SKYTRIBUTE    => 1762,
  :SPOOKYTRIBUTE => 1763,
  :DREADTRIBUTE  => 1764,
  :EARTHTRIBUTE  => 1765,
  :IRONTRIBUTE   => 1766,
  :TOXICTRIBUTE  => 1767,
  :INSECTTRIBUTE => 1768,
  :DRACOTRIBUTE  => 1769
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
  items = TRIBUTE_ITEMS.select { |item| pbTributeUnlockedItem?(item) }
  items.unshift(current_item_sym) if TRIBUTE_ITEMS.include?(current_item_sym) && !items.include?(current_item_sym)
  names = items.map { |item| PBItems.getName(getID(PBItems,item)) }
  names << _INTL("Cancel")
  return [names, items]
end

def pbChooseTributePokemon(helptext)
  chosen = -1
  pbFadeOutIn(99999) do
    scene = PokemonScreen_Scene.new
    screen = PokemonScreen.new(scene,$Trainer.party)
    screen.pbStartScene(helptext,false)
    begin
      chosen = screen.pbChoosePokemon
    ensure
      screen.pbEndScene
    end
  end
  return chosen
end

def pbChooseDracoTributeMove(pokemon)
  moves = pbGetRelearnableMoves(pokemon)
  assigned = pokemon.tributeDracoMove rescue 0
  moves.unshift(assigned) if assigned && assigned>0 && !moves.include?(assigned)
  if moves.length==0 && (!assigned || assigned<=0)
    Kernel.pbMessage(_INTL("{1} has no relearnable moves to inscribe.",pokemon.name))
    return nil
  end
  commands = moves.map { |move| PBMoves.getName(move) }
  if assigned && assigned>0
    commands << _INTL("Clear Tribute Move")
  end
  commands << _INTL("Cancel")
  cmd = Kernel.pbMessage(_INTL("Assign which relearnable move to the Draco Tribute?"),commands,-1)
  return :clear if assigned && assigned>0 && cmd==moves.length
  return nil if cmd<0 || cmd>=moves.length
  return moves[cmd]
end

def pbAssignDracoTributeMove(pokemon)
  return false if !pokemon || pokemon.isEgg?
  chosen = pbChooseDracoTributeMove(pokemon)
  return false if chosen.nil?
  if chosen==:clear
    pokemon.tributeDracoMove=0
    pokemon.tributeDracoPP=nil
    Kernel.pbMessage(_INTL("{1}'s Draco Tribute was cleared.",pokemon.name))
    return true
  end
  pokemon.tributeDracoMove=chosen
  pokemon.tributeDracoPP=nil
  Kernel.pbMessage(_INTL("{1} was inscribed on {2}'s Draco Tribute.",PBMoves.getName(chosen),pokemon.name))
  return true
end

def pbUseTribute(item, pokemon=nil, held=false)
  index = pbTributeIndexFromID(item)
  return false if !index
  if held
    return false if !pokemon || pokemon.item!=item
  else
    return false if !$PokemonBag.pbHasItem?(item)
  end
  current_sym = TRIBUTE_ITEMS[index]
  if current_sym==:DRACOTRIBUTE
    choice = Kernel.pbMessage(_INTL("What would you like to do with the Draco Tribute?"),
      [_INTL("Assign Tribute Move"),_INTL("Change Attunement"),_INTL("Cancel")],-1)
    if choice==0
      if !pokemon
        party_index = pbChooseTributePokemon(_INTL("Choose a Pokémon to inscribe."))
        return false if party_index<0
        pokemon = $Trainer.party[party_index]
      end
      return pbAssignDracoTributeMove(pokemon)
    end
    return false if choice!=1
  end

  names, items = pbBuildUnlockedTributeLists(current_sym)
  choice = Kernel.pbMessage(_INTL("Change the Tribute's attunement?"),
    names,-1,nil,items.index(current_sym))
  return false if choice<0 || choice>=items.length
  new_item = getID(PBItems,items[choice])
  return true if new_item==item

  if held
    pokemon.setItem(new_item)
    pokemon.calcStats
  elsif !$PokemonBag.pbReplaceOneItem(item,new_item)
    Kernel.pbMessage(_INTL("There is no room for another {1} in the Bag.",PBItems.getName(new_item)))
    return false
  end
  Kernel.pbMessage(_INTL("The Tribute attuned to {1}.",PBItems.getName(new_item)))
  return true
end

TRIBUTE_ITEMS.each do |item|
  ItemHandlers::UseFromBag.add(item,proc { |id| pbUseTribute(id) ? 1 : 0 })
  ItemHandlers::UseOnPokemon.add(item,proc { |id,pokemon,_scene| pbUseTribute(id,pokemon) })
end

def pbTributeMoveMatches?(attacker, item_sym, moveid)
  return false if !attacker || !moveid
  return false if !attacker.respond_to?(:hasWorkingItem) || !attacker.hasWorkingItem(item_sym)
  return false if !attacker.moves || !attacker.moves[0]
  return attacker.moves[0].id == moveid
end

def pbTributeWeatherType(battle)
  return nil if !battle
  harsh = battle.field.effects[PBEffects::HarshSunlight]
  heavy = battle.field.effects[PBEffects::HeavyRain]
  harsh_active = harsh == true || (harsh.is_a?(Numeric) && harsh > 0)
  heavy_active = heavy == true || (heavy.is_a?(Numeric) && heavy > 0)
  return PBTypes::FIRE if battle.pbWeather == PBWeather::SUNNYDAY || harsh_active
  return PBTypes::WATER if battle.pbWeather == PBWeather::RAINDANCE || heavy_active
  return PBTypes::ROCK if battle.pbWeather == PBWeather::SANDSTORM
  return PBTypes::ICE if battle.pbWeather == PBWeather::HAIL
  return nil
end

def pbSpookyTributeVanished?(battler)
  return false if !battler || !battler.respond_to?(:effects)
  return false if battler.effects[PBEffects::SpookyTribute] != 2
  return battler.effects[PBEffects::TwoTurnAttack] > 0
end

HEROIC_POKEMON = {
  :MEADOWTRIBUTE => {
    :TANGROWTH => {
      :species => :TANGROWTH,
      :form => 1,
      :heroic_form => 1
    },
    :SIMISAGE => { :species => :SIMISAGE },
    :BELLOSSOM => { :species => :BELLOSSOM },
    :CRADILY => { :species => :CRADILY },
    :BASTIODON_MYSTIC => { :species => :BASTIODON, :form => 1 }
  },
  :SPLASHTRIBUTE => {
    :SEAKING => { :species => :SEAKING },
    :SIMIPOUR => { :species => :SIMIPOUR },
    :LUMINEON => { :species => :LUMINEON },
    :POLIWRATH => { :species => :POLIWRATH },
    :PHIONE => { :species => :PHIONE }
  },
  :FLAMETRIBUTE => {
    :ARCANINE => { :species => :ARCANINE },
    :SIMISEAR => { :species => :SIMISEAR },
    :MAGMORTAR => { :species => :MAGMORTAR },
    :MOLTRES => { :species => :MOLTRES },
    :GOODRA_MYSTIC => { :species => :GOODRA, :form => 1 }
  },
  :BLANKTRIBUTE => {
    :DUBWOOL => { :species => :DUBWOOL },
    :DELCATTY => { :species => :DELCATTY },
    :WYRDEER => { :species => :WYRDEER },
    :HELIOLISK => { :species => :HELIOLISK },
    :WIGGLYTUFF => { :species => :WIGGLYTUFF }
  },
  :FISTTRIBUTE => {
    :HARIYAMA => { :species => :HARIYAMA },
    :INFERNAPE => { :species => :INFERNAPE },
    :QUAQUAVAL => { :species => :QUAQUAVAL },
    :PASSIMIAN => { :species => :PASSIMIAN },
    :UNFEZANT_MYSTIC => { :species => :UNFEZANT, :form => 1 }
  },
  :MINDTRIBUTE => {
    :MUSHARNA => { :species => :MUSHARNA },
    :HYPNO => { :species => :HYPNO },
    :UNOWN => { :species => :UNOWN },
    :ORANGURU => { :species => :ORANGURU },
    :VICTINI => { :species => :VICTINI }
  },
  :ZAPTRIBUTE => {
    :ZEBSTRIKA => { :species => :ZEBSTRIKA },
    :BOLTUND => { :species => :BOLTUND },
    :ELECTIVIRE => { :species => :ELECTIVIRE },
    :ZAPDOS => { :species => :ZAPDOS },
    :DEDENNE_MYSTIC => { :species => :DEDENNE, :form => 1 }
  },
  :ICICLETRIBUTE => {
    :CRYOGONAL => { :species => :CRYOGONAL },
    :JYNX => { :species => :JYNX },
    :DEWGONG => { :species => :DEWGONG },
    :ARTICUNO => { :species => :ARTICUNO },
    :QUAQUAVAL_MYSTIC => { :species => :QUAQUAVAL, :form => 1 }
  },
  :STONETRIBUTE => {
    :SUDOWOODO => { :species => :SUDOWOODO },
    :RHYPERIOR => { :species => :RHYPERIOR },
    :RAMPARDOS => { :species => :RAMPARDOS },
    :GOLEM => { :species => :GOLEM, :form => 0 },
    :GOLEM_ALOLAN => { :species => :GOLEM, :form => 1 }
  },
  :PIXIETRIBUTE => {
    :COMFEY => { :species => :COMFEY },
    :DEDENNE => { :species => :DEDENNE },
    :DACHSBUN => { :species => :DACHSBUN },
    :FLORGES => { :species => :FLORGES },
    :TOGEKISS => { :species => :TOGEKISS }
  },
  :SKYTRIBUTE => {
    :BRAVIARY => { :species => :BRAVIARY },
    :DELIBIRD => { :species => :DELIBIRD },
    :LEDIAN => { :species => :LEDIAN },
    :UNFEZANT => { :species => :UNFEZANT },
    :FEAROW => { :species => :FEAROW }
  },
  :SPOOKYTRIBUTE => {
    :MISMAGIUS => { :species => :MISMAGIUS },
    :SKELEDIRGE => { :species => :SKELEDIRGE },
    :DUSKNOIR => { :species => :DUSKNOIR },
    :DRIFBLIM => { :species => :DRIFBLIM },
    :CLAYDOL_MYSTIC => { :species => :CLAYDOL, :form => 1 }
  },
  :DREADTRIBUTE => {
    :ABSOL => { :species => :ABSOL },
    :MEOWSCARADA => { :species => :MEOWSCARADA },
    :DRAPION => { :species => :DRAPION },
    :THIEVUL => { :species => :THIEVUL },
    :SKELEDIRGE_MYSTIC => { :species => :SKELEDIRGE, :form => 1 }
  },
  :EARTHTRIBUTE => {
    :SANDSLASH => { :species => :SANDSLASH },
    :TORTERRA => { :species => :TORTERRA },
    :STUNFISK => { :species => :STUNFISK },
    :CLAYDOL => { :species => :CLAYDOL },
    :RAMPARDOS_MYSTIC => { :species => :RAMPARDOS, :form => 1 }
  },
  :IRONTRIBUTE => {
    :ORTHWORM => { :species => :ORTHWORM },
    :EMPOLEON => { :species => :EMPOLEON },
    :BASTIODON => { :species => :BASTIODON },
    :PROBOPASS => { :species => :PROBOPASS },
    :MEOWSCARADA_MYSTIC => { :species => :MEOWSCARADA, :form => 1 }
  },
  :TOXICTRIBUTE => {
    :MUK => { :species => :MUK, :form => 0 },
    :REVAVROOM => { :species => :REVAVROOM },
    :TENTACRUEL => { :species => :TENTACRUEL },
    :CROBAT => { :species => :CROBAT },
    :MUK_MYSTIC => { :species => :MUK, :form => 3 }
  },
  :INSECTTRIBUTE => {
    :SPIDOPS => { :species => :SPIDOPS },
    :ARIADOS => { :species => :ARIADOS },
    :ARMALDO => { :species => :ARMALDO },
    :LEAVANNY => { :species => :LEAVANNY },
    :LEDIAN_MYSTIC => { :species => :LEDIAN, :form => 1 }
  },
  :DRACOTRIBUTE => {
    :DRUDDIGON => { :species => :DRUDDIGON },
    :FLYGON => { :species => :FLYGON },
    :GOODRA => { :species => :GOODRA },
    :TURTONATOR => { :species => :TURTONATOR },
    :DRAPION_MYSTIC => { :species => :DRAPION, :form => 1 }
  }
}

def pbHeroicEntries(pokemon)
  return nil if !pokemon
  tribute_index=pbTributeIndexFromID(pokemon.item)
  return nil if !tribute_index
  return HEROIC_POKEMON[TRIBUTE_ITEMS[tribute_index]]
end

def pbHeroicDataMatches?(pokemon, heroic_data)
  return false if !isConst?(pokemon.species,PBSpecies,heroic_data[:species])
  if heroic_data.has_key?(:form)
    return false if pokemon.form != heroic_data[:form]
  end
  if heroic_data.has_key?(:gender)
    return false if pokemon.gender != heroic_data[:gender]
  end
  return true
end

def pbGetHeroicKey(pokemon)
  entries=pbHeroicEntries(pokemon)
  return nil if !entries
  eligible=entries.select { |_, data| pbHeroicDataMatches?(pokemon,data) }
  return eligible.max_by { |_, data| data.keys.count { |key| key==:form || key==:gender } }&.first
end

def pbHeroicPokemon?(pokemon, heroic_key)
  return false if !heroic_key
  return pbGetHeroicKey(pokemon) == heroic_key
end

# The form getter must resolve the held-item transformation before the
# Heroic battle lookup can match the resulting form.
def pbGetHeroicForm(pokemon)
  entries=pbHeroicEntries(pokemon)
  return nil if !entries
  entry=entries.each_value.find do |data|
    data[:heroic_form] && isConst?(pokemon.species,PBSpecies,data[:species])
  end
  return entry&.[](:heroic_form)
end
