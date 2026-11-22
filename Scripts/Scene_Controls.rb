#==============================================================================
# * Scene_Controls
#------------------------------------------------------------------------------
# Shows a help screen listing the keyboard controls.
# Display with:
#      pbEventScreen(ButtonEventScene)
#==============================================================================
class ButtonEventScene < EventScene
  #pk code
  def initialize(viewport=nil)
    super
    lines=[
      _INTL("Arrow Keys: Move"),
      _INTL("C: Talk/Select"),
      _INTL("X: Open Menu/Skip Text/Exit"),
      _INTL("A: Quicksave"),
      _INTL("S: Sprint"),
      _INTL("F: Turbo"),
      _INTL("M: Open Field Manual in-battle"),
      _INTL("E: Open Encyclopedia in-battle")
    ]
    screen=BitmapSprite.new(Graphics.width,Graphics.height,viewport)
    addUserSprite(screen)
    bitmap=screen.bitmap
    bitmap.fill_rect(0,0,bitmap.width,bitmap.height,Color.new(0,0,0))
    pbSetSystemFont(bitmap)
    bitmap.font.color=Color.new(248,248,248)
    lineHeight=36
    y=(bitmap.height-lines.length*lineHeight)/2
    lines.each do |line|
      bitmap.draw_text(32,y,bitmap.width-64,lineHeight,line)
      y+=lineHeight
    end
    onCTrigger.set(method(:pbOnScreen1))
    onBTrigger.set(method(:pbOnScreen1))
  end

  def pbOnScreen1(scene,args)
    scene.dispose
  end
end

