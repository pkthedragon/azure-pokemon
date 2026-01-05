#===============================================================================
# € BW Gender Selector by KleinStudio
#===============================================================================

#===============================================================================
# When it's true the script will also start the text entry scene for 
# write your trainer name
#===============================================================================

WRITETRAINERNAME  = true
TRAINERMALE       = "Graphics/Characters/trainer250"
TRAINERFEMALE     = "Graphics/Characters/trainer253"
TRAINERNEUTRAL     = "Graphics/Characters/trainer256"
TRAINEREXTRA1     = "Graphics/Characters/trainer_extra1"
TRAINEREXTRA2     = "Graphics/Characters/trainer_extra2"
TRAINEREXTRA3     = "Graphics/Characters/trainer_extra3"

class GenderSelectorScene
  def pbStartScene
    @sprites = {}
    # Force 512x384 viewport (your screen size)
    @viewport = Viewport.new(0, 0, 512, 384)
    @viewport.z = 99999
    @select = -1
    @finished = false

    # ---------------------------------------------------------------------
    # Define all available characters here (6 total)
    # player_id is the index you pass to pbChangePlayer
    # ---------------------------------------------------------------------
    @options = [
      { name: "Boy 1",     trainer: TRAINERMALE,    ui_name: "genderboy",     player_id: 0 },
      { name: "Neutral 1", trainer: TRAINERNEUTRAL, ui_name: "genderneutral", player_id: 6 },
      { name: "Girl 1",    trainer: TRAINERFEMALE,  ui_name: "gendergirl",    player_id: 3 },
      { name: "Extra 1",   trainer: TRAINEREXTRA1,  ui_name: "genderextra1",  player_id: 1 },
      { name: "Extra 2",   trainer: TRAINEREXTRA2,  ui_name: "genderextra2",  player_id: 2 },
      { name: "Extra 3",   trainer: TRAINEREXTRA3,  ui_name: "genderextra3",  player_id: 4 }
    ]
    # You can change player_id values above to match your metadata.

    # ---------------------------------------------------------------------
    # Background + scrolling strips
    # ---------------------------------------------------------------------
    @sprites["bg"] = IconSprite.new(@viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Gender/genderbg2")

    @sprites["genderbg"] = IconSprite.new(@viewport)
    @sprites["genderbg"].setBitmap("Graphics/Pictures/Gender/genderbg")

    # ---------------------------------------------------------------------
    # Create UI icons + trainer sprites for each option
    # Layout: 2 rows of 3 on a 512x384 screen
    # ---------------------------------------------------------------------
    top_y    = 384 / 2 - 64   # ~128
    bottom_y = 384 / 2 + 64   # ~256
    xs = [100, 256, 412]      # x positions for columns

    @options.each_with_index do |opt, i|
      row = (i < 3) ? 0 : 1
      col = i % 3
      char_x = xs[col]
      char_y = (row == 0) ? top_y : bottom_y

      # Icon (UI bar / highlight)
      @sprites["gender#{i}"] = IconSprite.new(@viewport)
      @sprites["gender#{i}"].setBitmap("Graphics/Pictures/Gender/#{opt[:ui_name]}")
      @sprites["gender#{i}"].opacity = 0

      # Trainer sprite
      @sprites["char#{i}"] = Sprite.new(@viewport)
      bmp = BitmapCache.load_bitmap(opt[:trainer])
      @sprites["char#{i}"].bitmap = bmp

      total_frames = bmp.width / bmp.height
      total_frames = 1 if total_frames < 1
      realwidth = bmp.width / total_frames
      @sprites["char#{i}"].src_rect.set((total_frames - 1) * realwidth, 0,
                                        realwidth, bmp.height)
      @sprites["char#{i}"].oy = bmp.height / 2
      @sprites["char#{i}"].ox = realwidth / 2
      @sprites["char#{i}"].x = char_x
      @sprites["char#{i}"].y = char_y
      @sprites["char#{i}"].zoom_x = 0.82
      @sprites["char#{i}"].zoom_y = 0.82
      @sprites["char#{i}"].opacity = 0
      @sprites["char#{i}"].tone.set(-60, -60, -60, 100) # start dimmed
    end

    @sprites["msgwindow"] = Kernel.pbCreateMessageWindow(@viewport)

    # start fully transparent, pbShow will fade in
    @sprites["bg"].opacity = 0
    @sprites["genderbg"].opacity = 0
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbHide
    10.times do
      Graphics.update
      @sprites["bg"].opacity        -= 25.5
      @sprites["genderbg"].opacity  -= 25.5
      @options.each_index do |i|
        @sprites["gender#{i}"].opacity -= 25.5
        @sprites["char#{i}"].opacity   -= 25.5
      end
    end
  end

  def pbShow
    10.times do
      Graphics.update
      @sprites["bg"].opacity       += 25.5
      @sprites["genderbg"].opacity += 25.5
      @options.each_index do |i|
        @sprites["gender#{i}"].opacity += 25.5
        @sprites["char#{i}"].opacity   += 25.5
      end
    end
  end

  # -------------------------------------------------------------------------
  # Visual update when selection changes: zoom + tone
  # -------------------------------------------------------------------------
  def applySelectionVisuals
    @options.each_index do |i|
      sprite = @sprites["char#{i}"]
      ui     = @sprites["gender#{i}"]
      if i == @select
        ui.opacity = 255
        sprite.tone.set(0, 0, 0, 0)
        sprite.zoom_x = 2.0
        sprite.zoom_y = 2.0
      else
        ui.opacity = 160
        sprite.tone.set(-60, -60, -60, 100)
        sprite.zoom_x = 0.82
        sprite.zoom_y = 0.82
      end
    end
  end

  # -------------------------------------------------------------------------
  # Confirm selection -> pbChangePlayer + name input
  # -------------------------------------------------------------------------
  def selection
    opt = @options[@select]
    return if !opt

    @sprites["msgwindow"].visible = false

    # Simple confirm prompt
    if !Kernel.pbConfirmMessage(_INTL("Are you sure?"))
      @sprites["msgwindow"].visible = true
      return
    end

    pbChangePlayer(opt[:player_id])
    Kernel.pbMessage(_INTL("What's your name?"))
    selectName
  end

  def selectName
    if WRITETRAINERNAME
      pbHide
      pbTrainerName
      if !Kernel.pbConfirmMessage(_INTL("Your name is {1}?",$Trainer.name))
        selectName
      else
        pbShow
        finalMessage
        pbHide
        @finished = true
      end
    else
      @finished = true
    end
  end

  def finalMessage
    Kernel.pbMessage(_INTL("Everything is looking good!"))
  end

  # -------------------------------------------------------------------------
  # Main update loop
  # -------------------------------------------------------------------------
  def pbUpdate
    pbShow
    Kernel.pbMessageDisplay(@sprites["msgwindow"],
      _INTL("What do you look like?\\^"))

    @select = 0
    applySelectionVisuals

    loop do
      oldselect = @select
      Graphics.update
      Input.update
      pbScrollBg

      if Input.trigger?(Input::LEFT)
        pbSEPlay("BW2MenuSelect")
        @select = [@select - 1, 0].max
      elsif Input.trigger?(Input::RIGHT)
        pbSEPlay("BW2MenuSelect")
        @select = [@select + 1, @options.length - 1].min
      elsif Input.trigger?(Input::UP)
        pbSEPlay("BW2MenuSelect")
        @select -= 3 if @select >= 3
      elsif Input.trigger?(Input::DOWN)
        pbSEPlay("BW2MenuSelect")
        @select += 3 if @select + 3 < @options.length
      end

      if @select != oldselect
        applySelectionVisuals
      end

      if Input.trigger?(Input::C)
        pbSEPlay("BW2MenuChoose")
        selection
      end
      break if @finished
    end
  end

  def pbScrollBg
    @sprites["genderbg"].ox += 1
    @options.each_index do |i|
      @sprites["gender#{i}"].ox += 1
    end
  end
end
###################################################

class GenderSelector
  def initialize(scene)
   @scene=scene
  end
  def pbStartScreen
   @scene.pbStartScene
   @scene.pbUpdate
   @scene.pbEndScene
  end
end

def pbGenderSelector
  scene=GenderSelectorScene.new
  screen=GenderSelector.new(scene)
  screen.pbStartScreen
end