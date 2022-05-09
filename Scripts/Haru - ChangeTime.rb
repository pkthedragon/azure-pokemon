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
    @cmdChangeTime=-1
    @cmdMap=-1
    @cmdPhone=-1
    @cmdJukebox=-1
    @cmdOnline=-1    
    @cmdPulse=-1
    @cmdRiftNotes=-1
    @cmdNotes=-1
    commands[@cmdChangeTime=commands.length]=_INTL("Change Time") if defined?($game_screen.aGetTime)
    commands[@cmdMap=commands.length]=_INTL("Map")
    commands[@cmdPhone=commands.length]=_INTL("Phone") if $PokemonGlobal.phoneNumbers &&
                                                          $PokemonGlobal.phoneNumbers.length>0
    commands[@cmdJukebox=commands.length]=_INTL("Jukebox")
    if $game_switches[1176]
      commands[@cmdPulse=commands.length]=_INTL("Rift Dex")
    end
    if $game_switches[1210]
      commands[@cmdRiftNotes=commands.length]=_INTL("Rift Notes")
    end
    if $game_switches[1177]
      commands[@cmdNotes=commands.length]=_INTL("Field Notes")
    end
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @button=AnimatedBitmap.new("Graphics/Pictures/Pokegear/pokegearButton")
    @sprites={}
    @sprites["background"] = IconSprite.new(0,0)
    femback=pbResolveBitmap(sprintf("Graphics/Pictures/Pokegear/pokegearbgf"))
    if $Trainer.isFemale? && femback
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/pokegearbgf")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/pokegearbg")
    end
    @sprites["command_window"] = Window_CommandPokemon.new(commands,160)
    @sprites["command_window"].index = @menu_index
    @sprites["command_window"].x = Graphics.width
    @sprites["command_window"].y = -3000 #0
    for i in 0...commands.length
      x=118
      y=196 - (commands.length*24) + (i*48)
      @sprites["button#{i}"]=PokegearButton.new(x,y,commands[i],i,@viewport)
      @sprites["button#{i}"].selected=(i==@sprites["command_window"].index)
      @sprites["button#{i}"].update
    end
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
  end
  #-----------------------------------------------------------------------------
  # update the scene
  #-----------------------------------------------------------------------------
  def update
    for i in 0...@sprites["command_window"].commands.length
      sprite=@sprites["button#{i}"]
      sprite.selected=(i==@sprites["command_window"].index) ? true : false
    end
    pbUpdateSpriteHash(@sprites)
    #update command window and the info if it's active
    if @sprites["command_window"].active
      update_command
      return
    end
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
#MODDED
        if @cmdChangeTime>=0 && @sprites["command_window"].index==@cmdChangeTime
        aNow = Time.new
            
        #Reset time
        aCurTime = pbGetTimeNow
           
        params=ChooseNumberParams.new
        params.setRange(0,23)
        params.setDefaultValue(aCurTime.hour)
          
        aSecs = (Kernel.pbMessageChooseNumber(_INTL("What hour is it?"), params)-aNow.hour)*3600   

        #Finish
        $game_screen.aSetTime(aNow+aSecs)
        
        aCurTime = pbGetTimeNow
        newHour = aCurTime.hour
        iInt = aCurTime.min
        dispMin = "00"
        if iInt < 15
          dispMin = "00"
        elsif iInt < 30
          dispMin = "15"
        elsif iInt < 45
          dispMin = "30"
        else
          dispMin = "45"
        end
        haruAMPM = "AM"
        if newHour > 12
          newHour -= 12
          haruAMPM = "PM"
        end
        Kernel.pbMessage(_INTL("The time is now {1}:{2} {3}.",newHour,dispMin,haruAMPM))
            
        #Update the clock
        $game_screen.aUpdateClock
      end
#MODDED
      if @cmdMap>=0 && @sprites["command_window"].index==@cmdMap
        pbPlayDecisionSE()               
        pbShowMap(-1,false)
      end
      if @cmdPhone>=0 && @sprites["command_window"].index==@cmdPhone
        pbPlayDecisionSE()
        pbFadeOutIn(99999) {
           PokemonPhoneScene.new.start
        }
      end
      if @cmdJukebox>=0 && @sprites["command_window"].index==@cmdJukebox
        pbPlayDecisionSE()
        $scene = Scene_Jukebox.new
      end      
      if @cmdPulse>=0 && @sprites["command_window"].index==@cmdPulse
        pbPlayDecisionSE()
        $scene = Scene_PulseDex.new
      end
      
      if @cmdNotes>=0 && @sprites["command_window"].index==@cmdNotes
        pbPlayDecisionSE()
        $scene = Scene_FieldNotes.new
      end
     
      if @cmdRiftNotes>=0 && @sprites["command_window"].index==@cmdRiftNotes
        pbPlayDecisionSE()
        $scene = Scene_RiftNotes.new
      end
        
      return
    end
  end
  def tryConnect
    $scene=Connect.new
  end    
end