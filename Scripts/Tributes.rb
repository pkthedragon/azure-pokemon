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
  _INTL("Stone Tribute"),
  _INTL("Pixie Tribute"),
  _INTL("Sky Tribute"),
  _INTL("Spooky Tribute"),
  _INTL("Dread Tribute"),
  _INTL("Earth Tribute"),
  _INTL("Iron Tribute"),
  _INTL("Toxic Tribute"),
  _INTL("Insect Tribute"),
  _INTL("Draco Tribute")
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

def pbChooseTributePokemon(helptext)
  chosen = -1
  pbFadeOutIn(99999) do
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    screen.pbStartScene(helptext,false)
    chosen = screen.pbChoosePokemon
    screen.pbEndScene
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
  return false if !pokemon || pokemon.egg?
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

def pbTributeMoveMatches?(attacker, item_sym, moveid)
  return false if !attacker || !moveid
  return false if !attacker.respond_to?(:hasWorkingItem) || !attacker.hasWorkingItem(item_sym)
  return false if !attacker.moves || !attacker.moves[0]
  return attacker.moves[0].id == moveid
end

def pbCurrentTributeUser(battle)
  return nil if !battle
  return nil if !battle.respond_to?(:lastMoveUser) || battle.lastMoveUser.nil? || battle.lastMoveUser<0
  return nil if !battle.respond_to?(:battlers)
  return battle.battlers[battle.lastMoveUser]
end

def pbCurrentTributeMove(battle)
  user = pbCurrentTributeUser(battle)
  return nil if !user || !battle || !battle.respond_to?(:lastMoveUsed)
  return nil if !user.moves || !user.moves[0]
  return nil if user.moves[0].id != battle.lastMoveUsed
  return user.moves[0]
end

def pbCurrentTributeMoveMatches?(battle, item_sym, require_status = nil)
  user = pbCurrentTributeUser(battle)
  move = pbCurrentTributeMove(battle)
  return false if !user || !move
  return false if !pbTributeMoveMatches?(user,item_sym,battle.lastMoveUsed)
  if !require_status.nil?
    return false if require_status && move.basedamage>0
    return false if !require_status && move.basedamage<=0
  end
  return true
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
      :heroic_form => 1,
      :effect => proc { |pokemon, battle|
        next {} if !battle
        if battle.pbWeather == PBWeather::SUNNYDAY
          next { :healing_multiplier => 2.0 }
        end
        next {}
      }
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
    :GOLEM => { :species => :GOLEM },
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
    :MUK => { :species => :MUK },
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

def pbTributeSpeciesSymbol(pokemon)
  return nil if !pokemon
  species_sym = getConstantName(PBSpecies, pokemon.species) rescue nil
  return species_sym.to_sym if species_sym
  return nil
end

def pbHeroicDataMatches?(pokemon, heroic_data)
  return false if !pokemon || !heroic_data
  species_sym = pbTributeSpeciesSymbol(pokemon)
  return false if !species_sym || heroic_data[:species] != species_sym
  if heroic_data.has_key?(:form)
    return false if pokemon.form != heroic_data[:form]
  end
  if heroic_data.has_key?(:gender)
    return false if pokemon.gender != heroic_data[:gender]
  end
  return true
end

def pbGetHeroicKey(pokemon)
  return nil if !pokemon
  tribute_sym = pbGetHeroicTribute(pokemon)
  return nil if !tribute_sym
  heroic_list = HEROIC_POKEMON[tribute_sym] || {}
  heroic_list.each do |heroic_key, heroic_data|
    return heroic_key if pbHeroicDataMatches?(pokemon, heroic_data)
  end
  return nil
end

def pbHeroicPokemon?(pokemon, heroic_key)
  return false if !heroic_key
  return pbGetHeroicKey(pokemon) == heroic_key
end

# Check if a Pokemon is currently in a heroic form
def pbIsHeroicPokemon?(pokemon)
  return !pbGetHeroicKey(pokemon).nil?
end

# Get the heroic form number for a Pokemon holding a tribute
# Returns nil if the combination doesn't create a heroic form
def pbGetHeroicForm(pokemon)
  return nil if !pokemon
  tribute_sym = pbGetHeroicTribute(pokemon)
  heroic_key = pbGetHeroicKey(pokemon)
  return nil if !tribute_sym || !heroic_key
  heroic_data = HEROIC_POKEMON[tribute_sym][heroic_key]
  return heroic_data[:heroic_form] if heroic_data && heroic_data[:heroic_form]
  return nil
end

# Get which tribute makes this Pokemon heroic (if any)
def pbGetHeroicTribute(pokemon)
  return nil if !pokemon
  species_sym = pbTributeSpeciesSymbol(pokemon)
  return nil if !species_sym
  HEROIC_POKEMON.each do |tribute_sym, pokemon_list|
    next if !isConst?(pokemon.item, PBItems, tribute_sym)
    pokemon_list.each_value do |heroic_data|
      if pbHeroicDataMatches?(pokemon, heroic_data)
        return tribute_sym
      end
    end
  end
  return nil
end

# Get the heroic effect modifiers for a Pokemon
# Returns a hash with effect modifiers, or empty hash if not heroic
def pbGetHeroicEffect(pokemon, battle)
  return {} if !pokemon
  tribute_sym = pbGetHeroicTribute(pokemon)
  heroic_key = pbGetHeroicKey(pokemon)
  return {} if !tribute_sym || !heroic_key
  heroic_data = HEROIC_POKEMON[tribute_sym][heroic_key]
  return {} if !heroic_data
  return heroic_data[:effect].call(pokemon, battle) if heroic_data[:effect]
  return {}
end
