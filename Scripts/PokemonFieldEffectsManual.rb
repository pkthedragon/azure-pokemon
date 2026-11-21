# Field Effects Manual - Interactive encyclopedia of field effects
# Displays comprehensive information about each field effect

Field_Note_Header_Coords = [2, -18, 300, 64]
Field_Note_Header_Colors = [Color.new(248, 248, 248), Color.new(0, 0, 0)]

class PokemonFieldEffectsManualScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbScene
  ensure #pk code
    @scene.pbEndScene
  end
end

#===============================================================================
# Field Effect Manual list
#===============================================================================
class Scene_FieldEffectsManual
  FIELD_IDS = [1,2,3,4,8,9,13,15,17,18,20,21,23,29,36,37,40,42,46,47].freeze #pk code

  #pk code
  def initialize(title=_INTL("Field Manual"), entries=nil)
    @title=title
    @entries=entries
  end

  def buildFieldMenu
    menu = []
    for field in FIELD_IDS
      prefix = field.to_s + ". " #pk code
      item = { label: prefix + pbGetFieldEffectName(field), field: field } #pk code
      menu.push(item)
    end

    return menu
  end

  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/pokegearbg") #pk code

    @menu = (@entries || buildFieldMenu) + [{ label: _INTL("Back"), back: true }] #pk code
    @choices = @menu.collect { |field| field[:label] }
    @sprites["command_window"] = Window_CommandPokemonWhiteArrow.newWithSize(@choices, 10, 30, Graphics.width - 20, Graphics.height - 64, @viewport) #pk code
    @sprites["command_window"].windowskin = nil
    @sprites["command_window"].baseColor = Color.new(248, 248, 248)
    @sprites["command_window"].shadowColor = Color.new(0, 0, 0)
    render_header

    pbFadeInAndShow(@sprites)
  end

  def render_header
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(@title, *Field_Note_Header_Coords, @viewport) #pk code
    @sprites["header"].baseColor = Field_Note_Header_Colors[0]
    @sprites["header"].shadowColor = Field_Note_Header_Colors[1]
    @sprites["header"].windowskin = nil
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
        menuindex = @sprites["command_window"].index
        item = @menu[menuindex]
        if item[:back]
          pbPlayCancelSE()
          break
        else #pk code
          pbPlayDecisionSE()
          #pk code
          scene = Scene_FieldEffectsManual_Info.new(item[:field], @menu, menuindex)
          scene.main
          @sprites["command_window"].index = scene.menu_index
        end
      end
    end
  end

  def pbEndScene
    return if !@viewport #pk code
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
# Detail View Scene - Shows comprehensive field effect information
#===============================================================================
class Scene_FieldEffectsManual_Info
  attr_reader :menu_index #pk code

  def initialize(field_id, menu = nil, menu_index = nil) #pk code
    @field_id = field_id
    @menu = menu #pk code
    @menu_index = menu_index #pk code
    @data = pageData #pk code
  end

  def main
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    # Background
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/pokegearbg") #pk code

    render_header
    render_page #pk code

    #pk code
    @sprites["footer"]=BitmapSprite.new(Graphics.width-70,24,@viewport)
    @sprites["footer"].y=Graphics.height-56
    footer=@sprites["footer"].bitmap
    pbSetSmallFont(footer)
    #pk code
    controls=if @data && @data[:sections]
      _INTL("Up/Down Scroll   L/R Page   Left/Right Category")
    elsif @menu
      _INTL("Up/Down Scroll   L/R Page   Left/Right Field")
    else
      _INTL("Up/Down Scroll   L/R Page   X Back")
    end
    pbDrawShadowText(footer,16,0,footer.width-16,24,controls,
       Field_Note_Header_Colors[0],Field_Note_Header_Colors[1])

    pbFadeInAndShow(@sprites)

    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)

      if Input.trigger?(Input::RIGHT) || Input.repeat?(Input::RIGHT)
        changeField(1)
      elsif Input.trigger?(Input::LEFT) || Input.repeat?(Input::LEFT)
        changeField(-1)
      end

      #pk code
      if Input.repeat?(Input::L)
        @scroll_y-=@visible_height-32
      elsif Input.repeat?(Input::R)
        @scroll_y+=@visible_height-32
      elsif Input.press?(Input::UP)
        @scroll_y-=6
      elsif Input.press?(Input::DOWN)
        @scroll_y+=6
      end
      @scroll_y=@scroll_y.clamp(0,@max_scroll)
      @sprites["info"].oy=@scroll_y

      if Input.trigger?(Input::B) || Input.trigger?(Input::C)
        pbPlayCancelSE()
        break
      end
    end

  ensure #pk code
    pbEndScene if @viewport
  end

  def render_header
    #pk code
    title=@data ? @data[:name] : _INTL("Field Manual")
    x,y,_width,height=Field_Note_Header_Coords
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(title, x, y, Graphics.width - 96, height, @viewport)
    @sprites["header"].baseColor = Field_Note_Header_Colors[0]
    @sprites["header"].shadowColor = Field_Note_Header_Colors[1]
    @sprites["header"].windowskin = nil
  end

  def render_page
    #pk code
    info=SpriteWindow_Base.new(0,22,Graphics.width,Graphics.height-64)
    @sprites["info"]=info
    info.viewport=@viewport
    info.windowskin=nil
    width=info.width-info.borderX-SpriteWindow_Base::TEXTPADDING
    text=if @data && @data[:sections]
      @data[:sections].map { |title,body|
        "<c3=CFDEF4,000000>#{fmtescape(title)}</c3>\n#{fmtescape(body)}"
      }.join("\n\n")
    else
      field_text=fmtescape(Messages.utf8Text(pbGenerateFieldInfoText).gsub("\t","  "))
      field_text.sub!(/\A(\d+\.[^\n]+)/,'<fs=20>\1</fs>')
      field_text.gsub!(/^(\([^\n]+\): *)$/,'<c3=CFDEF4,000000>\1</c3>')
      field_text
    end
    text=Messages.utf8Text(shadowc3tag(*Field_Note_Header_Colors)+text)
    chars=getFormattedText(info.contents,0,0,width,-1,text,32)
    info.contents=drawBitmapBuffer(chars)
    @visible_height=info.height-info.borderY
    @scroll_y=0
    @max_scroll=[info.contents.height-@visible_height,0].max
  end

  def changeField(increment)
    return if !@menu #pk code
    oldindex = @menu_index
    loop do
      @menu_index += increment
      if @menu_index >= @menu.length
        @menu_index = 0
      elsif @menu_index < 0
        @menu_index = @menu.length - 1
      end
      break unless @menu[@menu_index][:back] #pk code
    end
    return if @menu_index == oldindex

    @field_id = @menu[@menu_index][:field] #pk code
    redraw
  end

  def redraw
    pbPlayDecisionSE()
    #pk code
    @data=pageData
    @sprites.delete("header").dispose
    @sprites.delete("info").dispose
    render_page
    render_header
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  #pk code
  def pbGenerateFieldInfoText
    return @data[:manualText] if @data && @data[:manualText]
    return _INTL("No data available.")
  end

  #pk code
  def pageData
    entry=@menu && @menu[@menu_index][:entry]
    return entry || pbGetFieldEffectData(@field_id)
  end
end

#pk code
def pbEncyclopedia
  categories=[
    [_INTL("True Status Conditions"),[
      [_INTL("Poisoned"),_INTL("The affected Pokémon loses 1/8 of its max HP each turn.")],
      [_INTL("Burned"),_INTL("The affected Pokémon loses 1/16 of its max HP each turn and has its Attack halved.")],
      [_INTL("Frozen"),_INTL("The affected Pokémon loses 1/16 of its max HP each turn and has its Special Attack halved.")],
      [_INTL("Paralyzed"),_INTL("The affected Pokémon loses 1/16 of its max HP each turn and has its Speed halved.")],
      [_INTL("Crushed"),_INTL("The affected Pokémon takes 1.5x damage, or 2x damage if the hit is critical.")],
      [_INTL("Sleep"),_INTL("The affected Pokémon cannot act for one turn.")]
    ]],
    [_INTL("Volatile Status Conditions"),[
      [_INTL("Confused"),_INTL("For three turns, the affected Pokémon's moves also damage the user.")],
      [_INTL("Enchanted"),_INTL("For three turns, the affected Pokémon is always critically hit and takes 1/6 of its max HP as damage when switching out.")],
      [_INTL("Wounded"),_INTL("For three turns, the affected Pokémon loses 1/12 of its max HP each turn and has its healing halved.")],
      [_INTL("Drowsy"),_INTL("The affected Pokémon falls asleep at the end of the next turn.")],
      [_INTL("Blind"),_INTL("On the next turn, the affected Pokémon's attacking moves graze, and it is always critically hit.")]
    ]],
    [_INTL("Miscellaneous"),[
      [_INTL("Stat stage cap"),_INTL("Effects that raise stats can only do so once per Pokémon affected. This resets when that Pokémon switches out.")],
      [_INTL("Critical Hits"),_INTL("The base critical hit rate is 0%.")],
      [_INTL("Grazing"),_INTL("Missing an attacking move causes it to graze, dealing half damage with no additional effects.")]
    ]]
  ]
  entries=categories.map { |title,sections| { label: title, entry: { name: title, sections: sections } } }
  scene=Scene_FieldEffectsManual.new(_INTL("Encyclopedia"),entries)
  PokemonFieldEffectsManualScreen.new(scene).pbStartScreen
end
