#===============================================================================
# * Advanced Pokédex - by FL (Credits will be appreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. When a switch is ON, it displays at
# pokédex the pokémon PBS data for a caught pokémon like: base exp, egg steps
# to hatch, abilities, wild hold item, evolution, the moves that pokémon can
# learn by level/breeding/TM/TR/HM/tutors, among others.
#
#== INSTALLATION ===============================================================
#
# Put it above main, put a 512x384 background named "advancedPokedex" for this
# screen in "Graphics/Pictures/Pokedex/". At same folder, put three 512x32
# images for the top pokédex selection named "advancedInfoBar",
# "advancedAreaBar" and "advancedFormsBar".
#
# In UI_Pokedex_Entry script section, change both lines (use Ctrl+F to find
# it) '@page = 3 if @page > 3' into '@page=@maxPage if @page>@maxPage'.
#
#== HOW TO USE =================================================================
#
# Turn the switch at 'SWITCH' field (by default switch 704) as ON.
#
#===============================================================================

class AdvancedPokedexScene
  # Switch number that toggle this script ON/OFF
  SWITCH = 704

  # When true displays TMs/TRs/HMs/Tutors moves
  SHOW_MACHINE_TUTOR_MOVES = true

  # When false doesn't displays machine moves that aren't in any TM/TR/HM item
  SHOW_TUTOR_MOVES = true

  # When true displays TMs/TRs/HMs/Tutors without their subdivisions
  SHOW_ALL_MACHINE_TUTOR_TOGETHER = false

  # TMs/TRs/HMs digits to show on list. When 0, doesn't show number
  MACHINE_DIGITS = 3

  # Name of TM/TR usable only once
  TR_NAME = "TM"

  # When false doesn't show egg moves of a evolved pokémon
  EGG_MOVES_FIRST_STAGE = true

  # When true only display the last evolution method for a species that has more
  # than one evolution method (like Magneton evolving by item and location)
  SINGLE_EVOLUTION_METHOD = true

  # The Advanced Pokédex page number. You need to edit it (and barBitmapPath) if
  # you added more pages to the pokédex. Don't decrease it
  ADVANCED_PAGE = 4

  # Returns a bar index with ADV label for each page index.
  def barBitmapPath
    return [
      nil,
      _INTL("Graphics/Pictures/Pokedex/advancedInfoBar"),
      _INTL("Graphics/Pictures/Pokedex/advancedAreaBar"),
      _INTL("Graphics/Pictures/Pokedex/advancedFormsBar")
    ]
  end

  def pbStartScene(species)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @species=species
    @sprites={}
    @maxPage = ADVANCED_PAGE  # Always show Advanced page
    @subPage=1
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/advancedPokedex"))
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["overlay"].x=0
    @sprites["overlay"].y=0
    @sprites["info"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["advancedicon"]=PokemonSpeciesIconSprite.new(@species,@viewport)
    @sprites["advancedicon"].x=82
    @sprites["advancedicon"].y=328
    @sprites["advancedicon"].visible = false
    @sprites["dexbar"]=IconSprite.new(0,0,@viewport)
    @sprites["dexbar"].visible = false
    @page=ADVANCED_PAGE
    @totalSubPages=0
    @type1=nil
    @type2=nil
    drawPage(@page)
    pbUpdate
    return true
  end

  def drawPage(page)
    dexbarVisible = @page<ADVANCED_PAGE  # Always show bar when not on Advanced page
    @sprites["dexbar"].visible = dexbarVisible
    @sprites["dexbar"].setBitmap(barBitmapPath[@page]) if dexbarVisible
    if @sprites["advancedicon"]
      @sprites["advancedicon"].visible = page==ADVANCED_PAGE
    end
    drawPageAdvanced if page==ADVANCED_PAGE
  end

  def pbUpdate
    @sprites["info"].bitmap.clear
    pbSetSystemFont(@sprites["info"].bitmap)
    height = Graphics.height-54
    line2Y = Graphics.height-54

    # Bottom text
    textpos = [[
      PBSpecies.getName(@species),Graphics.width/2,Graphics.height-82,2,BASE_COLOR,SHADOW_COLOR
    ]]
    if $Trainer.owned[@species]
      textpos.push([
        _INTL("{1}/{2}",@subPage,@totalSubPages),
        Graphics.width-52,Graphics.height-52,1,BASE_COLOR,SHADOW_COLOR
      ])
    end
    pbDrawTextPositions(@sprites["info"].bitmap, textpos)

    # Type icon
    if !@type1 # This "if" only occurs when the getInfo isn't called
      @type1=$pkmn_dex[@species][3]
      @type2=$pkmn_dex[@species][4]
    end
    typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/Pokedex/pokedexTypes"))
    type1rect=Rect.new(0,@type1*32,96,32)
    type2rect=Rect.new(0,@type2*32,96,32)
    typeBaseX = (Graphics.width-type1rect.width)/2
    if @type1!=@type2
      @sprites["info"].bitmap.blt(typeBaseX-54,line2Y,typebitmap.bitmap,type1rect)
      @sprites["info"].bitmap.blt(typeBaseX+54,line2Y,typebitmap.bitmap,type2rect)
    else
      @sprites["info"].bitmap.blt(typeBaseX,line2Y,typebitmap.bitmap,type1rect)
    end

    @sprites["advancedicon"].update if @sprites["advancedicon"]
  end

  BASE_COLOR = Color.new(88,88,80)
  SHADOW_COLOR = Color.new(168,184,184)
  BASE_X = 30
  EXTRA_X = 224
  BASE_Y = 66
  EXTRA_Y = 32

  class PageGroup
    attr_accessor :label
    attr_accessor :pages
    attr_accessor :array
    attr_accessor :isMove

    def self.newInfoGroup(array)
      ret = self.new
      ret.array=array
      ret.setupInfoPageSize
      ret.isMove = false
      return ret
    end

    def self.newMoveGroup(label, moveArray)
      ret = self.new
      ret.label=label
      ret.array=moveArray
      ret.pages = 1+(moveArray.size-1)/10
      ret.isMove = true
      return ret
    end

    def setupInfoPageSize
      @pages = 0
      for i in 0...@array.size
        j = @array.size-i-1
        next if @array[j].empty?
        @pages = 1+j/2
        break
      end
    end
  end

  def drawPageAdvanced
    @sprites["background"].setBitmap(
      _INTL("Graphics/Pictures/Pokedex/advancedPokedex")
    )
    @totalSubPages=0
    @type1=$pkmn_dex[@species][3]
    @type2=$pkmn_dex[@species][4]
    if $Trainer.owned[@species]
      @groupArray = []
      @groupArray.push(PageGroup.newInfoGroup(getInfo))
      @groupArray.push(PageGroup.newMoveGroup(
        _INTL("LEVEL UP MOVES:"), getLevelMoves
      ))
      @groupArray.push(PageGroup.newMoveGroup(_INTL("EGG MOVES:"), getEggMoves))
      if SHOW_MACHINE_TUTOR_MOVES
        machineMoves = getMachineMoves
        @groupArray.push(PageGroup.newMoveGroup(
          _INTL("TM MOVES:"), machineMoves[0])
        )
        @groupArray.push(PageGroup.newMoveGroup(
          _INTL("#{TR_NAME} MOVES:"), machineMoves[1])
        )
        @groupArray.push(PageGroup.newMoveGroup(
          _INTL("HM MOVES:"), machineMoves[2])
        )
        @groupArray.push(PageGroup.newMoveGroup(
          _INTL("TUTOR MOVES:"), machineMoves[3])
        )
      end
      @totalSubPages = @groupArray.sum{|group| group.pages}
      @subPage= [@totalSubPages, @subPage].min
    end
    displaySubPage
  end

  def displaySubPage
    overlay = @sprites["overlay"].bitmap
    overlay.clear

    return if !$Trainer.owned[@species]

    # Page content
    turnedPages=0
    for group in @groupArray
      if @subPage<=group.pages+turnedPages
        if group.isMove
          displaySubPageMoves(group, @subPage-turnedPages)
        else
          displaySubPageInfo(group, @subPage-turnedPages)
        end
        break
      end
      turnedPages+=group.pages
    end
  end

  def displaySubPageInfo(group, subPage)
    textpos = []
    for i in (12*(subPage-1))...(12*subPage)
      line = i%6
      column = i/6
      next if !group.array[column] || !group.array[column][line]
      x = BASE_X+EXTRA_X*(column%2)
      y = BASE_Y+EXTRA_Y*line
      textpos.push([
        group.array[column][line],x,y,false,BASE_COLOR,SHADOW_COLOR
      ])
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
  end

  def displaySubPageMoves(group,subPage)
    textpos = [[group.label,BASE_X,BASE_Y,false,BASE_COLOR,SHADOW_COLOR]]
      for i in (10*(subPage-1))...(10*subPage)
      break if i>=group.array.size
      line = i%5
      column = i/5
      x = BASE_X+EXTRA_X*(column%2)
      y = BASE_Y+EXTRA_Y*(line+1)
      textpos.push([group.array[i],x,y,false,BASE_COLOR,SHADOW_COLOR])
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
  end

  def getInfo
    # ret works like a table with two columns per page
    ret = Array.new(2*4){ [] }
    # Base Stats
    baseStats=[
      $pkmn_dex[@species][5][0], # HP
      $pkmn_dex[@species][5][1], # Attack
      $pkmn_dex[@species][5][2], # Defense
      $pkmn_dex[@species][5][3], # Speed
      $pkmn_dex[@species][5][4], # Special Attack
      $pkmn_dex[@species][5][5]  # Special Defense
    ]
    baseStatsTot=0
    for i in 0...baseStats.size
      baseStatsTot+=baseStats[i]
    end
    ret[0][0]=_ISPRINTF(
      "                             HP ATK DEF SPD SAT SDF TOT"
    )
    ret[0][1]=_ISPRINTF(
      "BASE STATS:       {1:03d} {2:03d} {3:03d} {4:03d} {5:03d} {6:03d} {7:03d}",
      baseStats[0],baseStats[1],baseStats[2],
      baseStats[3],baseStats[4],baseStats[5],baseStatsTot
    )
    # Effort Points
    effortPoints=[
      $pkmn_dex[@species][11][0], # HP
      $pkmn_dex[@species][11][1], # Attack
      $pkmn_dex[@species][11][2], # Defense
      $pkmn_dex[@species][11][3], # Speed
      $pkmn_dex[@species][11][4], # Special Attack
      $pkmn_dex[@species][11][5]  # Special Defense
    ]
    effortPointsTot=0
    for i in 0...effortPoints.size
      effortPoints[i]=0 if !effortPoints[i]
      effortPointsTot+=effortPoints[i]
    end
    ret[0][2]=_ISPRINTF(
      "EFFORT POINTS: {1:03d} {2:03d} {3:03d} {4:03d} {5:03d} {6:03d} {7:03d}",
      effortPoints[0],effortPoints[1],effortPoints[2],
      effortPoints[3],effortPoints[4],effortPoints[5],effortPointsTot
    )
    # Abilities
    ability1=$pkmn_dex[@species][12][0]
    ability2=$pkmn_dex[@species][12][1]
    if ability1==ability2 || ability2==0
      abilityString = PBAbilities.getName(ability1)
    else
      abilityString = _INTL("{1}, {2}",
        PBAbilities.getName(ability1), PBAbilities.getName(ability2))
    end
    ret[0][3]=_INTL("ABILITIES: {1}",abilityString)
    # Hidden Abilities
    hiddenAbility1=$pkmn_dex[@species][17]
    if hiddenAbility1!=0
      abilityString = PBAbilities.getName(hiddenAbility1)
      ret[0][4]=_INTL("HIDDEN ABILITIES: {1}",abilityString)
    end
    # Base Exp
    ret[2][0]=_INTL("BASE EXP: {1}",$pkmn_dex[@species][16])
    # Catch Rate
    ret[2][1]=_INTL("CATCH RATE: {1}",$pkmn_dex[@species][6])
    # Growth Rate
    growthRate=$pkmn_dex[@species][9]
    growthRateString = [_INTL("Medium"),_INTL("Erratic"),_INTL("Fluctuating"),
      _INTL("Parabolic"),_INTL("Fast"),_INTL("Slow")][growthRate]
    ret[2][2]=_INTL(
      "GROWTH RATE: {1} ({2})",growthRateString,PBExperience.pbGetMaxExperience(growthRate)
    )
    # Gender Rate
    genderbyte=$pkmn_dex[@species][7]
    if genderbyte==0
      genderString = _INTL("Always male")
    elsif genderbyte==254
      genderString = _INTL("Always female")
    elsif genderbyte==255
      genderString = _INTL("Genderless")
    else
      genderPercent = 100-((genderbyte+1)*100/256.0)
      genderString = _INTL("Male {1}%",genderPercent)
    end
    ret[2][3]= _INTL("GENDER RATE: {1}", genderString)
    # Egg Steps to Hatch
    stepsToHatch = $pkmn_dex[@species][10]
    ret[2][4]= _INTL(
      "STEPS TO HATCH EGG: {1} ({2} cycles)",
      stepsToHatch,stepsToHatch/255
    )
    # Breed Group
    compat10=$pkmn_dex[@species][13][0]
    compat11=$pkmn_dex[@species][13][1]
    eggGroupArray=[
      nil,_INTL("Monster"),_INTL("Water1"),_INTL("Bug"),_INTL("Flying"),
      _INTL("Ground"),_INTL("Fairy"),_INTL("Plant"),_INTL("Humanshape"),
      _INTL("Water3"),_INTL("Mineral"),_INTL("Indeterminate"),
      _INTL("Water2"),_INTL("Ditto"),_INTL("Dragon"),_INTL("No Eggs")
    ]
    if compat10==compat11
      eggGroups = eggGroupArray[compat10]
    else
      eggGroups = _INTL("{1}, {2}",
        eggGroupArray[compat10],eggGroupArray[compat11])
    end
    ret[2][5]=_INTL("BREED GROUP: {1}",eggGroups)
    # Happiness base
    ret[4][1]=_INTL("HAPPINESS BASE: {1}",$pkmn_dex[@species][8])
    # Color
    colorName=[
      _INTL("Red"),_INTL("Blue"),_INTL("Yellow"),
      _INTL("Green"),_INTL("Black"),_INTL("Brown"),
      _INTL("Purple"),_INTL("Gray"),_INTL("White"),_INTL("Pink")
    ][$pkmn_dex[@species][1]]
    ret[4][2]=_INTL("COLOR: {1}",colorName)
    # Wild hold item
    holdItems=[$pkmn_dex[@species][18],$pkmn_dex[@species][19],$pkmn_dex[@species][20]]
    holdItemsStrings=[]
    hasAlwaysHoldItem = (
      holdItems[0]!=0 &&
      holdItems[0] == holdItems[1] &&
      holdItems[0] == holdItems[2]
    )
    if hasAlwaysHoldItem
      holdItemsStrings.push(
        _INTL("{1} (always)",PBItems.getName(holdItems[0]))
      )
    else
      holdItemsStrings.push(_INTL("{1} (common)",
        PBItems.getName(holdItems[0]))) if holdItems[0]>0
      holdItemsStrings.push(_INTL("{1} (uncommon)",
        PBItems.getName(holdItems[1]))) if holdItems[1]>0
      holdItemsStrings.push(_INTL("{1} (rare)",
        PBItems.getName(holdItems[2]))) if holdItems[2]>0
    end
    ret[6][0] = _INTL(
      "WILD ITEMS: {1}",
      holdItemsStrings.empty? ? _INTL("None") : holdItemsStrings[0]
    )
    ret[6][1] = holdItemsStrings[1] if holdItemsStrings.size>1
    ret[6][2] = holdItemsStrings[2] if holdItemsStrings.size>2
    # Evolutions
    evolutionsStrings = []
    lastEvolutionSpecies = nil
    for evoData in pbGetEvolvedFormData(@species)
      if SINGLE_EVOLUTION_METHOD && lastEvolutionSpecies==evoData[2]
        evolutionsStrings.pop
      end
      evolutionsStrings.push(getEvolutionMessage(evoData))
      lastEvolutionSpecies=evoData[2]
    end
    line=3
    column=6
    ret[column][line] = _INTL(
      "EVO: {1}",
      evolutionsStrings.empty? ? _INTL("None") : evolutionsStrings[0]
    )
    evolutionsStrings.shift
    line+=1
    for string in evolutionsStrings
      if line>5  # For when the pokémon has more than 3 evolutions (AKA Eevee)
        line=0
        column+=2
        ret += Array.new(2){ [] }
      end
      ret[column][line] = string
      line+=1
    end
    return ret
  end

  # Gets the evolution array and return evolution message
  def getEvolutionMessage(evolution)
    evoName = PBSpecies.getName(evolution[2])
    evoMethod = evolution[0]
    evoParam = evolution[1]
    ret = case evoMethod
      when 1
        _INTL("{1} when happy",evoName)
      when 2
        _INTL("{1} when happy at day",evoName)
      when 3
        _INTL("{1} when happy at night",evoName)
      when 4
        _INTL("{1} at level {2}", evoName,evoParam)
      when 5
        _INTL("{1} trading",evoName)
      when 6
        _INTL("{1} trading holding {2}",evoName,PBItems.getName(evoParam))
      when 7
        _INTL("{1} using {2}",evoName,PBItems.getName(evoParam))
      when 8
        _INTL("{1} at level {2} and ATK > DEF",evoName,evoParam)
      when 9
        _INTL("{1} at level {2} and ATK = DEF",evoName,evoParam)
      when 10
        _INTL("{1} at level {2} and DEF < ATK",evoName,evoParam)
      when 11,12
        _INTL("{1} at level {2} with personalID",evoName,evoParam)
      when 13
        _INTL("{1} at level {2}",evoName,evoParam)
      when 14
        _INTL("{1} at level {2} with empty ball/space",evoName,evoParam)
      when 15
        _INTL("{1} when beauty is greater than {2}",evoName,evoParam)
      when 16
        _INTL("{1} using {2} and it's male",evoName,PBItems.getName(evoParam))
      when 17
        _INTL("{1} using {2} and it's female",evoName,PBItems.getName(evoParam))
      when 18
        _INTL("{1} holding {2} at day",evoName,PBItems.getName(evoParam))
      when 19
        _INTL("{1} holding {2} at night",evoName,PBItems.getName(evoParam))
      when 20
        _INTL("{1} when has move {2}",evoName,PBMoves.getName(evoParam))
      when 21
        _INTL("{1} when has {2} at party",evoName,PBSpecies.getName(evoParam))
      when 22
        _INTL("{1} at level {2} and it's male",evoName,evoParam)
      when 23
        _INTL("{1} at level {2} and it's female",evoName,evoParam)
      when 24
        _INTL("{1} at {2}",evoName, pbGetMapNameFromId(evoParam))
      when 25
        _INTL("{1} trading by {2}",evoName,PBSpecies.getName(evoParam))
      when 26
        _INTL("{1} bad influence at level {2}", evoName,evoParam)
      when 27
        _INTL("{1} custom2 with {2}", evoName,evoParam)
      when 28
        _INTL("{1} at level {2} when raining", evoName,evoParam)
      when 29
        _INTL("{1} LevelDay with {2}", evoName,evoParam)
      when 30
        _INTL("{1} LevelNight with {2}", evoName,evoParam)
      when 31
        _INTL("{1} BattleCrits with {2}", evoName,evoParam)
      when 32
        _INTL("{1} custom7 with {2}", evoName,evoParam)
      when 33
        _INTL("{1} GimmiCoin with {2}", evoName,evoParam)
      when 34
        _INTL("{1} holding {2}",evoName,PBItems.getName(evoParam))
      else
        evoName
    end
    return ret
  end

  def getLevelMoves
    $pkmn_moves = pbCachedData("Data/attacksRS.rxdata") if !$pkmn_moves
    return $pkmn_moves[@species].map{|moveData|
      _ISPRINTF(
        "{1:02d} {2:s}",moveData[0],PBMoves.getName(moveData[1])
      )
    }
  end

  def getEggMoves
    if EGG_MOVES_FIRST_STAGE
      eggMoveSpecies = pbGetBabySpecies(@species)
    else
      eggMoveSpecies = @species
    end
    $pkmn_egg = pbCachedData("Data/eggEmerald.dat") if !$pkmn_egg
    movelist=[]
    for moves in [$pkmn_egg[pbGetBabySpecies(@species)],$pkmn_egg[pbGetLessBabySpecies(@species)],$pkmn_egg[@species]]
      if moves
        for i in moves
          movelist.push(i)
        end
      end
    end
    ret=[]
    for move in movelist
      ret.push(PBMoves.getName(move))
    end
    ret.sort!
    return ret
  end

  # Return a nested array with TMs, TRs, HMs and other tutors
  def getMachineMoves
    tmData=pbCachedData("Data/tm.dat")
    movesArray=[]
    for move in 1...tmData.size
      next if !tmData[move]
      movesArray.push(move) if tmData[move].any?{ |item| item==@species }
    end
    tmArray = []
    trArray = []
    hmArray = []
    tutorArray = []
    machineMoves = []
    if !SHOW_ALL_MACHINE_TUTOR_TOGETHER
      for item in 1..PBItems.maxValue
        next if !pbIsMachine?(item)
        move = $ItemData[item][ITEMMACHINE]
        next if !movesArray.include?(move)
        if MACHINE_DIGITS>0
          machineLabel = PBItems.getName(item)
          machineLabel = machineLabel[2,machineLabel.size-2]
          if pbIsHiddenMachine?(item)
            machineLabel = "H"+machineLabel[1,1]
          end
          machineLabel = machineLabel.to_i
          machineLabel = "%0#{MACHINE_DIGITS}d" % (
            machineLabel % 10**MACHINE_DIGITS
          )
          moveLabel = _INTL(
            "{1} {2}",machineLabel,PBMoves.getName(move)
          )
        else
          moveLabel = PBMoves.getName(move)
        end
        movesArray.delete(move)
        if pbIsHiddenMachine?(item)
          hmArray.push(moveLabel)
        elsif $ItemData[item][ITEMUSE]==4  # TR (consumable TM)
          trArray.push(moveLabel)
        else
          tmArray.push(moveLabel)
        end
      end
    end
    if SHOW_TUTOR_MOVES
      tutorArray = movesArray.map{|move| PBMoves.getName(move)}
    end
    return [tmArray.sort, trArray.sort, hmArray.sort, tutorArray.sort]
  end

  def pbControls(listlimits)
    Graphics.transition
    ret=0
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::ACTION)
        if @page == ADVANCED_PAGE
          @subPage-=1
          @subPage=@totalSubPages if @subPage<1
          displaySubPage
        end
      elsif Input.trigger?(Input::USE)
        if @page == ADVANCED_PAGE
          @subPage+=1
          @subPage=1 if @subPage>@totalSubPages
          displaySubPage
        end
      elsif Input.trigger?(Input::LEFT)
        ret=4
        break
      # If not at top of list
      elsif Input.trigger?(Input::UP) && listlimits&1==0
        ret=8
        break
      # If not at end of list
      elsif Input.trigger?(Input::DOWN) && listlimits&2==0
        ret=2
        break
      elsif Input.trigger?(Input::B)
        ret=1
        pbPlayCancelSE()
        pbFadeOutAndHide(@sprites)
        break
      end
    end
    return ret
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end


class AdvancedPokedex
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(species,listlimits)
    @scene.pbStartScene(species)
    ret=@scene.pbControls(listlimits)
    @scene.pbEndScene
    return ret
  end
end
