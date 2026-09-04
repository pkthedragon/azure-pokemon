# Trainer Index - Trainer Battle Encyclopedia
# Tracks and displays trainer battles the player has encountered

class PokemonTrainerIndexScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbScene
    @scene.pbEndScene
  end
end

#===============================================================================
# Main List Scene - Shows all encountered trainers
#===============================================================================
class Scene_TrainerIndex
  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/navbg")

    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Trainer Index"), 94, 0, Graphics.width - 94, 64, @viewport
    )
    @sprites["header"].baseColor = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.new(0, 0, 0)
    @sprites["header"].windowskin = nil

    @choices = pbGetEncounteredTrainers
    @sprites["command_window"] = Window_CommandPokemonWhiteArrow.new(@choices, 324)
    @sprites["command_window"].viewport = @viewport
    @sprites["command_window"].windowskin = nil
    @sprites["command_window"].x = 94
    @sprites["command_window"].y = 64
    @sprites["command_window"].height = Graphics.height - 64

    pbFadeInAndShow(@sprites)
  end

  def pbScene
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)

      if Input.trigger?(Input::B)
        pbPlayCancelSE()
        break
      elsif Input.trigger?(Input::C)
        index = @sprites["command_window"].index
        if index == @choices.length - 1  # "Back" option
          pbPlayCancelSE()
          break
        elsif @choices[index] != "???"
          pbPlayDecisionSE()
          trainer_key = pbGetTrainerKeyFromIndex(index)
          pbShowTrainerDetails(trainer_key)
        else
          pbPlayBuzzerSE()
        end
      end
    end
  end

  def pbShowTrainerDetails(trainer_key)
    scene = Scene_TrainerIndex_Info.new(trainer_key)
    scene.main
  end

  def pbGetEncounteredTrainers
    # Initialize tracking if not present
    if !$PokemonGlobal.respond_to?(:encounteredTrainers)
      $PokemonGlobal.encounteredTrainers = []
    end

    # Load trainer data
    $trainerdata = load_data("Data/trainers.dat") if !$trainerdata

    trainers = []
    @trainer_key_map = []

    # Iterate through all trainers
    $trainerdata.each do |trainer|
      trainerid = trainer[0]
      trainername = trainer[1]
      partyid = trainer[4]

      # Create unique key for this trainer
      key = [trainerid, trainername, partyid]
      @trainer_key_map.push(key)

      # Get trainer type name
      trainertype_name = PBTrainers.getName(trainerid) rescue "???"

      # Check if this trainer has been encountered
      if $PokemonGlobal.encounteredTrainers.include?(key)
        trainers.push("#{trainertype_name} #{trainername}")
      else
        trainers.push("???")
      end
    end

    trainers.push(_INTL("Back"))
    return trainers
  end

  def pbGetTrainerKeyFromIndex(index)
    return @trainer_key_map[index]
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
# Detail View Scene - Shows comprehensive trainer battle information
#===============================================================================
class Scene_TrainerIndex_Info
  def initialize(trainer_key)
    @trainer_key = trainer_key
    @trainerid = trainer_key[0]
    @trainername = trainer_key[1]
    @partyid = trainer_key[2]

    # Use the same first-record lookup semantics as trainer battle loading.
    @trainer_data = AzureTrainerDataCache.record(
      @trainerid,@trainername,@partyid
    )
  end

  def main
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    # Background
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/navbg")

    # Generate trainer info text
    info_text = pbGenerateTrainerInfoText

    # Info window with scrolling
    @sprites["info"] = Window_AdvancedTextPokemon.newWithSize(
      info_text, 10, 10, Graphics.width - 20, Graphics.height - 20, @viewport
    )
    @sprites["info"].baseColor = Color.new(248, 248, 248)
    @sprites["info"].shadowColor = Color.new(80, 80, 80)

    # Scroll position
    @scroll_y = 0
    @max_scroll = [@sprites["info"].contents.height - @sprites["info"].height + 32, 0].max

    pbFadeInAndShow(@sprites)

    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)

      # Scrolling
      if Input.press?(Input::UP) && @scroll_y > 0
        @scroll_y -= 4
        @sprites["info"].oy = @scroll_y
      elsif Input.press?(Input::DOWN) && @scroll_y < @max_scroll
        @scroll_y += 4
        @sprites["info"].oy = @scroll_y
      end

      if Input.trigger?(Input::B) || Input.trigger?(Input::C)
        pbPlayCancelSE()
        break
      end
    end

    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbGenerateTrainerInfoText
    return "No data available." if !@trainer_data

    text = ""

    # Trainer type and name
    trainertype_name = PBTrainers.getName(@trainerid) rescue "Unknown"
    text << "<ac><b>#{trainertype_name} #{@trainername}</b></ac>\n"
    if @partyid > 0
      text << "<ac>(Team #{@partyid})</ac>\n"
    end
    text << "\n"

    # Items
    items = @trainer_data[2]
    if items && items.length > 0
      text << "<c2=5080F0F0>ITEMS:</c2>\n"
      items.each do |item|
        item_name = PBItems.getName(item) rescue item.to_s
        text << "• #{item_name}\n"
      end
      text << "\n"
    end

    # Pokemon party
    party = @trainer_data[3]
    if party && party.length > 0
      text << "<c2=50F0A050>═══ POKEMON TEAM ═══</c2>\n"
      text << "Team Size: #{party.length}\n\n"

      party.each_with_index do |poke, i|
        text << "<c2=50D0D050>Pokemon #{i + 1}:</c2>\n"
        text << pbFormatPokemonInfo(poke)
        text << "\n"
      end
    end

    text << "\n<ac>Press B to return</ac>"

    return text
  end

  def pbFormatPokemonInfo(poke)
    text = ""

    # Constants for trainer pokemon data structure
    TSPECIES = 0
    TPLEVEL = 1
    TPITEM = 2
    TPMOVE1 = 3
    TPMOVE2 = 4
    TPMOVE3 = 5
    TPMOVE4 = 6
    TPABILITY = 7
    TPGENDER = 8
    TPFORM = 9
    TPSHINY = 10
    TPNATURE = 11
    TPIV = 12
    TPSHADOW = 13
    TPNICKNAME = 14
    TPBALL = 15
    TPEV = 16
    TPHAPPINESS = 17
    TPBOSS = 18

    # Species and Level
    species = poke[TSPECIES]
    species_name = PBSpecies.getName(species) rescue species.to_s
    text << "Species: #{species_name}\n"
    text << "Level: #{poke[TPLEVEL]}\n" if poke[TPLEVEL]

    # Form
    if poke[TPFORM] && poke[TPFORM] > 0
      text << "Form: #{poke[TPFORM]}\n"
    end

    # Ability
    if poke[TPABILITY] && poke[TPABILITY] > 0
      ability_name = PBAbilities.getName(poke[TPABILITY]) rescue poke[TPABILITY].to_s
      text << "Ability: #{ability_name}\n"
    end

    # Held Item
    if poke[TPITEM] && poke[TPITEM] > 0
      item_name = PBItems.getName(poke[TPITEM]) rescue poke[TPITEM].to_s
      text << "Item: #{item_name}\n"
    end

    # Nature
    if poke[TPNATURE]
      nature = poke[TPNATURE]
      if nature.is_a?(Symbol)
        nature_name = nature.to_s.capitalize
      elsif nature.is_a?(Integer) && nature > 0
        nature_name = PBNatures.getName(nature) rescue nature.to_s
      else
        nature_name = nil
      end
      text << "Nature: #{nature_name}\n" if nature_name
    end

    # Gender
    if poke[TPGENDER]
      gender = case poke[TPGENDER]
      when 0, "M", "m" then "Male"
      when 1, "F", "f" then "Female"
      when 2 then "Genderless"
      else poke[TPGENDER].to_s
      end
      text << "Gender: #{gender}\n"
    end

    # Shiny
    if poke[TPSHINY] && (poke[TPSHINY] == true || poke[TPSHINY] == "shiny")
      text << "Shiny: Yes\n"
    end

    # Nickname
    if poke[TPNICKNAME] && poke[TPNICKNAME].to_s.length > 0
      text << "Nickname: #{poke[TPNICKNAME]}\n"
    end

    # IVs
    if poke[TPIV]
      text << "IVs: #{poke[TPIV]}\n"
    end

    # EVs
    if poke[TPEV] && poke[TPEV].is_a?(String)
      ev_str = poke[TPEV]
      ev_values = ev_str.split(',').map(&:to_i)
      if ev_values.length == 6
        ev_names = ["HP", "Atk", "Def", "SpA", "SpD", "Spe"]
        ev_display = ev_values.each_with_index.map { |val, i| "#{ev_names[i]}:#{val}" if val > 0 }.compact.join(", ")
        text << "EVs: #{ev_display}\n" if ev_display.length > 0
      else
        text << "EVs: #{ev_str}\n"
      end
    end

    # Happiness
    if poke[TPHAPPINESS] && poke[TPHAPPINESS] > 0
      text << "Happiness: #{poke[TPHAPPINESS]}\n"
    end

    # Moves
    moves = []
    moves << poke[TPMOVE1] if poke[TPMOVE1] && poke[TPMOVE1] > 0
    moves << poke[TPMOVE2] if poke[TPMOVE2] && poke[TPMOVE2] > 0
    moves << poke[TPMOVE3] if poke[TPMOVE3] && poke[TPMOVE3] > 0
    moves << poke[TPMOVE4] if poke[TPMOVE4] && poke[TPMOVE4] > 0

    if moves.length > 0
      text << "Moves:\n"
      moves.each do |move|
        move_name = PBMoves.getName(move) rescue move.to_s
        text << "  • #{move_name}\n"
      end
    end

    # Boss indicator
    if poke[TPBOSS]
      text << "Boss Pokemon: #{poke[TPBOSS]}\n"
    end

    return text
  end
end

#===============================================================================
# Helper Functions
#===============================================================================

# Call this function when a trainer battle starts to register the encounter
def pbRegisterTrainerEncounter(trainerid, trainername, partyid)
  if !$PokemonGlobal.respond_to?(:encounteredTrainers)
    $PokemonGlobal.encounteredTrainers = []
  end

  key = [trainerid, trainername, partyid]

  if !$PokemonGlobal.encounteredTrainers.include?(key)
    $PokemonGlobal.encounteredTrainers.push(key)
  end
end
