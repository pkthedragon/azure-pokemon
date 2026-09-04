# Field Effects Manual - Interactive encyclopedia of field effects
# Displays comprehensive information about each field effect

class PokemonFieldEffectsManualScreen
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
# Main List Scene - Shows all discovered field effects
#===============================================================================
class Scene_FieldEffectsManual
  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/navbg")

    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Field Effects Manual"), 94, 0, Graphics.width - 94, 64, @viewport
    )
    @sprites["header"].baseColor = Color.new(248, 248, 248)
    @sprites["header"].shadowColor = Color.new(0, 0, 0)
    @sprites["header"].windowskin = nil

    @choices = pbFieldEffectsSeen
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
          field_id = pbGetFieldIDFromIndex(index)
          pbShowFieldEffectDetails(field_id)
        else
          pbPlayBuzzerSE()
        end
      end
    end
  end

  def pbShowFieldEffectDetails(field_id)
    scene = Scene_FieldEffectsManual_Info.new(field_id)
    scene.main
  end

  def pbFieldEffectsSeen
    fields = []

    # Map field IDs to their unlock switches
    # Only includes the 20 field effects in the game
    FIELD_ID_TO_SWITCH = {
      1 => 600,   # Electric Terrain
      2 => 601,   # Grassy Terrain
      3 => 602,   # Misty Terrain
      4 => 603,   # Dark Crystal Cavern
      8 => 604,   # Swamp Field
      9 => 605,   # Rainbow Field
      13 => 606,  # Icy Field
      15 => 607,  # Forest Field
      17 => 608,  # Factory Field
      18 => 609,  # Short-circuit Field
      20 => 610,  # Ashen Beach
      21 => 611,  # Water Surface
      23 => 612,  # Cave
      29 => 613,  # Blessed Field
      36 => 614,  # Inverse Field
      37 => 615,  # Psychic Terrain
      40 => 616,  # Cursed Field
      42 => 617,  # Bewitched Woods
      45 => 618,  # Beach Field
      47 => 619   # Library Field
    }

    @field_id_map = []  # Store the mapping for index -> field_id

    FIELD_ID_TO_SWITCH.each do |field_id, switch_id|
      if $game_switches[switch_id]
        name = pbGetFieldEffectName(field_id)
        fields.push(name)
        @field_id_map.push(field_id)
      else
        fields.push("???")
        @field_id_map.push(nil)
      end
    end

    fields.push(_INTL("Back"))
    return fields
  end

  def pbGetFieldIDFromIndex(index)
    return @field_id_map[index]
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
# Detail View Scene - Shows comprehensive field effect information
#===============================================================================
class Scene_FieldEffectsManual_Info
  def initialize(field_id)
    @field_id = field_id
    @data = pbGetFieldEffectData(field_id)
  end

  def main
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    # Background
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/navbg")

    # Generate field info text
    info_text = pbGenerateFieldInfoText

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

  def pbGenerateFieldInfoText
    return "No data available." if !@data

    text = ""

    # Header
    text << "<ac><b>#{@data[:name]}</b></ac>\n"
    text << "<ac>(#{@data[:abbr]})</ac>\n\n"
    text << "\"<i>#{@data[:message]}</i>\"\n\n"

    # Passive Effects
    if @data[:passiveEffects] && @data[:passiveEffects].length > 0
      text << "<c2=5080F0F0>PASSIVE EFFECTS</c2>\n"
      @data[:passiveEffects].each do |effect|
        text << "• #{effect}\n"
      end
      text << "\n"
    end

    # How it's created
    if @data[:createdBy]
      text << "<c2=5080F0F0>CREATED BY</c2>\n"
      if @data[:createdBy][:moves]
        text << "Moves: #{@data[:createdBy][:moves].join(', ')}\n"
      end
      if @data[:createdBy][:abilities]
        text << "Abilities: #{@data[:createdBy][:abilities].join(', ')}\n"
      end
      if @data[:createdBy][:duration]
        text << "Duration: #{@data[:createdBy][:duration]} turns\n"
      end
      if @data[:createdBy][:note]
        text << "Note: #{@data[:createdBy][:note]}\n"
      end
      text << "\n"
    end

    # Overlay Effects
    if @data[:overlayEffects] && @data[:overlayEffects][:effects] &&
       @data[:overlayEffects][:effects].length > 0
      text << "<c2=5080F0F0>#{@data[:overlayEffects][:terrain].upcase} OVERLAY</c2>\n"
      @data[:overlayEffects][:effects].each do |effect|
        text << "• #{effect}\n"
      end
      text << "\n"
    end

    # Field Damage
    if @data[:fieldDamage]
      text << "<c2=50F08080>FIELD DAMAGE</c2>\n"
      fd = @data[:fieldDamage]
      text << "Damage: #{fd[:amount]}\n" if fd[:amount]
      text << "Timing: #{fd[:timing]}\n" if fd[:timing]
      text << "Affects: #{fd[:affects]}\n" if fd[:affects]
      if fd[:immuneAbilities] && fd[:immuneAbilities].length > 0
        text << "Immune Abilities: #{fd[:immuneAbilities].join(', ')}\n"
      end
      if fd[:immuneConditions] && fd[:immuneConditions].length > 0
        text << "Immune Conditions: #{fd[:immuneConditions].join(', ')}\n"
      end
      if fd[:doubledAbilities] && fd[:doubledAbilities].length > 0
        text << "Doubled Damage: #{fd[:doubledAbilities].join(', ')}\n"
      end
      text << "\n"
    end

    # Move Effects
    if @data[:moveEffects]
      me = @data[:moveEffects]

      # Power Boosts
      if me[:powerBoost] && me[:powerBoost].keys.length > 0
        text << "<c2=50F0A050>POWER BOOSTS</c2>\n"
        me[:powerBoost].each do |multiplier, moves|
          text << "x#{multiplier}: #{moves.join(', ')}\n"
        end
        text << "\n"
      end

      # Power Decreases
      if me[:powerDecrease] && me[:powerDecrease].keys.length > 0
        text << "<c2=50F05050>POWER DECREASES</c2>\n"
        me[:powerDecrease].each do |multiplier, moves|
          text << "x#{multiplier}: #{moves.join(', ')}\n"
        end
        text << "\n"
      end

      # Additional Damage Types
      if me[:additionalDamageType] && me[:additionalDamageType].keys.length > 0
        text << "<c2=50D0D050>ADDITIONAL DAMAGE TYPES</c2>\n"
        me[:additionalDamageType].each do |type, moves|
          text << "#{type}: #{moves.join(', ')}\n"
        end
        text << "\n"
      end

      # Accuracy Changes
      if me[:accuracyChange] && me[:accuracyChange].keys.length > 0
        text << "<c2=5050D0F0>ACCURACY CHANGES</c2>\n"
        me[:accuracyChange].each do |acc, moves|
          text << "#{acc}%: #{moves.join(', ')}\n"
        end
        text << "\n"
      end

      # Stat Effect Amplified
      if me[:statEffectAmplified] && me[:statEffectAmplified].length > 0
        text << "<c2=50C050F0>STAT EFFECTS AMPLIFIED</c2>\n"
        text << "#{me[:statEffectAmplified].join(', ')}\n\n"
      end

      # Moves that Fail
      if me[:fail] && me[:fail].length > 0
        text << "<c2=50F03030>MOVES THAT FAIL</c2>\n"
        text << "#{me[:fail].join(', ')}\n\n"
      end

      # Special Move Effects
      if me[:special] && me[:special].length > 0
        text << "<c2=50F0F050>SPECIAL MOVE EFFECTS</c2>\n"
        me[:special].each do |effect|
          text << "• #{effect}\n"
        end
        text << "\n"
      end

      # Duration Changes
      if me[:durationChange] && me[:durationChange].keys.length > 0
        text << "<c2=5090F0D0>DURATION CHANGES</c2>\n"
        me[:durationChange].each do |move, duration|
          text << "#{move}: #{duration} turns\n"
        end
        text << "\n"
      end
    end

    # Ability Effects
    if @data[:abilityEffects] && @data[:abilityEffects].length > 0
      text << "<c2=50A0F050>ABILITY EFFECTS</c2>\n"
      @data[:abilityEffects].each do |effect|
        text << "• #{effect}\n"
      end
      text << "\n"
    end

    # Field Transformations
    if @data[:fieldTransformations]
      ft = @data[:fieldTransformations]

      if (ft[:terminates] && ft[:terminates].length > 0) ||
         (ft[:transformsTo] && ft[:transformsTo].keys.length > 0) ||
         (ft[:disables] && ft[:disables].length > 0)
        text << "<c2=50F0A0A0>FIELD TRANSFORMATIONS</c2>\n"

        if ft[:terminates] && ft[:terminates].length > 0
          text << "Terminates: #{ft[:terminates].join(', ')}\n"
        end

        if ft[:transformsTo] && ft[:transformsTo].keys.length > 0
          ft[:transformsTo].each do |new_field, moves|
            text << "→ #{new_field}: #{moves.join(', ')}\n"
          end
        end

        if ft[:disables] && ft[:disables].length > 0
          text << "Disables: #{ft[:disables].join(', ')}\n"
        end

        text << "\n"
      end
    end

    # Item Effects
    if @data[:itemEffects] && @data[:itemEffects].length > 0
      text << "<c2=50F0D050>ITEM EFFECTS</c2>\n"
      @data[:itemEffects].each do |effect|
        text << "• #{effect}\n"
      end
      text << "\n"
    end

    text << "\n<ac>Press B to return</ac>"

    return text
  end
end
