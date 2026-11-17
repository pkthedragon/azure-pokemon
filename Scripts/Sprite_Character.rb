class BushBitmap
  def initialize(bitmap,isTile,depth)
    @bitmaps=[]
    @bitmap=bitmap
    @isTile=isTile
    @isBitmap=@bitmap.is_a?(Bitmap)
    @depth=depth
  end

  def dispose
    for b in @bitmaps
      b.dispose if b
    end
  end

  def bitmap
    thisBitmap=@isBitmap ? @bitmap : @bitmap.bitmap
    current=@isBitmap ? 0 : @bitmap.currentIndex
    if !@bitmaps[current]
      if @isTile
        @bitmaps[current]=Sprite_Character.pbBushDepthTile(thisBitmap,@depth)
      else
        @bitmaps[current]=Sprite_Character.pbBushDepthBitmap(thisBitmap,@depth)
      end
    end
    return @bitmaps[current]
  end
end



class Sprite_Character < RPG::Sprite
  attr_accessor :character

  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    @oldbushdepth=0
    update
  end

  def groundY
    return @character.screen_y_ground
  end

  def self.pbBushDepthBitmap(bitmap,depth)
    ret=Bitmap.new(bitmap.width,bitmap.height)
    charheight=ret.height/4
    for i in 0...4
      cy=charheight-depth-2
      y=i*charheight
      ret.blt(0,y,bitmap,Rect.new(0,y,ret.width,cy)) if cy>=0
      ret.blt(0,y+cy,bitmap,Rect.new(0,y+cy,ret.width,2),170) if cy>=0    
      ret.blt(0,y+cy+2,bitmap,Rect.new(0,y+cy+2,ret.width,2),85) if cy+2>=0    
    end
    return ret
  end

  def self.pbBushDepthTile(bitmap,depth)
    ret=Bitmap.new(bitmap.width,bitmap.height)
    charheight=ret.height
    cy=charheight-depth-2
    y=charheight
    ret.blt(0,y,bitmap,Rect.new(0,y,ret.width,cy)) if cy>=0
    ret.blt(0,y+cy,bitmap,Rect.new(0,y+cy,ret.width,2),170) if cy>=0    
    ret.blt(0,y+cy+2,bitmap,Rect.new(0,y+cy+2,ret.width,2),85) if cy+2>=0    
    return ret
  end

  def dispose
    @bushbitmap.dispose if @bushbitmap
    @bushbitmap=nil
    @charbitmap.dispose if @charbitmap
    @charbitmap=nil
    disposeAlternateCharset
    super
  end

  def disposeAlternateCharset
    @alternateCharset.dispose if @alternateCharset
    @alternateCharset=nil
  end

  def loadCharacterCharset(name,hue)
    retain=!$INEDITOR && (@character.equal?($game_player) || @character.move_route_forcing)
    keepCurrent=retain && @charbitmapAnimated && @charbitmap && @charbitmap.length==1
    return @charbitmap if keepCurrent && @character_name==name && @character_hue==hue

    if retain && @alternateCharset && @alternateCharsetName==name && @alternateCharsetHue==hue
      bitmap=@alternateCharset
      @alternateCharset=nil
    else
      bitmap=AnimatedBitmap.new("Graphics/Characters/"+name,hue)
      disposeAlternateCharset
    end
    # Reuse one static sheet during walking/running and scripted graphic changes.
    if keepCurrent
      @alternateCharset=@charbitmap
      @alternateCharsetName=@character_name
      @alternateCharsetHue=@character_hue
    else
      @charbitmap.dispose if @charbitmap
    end
    return bitmap
  end

  def update
    super
    tileId=@character.tile_id
    name=@character.character_name
    hue=@character.character_hue
    graphic_changed = @tile_id != tileId || @character_name != name || @character_hue != hue
    # A settled invisible trigger still updates its event logic and can show an animation.
    if !graphic_changed && @character.is_a?(Game_Event) && tileId==0 && name.empty? &&
       @character.animation_id==0 && @loopAnimations.empty? && @animations.none?(&:active?)
      return
    end
    currentbushdepth = @character.bush_depth
    if graphic_changed
      if tileId >= 384
        @charbitmap.dispose if @charbitmap
        disposeAlternateCharset
        @charbitmap = pbGetTileBitmap(@character.map.tileset_name,tileId,hue)
        @charbitmapAnimated=false
        @cw = 32  # added
        @ch = 32  # added
        self.src_rect.set(0, 0, 32, 32)
        self.ox = Game_Map::TILEWIDTH/2
        self.oy = Game_Map::TILEHEIGHT
      else
        @charbitmap = loadCharacterCharset(name,hue)
        @charbitmapAnimated=true
        @cw = @charbitmap.width / 4
        @ch = @charbitmap.height / 4
        self.ox = @cw / 2
        if name[/offset/]
          self.oy = @ch - 16
        else
          self.oy = @ch
        end
      end
      @tile_id = tileId
      @character_name = name
      @character_hue = hue
    end
    if graphic_changed || @oldbushdepth != currentbushdepth
      @bushbitmap.dispose if @bushbitmap
      @bushbitmap=nil
      @oldbushdepth=currentbushdepth
    end
    @charbitmap.update if @charbitmapAnimated
    if currentbushdepth==0
      bitmap=@charbitmapAnimated ? @charbitmap.bitmap : @charbitmap
    else
      if !@bushbitmap
        @bushbitmap=BushBitmap.new(@charbitmap,@tile_id >= 384,currentbushdepth)
      end
      bitmap=@bushbitmap.bitmap
    end
    self.bitmap = bitmap if graphic_changed || !self.bitmap.equal?(bitmap)
    visible = !@character.transparent
    self.visible = visible if self.visible != visible
    if @tile_id == 0
      if @character==$game_player 
        if $PokemonGlobal.surfing || $PokemonGlobal.diving || $PokemonGlobal.lavasurfing
          bob=((Graphics.frame_count%60)/15).floor
          self.oy=(bob>=2) ? @ch-16-2 : @ch-16
        end
      end
      if @character==$game_player && !$PokemonGlobal.fishing && ($PokemonGlobal.surfing || $PokemonGlobal.diving || $PokemonGlobal.lavasurfing)
        sx = bob * @cw
      else
        sx = @character.pattern * @cw
      end
      sy = (@character.direction - 2) / 2 * @ch
      rect = self.src_rect
      if rect.x != sx || rect.y != sy || rect.width != @cw || rect.height != @ch
        rect.set(sx, sy, @cw, @ch)
      end
    end
    if self.visible
      if $PokemonSystem.tilemap==0 || (@character.is_a?(Game_Event) && @character.name=="RegularTone")
        self.tone.set(0,0,0,0)
      else
        pbDayNightTint(self)
      end
    end
    x = @character.screen_x
    y = @character.screen_y
    z = @character.screen_z(@ch)
    opacity = @character.opacity
    blend = @character.blend_type
    self.x = x if self.x != x
    self.y = y if self.y != y
    self.z = z if self.z != z
    self.opacity = opacity if self.opacity != opacity
    self.blend_type = blend if self.blend_type != blend
#    self.bush_depth = @character.bush_depth
    if @character.animation_id != 0
      animation = pbLoadRPGAnimations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
  end
end
