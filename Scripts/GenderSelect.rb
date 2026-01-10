#===============================================================================
# € BW Gender Selector by KleinStudio (patched)
#===============================================================================

WRITETRAINERNAME  = true
TRAINERMALE       = "Graphics/Characters/trainer250"
TRAINERFEMALE     = "Graphics/Characters/trainer253"
TRAINERNEUTRAL    = "Graphics/Characters/trainer256"
TRAINEREXTRA1     = "Graphics/Characters/trainer251"
TRAINEREXTRA2     = "Graphics/Characters/trainer254"
TRAINEREXTRA3     = "Graphics/Characters/trainer257"

# Pixel-safe zoom (avoids fractional resampling artifacts on pixel art).
# If your sprites are authored at true 2x density (each intended pixel is 2x2),
# 0.5 will display them at "native" pixel size crisply.
CHAR_ZOOM = 1.0

# Layout tuning
ROW_HALF_GAP   = 80   # bigger number = rows further apart (was effectively 64)
FEMALE_X_NUDGE = 5   # "a tad" to the right; adjust to taste

class GenderSelectorScene
  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, 512, 384)
    @viewport.z = 99999
    @select = -1
    @finished = false

    # Cache base positions so hover effects never drift
    @base_char_x = []
    @base_char_y = []

    # ---------------------------------------------------------------------
    # Define all available characters here (6 total)
    # Swap positions of TRAINERFEMALE and TRAINERNEUTRAL in the grid order.
    # ---------------------------------------------------------------------
    @options = [
      { name: "Boy 1",     trainer: TRAINERMALE,    ui_name: "genderboy",     player_id: 0 },
      { name: "Girl 1",    trainer: TRAINERFEMALE,  ui_name: "gendergirl",    player_id: 3 }, # swapped
      { name: "Neutral 1", trainer: TRAINERNEUTRAL, ui_name: "genderneutral", player_id: 6 }, # swapped
      { name: "Extra 1",   trainer: TRAINEREXTRA1,  ui_name: "genderboy",     player_id: 1 },
      { name: "Extra 2",   trainer: TRAINEREXTRA2,  ui_name: "genderneutral", player_id: 4 },
      { name: "Extra 3",   trainer: TRAINEREXTRA3,  ui_name: "gendergirl",    player_id: 7 }
    ]

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
    #
    # PATCH: Increase vertical spacing between rows.
    # ---------------------------------------------------------------------
    center_y = 384 / 2
    top_y    = center_y - ROW_HALF_GAP
    bottom_y = center_y + ROW_HALF_GAP
    xs = [100, 256, 412]

    @options.each_with_index do |opt, i|
      row = (i < 3) ? 0 : 1
      col = i % 3
      char_x = xs[col]
      char_y = (row == 0) ? top_y : bottom_y

      # PATCH: nudge FEMALE sprite slightly right (only "Girl 1" option)
      # "Girl 1" is option index 1 in our swapped ordering above.
      char_x += FEMALE_X_NUDGE if i == 1

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
      @sprites["char#{i}"].x  = char_x
      @sprites["char#{i}"].y  = char_y

      # Pixel-safe constant zoom (no fractional scaling)
      @sprites["char#{i}"].zoom_x = CHAR_ZOOM
      @sprites["char#{i}"].zoom_y = CHAR_ZOOM

      @sprites["char#{i}"].opacity = 0
      @sprites["char#{i}"].tone.set(-60, -60, -60, 100)

      # Cache base positions for stable hover lift (no drifting)
      @base_char_x[i] = char_x
      @base_char_y[i] = char_y
    end

    # PATCH: Remove msgbox entirely (do not create any message window)

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
  # Visual update when selection changes:
  # - highlight + tone
  # - small lift effect using cached base_y (no drift)
  # - NO sprite resizing on hover
  # -------------------------------------------------------------------------
  def applySelectionVisuals
    lift = 6
    @options.each_index do |i|
      sprite = @sprites["char#{i}"]
      ui     = @sprites["gender#{i}"]

      if i == @select
        ui.opacity = 255
        sprite.tone.set(0, 0, 0, 0)
        sprite.y = @base_char_y[i] - lift
      else
        ui.opacity = 160
        sprite.tone.set(-60, -60, -60, 100)
        sprite.y = @base_char_y[i]
      end

      sprite.zoom_x = CHAR_ZOOM
      sprite.zoom_y = CHAR_ZOOM
    end
  end

  # -------------------------------------------------------------------------
  # Confirm selection -> pbChangePlayer + name input
  # -------------------------------------------------------------------------
  def selection
    opt = @options[@select]
    return if !opt

    if !Kernel.pbConfirmMessage(_INTL("Are you sure?"))
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
  # PATCH: No message box display at all.
  # -------------------------------------------------------------------------
  def pbUpdate
    pbShow

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

      applySelectionVisuals if @select != oldselect

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
    @scene = scene
  end
  def pbStartScreen
    @scene.pbStartScene
    @scene.pbUpdate
    @scene.pbEndScene
  end
end

def pbGenderSelector
  scene  = GenderSelectorScene.new
  screen = GenderSelector.new(scene)
  screen.pbStartScreen
end
