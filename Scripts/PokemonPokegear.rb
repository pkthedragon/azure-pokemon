class PokegearButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_reader :selected

  def initialize(x,y,name,index,viewport,button_bitmap,icon_path=nil)
    super(viewport)
    @index=index
    @name=name
    @contents=BitmapWrapper.new(button_bitmap.width,button_bitmap.height)
    self.bitmap=@contents
    self.x=x
    self.y=y
    draw_button(button_bitmap,icon_path)
    self.selected=false
  end

  def dispose
    @contents.dispose
    super
  end

  def selected=(value)
    return if @selected==value
    @selected=value
    height=@contents.height/2
    self.src_rect.set(0,value ? height : 0,@contents.width,height)
  end

  private

  def draw_button(button_bitmap,icon_path)
    @contents.blt(0,0,button_bitmap,button_bitmap.rect)
    pbSetSystemFont(@contents)
    textpos=[          # Name is written on both unselected and selected buttons
       [@name,@contents.width/2,10,2,Color.new(248,248,248),Color.new(40,40,40)],
       [@name,@contents.width/2,62,2,Color.new(248,248,248),Color.new(40,40,40)]
    ]
    pbDrawTextPositions(@contents,textpos)
    icon_path=pbResolveBitmap(icon_path || "Graphics/Pictures/Pokegear/pokegear#{@name}")
    return if !icon_path
    icon=AnimatedBitmap.new(icon_path)
    if icon.width<=40 && icon.height<=32
      @contents.blt(18,10,icon.bitmap,icon.bitmap.rect)
      @contents.blt(18,62,icon.bitmap,icon.bitmap.rect)
    else
      @contents.stretch_blt(Rect.new(18,10,32,32),icon.bitmap,icon.bitmap.rect)
      @contents.stretch_blt(Rect.new(18,62,32,32),icon.bitmap,icon.bitmap.rect)
    end
    icon.dispose
  end
end



#===============================================================================
# - Scene_Pokegear
#-------------------------------------------------------------------------------
# Modified By Harshboy
# Modified by Peter O.
# Also Modified By OblivionMew
# Overhauled by Maruno
#===============================================================================
class Scene_Pokegear
  #-----------------------------------------------------------------------------
  # initialize
  #-----------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #-----------------------------------------------------------------------------
  # main
  #-----------------------------------------------------------------------------
  def main
    commands=[]
# OPTIONS - If you change these, you should also change update_command below.
    @cmdMap=-1
    @cmdPhone=-1
    @cmdTutor=-1
    @cmdMagnet=-1
    @cmdJukebox=-1
    @cmdOnline=-1    
    #@cmdPortablePC=-1
    @cmdPulse=-1
    @cmdRiftNotes=-1
    @cmdNotes=-1
    @cmdFieldManual=-1
    @cmdTrainerIndex=-1
    @cmdRecords=-1
#    @cmdNews=-1
    commands[@cmdMap=commands.length]=_INTL("Map")
    commands[@cmdPhone=commands.length]=_INTL("Phone") if $PokemonGlobal.phoneNumbers &&
                                                          $PokemonGlobal.phoneNumbers.length>0
    commands[@cmdJukebox=commands.length]=_INTL("Jukebox")
    commands[@cmdTutor=commands.length]=_INTL("Tutor.net") if $game_switches[1492]==true
    commands[@cmdMagnet=commands.length]=_INTL("PokeMagnet") if $game_switches[1437]==true
#    commands[@cmdNews=commands.length]=_INTL("Gearen News")
    if $game_switches[1176]
      commands[@cmdPulse=commands.length]=_INTL("Rift Dex")
    end
    if $game_switches[1210]
      commands[@cmdRiftNotes=commands.length]=_INTL("Rift Notes")
    end
    if $game_switches[1177]
      commands[@cmdNotes=commands.length]=_INTL("Field Notes")
    end
    if $game_switches[1178]
      commands[@cmdFieldManual=commands.length]=_INTL("Field Manual")
    end
    if $game_switches[1179]
      commands[@cmdTrainerIndex=commands.length]=_INTL("Trainer Index")
    end
    # if !($game_switches[1235]==true)  && ($game_switches[1408]==true)
    #   if !($game_variables[456]>34 && $game_variables[456]<70) &&  !($game_map.map_id == 94 || $game_map.map_id == 99 || $game_map.map_id == 160 || $game_map.map_id == 164 || $game_map.map_id == 66 || $game_map.map_id == 144 || $game_map.map_id == 33 || $game_map.map_id == 153)
    #     commands[@cmdPortablePC=commands.length]=_INTL("PC")
    #   end
    # end
    if $game_switches[1296]
      commands[@cmdRecords=commands.length]=_INTL("Records")
    end
    run_menu(commands)
  end
  def run_menu(commands,command_icons={})
    @buttons=[]
    @menu_index=@menu_index.clamp(0,commands.length-1)
    @button_viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @button_viewport.z=99999

    background_path="Graphics/Pictures/Pokegear/pokegearbg"
    button_path="Graphics/Pictures/Pokegear/pokegearButton"
    if $Trainer.isFemale?
      background_path=pbResolveBitmap("#{background_path}f") || background_path
      button_path=pbResolveBitmap("#{button_path}f") || button_path
    end
    background=IconSprite.new(0,0)
    background.setBitmap(background_path)
    button_art=AnimatedBitmap.new(button_path)
    commands.each_with_index do |name,index|
      y=196-(commands.length*24)+(index*48)
      @buttons.push(PokegearButton.new(118,y,name,index,@button_viewport,button_art.bitmap,command_icons[index]))
    end
    @buttons[@menu_index].selected=true
    scroll_to_selected_button
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      background.update
      update
      break if $scene!=self
    end
    Graphics.freeze
  ensure
    @buttons.each { |button| button.dispose }
    button_art.dispose if button_art
    background.dispose if background
    @button_viewport.dispose if @button_viewport
  end

  def update
    count=@buttons.length
    if Input.repeat?(Input::DOWN) && (Input.trigger?(Input::DOWN) || @menu_index<count-1)
      move_menu_cursor((@menu_index+1)%count)
    end
    if Input.repeat?(Input::UP) && (Input.trigger?(Input::UP) || @menu_index>0)
      move_menu_cursor((@menu_index-1)%count)
    end
    # The menu is one page. The shoulder buttons go to either end.
    move_menu_cursor(count-1) if Input.repeat?(Input::R)
    move_menu_cursor(0) if Input.repeat?(Input::L)
    update_command
  end

  def move_menu_cursor(index)
    return if @menu_index==index
    @buttons[@menu_index].selected=false
    @menu_index=index
    @buttons[@menu_index].selected=true
    scroll_to_selected_button
    pbPlayCursorSE()
  end

  def scroll_to_selected_button
    button=@buttons[@menu_index]
    top=@button_viewport.oy
    next_top=top.clamp(button.y+button.src_rect.height-Graphics.height,button.y)
    @button_viewport.oy=next_top if next_top!=top
  end

  #-----------------------------------------------------------------------------
  # update the command window
  #-----------------------------------------------------------------------------
  def update_command
    if Input.trigger?(Input::B)
      pbPlayCancelSE()
      $scene = Scene_Map.new
      return
    end
    if Input.trigger?(Input::C)
      if @cmdMap>=0 && @menu_index==@cmdMap
        pbPlayDecisionSE()               
        pbShowMap(-1,false)
      end
      if @cmdPhone>=0 && @menu_index==@cmdPhone
        pbPlayDecisionSE()
        pbFadeOutIn(99999) {
           PokemonPhoneScene.new.start
        }
      end
      if @cmdJukebox>=0 && @menu_index==@cmdJukebox
        pbPlayDecisionSE()
        $scene = Scene_Jukebox.new
      end
      # if @cmdPortablePC>=0 && @menu_index==@cmdPortablePC
      #   pbPlayDecisionSE()
      #   pbPokeCenterPC
      # end
#      if @cmdNews>=0 && @menu_index==@cmdNews
#        pbPlayDecisionSE()
#        print "about to play news"
#        $game_switches[1450] = true
#        $scene = Scene_Map.new
#        #return pbCommonEvent(17)
        
#        print "done playing news"
#        return 1
#      end
      if @cmdPulse>=0 && @menu_index==@cmdPulse
        pbPlayDecisionSE()
        $scene = Scene_PulseDex.new
      end
    if @cmdTutor>=0 && @menu_index==@cmdTutor
 #       move=pbChooseTutorList
 #         if move!=0
 #         pbMoveTutorChoose(move,false,false,true)
 #       end
    pbTutorNet
    end
      
    if @cmdRiftNotes>=0 && @menu_index==@cmdRiftNotes
        pbPlayDecisionSE()
        $scene = Scene_RiftNotes.new
      end
      if @cmdNotes>=0 && @menu_index==@cmdNotes
        pbPlayDecisionSE()
        $scene = Scene_FieldNotes.new
      end
      if @cmdFieldManual>=0 && @menu_index==@cmdFieldManual
        pbPlayDecisionSE()
        scene = Scene_FieldEffectsManual.new
        screen = PokemonFieldEffectsManualScreen.new(scene)
        pbFadeOutIn(99999) { screen.pbStartScreen }
      end
      if @cmdTrainerIndex>=0 && @menu_index==@cmdTrainerIndex
        pbPlayDecisionSE()
        scene = Scene_TrainerIndex.new
        screen = PokemonTrainerIndexScreen.new(scene)
        pbFadeOutIn(99999) { screen.pbStartScreen }
      end
      if @cmdRecords>=0 && @menu_index==@cmdRecords
        pbPlayDecisionSE()
        pbViewQuests
#        $scene = Scene_FieldNotes.new
      end

      return
    end
  end
  def tryConnect
    $scene=Connect.new
  end    
end
