class MoveHandlerHash < HandlerHash
  def initialize
    super(:PBMoves)
  end
end



module HiddenMoveHandlers
  CanUseMove     = MoveHandlerHash.new
  ConfirmUseMove = MoveHandlerHash.new
  UseMove        = MoveHandlerHash.new

  #pk code
  FIELD_MOVE_CATEGORIES = {
    PBMoves::CUT       => PBStuff::SLASHINGMOVE,
    PBMoves::ROCKSMASH => PBStuff::BLUDGEONINGMOVE | PBStuff::BOMBMOVE,
    PBMoves::STRENGTH  => PBStuff::DISPLACEMENTMOVE,
    PBMoves::HEADBUTT  => PBStuff::DISPLACEMENTMOVE,
    PBMoves::FLASH     => PBStuff::LIGHTMOVE,
    PBMoves::ROCKCLIMB => PBStuff::SCALINGMOVE,
    PBMoves::WATERFALL => PBStuff::SCALINGMOVE,
    PBMoves::FLY       => PBStuff::TRANSPORTMOVE
  }.freeze

  def self.known_move(pokemon, action)
    return nil if !pokemon || pokemon.isEgg?
    for move in pokemon.moves
      return move if move && move.id==action
    end
    category=FIELD_MOVE_CATEGORIES[action]
    return nil if !category
    for move in pokemon.moves
      return move if move && category.include?(move.id)
    end
    return nil
  end

  def self.party_user(action)
    return nil if !$Trainer || !$Trainer.party
    for pokemon in $Trainer.party
      return pokemon if known_move(pokemon,action)
    end
    return nil
  end

  def self.move_name(action, pokemon)
    move=known_move(pokemon,action)
    return PBMoves.getName(move ? move.id : action)
  end

  def self.available_category_actions(pokemon, known_ids)
    return FIELD_MOVE_CATEGORIES.keys.select do |action|
      !known_ids.include?(action) && known_move(pokemon, action) &&
        triggerCanUseMove(action, pokemon, false)
    end
  end

  def self.event_runs?(event, script)
    return event&.list&.any? do |command|
      command.code==111 && command.parameters[0]==12 && command.parameters[1]==script
    end
  end

  def self.addCanUseMove(item,proc); CanUseMove.add(item,proc); end
  def self.addConfirmUseMove(item,proc); ConfirmUseMove.add(item,proc); end
  def self.addUseMove(item,proc); UseMove.add(item,proc); end

  def self.hasHandler(item)
    return CanUseMove[item]!=nil && UseMove[item]!=nil
  end

  # Returns whether move can be used
  def self.triggerCanUseMove(item,pokemon,showmsg)
    return false if !CanUseMove[item]
    return CanUseMove.trigger(item,pokemon,showmsg)
  end

  # Returns whether the player confirmed that they want to use the move
  def self.triggerConfirmUseMove(item,pokemon)
    return true if !ConfirmUseMove[item]
    return ConfirmUseMove.trigger(item,pokemon)
  end
  
  def self.triggerUseMove(item,pokemon)
    # Returns whether move was used
    return false if !UseMove[item]
    return UseMove.trigger(item,pokemon)
  end
end

def Kernel.pbCanUseHiddenMove?(pkmn,move,showmsg=true)
  return HiddenMoveHandlers.triggerCanUseMove(move,pkmn,showmsg)
end

def Kernel.pbConfirmUseHiddenMove(pokemon,move)
  return HiddenMoveHandlers.triggerConfirmUseMove(move,pokemon)
end

def Kernel.pbUseHiddenMove(pokemon,move)
  return HiddenMoveHandlers.triggerUseMove(move,pokemon)
end

def Kernel.pbHiddenMoveEvent
  Events.onAction.trigger(nil)
end

def pbCheckHiddenMoveSwitch(switch_num=-1,showmsg=true)
  return true if switch_num<0   # No switch requirement
  return true if $DEBUG
  if $game_switches[switch_num]
    return true
  end
  Kernel.pbMessage(_INTL("You are not able to use this move yet.")) if showmsg
  return false
end

def pbHiddenMoveAnimation(pokemon)
  return false if !pokemon
  return false if $PokemonSystem && $PokemonSystem.field_move_animation==1
  strobes=[]
  screen_width=Graphics.width
  screen_height=Graphics.height
  viewport=Viewport.new(0,0,screen_width,screen_height)
  viewport_rect=viewport.rect
  viewport.visible=false
  viewport.z=99999
  bg=Sprite.new(viewport)
  background=BitmapCache.load_bitmap("Graphics/Pictures/hiddenMovebg")
  bg.bitmap=background
  background_height=background.height
  background_top=(screen_height-background_height)/2
  sprite=PokemonSprite.new(viewport)
  sprite.setPokemonBitmap(pokemon)
  BitmapCache.retain_hidden_move_bitmap(sprite.bitmap)
  sprite.z=1
  sprite_half_width=sprite.bitmap.width/2
  sprite.ox=sprite_half_width
  sprite.oy=sprite.bitmap.height/2
  sprite.visible=false
  strobebitmap=AnimatedBitmap.new("Graphics/Pictures/hiddenMoveStrobes")
  strobe_texture=strobebitmap.bitmap
  strobe_width=strobe_texture.width
  strobe_rows=background_height/16-2
  15.times do |i|
    strobe=Sprite.new(viewport)
    strobes.push(strobe)
    strobe.bitmap=strobe_texture
    strobe.src_rect.set(0,(i%2)*16,52,16)
    strobe.z=((i%2)==0 ? 2 : 0)
    strobe.visible=false
  end
  closed_rect=Rect.new(0,screen_height/2,screen_width,0)
  open_rect=Rect.new(0,background_top,screen_width,background_height)
  interp=RectInterpolator.new(closed_rect,open_rect,10)
  ptinterp=nil
  phase=1
  frames=0
  Graphics.frame_reset
  begin
    Graphics.update
    Input.update
    case phase
    when 1, 5 # Open or close the viewport
      interp.update
      interp.set(viewport_rect)
      viewport_height=viewport_rect.height
      viewport.visible=viewport_height>0
      bg.oy=(background_height-viewport_height)/2
      strobe_origin_y=viewport_rect.y
      strobes.each { |strobe| strobe.oy=strobe_origin_y }
      if interp.done?
        if phase==1
          phase=2
          ptinterp=PointInterpolator.new(
             screen_width+sprite_half_width,background_height/2,
             screen_width/2,background_height/2,
             16)
        else
          phase=6
        end
      end
    when 2 # Slide Pokémon sprite in from right to centre
      ptinterp.update
      sprite.x=ptinterp.x
      sprite.y=ptinterp.y
      sprite.visible=true
      if ptinterp.done?
        phase=3
        pbPlayCry(pokemon)
        frames=0
      end
    when 3 # Wait
      frames+=1
      if frames>30
        phase=4
        ptinterp=PointInterpolator.new(
           screen_width/2,background_height/2,
           -sprite_half_width,background_height/2,
           16)
        frames=0
      end
    when 4 # Slide Pokémon sprite off from centre to left
      ptinterp.update
      sprite.x=ptinterp.x
      sprite.y=ptinterp.y
      if ptinterp.done?
        phase=5
        sprite.visible=false
        interp.restart(open_rect,closed_rect,10)
      end
    end
    for strobe in strobes
      if !strobe.visible
        strobe.y=16*(1+rand(strobe_rows))+background_top
        strobe.x=rand(screen_width)
        strobe.visible=true
      elsif (strobe_x=strobe.x)<screen_width
        strobe.x=strobe_x+32
      else
        strobe.y=16*(1+rand(strobe_rows))+background_top
        strobe.x=-strobe_width-rand(screen_width/4)
      end
    end
    pbUpdateSceneMap
  end while phase!=6
  return true
ensure
  sprite.dispose if sprite
  strobes.each { |strobe| strobe.dispose } if strobes
  bg.dispose if bg
  strobebitmap.dispose if strobebitmap
  background.dispose if background
  viewport.dispose if viewport
end

#===============================================================================
# Cut
#===============================================================================
def Kernel.pbCut
  move = PBMoves::CUT
  movefinder = HiddenMoveHandlers.party_user(move)
  if !pbCheckHiddenMoveSwitch(SWITCHFORCUT,false) || !$PokemonBag.pbHasItem?(:HM01) ||
   (!$DEBUG && !movefinder && !$PokemonBag.pbHasItem?(:GOLDENAXE) )
    Kernel.pbMessage(_INTL("This tree looks like it can be cut down."))
    return false
  end
  if !movefinder && $PokemonBag.pbHasItem?(:HM01) &&
   $PokemonBag.pbHasItem?(:GOLDENAXE) && $game_switches[1235]
    Kernel.pbMessage(_INTL("Golden items cannot be used at this time."))
    return false
  end
  Kernel.pbMessage(_INTL("This tree looks like it can be cut down!\1"))
  if Kernel.pbConfirmMessage(_INTL("Would you like to cut it?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    if speciesname==$Trainer.name && $PokemonBag.pbHasItem?(:GOLDENAXE)
      Kernel.pbMessage(_INTL("{1} used the Golden Axe!",speciesname))
    else
      Kernel.pbMessage(_INTL("{1} used {2}!",speciesname,HiddenMoveHandlers.move_name(move,movefinder)))
    end
    pbHiddenMoveAnimation(movefinder)
    return true
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:CUT,lambda{|move,pkmn,showmsg|
  return false if !pbCheckHiddenMoveSwitch(SWITCHFORCUT,showmsg)
  facingEvent = $game_player.pbFacingEvent
  return true if HiddenMoveHandlers.event_runs?(facingEvent,"Kernel.pbCut")
  if !facingEvent || (facingEvent.name!="Tree" && facingEvent.graphicName!="Object tree 1" && facingEvent.graphicName!="Object tree 3")
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:CUT,lambda{|move,pokemon|
   facingEvent = $game_player.pbFacingEvent
   if HiddenMoveHandlers.event_runs?(facingEvent,"Kernel.pbCut")
     facingEvent.start
     return true
   end
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,HiddenMoveHandlers.move_name(move,pokemon)))
   end
   if facingEvent
     facingEvent.erase
     $PokemonMap.addErasedEvent(facingEvent.id)
   end
   return true
})

#===============================================================================
# Headbutt
#===============================================================================
def Kernel.pbHeadbuttEffect(event)
  a=((event.x*event.y+event.x*event.y)/5)%10
  b=($Trainer.id&0xFFFF)%10
  chance=1
  if a==b
    chance=8
  elsif a>b && (a-b).abs<5
    chance=5
  elsif a<b && (a-b).abs>5
    chance=5
  end
  enctype=chance==1 ? EncounterTypes::HeadbuttLow : EncounterTypes::HeadbuttHigh
  alternative=enctype==EncounterTypes::HeadbuttLow ? EncounterTypes::HeadbuttHigh : EncounterTypes::HeadbuttLow
  if !Kernel.pbDisplacementEncounterAvailable?(enctype) &&
     Kernel.pbDisplacementEncounterAvailable?(alternative)
    enctype=alternative
  end
  # Always trigger encounter if available
  if !pbEncounter(enctype)
    Kernel.pbMessage(_INTL("Nope.  Nothing..."))
  end
end

def Kernel.pbHeadbutt(event)
  movefinder=Kernel.pbDisplacementCheck
  if $DEBUG || movefinder
    if Kernel.pbConfirmMessage(_INTL("A Pokémon could be in this tree.  Would you like to use Headbutt?"))
      speciesname=!movefinder ? $Trainer.name : movefinder.name
      Kernel.pbMessage(_INTL("{1} used {2}!",speciesname,HiddenMoveHandlers.move_name(PBMoves::HEADBUTT,movefinder)))
      pbHiddenMoveAnimation(movefinder)
      Kernel.pbHeadbuttEffect(event)
    end
  else
    Kernel.pbMessage(_INTL("A Pokémon could be in this tree.  Maybe a Pokémon could shake it."))
  end
  Input.update
  return
end

def Kernel.pbHeadbuttEffect2(event)
  a=((event.x*event.y+event.x*event.y)/5)%10
  b=($Trainer.id&0xFFFF)%10
  chance=1
  if a==b
    chance=8
  elsif a>b && (a-b).abs<5
    chance=5
  elsif a<b && (a-b).abs>5
    chance=5
  end
  # Always trigger encounter if available
  if !pbEncounter(chance==1 ? EncounterTypes::HeadbuttLow : EncounterTypes::HeadbuttHigh)
    Kernel.pbMessage(_INTL("Nope.  Nothing..."))
  end
end

def Kernel.pbHeadbutt2(event)
  movefinder=Kernel.pbDisplacementCheck
  if $DEBUG || movefinder
    if Kernel.pbConfirmMessage(_INTL("A Pokémon might fall from this pole.  Want to headbutt it?"))
      speciesname=!movefinder ? $Trainer.name : movefinder.name
      Kernel.pbMessage(_INTL("{1} used {2}!",speciesname,HiddenMoveHandlers.move_name(PBMoves::HEADBUTT,movefinder)))
      pbHiddenMoveAnimation(movefinder)
      Kernel.pbHeadbuttEffect2(event)
    end
  else
    Kernel.pbMessage(_INTL("A Pokémon might fall from this pole.  Maybe a Pokémon could shake it."))
  end
  Input.update
  return
end

#===============================================================================
# Displacement Move Encounters (any move that can shake trees/objects)
#===============================================================================
#pk code
def Kernel.pbDisplacementCheck
  return HiddenMoveHandlers.party_user(PBMoves::HEADBUTT)
end

def Kernel.pbDisplacementEncounterAvailable?(enctype=nil)
  return false if !$game_map || !$PokemonEncounters
  data=PBEncounterData.try_get($game_map.map_id)
  return false if !data
  types=enctype ? [enctype] : [EncounterTypes::HeadbuttLow,EncounterTypes::HeadbuttHigh]
  return types.any? do |type|
    table=data.try_get(type)
    table && !table.slots.empty?
  end
end

def Kernel.pbDisplacementEncounter(event=nil, movefinder=nil)
  movefinder ||= Kernel.pbDisplacementCheck
  move=HiddenMoveHandlers.known_move(movefinder,PBMoves::HEADBUTT)
  return false if !move || !Kernel.pbDisplacementEncounterAvailable?

  if !event
    facing=pbFacingTile
    return false if !facing || facing[0]!=$game_map.map_id
    event=Struct.new(:x, :y).new(facing[1],facing[2])
  end

  if Kernel.pbConfirmMessage(_INTL("You might be able to shake a Pokémon down. Use a displacement move?"))
    Kernel.pbMessage(_INTL("{1} used {2}!",movefinder.name,PBMoves.getName(move.id)))
    pbHiddenMoveAnimation(movefinder)
    backdrop=pbGetMetadata($game_map.map_id,MetadataBattleBack)
    cave=backdrop.to_s.start_with?("Cave")
    old_field=$game_variables[708] if cave
    begin
      $game_variables[708]=23 if cave
      Kernel.pbHeadbuttEffect(event)
    ensure
      $game_variables[708]=old_field if cave
    end
  end
  Input.update
  return true
end

HiddenMoveHandlers::CanUseMove.add(:HEADBUTT,lambda{|move,pkmn,showmsg|
   if Kernel.pbFacingTerrainTag==PBTerrain::Displacement
     return true if HiddenMoveHandlers.known_move(pkmn,move) && Kernel.pbDisplacementEncounterAvailable?
     Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
     return false
   end
   facingEvent=$game_player.pbFacingEvent
   if !facingEvent || (facingEvent.name!="HeadbuttTree" && facingEvent.graphicName!="Object tree 2")
     Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:HEADBUTT,lambda{|move,pokemon|
   if Kernel.pbFacingTerrainTag==PBTerrain::Displacement
     return Kernel.pbDisplacementEncounter(nil,pokemon)
   end
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,HiddenMoveHandlers.move_name(move,pokemon)))
   end
   facingEvent=$game_player.pbFacingEvent
   Kernel.pbHeadbuttEffect(facingEvent)
})

#===============================================================================
# Rock Smash
#===============================================================================
def pbRockSmashRandomEncounter
  # Always trigger Rock Smash encounter if available
  pbEncounter(EncounterTypes::RockSmash)
end

def Kernel.pbRockSmash
  move = PBMoves::ROCKSMASH
  movefinder = HiddenMoveHandlers.party_user(move)
  wall = $game_switches[999]
  if !pbCheckHiddenMoveSwitch(SWITCHFORROCKSMASH,false) ||
   (!$DEBUG && !movefinder && !$PokemonBag.pbHasItem?(:GOLDENHAMMER) )
    if wall
      Kernel.pbMessage(_INTL("It's a brittle wall. A Pokémon may be able to smash it."))
    else
      Kernel.pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
    end
    return false
  end  
  if !movefinder && $PokemonBag.pbHasItem?(:TM94) &&
   $PokemonBag.pbHasItem?(:GOLDENHAMMER) && $game_switches[1235]
    Kernel.pbMessage(_INTL("Golden items cannot be used at this time."))
    return false
  end
  prompt = wall ? _INTL("This wall appears to be breakable. Would you like to smash it?") :
    _INTL("This rock appears to be breakable. Would you like to smash it?")
  return false if !Kernel.pbConfirmMessage(prompt)
  speciesname=movefinder ? movefinder.name : $Trainer.name
  if !movefinder && $PokemonBag.pbHasItem?(:GOLDENHAMMER) && $PokemonBag.pbHasItem?(:TM94)
    Kernel.pbMessage(_INTL("{1} used the Golden Hammer!",speciesname))
  else
    Kernel.pbMessage(_INTL("{1} used {2}!",speciesname,HiddenMoveHandlers.move_name(move,movefinder)))
  end
  pbHiddenMoveAnimation(movefinder)
  return true
end

HiddenMoveHandlers::CanUseMove.add(:ROCKSMASH,lambda{|move,pkmn,showmsg|
  return false if !pbCheckHiddenMoveSwitch(SWITCHFORROCKSMASH,showmsg)
  facingEvent=$game_player.pbFacingEvent
  return true if HiddenMoveHandlers.event_runs?(facingEvent,"Kernel.pbRockSmash")
  if !facingEvent || (facingEvent.name!="Rock" && facingEvent.graphicName!="Object rock")
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:ROCKSMASH,lambda{|move,pokemon|
  facingEvent = $game_player.pbFacingEvent
  if HiddenMoveHandlers.event_runs?(facingEvent,"Kernel.pbRockSmash")
    facingEvent.start
    return true
  end
  if !pbHiddenMoveAnimation(pokemon)
    Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,HiddenMoveHandlers.move_name(move,pokemon)))
  end
  if facingEvent
    facingEvent.erase
    $PokemonMap.addErasedEvent(facingEvent.id)
  end
  return true
})

#===============================================================================
# Strength
#===============================================================================
def Kernel.pbStrength
  #if $PokemonMap.strengthUsed
  if $strengthUsed
    Kernel.pbMessage(_INTL("You are now able to move boulders around."))
    return false
  end
  move = PBMoves::STRENGTH
  movefinder = HiddenMoveHandlers.party_user(move)
  if !pbCheckHiddenMoveSwitch(SWITCHFORSTRENGTH,false) || !$PokemonBag.pbHasItem?(:HM04) ||
    (!$DEBUG && !movefinder && !$PokemonBag.pbHasItem?(:GOLDENGAUNTLET) )
    Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside."))
    return false
  end
  if !movefinder && $PokemonBag.pbHasItem?(:HM04) &&
   $PokemonBag.pbHasItem?(:GOLDENGAUNTLET) && $game_switches[1235]
    Kernel.pbMessage(_INTL("Golden items cannot be used at this time."))
    return false
  end

  Kernel.pbMessage(_INTL("It's a big boulder, but a Pokémon may be able to push it aside.\1"))
  if Kernel.pbConfirmMessage(_INTL("Would you like to push it?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    if speciesname==$Trainer.name && $PokemonBag.pbHasItem?(:GOLDENGAUNTLET)
      Kernel.pbMessage(_INTL("{1} used the Golden Gauntlet!",speciesname))
    else
      Kernel.pbMessage(_INTL("{1} used {2}!",speciesname,HiddenMoveHandlers.move_name(move,movefinder)))
    end
    pbHiddenMoveAnimation(movefinder)
    Kernel.pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",speciesname))
    #$PokemonMap.strengthUsed = true
    $strengthUsed = true
    return true
  end
  return false
end

Events.onAction+=lambda{|sender,e|
  facingEvent = $game_player.pbFacingEvent
  if facingEvent and facingEvent.name.length>=7
    # so we can have "boulder" with extra stuff in name
    eventName = (facingEvent.name[0,7]).downcase
    if eventName=="boulder"
      Kernel.pbStrength
    end
  end
}

HiddenMoveHandlers::CanUseMove.add(:STRENGTH,lambda{|move,pkmn,showmsg|
  return false if !pbCheckHiddenMoveSwitch(SWITCHFORSTRENGTH,showmsg)
  #if $PokemonMap.strengthUsed
  if $strengthUsed
    Kernel.pbMessage(_INTL("You can already move boulders.")) if showmsg
    return false
  end
  return true  
})

HiddenMoveHandlers::UseMove.add(:STRENGTH,lambda{|move,pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    Kernel.pbMessage(_INTL("{1} used {2}!\1",pokemon.name,HiddenMoveHandlers.move_name(move,pokemon)))
  end
  Kernel.pbMessage(_INTL("It is now possible to move boulders around!",pokemon.name))
  #$PokemonMap.strengthUsed = true
  $strengthUsed = true
  return true
})

#===============================================================================
# Surf
#===============================================================================
def Kernel.pbSurf
  return false if $game_player.pbHasDependentEvents?
  move = getID(PBMoves,:SURF)
  movefinder = Kernel.pbCheckMove(move)
  if !pbCheckHiddenMoveSwitch(SWITCHFORSURF,false) || !$PokemonBag.pbHasItem?(:HM03) ||
    (!$DEBUG && !movefinder && !$PokemonBag.pbHasItem?(:GOLDENSURFBOARD) )
    return false
  end
  if !movefinder && $PokemonBag.pbHasItem?(:HM03) &&
   $PokemonBag.pbHasItem?(:GOLDENSURFBOARD) && $game_switches[1235]
    Kernel.pbMessage(_INTL("Golden items cannot be used at this time."))
    return false
  end

  if Kernel.pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    if speciesname==$Trainer.name && $PokemonBag.pbHasItem?(:GOLDENSURFBOARD)
      Kernel.pbMessage(_INTL("{1} used the Golden Surfboard!",speciesname))
    else
      Kernel.pbMessage(_INTL("{1} used Surf!",speciesname))
    end
    Kernel.pbCancelVehicles
    pbHiddenMoveAnimation(movefinder)
    surfbgm = pbGetMetadata(0,MetadataSurfBGM)
    pbCueBGM(surfbgm,0.5) if surfbgm
    pbStartSurfing()
    return true
  end
  return false
end

def pbStartSurfing()
  Kernel.pbCancelVehicles
  $PokemonEncounters.clearStepCount
  $PokemonGlobal.swimming = false if $PokemonGlobal.respond_to?(:swimming)
  $PokemonGlobal.surfing = true
  $PokemonTemp.surfJump = $MapFactory.getFacingCoords($game_player.x,$game_player.y,$game_player.direction)
  Kernel.pbUpdateVehicle
  Kernel.pbJumpToward
  $PokemonTemp.surfJump = nil
  Kernel.pbUpdateVehicle
  $game_player.check_event_trigger_here([1,2])
end


def pbEndSurf(xOffset,yOffset)
  return false if !$PokemonGlobal.surfing
  x = $game_player.x
  y = $game_player.y
  currentTag = $game_map.terrain_tag(x,y)
  facingTag = Kernel.pbFacingTerrainTag
  if pbIsSurfableTag?(currentTag) && !pbIsSurfableTag?(facingTag)
    $PokemonTemp.surfJump = [x,y]
    if Kernel.pbJumpToward(1,false,true)
      $game_map.autoplayAsCue
      $game_player.increase_steps
      result = $game_player.check_event_trigger_here([1,2])
      Kernel.pbOnStepTaken(result)
    end
    $PokemonTemp.surfJump = nil
    return true
  end
  return false
end

def pbEndSwim(xOffset,yOffset)
  return false if !$PokemonGlobal.respond_to?(:swimming) || !$PokemonGlobal.swimming
  return false if $PokemonGlobal.surfing  # Don't interfere with surfing
  x = $game_player.x
  y = $game_player.y
  currentTag = $game_map.terrain_tag(x,y)
  facingTag = Kernel.pbFacingTerrainTag
  # Check if we're on still water and facing non-water (land transition)
  if pbIsStillWaterTag?(currentTag) && !pbIsWaterTag?(facingTag)
    # Calculate destination coordinates
    newX = x + xOffset
    newY = y + yOffset
    # Check if the destination tile is passable from land (including events)
    if !$game_map.valid?(newX, newY)
      return true if !$MapFactory
      return true if !$MapFactory.isPassableFromEdge?(newX, newY)
      return false
    end
    # Block landing on non-through character events even if swimming is passable
    for event in $game_map.events.values
      next unless event.x == newX && event.y == newY
      next if event.through
      next if event.tile_id && event.tile_id > 0
      return true if event.character_name.to_s.strip != ""
    end
    # Check if the destination tile itself is passable (ignoring direction from water)
    passable = $game_map.passableStrict?(newX, newY, 0) rescue true
    return true unless passable
    # Destination is clear, allow movement to proceed
    return false
  end
  return false
end

def Kernel.pbTransferSurfing(mapid,xcoord,ycoord,direction=$game_player.direction)
  pbFadeOutIn(99999){
     $game_temp.player_new_map_id    = mapid
     $game_temp.player_new_x         = xcoord
     $game_temp.player_new_y         = ycoord
     $game_temp.player_new_direction = direction
     Kernel.pbCancelVehicles
     $PokemonGlobal.surfing = true
     Kernel.pbUpdateVehicle
     $scene.transfer_player(false)
     $game_map.autoplay
     $game_map.refresh
  }
end

Events.onAction+=lambda{|sender,e|
  return if $PokemonGlobal.surfing
  return if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
  return if !pbIsRoughWaterTag?(Kernel.pbFacingTerrainTag)
  return if !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
  return if $game_player.pbHasDependentEvents?
  Kernel.pbSurf
}
HiddenMoveHandlers::CanUseMove.add(:SURF,lambda{|move,pkmn,showmsg|
  return false if !pbCheckHiddenMoveSwitch(SWITCHFORSURF,showmsg)
  if $PokemonGlobal.surfing
    Kernel.pbMessage(_INTL("You're already surfing.")) if showmsg
    return false
  end
  if $game_player.pbHasDependentEvents?
    Kernel.pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    return false
  end
  if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
    Kernel.pbMessage(_INTL("Let's enjoy cycling!")) if showmsg
    return false
  end
  if !pbIsRoughWaterTag?(Kernel.pbFacingTerrainTag) ||
     !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
    Kernel.pbMessage(_INTL("No surfing here!")) if showmsg
    return false
  end
  return true
})
 
HiddenMoveHandlers::UseMove.add(:SURF,lambda{|move,pokemon|
  Kernel.pbCancelVehicles
  if !pbHiddenMoveAnimation(pokemon)
    Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
  end
  surfbgm = pbGetMetadata(0,MetadataSurfBGM)
  pbCueBGM(surfbgm,0.5) if surfbgm
  pbStartSurfing()
  return true
})
 
#===============================================================================
# Lava Surf
#===============================================================================
def Kernel.pbLavaSurf
  return false if $game_player.pbHasDependentEvents?
  move = getID(PBMoves,:LAVASURF)
  movefinder = Kernel.pbCheckMove(move)
  if !pbCheckHiddenMoveSwitch(SWITCHFORLAVASURF,false) || !$PokemonBag.pbHasItem?(:TM110) ||
   (!$DEBUG && !movefinder && !$PokemonBag.pbHasItem?(:GOLDENDRIFTBOARD) )
    return false
  end
  if !movefinder && $PokemonBag.pbHasItem?(:TM110) &&
   $PokemonBag.pbHasItem?(:GOLDENDRIFTBOARD) && $game_switches[1235]
    Kernel.pbMessage(_INTL("Golden items cannot be used at this time."))
    return false
  end
  if Kernel.pbConfirmMessage(_INTL("The lava is a deep red...\nWould you like to surf on it?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    if speciesname==$Trainer.name && $PokemonBag.pbHasItem?(:GOLDENDRIFTBOARD) && $PokemonBag.pbHasItem?(:TM110)
      Kernel.pbMessage(_INTL("{1} used the Golden Drift Board!",speciesname))
    else
      Kernel.pbMessage(_INTL("{1} used Magma Drift!",speciesname))
    end
    Kernel.pbCancelVehicles
    pbHiddenMoveAnimation(movefinder)
    surfbgm="Feeling - Hotheaded"
    pbCueBGM(surfbgm,0.5) if surfbgm
    pbStartLavaSurfing()
    return true
  end
  return false
end

def pbStartLavaSurfing()
  Kernel.pbCancelVehicles
  $PokemonEncounters.clearStepCount
  $PokemonGlobal.lavasurfing = true
  $PokemonTemp.surfJump = $MapFactory.getFacingCoords($game_player.x,$game_player.y,$game_player.direction)
  Kernel.pbUpdateVehicle
  Kernel.pbJumpToward
  $PokemonTemp.surfJump = nil
  Kernel.pbUpdateVehicle
  $game_player.check_event_trigger_here([1,2])
end

def pbEndLavaSurf(xOffset,yOffset)
  return false if !$PokemonGlobal.lavasurfing
  x = $game_player.x
  y = $game_player.y
  currentTag = $game_map.terrain_tag(x,y)
  facingTag = Kernel.pbFacingTerrainTag
  if pbIsPassableLavaTag?(currentTag) && !pbIsPassableLavaTag?(facingTag)
    $PokemonTemp.surfJump = [x,y]
    if Kernel.pbJumpToward(1,false,true)
      $game_map.autoplayAsCue
      $game_player.increase_steps
      result = $game_player.check_event_trigger_here([1,2])
      Kernel.pbOnStepTaken(result)
    end
    $PokemonTemp.surfJump = nil
    return true
  end
  return false
end

def Kernel.pbTransferLavaSurfing(mapid,xcoord,ycoord,direction=$game_player.direction)
  pbFadeOutIn(99999){
     $game_temp.player_new_map_id    = mapid
     $game_temp.player_new_x         = xcoord
     $game_temp.player_new_y         = ycoord
     $game_temp.player_new_direction = direction
     Kernel.pbCancelVehicles
     $PokemonGlobal.lavasurfing = true
     Kernel.pbUpdateVehicle
     $scene.transfer_player(false)
     $game_map.autoplay
     $game_map.refresh
  }
end

Events.onAction+=lambda{|sender,e|
  return if $PokemonGlobal.lavasurfing
  return if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
  return if !pbIsPassableLavaTag?(Kernel.pbFacingTerrainTag)
  return if !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
  return if $game_player.pbHasDependentEvents?
  Kernel.pbLavaSurf
}

HiddenMoveHandlers::CanUseMove.add(:LAVASURF,lambda{|move,pkmn,showmsg|
  return false if !pbCheckHiddenMoveSwitch(SWITCHFORLAVASURF,showmsg)
  if $PokemonGlobal.lavasurfing
    Kernel.pbMessage(_INTL("You're already surfing.")) if showmsg
    return false
  end
  if $game_player.pbHasDependentEvents?
    Kernel.pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    return false
  end
  if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
    Kernel.pbMessage(_INTL("Let's enjoy cycling!")) if showmsg
    return false
  end
  if !pbIsPassableLavaTag?(Kernel.pbFacingTerrainTag) ||
     !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction)
    Kernel.pbMessage(_INTL("No surfing here!")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:LAVASURF,lambda{|move,pokemon|
  Kernel.pbCancelVehicles
  if !pbHiddenMoveAnimation(pokemon)
    Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
  end
  surfbgm="Feeling - Hotheaded"
  pbCueBGM(surfbgm,0.5) if surfbgm
  pbStartLavaSurfing()
  return true
})

#===============================================================================
# Waterfall
#===============================================================================
def Kernel.pbAscendWaterfall(event=nil)
  event = $game_player if !event
  return if !event
  return if event.direction!=8 # can't ascend if not facing up
  oldthrough = event.through
  oldmovespeed = event.move_speed
  terrain = Kernel.pbFacingTerrainTag
  return if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  event.through = true
  event.move_speed = 2
  loop do
    event.move_up
    terrain = pbGetTerrainTag(event)
    break if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  end
  event.through    = oldthrough
  event.move_speed = oldmovespeed
end

def Kernel.pbDescendWaterfall(event=nil)
  event = $game_player if !event
  return if !event
  return if event.direction!=2  # Can't descend if not facing down
  oldthrough   = event.through
  oldmovespeed = event.move_speed
  terrain = Kernel.pbFacingTerrainTag
  return if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  event.through = true
  event.move_speed = 2
  loop do
    event.move_down
    terrain = pbGetTerrainTag(event)
    break if terrain!=PBTerrain::Waterfall && terrain!=PBTerrain::WaterfallCrest
  end
  event.through    = oldthrough
  event.move_speed = oldmovespeed
end

def Kernel.pbWaterfall
  move = PBMoves::WATERFALL
  movefinder = HiddenMoveHandlers.party_user(move)
  if !pbCheckHiddenMoveSwitch(SWITCHFORWATERFALL,false) || !$PokemonBag.pbHasItem?(:HM05) ||
    (!$DEBUG && !movefinder && !$PokemonBag.pbHasItem?(:GOLDENJETPACK) )
    Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
    return false
  end
  if !movefinder && $PokemonBag.pbHasItem?(:HM05) &&
   $PokemonBag.pbHasItem?(:GOLDENJETPACK) && $game_switches[1235]
    Kernel.pbMessage(_INTL("Golden items cannot be used at this time."))
    return false
  end
  if Kernel.pbConfirmMessage(_INTL("It's a large waterfall. Would you like to use Waterfall?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    if speciesname==$Trainer.name && $PokemonBag.pbHasItem?(:GOLDENJETPACK)
      Kernel.pbMessage(_INTL("{1} used the Golden Jetpack!",speciesname))
    else
      Kernel.pbMessage(_INTL("{1} used {2}!",speciesname,HiddenMoveHandlers.move_name(move,movefinder)))
    end
    pbHiddenMoveAnimation(movefinder)
    pbAscendWaterfall
    return true
  end
  return false
end

Events.onAction+=lambda{|sender,e|
  terrain = Kernel.pbFacingTerrainTag
  if terrain==PBTerrain::Waterfall
    Kernel.pbWaterfall
    return
  elsif terrain==PBTerrain::WaterfallCrest
    Kernel.pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
    return
  end
}

HiddenMoveHandlers::CanUseMove.add(:WATERFALL,lambda{|move,pkmn,showmsg|
  return false if !pbCheckHiddenMoveSwitch(SWITCHFORWATERFALL,showmsg)
   if Kernel.pbFacingTerrainTag!=PBTerrain::Waterfall
     Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
     return false
   end
   return true
})

HiddenMoveHandlers::UseMove.add(:WATERFALL,lambda{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,HiddenMoveHandlers.move_name(move,pokemon)))
   end
   Kernel.pbAscendWaterfall
   return true
})

#===============================================================================
# Dive
#===============================================================================
def Kernel.pbDive
  return false if $game_player.pbHasDependentEvents?
  divemap = pbGetMetadata($game_map.map_id,MetadataDiveMap)
  return false if !divemap
  move = getID(PBMoves,:DIVE)
  movefinder = Kernel.pbCheckMove(move)
  if !pbCheckHiddenMoveSwitch(SWITCHFORDIVE,false) ||
   (!$DEBUG && !movefinder && !$PokemonBag.pbHasItem?(:GOLDENSCUBAGEAR))
    Kernel.pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
    return false
  end
  if !movefinder && $PokemonBag.pbHasItem?(:HM06) &&
   $PokemonBag.pbHasItem?(:GOLDENSCUBAGEAR) && $game_switches[1235]
    Kernel.pbMessage(_INTL("Golden items cannot be used at this time."))
    return false
  end

  if Kernel.pbConfirmMessage(_INTL("The sea is deep here.  Would you like to use Dive?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    if speciesname==$Trainer.name && $PokemonBag.pbHasItem?(:GOLDENSCUBAGEAR)
      Kernel.pbMessage(_INTL("{1} used the Golden Scuba Gear!",speciesname))
    else
      Kernel.pbMessage(_INTL("{1} used Dive!",speciesname))
    end
    pbHiddenMoveAnimation(movefinder)
    pbFadeOutIn(99999){
       $game_temp.player_new_map_id    = divemap
       $game_temp.player_new_x         = $game_player.x
       $game_temp.player_new_y         = $game_player.y
       $game_temp.player_new_direction = $game_player.direction
       Kernel.pbCancelVehicles
       $PokemonGlobal.diving = true
       Kernel.pbUpdateVehicle
       $scene.transfer_player(false)
       $game_map.autoplay
       $game_map.refresh
    }
    return true
  end
  return false
end

def Kernel.pbSurfacing
  return if !$PokemonGlobal.diving
  divemap = nil
  meta = pbLoadMetadata
  for i in 0...meta.length
    if meta[i] && meta[i][MetadataDiveMap] && meta[i][MetadataDiveMap]==$game_map.map_id
      divemap = i; break
    end
  end
  return if !divemap
  move = getID(PBMoves,:DIVE)
  movefinder = Kernel.pbCheckMove(move)
  if !pbCheckHiddenMoveSwitch(SWITCHFORDIVE,false) ||
   (!$DEBUG && !movefinder && !$PokemonBag.pbHasItem?(:GOLDENSCUBAGEAR))
    Kernel.pbMessage(_INTL("Light is filtering down from above. A Pokémon may be able to surface here."))
    return false
  end
  if Kernel.pbConfirmMessage(_INTL("Light is filtering down from above. Would you like to use Dive?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    Kernel.pbMessage(_INTL("{1} used Dive!",speciesname))
    pbHiddenMoveAnimation(movefinder)
    pbFadeOutIn(99999){
       $game_temp.player_new_map_id    = divemap
       $game_temp.player_new_x         = $game_player.x
       $game_temp.player_new_y         = $game_player.y
       $game_temp.player_new_direction = $game_player.direction
       Kernel.pbCancelVehicles
       $PokemonGlobal.surfing = true
       Kernel.pbUpdateVehicle
       $scene.transfer_player(false)
       surfbgm = pbGetMetadata(0,MetadataSurfBGM)
       (surfbgm) ?  pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
       $game_map.refresh
    }
    return true
  end
  return false
end

def Kernel.pbTransferUnderwater(mapid,xcoord,ycoord,direction=$game_player.direction)
  pbFadeOutIn(99999){
     $game_temp.player_new_map_id    = mapid
     $game_temp.player_new_x         = xcoord
     $game_temp.player_new_y         = ycoord
     $game_temp.player_new_direction = direction
     Kernel.pbCancelVehicles
     $PokemonGlobal.diving = true
     Kernel.pbUpdateVehicle
     $scene.transfer_player(false)
     $game_map.autoplay
     $game_map.refresh
  }
end

Events.onAction+=lambda{|sender,e|
  if $PokemonGlobal.diving
    if DIVINGSURFACEANYWHERE
      Kernel.pbSurfacing
      return
    end
    divemap = nil
    meta = pbLoadMetadata
    for i in 0...meta.length
      if meta[i] && meta[i][MetadataDiveMap] && meta[i][MetadataDiveMap]==$game_map.map_id
        divemap = i; break
      end
    end
    if $MapFactory.getTerrainTag(divemap,$game_player.x,$game_player.y)==PBTerrain::DeepWater
      Kernel.pbSurfacing
      return
    end
  else
    if $game_player.terrain_tag==PBTerrain::DeepWater
      Kernel.pbDive
      return
    end
  end
}

HiddenMoveHandlers::CanUseMove.add(:DIVE,lambda{|move,pkmn,showmsg|
  return false if !pbCheckHiddenMoveSwitch(SWITCHFORDIVE,showmsg)
  if $PokemonGlobal.diving
    return true if DIVINGSURFACEANYWHERE
    divemap = nil
    meta = pbLoadMetadata
    for i in 0...meta.length
      if meta[i] && meta[i][MetadataDiveMap] && meta[i][MetadataDiveMap]==$game_map.map_id
        divemap = i; break
      end
    end
    if $MapFactory.getTerrainTag(divemap,$game_player.x,$game_player.y)==PBTerrain::DeepWater
      return true
    else
      Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
      return false
    end
  end
  if $game_player.terrain_tag!=PBTerrain::DeepWater
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  if !pbGetMetadata($game_map.map_id,MetadataDiveMap)
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:DIVE,lambda{|move,pokemon|
  wasdiving = $PokemonGlobal.diving
  if $PokemonGlobal.diving
    divemap = nil
    meta = pbLoadMetadata
    for i in 0...meta.length
      if meta[i] && meta[i][MetadataDiveMap] && meta[i][MetadataDiveMap]==$game_map.map_id
        divemap = i; break
      end
    end
  else
    divemap=pbGetMetadata($game_map.map_id,MetadataDiveMap)
  end
  return false if !divemap
  if !pbHiddenMoveAnimation(pokemon)
    Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
  end
  pbFadeOutIn(99999){
     $game_temp.player_new_map_id    = divemap
     $game_temp.player_new_x         = $game_player.x
     $game_temp.player_new_y         = $game_player.y
     $game_temp.player_new_direction = $game_player.direction
     Kernel.pbCancelVehicles
     (wasdiving) ? $PokemonGlobal.surfing = true : $PokemonGlobal.diving = true
     Kernel.pbUpdateVehicle
     $scene.transfer_player(false)
     $game_map.autoplay
     $game_map.refresh
  }
  return true
})

#===============================================================================
# Fly
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLY,lambda{|move,pkmn,showmsg|
  return false if !pbCheckHiddenMoveSwitch(SWITCHFORFLY,showmsg)
  return false if !$PokemonBag.pbHasItem?(:HM02)
  if inPast?
    Kernel.pbMessage(_INTL("You are unable to travel in the past!")) if showmsg
    return false
  end
  if $game_player.pbHasDependentEvents?
    Kernel.pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    return false
  end
  if $game_switches[999]
    Kernel.pbMessage(_INTL("It can't be used while riding a Pokemon.")) if showmsg
    return false
  end
  if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:FLY,lambda{|move,pokemon|
   if !$PokemonTemp.flydata
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,HiddenMoveHandlers.move_name(move,pokemon)))
   end
   pbFadeOutIn(99999){
      $strengthUsed = false
      $game_temp.player_new_map_id    = $PokemonTemp.flydata[0]
      $game_temp.player_new_x         = $PokemonTemp.flydata[1]
      $game_temp.player_new_y         = $PokemonTemp.flydata[2]
      $game_temp.player_new_direction = 2
      Kernel.pbCancelVehicles
      $PokemonTemp.flydata = nil
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
      $game_variables[298] = 0
   }
   pbEraseEscapePoint
   return true
})

#===============================================================================
# Flash
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLASH,lambda{|move,pkmn,showmsg|
  return false if !pbCheckHiddenMoveSwitch(SWITCHFORFLASH,showmsg)
  if !pbGetMetadata($game_map.map_id,MetadataDarkMap)
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  if $PokemonGlobal.flashUsed
    Kernel.pbMessage(_INTL("Flash is already being used.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:FLASH,lambda{|move,pokemon|
   darkness = $PokemonTemp.darknessSprite
   return false if !darkness || darkness.disposed?
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,HiddenMoveHandlers.move_name(move,pokemon)))
   end
   $PokemonGlobal.flashUsed = true
   while darkness.radius<176
     Graphics.update
     Input.update
     pbUpdateSceneMap
     darkness.radius += 4
   end
   return true
})

#===============================================================================
# Dig
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:DIG,lambda{|move,pkmn,showmsg|
   escape = ($PokemonGlobal.escapePoint rescue nil)
   if !escape || escape==[]
     Kernel.pbMessage(_INTL("Can't use that here."))
     return false
   end
   if $game_player.pbHasDependentEvents?
     Kernel.pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
     return false
   end
   return true
})

HiddenMoveHandlers::ConfirmUseMove.add(:DIG,lambda{|move,pkmn|
  escape = ($PokemonGlobal.escapePoint rescue nil)
  return false if !escape || escape==[]
  mapname = pbGetMapNameFromId(escape[0])
  return Kernel.pbConfirmMessage(_INTL("Want to escape from here and return to {1}?",mapname))
})
  
  
HiddenMoveHandlers::UseMove.add(:DIG,lambda{|move,pokemon|
   escape = ($PokemonGlobal.escapePoint rescue nil)
   if escape
     if !pbHiddenMoveAnimation(pokemon)
       Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
     end
     pbFadeOutIn(99999){
        $game_temp.player_new_map_id    = escape[0]
        $game_temp.player_new_x         = escape[1]
        $game_temp.player_new_y         = escape[2]
        $game_temp.player_new_direction = escape[3]
        Kernel.pbCancelVehicles
        $scene.transfer_player
        $game_map.autoplay
        $game_map.refresh
        $game_variables[298] = 0
     }
     terrain=Kernel.pbFacingTerrainTag
     if pbIsWaterTag?(terrain) && !$PokemonGlobal.surfing 
       pbStartSurfing()
       return true
     end
     
     pbEraseEscapePoint
     return true
   end
   return false
})

def pbFakeDig
  escape = ($PokemonGlobal.escapePoint rescue nil)
  if escape
    pbFadeOutIn(99999){
       $game_temp.player_new_map_id    = escape[0]
       $game_temp.player_new_x         = escape[1]
       $game_temp.player_new_y         = escape[2]
       $game_temp.player_new_direction = escape[3]
       Kernel.pbCancelVehicles
       $scene.transfer_player
       $game_map.autoplay
       $game_map.refresh
       $game_variables[298] = 0
    }
    pbEraseEscapePoint
    return true
  end
end

#===============================================================================
# Sweet Scent
#===============================================================================
def pbSweetScent
  if $game_screen.weather_type!=0
    Kernel.pbMessage(_INTL("The sweet scent faded for some reason..."))
    return
  end
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  count = 0
  viewport.color.alpha -= 10
  begin
    if viewport.color.alpha<128 && count==0
      viewport.color.red   = 255
      viewport.color.green = 0
      viewport.color.blue  = 0
      viewport.color.alpha += 8
    else
      count += 1
      if count>10
        viewport.color.alpha -= 8
      end
    end
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end until viewport.color.alpha<=0
  viewport.dispose
  encounter = nil
  enctype = $PokemonEncounters.pbEncounterType
  if enctype<0 || !$PokemonEncounters.isEncounterPossibleHere?() ||
     !pbEncounter(enctype)
    Kernel.pbMessage(_INTL("There appears to be nothing here..."))
  end
end

HiddenMoveHandlers::CanUseMove.add(:SWEETSCENT,lambda{|move,pkmn,showmsg|
   return true
})

HiddenMoveHandlers::UseMove.add(:SWEETSCENT,lambda{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,PBMoves.getName(move)))
   end
   pbSweetScent
   return true
})

#### SARDINES - RockClimb - START
#===============================================================================
# Rock Climb
#===============================================================================
def Kernel.pbAscendDescendRock(event=nil)
  event = $game_player if !event
  return if !event
  return if event.direction!=8 && event.direction!=2
  oldthrough = event.through
  oldmovespeed = event.move_speed
  terrain = Kernel.pbFacingTerrainTag
  return if terrain!=PBTerrain::RockClimb
  event.through = true
  event.move_speed = 5.5
  loop do
    event.move_up if event.direction==8
    event.move_down if event.direction==2
    terrain = Kernel.pbGetTerrainTag(event)
    break if terrain!=PBTerrain::RockClimb
  end
  event.through    = oldthrough
#  event.move_speed = oldmovespeed
end

def Kernel.pbRockClimb
  move = PBMoves::ROCKCLIMB
  movefinder = HiddenMoveHandlers.party_user(move)
  if !pbCheckHiddenMoveSwitch(SWITCHFORROCKCLIMB,false) || !$PokemonBag.pbHasItem?(:TM101) ||
   (!$DEBUG && !movefinder && !$PokemonBag.pbHasItem?(:GOLDENCLAWS) )
    Kernel.pbMessage(_INTL("A wall of rock is in front of you."))
    return false
  end
  if !movefinder && $PokemonBag.pbHasItem?(:TM101) &&
   $PokemonBag.pbHasItem?(:GOLDENCLAWS) && $game_switches[1235]
    Kernel.pbMessage(_INTL("Golden items cannot be used at this time."))
    return false
  end

  if Kernel.pbConfirmMessage(_INTL("These rocks look like they can be climbed upon. Would you like to climb them?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    if speciesname==$Trainer.name && $PokemonBag.pbHasItem?(:GOLDENCLAWS) && $PokemonBag.pbHasItem?(:TM101)
      Kernel.pbMessage(_INTL("{1} used the Golden Claws!",speciesname))
    else
      Kernel.pbMessage(_INTL("{1} used {2}!",speciesname,HiddenMoveHandlers.move_name(move,movefinder)))
    end
    pbHiddenMoveAnimation(movefinder)
    pbAscendDescendRock
    return true
  end
  return false
end

Events.onAction+=lambda{|sender,e|
  terrain=Kernel.pbFacingTerrainTag
  if terrain==PBTerrain::RockClimb
    Kernel.pbRockClimb
    return
  end
}

HiddenMoveHandlers::CanUseMove.add(:ROCKCLIMB,lambda{|move,pkmn,showmsg|
  return false if !pbCheckHiddenMoveSwitch(SWITCHFORROCKCLIMB,showmsg)
  if Kernel.pbFacingTerrainTag!=PBTerrain::RockClimb
    Kernel.pbMessage(_INTL("Can't use that here.")) if showmsg
    return false
  end
  return true
})

HiddenMoveHandlers::UseMove.add(:ROCKCLIMB,lambda{|move,pokemon|
   if !pbHiddenMoveAnimation(pokemon)
     Kernel.pbMessage(_INTL("{1} used {2}!",pokemon.name,HiddenMoveHandlers.move_name(move,pokemon)))
   end
   pbSEPlay("PRSFX- Rock Climb")
   Kernel.pbAscendDescendRock
   return true
})
#### SARDINES - RockClimb - END
