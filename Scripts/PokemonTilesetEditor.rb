begin

def pbTilesetWrapper
  return PokemonDataWrapper.new(
     "Data/Tilesets.rxdata",
     "Data/TilesetsTemp.rxdata",
     Proc.new{
        Kernel.pbMessage(_INTL("The editor has detected that the tileset data was recently edited in RPG Maker XP."))
        next !Kernel.pbConfirmMessage(_INTL("Do you want to load those recent edits?"))
     }
  )
end



class PokemonTilesetScene
  def pbUpdateTileset
    @sprites["overlay"].bitmap.clear
    textpos=[]
    @sprites["tileset"].src_rect=Rect.new(0,@topy,256,Graphics.height-64)
    tilesize=@tileset.terrain_tags.xsize
    for yy in 0...(Graphics.height-64)/32
      ypos=(yy+(@topy/32))*8+384
      next if ypos>=tilesize
      for xx in 0...8
        terr=ypos<384 ? @tileset.terrain_tags[xx*48] : @tileset.terrain_tags[ypos+xx]
        if ypos<384
          @tilehelper.bltTile(@sprites["overlay"].bitmap,xx*32,yy*32,xx*48)
        end
        textpos.push(["#{terr}",xx*32+16,yy*32,2,Color.new(80,80,80),Color.new(192,192,192)])
      end
    end
    @sprites["overlay"].bitmap.fill_rect(@x,@y-@topy,32,4,Color.new(255,0,0))
    @sprites["overlay"].bitmap.fill_rect(@x,@y-@topy,4,32,Color.new(255,0,0))
    @sprites["overlay"].bitmap.fill_rect(@x,@y-@topy+28,32,4,Color.new(255,0,0))
    @sprites["overlay"].bitmap.fill_rect(@x+28,@y-@topy,4,32,Color.new(255,0,0))
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
  end

  def pbGetSelected(x,y)
    if y<0
      return 48*(x/32)
    else
      return (y/32)*8+384+(x/32)
    end
  end

  def pbSetSelected(i,value)
    if i<384
      for j in 0...48
        @tileset.terrain_tags[i+j]=value
      end
    else
      @tileset.terrain_tags[i]=value
    end
  end

  def pbChooseTileset
    commands=[]
    for i in 1...@tilesetwrapper.data.length
      commands.push(sprintf("%03d %s",i,@tilesetwrapper.data[i].name))
    end
    ret=Kernel.pbShowCommands(nil,commands,-1)
    if ret>=0
      @tileset=@tilesetwrapper.data[ret+1]
      @tilehelper.dispose
      @tilehelper=TileDrawingHelper.fromTileset(@tileset)
      @sprites["tileset"].setBitmap("Graphics/Tilesets/#{@tileset.tileset_name}")
      @x=0
      @y=-32
      @topy=-32
      pbUpdateTileset
    end
  end

  def pbStartScene
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @tilesetwrapper=pbTilesetWrapper
    @tileset=@tilesetwrapper.data[1]
    @tilehelper=TileDrawingHelper.fromTileset(@tileset)
    @sprites={}
    @sprites["title"]=Window_UnformattedTextPokemon.new(_INTL("Tileset Editor (PgUp/PgDn: SCROLL; Z: MENU)"))
    @sprites["title"].viewport=@viewport
    @sprites["title"].x=0
    @sprites["title"].y=0
    @sprites["title"].width=Graphics.width
    @sprites["title"].height=64
    @sprites["tileset"]=IconSprite.new(0,64,@viewport)
    @sprites["tileset"].setBitmap("Graphics/Tilesets/#{@tileset.tileset_name}")
    @sprites["tileset"].src_rect=Rect.new(0,0,256,Graphics.height-64)
    @sprites["overlay"]=BitmapSprite.new(256,Graphics.height-64,@viewport)
    @sprites["overlay"].x=0
    @sprites["overlay"].y=64
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["title"].visible=true
    @sprites["tileset"].visible=true
    @sprites["overlay"].visible=true
    @x=0
    @y=-32
    @topy=-32
    pbUpdateTileset
    pbFadeInAndShow(@sprites)
    height=@sprites["tileset"].bitmap.height
    ########
    loop do
      Graphics.update
      Input.update
      if Input.repeat?(Input::UP)
        @y-=32
        @y=-32 if @y<-32
        @topy=@y if @y<@topy
        pbUpdateTileset
      elsif Input.repeat?(Input::DOWN)
        @y+=32
        @y=@sprites["tileset"].bitmap.height-32 if @y>=@sprites["tileset"].bitmap.height-32
        @topy=@y-(Graphics.height-64)+32 if @y-@topy>=Graphics.height-64
        pbUpdateTileset
      elsif Input.repeat?(Input::LEFT)
        @x-=32
        @x=0 if @x<0
        pbUpdateTileset
      elsif Input.repeat?(Input::RIGHT)
        @x+=32
        @x=256-32 if @x>=256-32
        pbUpdateTileset
      elsif Input.repeat?(Input::L)
        @y-=((Graphics.height-64)/32)*32
        @topy-=((Graphics.height-64)/32)*32
        @y=-32 if @y<-32
        @topy=@y if @y<@topy
        @topy=-32 if @topy<-32
        pbUpdateTileset
      elsif Input.repeat?(Input::R)
        @y+=((Graphics.height-64)/32)*32
        @topy+=((Graphics.height-64)/32)*32
        @y=@sprites["tileset"].bitmap.height-32 if @y>=@sprites["tileset"].bitmap.height-32
        @topy=@y-(Graphics.height-64)+32 if @y-@topy>=Graphics.height-64
        @topy=@sprites["tileset"].bitmap.height-(Graphics.height-64) if @topy>=@sprites["tileset"].bitmap.height-(Graphics.height-64)
        pbUpdateTileset
      elsif Input.trigger?(Input::A)
        commands=[
           _INTL("Go to bottom"),
           _INTL("Go to top"),
           _INTL("Change tileset"),
           _INTL("Cancel")
        ]
        ret=Kernel.pbShowCommands(nil,commands,-1)
        case ret
          when 0
            @y=@sprites["tileset"].bitmap.height-32
            @topy=@y-(Graphics.height-64)+32 if @y-@topy>=Graphics.height-64
            pbUpdateTileset
          when 1
            @y=-32
            @topy=@y if @y<@topy
            pbUpdateTileset
          when 2
            pbChooseTileset
        end
      elsif Input.trigger?(Input::B)
        if Kernel.pbConfirmMessage(_INTL("Save changes?"))
          @tilesetwrapper.save
          $data_tilesets=@tilesetwrapper.data
          if $game_map && $MapFactory
            $MapFactory.setup($game_map.map_id)
            $game_player.center($game_player.x,$game_player.y)
            if $scene.is_a?(Scene_Map)
              $scene.disposeSpritesets
              $scene.createSpritesets
            end
          end
          Kernel.pbMessage(_INTL("To ensure that the changes remain, close and reopen RPG Maker XP."))
        end
        break if Kernel.pbConfirmMessage(_INTL("Exit from the editor?"))
      elsif Input.trigger?(Input::C)
        selected=pbGetSelected(@x,@y)
        params=ChooseNumberParams.new
        params.setRange(0,99)
        params.setDefaultValue(@tileset.terrain_tags[selected])
        pbSetSelected(selected,Kernel.pbMessageChooseNumber(
           _INTL("Set the terrain tag."),params
        ))
        pbUpdateTileset
      end
    end
    ########
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @tilehelper.dispose
  end
end



def pbTilesetScreen
  pbFadeOutIn(99999){
     scene=PokemonTilesetScene.new
     scene.pbStartScene
  }
end

# Text-based terrain tag editor for large tilesets that cause mega surface errors
def pbTextTerrainTagEditor
  tilesetwrapper = pbTilesetWrapper
  loop do
    # Choose tileset
    commands = []
    for i in 1...tilesetwrapper.data.length
      commands.push(sprintf("%03d %s", i, tilesetwrapper.data[i].name))
    end
    tilesetIndex = Kernel.pbShowCommands(nil, commands, -1)
    break if tilesetIndex < 0
    tileset = tilesetwrapper.data[tilesetIndex + 1]

    loop do
      # Main menu for this tileset
      menuCommands = [
        _INTL("Set tag by tile index"),
        _INTL("Set tag by row/column"),
        _INTL("View current tags (range)"),
        _INTL("Set autotile tag (0-7)"),
        _INTL("Save and exit"),
        _INTL("Back to tileset list")
      ]
      choice = Kernel.pbShowCommands(nil, menuCommands, -1)

      case choice
      when 0 # Set by tile index
        params = ChooseNumberParams.new
        params.setRange(0, tileset.terrain_tags.xsize - 1)
        params.setDefaultValue(384)
        tileIndex = Kernel.pbMessageChooseNumber(_INTL("Enter tile index (384+ for regular tiles):"), params)

        currentTag = tileset.terrain_tags[tileIndex]
        Kernel.pbMessage(_INTL("Current terrain tag at index {1}: {2}", tileIndex, currentTag))

        params2 = ChooseNumberParams.new
        params2.setRange(0, 99)
        params2.setDefaultValue(currentTag)
        newTag = Kernel.pbMessageChooseNumber(_INTL("Set new terrain tag:"), params2)
        tileset.terrain_tags[tileIndex] = newTag
        Kernel.pbMessage(_INTL("Set index {1} to terrain tag {2}.", tileIndex, newTag))

      when 1 # Set by row/column
        Kernel.pbMessage(_INTL("Regular tiles start at row 0. Each row has 8 columns (0-7)."))
        params = ChooseNumberParams.new
        params.setRange(0, 999)
        params.setDefaultValue(0)
        row = Kernel.pbMessageChooseNumber(_INTL("Enter row (0 = first row of regular tiles):"), params)

        params2 = ChooseNumberParams.new
        params2.setRange(0, 7)
        params2.setDefaultValue(0)
        col = Kernel.pbMessageChooseNumber(_INTL("Enter column (0-7):"), params2)

        tileIndex = 384 + (row * 8) + col
        if tileIndex >= tileset.terrain_tags.xsize
          Kernel.pbMessage(_INTL("Error: Index {1} is out of bounds (max {2}).", tileIndex, tileset.terrain_tags.xsize - 1))
          next
        end

        currentTag = tileset.terrain_tags[tileIndex]
        Kernel.pbMessage(_INTL("Row {1}, Col {2} (index {3}) = tag {4}", row, col, tileIndex, currentTag))

        params3 = ChooseNumberParams.new
        params3.setRange(0, 99)
        params3.setDefaultValue(currentTag)
        newTag = Kernel.pbMessageChooseNumber(_INTL("Set new terrain tag:"), params3)
        tileset.terrain_tags[tileIndex] = newTag
        Kernel.pbMessage(_INTL("Set to terrain tag {1}.", newTag))

      when 2 # View range
        params = ChooseNumberParams.new
        params.setRange(0, tileset.terrain_tags.xsize - 1)
        params.setDefaultValue(384)
        startIndex = Kernel.pbMessageChooseNumber(_INTL("Start index:"), params)

        params2 = ChooseNumberParams.new
        params2.setRange(1, 64)
        params2.setDefaultValue(16)
        count = Kernel.pbMessageChooseNumber(_INTL("How many tiles to show:"), params2)

        text = ""
        for i in 0...count
          idx = startIndex + i
          break if idx >= tileset.terrain_tags.xsize
          row = (idx - 384) / 8
          col = (idx - 384) % 8
          tag = tileset.terrain_tags[idx]
          text += sprintf("[%d] r%d,c%d = %d\n", idx, row, col, tag)
        end
        Kernel.pbMessage(text)

      when 3 # Set autotile tag
        params = ChooseNumberParams.new
        params.setRange(0, 7)
        params.setDefaultValue(0)
        autotileNum = Kernel.pbMessageChooseNumber(_INTL("Which autotile (0-7)?"), params)

        baseIndex = autotileNum * 48
        currentTag = tileset.terrain_tags[baseIndex]
        Kernel.pbMessage(_INTL("Autotile {1} current tag: {2}", autotileNum, currentTag))

        params2 = ChooseNumberParams.new
        params2.setRange(0, 99)
        params2.setDefaultValue(currentTag)
        newTag = Kernel.pbMessageChooseNumber(_INTL("Set new terrain tag:"), params2)

        # Set all 48 tiles of this autotile
        for j in 0...48
          tileset.terrain_tags[baseIndex + j] = newTag
        end
        Kernel.pbMessage(_INTL("Set autotile {1} (indices {2}-{3}) to tag {4}.", autotileNum, baseIndex, baseIndex + 47, newTag))

      when 4 # Save and exit
        tilesetwrapper.save
        $data_tilesets = tilesetwrapper.data
        if $game_map && $MapFactory
          $MapFactory.setup($game_map.map_id)
          $game_player.center($game_player.x, $game_player.y)
          if $scene.is_a?(Scene_Map)
            $scene.disposeSpritesets
            $scene.createSpritesets
          end
        end
        Kernel.pbMessage(_INTL("Saved! Close and reopen RPG Maker XP to keep changes."))
        return

      when 5 # Back
        break

      else
        break
      end
    end
  end
end



rescue Exception
if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
  raise $!
else
end

end