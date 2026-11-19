class Scene_Pokegear
  #-----------------------------------------------------------------------------
  # main
  #-----------------------------------------------------------------------------
  def main
    commands=[]
    command_icons={}
# OPTIONS - If you change these, you should also change update_command below.
    @cmdChangeTime=-1
    @cmdMap=-1
    @cmdTutor=-1
    @cmdPokedex=-1
    @cmdMagnet=-1
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
    commands[@cmdTutor=commands.length]=_INTL("Tutor.net") if $game_switches[1492]==true
    # Both Pokédex handoff events in the Pokémon Lab finish by setting LogiumBattle.
    if $Trainer.pokedex && $game_switches[1300]
      commands[@cmdPokedex=commands.length]=_INTL("Pokédex")
      command_icons[@cmdPokedex]="Graphics/Icons/menuPokedex"
    end
    if $game_switches[1437]
      commands[@cmdMagnet=commands.length]=_INTL("PokéMagnet")
      command_icons[@cmdMagnet]=pbItemIconFile(PBItems::MAGNET)
    end
    run_menu(commands,command_icons)
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
        if @cmdChangeTime>=0 && @menu_index==@cmdChangeTime
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
      if @cmdPulse>=0 && @menu_index==@cmdPulse
        pbPlayDecisionSE()
        $scene = Scene_PulseDex.new
      end
      
      if @cmdNotes>=0 && @menu_index==@cmdNotes
        pbPlayDecisionSE()
        $scene = Scene_FieldNotes.new
      end
     
      if @cmdRiftNotes>=0 && @menu_index==@cmdRiftNotes
        pbPlayDecisionSE()
        $scene = Scene_RiftNotes.new
      end
      
      if @cmdPokedex>=0 && @menu_index==@cmdPokedex
        pbPlayDecisionSE()
        open_pokedex
      end
      if @cmdMagnet>=0 && @menu_index==@cmdMagnet
        pbPlayDecisionSE()
        cycle_pokemagnet
      end

  if @cmdTutor>=0 && @menu_index==@cmdTutor
    pbTutorNet
  end
        
      return
    end
  end
  def tryConnect
    $scene=Connect.new
  end

  private

  def open_pokedex
    pbSetViableDexes
    unless DEXDEPENDSONLOCATION
      if $PokemonGlobal.pokedexViable.length!=1
        $scene=Scene_PokedexMenu.new(0,self)
        return
      end
      $PokemonGlobal.pokedexDex=$PokemonGlobal.pokedexViable[0]
      $PokemonGlobal.pokedexDex=-1 if $PokemonGlobal.pokedexDex==$PokemonGlobal.pokedexUnlocked.length-1
    end
    pbFadeOutIn(99999) {
      screen=PokemonPokedex.new(PokemonPokedexScene.new)
      screen.pbStartScreen
    }
  end

  def cycle_pokemagnet
    mode=$game_variables[687]<2 ? $game_variables[687]+1 : 0
    $game_variables[687]=mode
    $game_switches[74]=(mode==1)
    $game_switches[75]=(mode==2)
    case mode
    when 0 then Kernel.pbMessage(_INTL("Now in neutral mode."))
    when 1 then Kernel.pbMessage(_INTL("Now in attract mode."))
    when 2 then Kernel.pbMessage(_INTL("Now in repel mode."))
    end
  end
end
