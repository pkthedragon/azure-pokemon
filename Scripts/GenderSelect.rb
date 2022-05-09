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

class GenderSelectorScene

def pbStartScene
 @sprites={}
 @viewport=Viewport.new(0,0,Graphics.width,DEFAULTSCREENHEIGHT)
 @viewport.z=99999
 @select=-1
 @finished=false
 
 #===================================================
 # Create bars
 #===================================================
 
 @sprites["bg"] = IconSprite.new(@viewport)
 @sprites["bg"].setBitmap("Graphics/Pictures/Gender/genderbg2")
 
 @sprites["genderbg"] = IconSprite.new(@viewport)
 @sprites["genderbg"].setBitmap("Graphics/Pictures/Gender/genderbg")
 @sprites["genderbg"].opacity = 255
 
 @sprites["genderboy"] = IconSprite.new(@viewport)
 @sprites["genderboy"].setBitmap("Graphics/Pictures/Gender/genderboy")
 @sprites["genderboy"].opacity = 0
 
 @sprites["genderneutral"] = IconSprite.new(@viewport)
 @sprites["genderneutral"].setBitmap("Graphics/Pictures/Gender/genderneutral")
 @sprites["genderneutral"].opacity = 0
 
 @sprites["gendergirl"] = IconSprite.new(@viewport)
 @sprites["gendergirl"].setBitmap("Graphics/Pictures/Gender/gendergirl")
 @sprites["gendergirl"].opacity = 0
 

 #===================================================
 # Create trainer sprites
 #===================================================
  @sprites["girl"]=Sprite.new(@viewport)
  @sprites["girl"].bitmap=BitmapCache.load_bitmap(TRAINERFEMALE)
  @totalframeg=@sprites["girl"].bitmap.width/@sprites["girl"].bitmap.height
  @totalframeg=1 if @totalframeg<1
  realwidthg=@sprites["girl"].bitmap.width/@totalframeg
  @sprites["girl"].src_rect.set((@totalframeg-1)*realwidthg, 0,
  realwidthg,@sprites["girl"].bitmap.height)
  @sprites["girl"].oy=@sprites["girl"].bitmap.height/2
  @sprites["girl"].ox=realwidthg/2
  @sprites["girl"].x=412
  @sprites["girl"].y=DEFAULTSCREENHEIGHT/2

  @sprites["boy"]=Sprite.new(@viewport)
  @sprites["boy"].bitmap=BitmapCache.load_bitmap(TRAINERMALE)
  @totalframeb=@sprites["boy"].bitmap.width/@sprites["boy"].bitmap.height
  @totalframeb=1 if @totalframeb<1
  realwidthb=@sprites["boy"].bitmap.width/@totalframeb
  @sprites["boy"].src_rect.set((@totalframeb-1)*realwidthb, 0,
  realwidthb,@sprites["boy"].bitmap.height)
  @sprites["boy"].oy=@sprites["boy"].bitmap.height/2
  @sprites["boy"].ox=realwidthb/2
  @sprites["boy"].x=100
  @sprites["boy"].y=DEFAULTSCREENHEIGHT/2
  
  @sprites["neutral"]=Sprite.new(@viewport)
  @sprites["neutral"].bitmap=BitmapCache.load_bitmap(TRAINERNEUTRAL)
  @totalframeb=@sprites["neutral"].bitmap.width/@sprites["neutral"].bitmap.height
  @totalframeb=1 if @totalframeb<1
  realwidthb=@sprites["neutral"].bitmap.width/@totalframeb
  @sprites["neutral"].src_rect.set((@totalframeb-1)*realwidthb, 0,
  realwidthb,@sprites["neutral"].bitmap.height)
  @sprites["neutral"].oy=@sprites["neutral"].bitmap.height/2
  @sprites["neutral"].ox=realwidthb/2
  @sprites["neutral"].x=256
  @sprites["neutral"].y=DEFAULTSCREENHEIGHT/2

  @BOYX=@sprites["boy"].x
  
  @GIRLX=@sprites["girl"].x
  
  @NEUTRALX=@sprites["neutral"].x

  @sprites["msgwindow"]=Kernel.pbCreateMessageWindow(@viewport)
  
  @sprites["bg"].opacity=0
  @sprites["genderbg"].opacity=0
  @sprites["genderboy"].opacity=0
  @sprites["boy"].opacity=0
  @sprites["gendergirl"].opacity=0
  @sprites["girl"].opacity=0
  @sprites["genderneutral"].opacity=0
  @sprites["neutral"].opacity=0

end

  
def pbEndScene
  pbDisposeSpriteHash(@sprites)
  @viewport.dispose
end
    
def pbHide
10.times do
Graphics.update
@sprites["bg"].opacity-=25.5
@sprites["genderbg"].opacity-=25.5
@sprites["genderboy"].opacity-=25.5
@sprites["boy"].opacity-=25.5
@sprites["gendergirl"].opacity-=25.5
@sprites["girl"].opacity-=25.5
@sprites["genderneutral"].opacity-=25.5
@sprites["neutral"].opacity-=25.5
end
end

def pbShow
10.times do
Graphics.update
@sprites["bg"].opacity+=25.5
@sprites["genderbg"].opacity+=25.5

@sprites["genderboy"].opacity+=25.5 if @select==0
@sprites["boy"].opacity+=25.5 if ![1,2].include?(@select)

@sprites["gendergirl"].opacity+=25.5 if @select==2
@sprites["girl"].opacity+=25.5 if ![0,1].include?(@select)

@sprites["genderneutral"].opacity+=25.5 if @select==1
@sprites["neutral"].opacity+=25.5 if ![0,2].include?(@select)
end
end

def selectBoy(first=false)
  frame=0
  6.times do
    Graphics.update
    pbScrollBg
    frame+=1
    @sprites["gendergirl"].opacity-=12
    @sprites["genderneutral"].opacity-=12
    @sprites["genderboy"].opacity+=12
    @sprites["boy"].tone.set(0,0,0,0)
    if !first
      @sprites["boy"].zoom_x+=0.015*2 if @sprites["boy"].zoom_x != 2.0
      @sprites["boy"].zoom_y+=0.015*2 if @sprites["boy"].zoom_y != 2.0
    end
    @sprites["girl"].zoom_x-=0.015*2 if @sprites["girl"].zoom_x > 0.820
    @sprites["girl"].zoom_y-=0.015*2 if @sprites["girl"].zoom_y > 0.820
    @sprites["neutral"].zoom_x-=0.015*2
    @sprites["neutral"].zoom_y-=0.015*2
    if frame==4
      @sprites["girl"].tone.set(-60,-60,-60,100)
      @sprites["neutral"].tone.set(-60,-60,-60,100)
    end
  end
  16.times do
    Graphics.update
    pbScrollBg
    @sprites["gendergirl"].opacity-=12
    @sprites["genderneutral"].opacity-=12
    @sprites["genderboy"].opacity+=12
  end
end

def selectGirl
  frame=0
  6.times do
    Graphics.update
    pbScrollBg
    frame+=1
    @sprites["gendergirl"].opacity+=12
    @sprites["genderneutral"].opacity-=12
    @sprites["genderboy"].opacity-=12
    @sprites["girl"].tone.set(0,0,0,0)
    @sprites["girl"].zoom_x+=0.015*2 if @sprites["girl"].zoom_x != 2.0
    @sprites["girl"].zoom_y+=0.015*2 if @sprites["girl"].zoom_y != 2.0
    @sprites["boy"].zoom_x-=0.015*2 if @sprites["boy"].zoom_x > 0.820
    @sprites["boy"].zoom_y-=0.015*2 if @sprites["boy"].zoom_y > 0.820
    @sprites["neutral"].zoom_x-=0.015*2
    @sprites["neutral"].zoom_y-=0.015*2
    if frame==4
      @sprites["boy"].tone.set(-60,-60,-60,100)
      @sprites["neutral"].tone.set(-60,-60,-60,100)
    end
  end
  16.times do
    Graphics.update
    pbScrollBg
    @sprites["gendergirl"].opacity+=12
    @sprites["genderneutral"].opacity-=12
    @sprites["genderboy"].opacity-=12
  end
end

def selectNeutral
  frame=0
  6.times do
    Graphics.update
    pbScrollBg
    frame+=1
    @sprites["gendergirl"].opacity-=12
    @sprites["genderneutral"].opacity+=12
    @sprites["genderboy"].opacity-=12
    @sprites["neutral"].tone.set(0,0,0,0)
    @sprites["neutral"].zoom_x+=0.015*2 if @sprites["neutral"].zoom_x != 2.0
    @sprites["neutral"].zoom_y+=0.015*2 if @sprites["neutral"].zoom_y != 2.0
    @sprites["boy"].zoom_x-=0.015*2 if @sprites["boy"].zoom_x > 0.820
    @sprites["boy"].zoom_y-=0.015*2 if @sprites["boy"].zoom_y > 0.820
    @sprites["girl"].zoom_x-=0.015*2 if @sprites["girl"].zoom_x > 0.820
    @sprites["girl"].zoom_y-=0.015*2 if @sprites["girl"].zoom_y > 0.820
    if frame==4
      @sprites["boy"].tone.set(-60,-60,-60,100)
      @sprites["girl"].tone.set(-60,-60,-60,100)
    end
  end
  16.times do
    Graphics.update
    pbScrollBg
    @sprites["gendergirl"].opacity-=12
    @sprites["genderneutral"].opacity+=12
    @sprites["genderboy"].opacity-=12
  end
end


def selection
  # Boy is selected
  if @select==0 
    actualboyx=@sprites["boy"].x
    22.times do # Animation
      Graphics.update
      pbScrollBg
      @sprites["girl"].opacity-=18
      @sprites["neutral"].opacity-=18
      @sprites["boy"].x+=12 if @sprites["boy"].x!=DEFAULTSCREENWIDTH/2
      @sprites["boy"].x=DEFAULTSCREENWIDTH/2 if @sprites["boy"].x>DEFAULTSCREENWIDTH/2
    end
    @sprites["msgwindow"].visible=false
    if !Kernel.pbConfirmMessage(_INTL("Are you sure?"))
      22.times do
        Graphics.update
        pbScrollBg
        @sprites["girl"].opacity+=18
        @sprites["neutral"].opacity+=18
        @sprites["boy"].x-=12 if @sprites["boy"].x!=actualboyx
        @sprites["boy"].x=actualboyx if @sprites["boy"].x<actualboyx
        @sprites["msgwindow"].visible=true
      end
    else
      pbChangePlayer(0)
      @sprites["msgwindow"].visible=false
      Kernel.pbMessage(_INTL("What's your name?"))
      selectName
    end
  # Neutral is selected  
  elsif @select==1 
    actualneutralx=@sprites["neutral"].x
    22.times do # Animation
      Graphics.update
      pbScrollBg
      @sprites["boy"].opacity-=18
      @sprites["girl"].opacity-=18
    end
    @sprites["msgwindow"].visible=false
    if !Kernel.pbConfirmMessage(_INTL("Are you sure?"))
      22.times do
        Graphics.update
        pbScrollBg
        @sprites["boy"].opacity+=18
        @sprites["girl"].opacity+=18
        @sprites["msgwindow"].visible=true
      end
    else
      pbChangePlayer(6)
      @sprites["msgwindow"].visible=false
      Kernel.pbMessage(_INTL("What's your name?"))
      selectName
    end
  # Girl is selected
  elsif @select==2 
    actualgirlx=@sprites["girl"].x
    22.times do # Animation
      Graphics.update
      pbScrollBg
      @sprites["boy"].opacity-=18
      @sprites["neutral"].opacity-=18
      @sprites["girl"].x-=12 if @sprites["girl"].x!=DEFAULTSCREENWIDTH/2
      @sprites["girl"].x=DEFAULTSCREENWIDTH/2 if @sprites["girl"].x<DEFAULTSCREENWIDTH/2
    end
    @sprites["msgwindow"].visible=false
    if !Kernel.pbConfirmMessage(_INTL("Are you sure?"))
      22.times do
        Graphics.update
        pbScrollBg
        @sprites["boy"].opacity+=18
        @sprites["neutral"].opacity+=18
        @sprites["girl"].x+=12 if @sprites["girl"].x!=actualgirlx
        @sprites["girl"].x=actualgirlx if @sprites["girl"].x>actualgirlx
        @sprites["msgwindow"].visible=true
      end
    else
      pbChangePlayer(3)
      @sprites["msgwindow"].visible=false
      Kernel.pbMessage(_INTL("What's your name?"))
      selectName
    end
  end
  
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
      @finished=true
    end
  else
    @finished=true
  end
end

def finalMessage
  Kernel.pbMessage(_INTL("Everything is looking good!"))
end

def pbUpdate
  pbShow
  Kernel.pbMessageDisplay(@sprites["msgwindow"],
      _INTL("What do you look like?\\^"))
  @select=0
  selectBoy(true)
  loop do
    oldselect=@select
    Graphics.update
    Input.update
    pbScrollBg
    if Input.trigger?(Input::LEFT)
      pbSEPlay("BW2MenuSelect")
      @select = [@select-1,0].max
    elsif Input.trigger?(Input::RIGHT)
      pbSEPlay("BW2MenuSelect")
      @select = [@select+1,2].min
    end
    if @select != oldselect
      selectBoy if @select==0
      selectNeutral if @select==1
      selectGirl if @select==2
    end
    if Input.trigger?(Input::C)
      pbSEPlay("BW2MenuChoose")
      selection
    end
    break if @finished
  end
end

def pbScrollBg
  @sprites["genderbg"].ox+=1
  @sprites["genderboy"].ox+=1
  @sprites["genderneutral"].ox+=1
  @sprites["gendergirl"].ox+=1
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