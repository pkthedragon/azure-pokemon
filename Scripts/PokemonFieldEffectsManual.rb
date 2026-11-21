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

  def buildFieldMenu
    menu = []
    for field in FIELD_IDS
      prefix = field.to_s + ". " #pk code
      item = { label: prefix + pbGetFieldEffectName(field), field: field } #pk code
      menu.push(item)
    end

    back = { label: _INTL("Back"), back: true } #pk code
    menu.push(back)
    return menu
  end

  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/pokegearbg") #pk code

    @menu = buildFieldMenu #pk code
    @choices = @menu.collect { |field| field[:label] }
    @sprites["command_window"] = Window_CommandPokemonWhiteArrow.newWithSize(@choices, 10, 30, Graphics.width - 20, Graphics.height - 64, @viewport) #pk code
    @sprites["command_window"].windowskin = nil
    @sprites["command_window"].baseColor = Color.new(248, 248, 248)
    @sprites["command_window"].shadowColor = Color.new(0, 0, 0)
    render_header

    pbFadeInAndShow(@sprites)
  end

  def render_header
    @sprites["header"] = Window_UnformattedTextPokemon.newWithSize(_INTL("Field Manual"), *Field_Note_Header_Coords, @viewport) #pk code
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
        elsif item[:field]
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
    @data = pbGetFieldEffectData(field_id)
    @menu = menu #pk code
    @menu_index = menu_index #pk code
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
    controls=@menu ? _INTL("Up/Down Scroll   L/R Page   Left/Right Field") :
                    _INTL("Up/Down Scroll   L/R Page   X Back")
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
    text=Messages.utf8Text(shadowc3tag(*Field_Note_Header_Colors)+pbGenerateFieldInfoText)
    width=info.width-info.borderX-SpriteWindow_Base::TEXTPADDING
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
      break unless @menu[@menu_index][:field].nil?
    end
    return if @menu_index == oldindex

    @field_id = @menu[@menu_index][:field] #pk code
    redraw
  end

  def redraw
    pbPlayDecisionSE()
    #pk code
    @data=pbGetFieldEffectData(@field_id)
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
    return "No data available." if !@data

    title="#{pbFieldEffectID(@field_id)}. #{@data[:name]} [#{@data[:abbr]}]"
    text="<c3=F8F8F8,000000><fs=25>#--- #{title} ---#</fs></c3>\n\n"
    text << "<c3=FFBD70,000000>\"#{@data[:message]}\"</c3>\n\n"

    overlay=@data[:overlayEffects]
    if overlay
      pbFieldManualSection(text,"(Overlay):",overlay[:effects],"CFDEF4",overlay[:terrain])
    end

    pbFieldManualSection(text,"(The following moves are affected by this field.):",
                         pbFieldManualMoves,"A9E7A1")
    pbFieldManualSection(text,"(The following abilities are affected by this field):",
                         @data[:abilityEffects],"C7E6A6")
    pbFieldManualSection(text,"(The following items are affected by this field):",
                         @data[:itemEffects],"B6E9D5")

    pbFieldManualSection(text,"(Other effects):",@data[:passiveEffects],"CFDEF4")

    if created=@data[:createdBy]
      effects=[]
      effects << "These moves can create or advance this field: #{created[:moves].join(', ')}" if created[:moves]
      effects << "These abilities can create this field: #{created[:abilities].join(', ')}" if created[:abilities]
      effects << "The field lasts for #{created[:duration]} turns" if created[:duration]
      effects << created[:note] if created[:note]
      pbFieldManualSection(text,"(How this field is created):",effects,"CFDEF4")
    end

    if damage=@data[:fieldDamage]
      effects=[]
      effects << "Damage: #{damage[:amount]}" if damage[:amount]
      effects << "Timing: #{damage[:timing]}" if damage[:timing]
      effects << "Affects: #{damage[:affects]}" if damage[:affects]
      effects << "These abilities give immunity: #{damage[:immuneAbilities].join(', ')}" if damage[:immuneAbilities]
      effects << "These conditions give immunity: #{damage[:immuneConditions].join(', ')}" if damage[:immuneConditions]
      effects << "These abilities double the damage: #{damage[:doubledAbilities].join(', ')}" if damage[:doubledAbilities]
      pbFieldManualSection(text,"(Field damage):",effects,"FFADAD")
    end

    if changes=@data[:fieldTransformations]
      effects=[]
      if changes[:terminates] && !changes[:terminates].empty?
        effects << "These effects end the field: #{changes[:terminates].join(', ')}"
      end
      (changes[:transformsTo] || {}).each do |field,causes|
        effects << "These effects change the field to #{field}: #{causes.join(', ')}"
      end
      effects.concat(changes[:disables]) if changes[:disables]
      effects << changes[:note] if changes[:note]
      pbFieldManualSection(text,"(Field transformations):",effects,"F6C1AA")
    end

    return text.rstrip
  end

  #pk code
  def pbFieldManualMoves
    moves=@data[:moveEffects]
    return [] unless moves

    effects=[]
    [:powerBoost,:powerDecrease].each do |key|
      (moves[key] || {}).each do |factor,list|
        multiplier=factor.to_s.gsub(/\d+(?:\.\d+)?/) { |value| value.sub(/\.0\z/,"")+"x" }
        effects << "These moves deal #{multiplier} damage: #{list.join(', ')}"
      end
    end
    (moves[:additionalDamageType] || {}).each do |type,list|
      effects << "These moves gain additional #{type}-type damage: #{list.join(', ')}"
    end
    (moves[:accuracyChange] || {}).each do |accuracy,list|
      explained,affected=list.partition { |move| move.match?(/\bskips? the accuracy check\z/) }
      effects.concat(explained)
      effects << "These moves have #{accuracy}% accuracy: #{affected.join(', ')}" unless affected.empty?
    end

    failed=moves[:fail] || []
    if failed.length==1
      effects << "#{failed.first} fails"
    elsif !failed.empty?
      effects << "These moves fail: #{failed.join(', ')}"
    end
    effects.concat(moves[:statChanges] || [])
    (moves[:durationChange] || {}).each do |move,duration|
      duration="#{duration} turns" if duration.is_a?(Numeric)
      verb=move.include?(" and ") ? "last" : "lasts"
      effects << "#{move} #{verb} for #{duration}"
    end
    effects.concat(moves[:special]) if moves[:special]
    return effects
  end

  #pk code
  def pbFieldManualSection(text,title,effects,color,subheading=nil)
    return if !effects || effects.empty?
    text << "<c3=#{color},000000>#{title}</c3>\n\n"
    text << "#{subheading}:\n\n" if subheading
    effects.each do |effect|
      text << "* #{effect}"
      text << "." unless effect.end_with?(".","!","?")
      text << "\n"
    end
    text << "\n"
  end
end
