class PokegearButton < SpriteWrapper
  attr_reader :index
  attr_reader :name
  attr_reader :selected

  def initialize(x,y,name,index,viewport,button_bitmap) #pk code
    super(viewport)
    @index=index
    @name=name
    @contents=BitmapWrapper.new(button_bitmap.width,button_bitmap.height)
    self.bitmap=@contents
    self.x=x
    self.y=y
    draw_button(button_bitmap) #pk code
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

  def draw_button(button_bitmap) #pk code
    @contents.blt(0,0,button_bitmap,button_bitmap.rect)
    pbSetSystemFont(@contents)
    textpos=[          # Name is written on both unselected and selected buttons
       [@name,@contents.width/2,10,2,Color.new(248,248,248),Color.new(40,40,40)],
       [@name,@contents.width/2,(@contents.height/2)+10,2,Color.new(248,248,248),Color.new(40,40,40)] #pk code
    ]
    pbDrawTextPositions(@contents,textpos)
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
    @cmdTrainerIndex=-1
    @cmdRecords=-1
#    @cmdNews=-1
    commands[@cmdMap=commands.length]=_INTL("Map")
    commands[@cmdMagnet=commands.length]=_INTL("PokéMagnet") if $game_switches[1437]==true #pk code
    commands[@cmdEncyclopedia=commands.length]=_INTL("Encyclopedia") #pk code
    commands[@cmdTutor=commands.length]=_INTL("Tutor.net") if $game_switches[1492]==true #pk code
    commands[@cmdFieldManual=commands.length]=_INTL("Field Manual") #pk code
    commands[@cmdJukebox=commands.length]=_INTL("Jukebox")
    commands[@cmdPhone=commands.length]=_INTL("Phone") if $PokemonGlobal.phoneNumbers &&
                                                          $PokemonGlobal.phoneNumbers.length>0
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
  #pk code
  def run_menu(commands)
    @buttons=[]
    @menu_index=@menu_index.clamp(0,commands.length-1)

    background_path="Graphics/Pictures/Pokegear/pokegearbg"
    button_path="Graphics/Pictures/Pokegear/pokegearButton"
    if $Trainer.isFemale?
      background_path=pbResolveBitmap("#{background_path}f") || background_path
      button_path=pbResolveBitmap("#{button_path}f") || button_path
    end
    background=IconSprite.new(0,0)
    background.setBitmap(background_path)
    button_art=AnimatedBitmap.new(button_path)
    #pk code
    button_height=button_art.bitmap.height/2
    visible_buttons=[commands.length,[(Graphics.height-124)/button_height,1].max].min
    menu_height=visible_buttons*button_height
    @button_viewport=Viewport.new(0,(Graphics.height-menu_height)/2,Graphics.width,menu_height)
    @button_viewport.z=99999
    x=(Graphics.width-button_art.bitmap.width)/2
    for i in 0...commands.length
      @buttons[i]=PokegearButton.new(x,i*button_height,commands[i],i,@button_viewport,button_art.bitmap)
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
    # The shoulder buttons go to either end.
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
    next_top=top.clamp(button.y+button.src_rect.height-@button_viewport.rect.height,button.y) #pk code
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
      if @menu_index==@cmdFieldManual #pk code
        pbPlayDecisionSE()
        scene = Scene_FieldEffectsManual.new
        screen = PokemonFieldEffectsManualScreen.new(scene)
        pbFadeOutIn(99999) { screen.pbStartScreen }
      end
      #pk code
      if @menu_index==@cmdEncyclopedia
        pbPlayDecisionSE()
        pbFadeOutIn(99999) { pbEncyclopedia }
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
