#===============================================================================
# Data box for boss battles (by Stochastic)
# - adapted by Sardines for Pokemon Rejuvenation
#===============================================================================
class PokeBattle_Pokemon
  attr_accessor(:isbossmon)   # is a boss pokemon
  attr_accessor(:shieldCount)   # number of shields 
  attr_accessor(:bossId) # id of the boss idk
  attr_accessor(:sosmon) # is it a pokemon called by SOS
  @sosmon=false

  alias __core_baseStats baseStats
  def baseStats
    val = __core_baseStats
    val = $bosscache[self.bossId].moninfo[:BaseStats] if self.bossId && $bosscache[self.bossId].moninfo[:BaseStats]
    return val
  end
end

def bossHandler(decision, pokemon)
  $game_switches[:No_Catch]=false
  return if !pokemon.isbossmon
  return if decision != 4
  poke = $bosscache[pokemon.bossId].moninfo
  if poke[:moves]
    k=0
    for move in poke[:moves]
      next if move.nil?
      pokemon.moves[k]=PBMove.new(move)
      k+=1
    end
  else
    pokemon.resetMoves
  end
  pokemon.level = poke[:level]
  pokemon.isbossmon = false
  pokemon.shieldCount = nil
  pokemon.bossId = nil
  pokemon.item = nil
  for i in 0...6
    pokemon.ev[i]=0
  end
  if decision == 4
      if !$Trainer.pokedex.nil?
          $Trainer.pokedex.dexList[pokemon.species][:shadowCaught?] = true
      end
  end
end

class BossPokemonDataBox < SpriteWrapper
  HP_GAUGE_SIZE = 296
  HP_COLOR_RED = Color.new(248,88,40)
  TEXT_COLOR_GRAY = Color.new(225,225,225)
  
  attr_reader :battler
  attr_accessor :selected
  attr_reader :animatingHP
  attr_reader :animatingEXP
  attr_reader :appearing
  attr_accessor :shieldCount
  attr_reader :shieldX
  attr_reader :shieldY
  attr_reader :shieldGaugeX
  attr_reader :shieldGaugeY
  attr_reader :doublebattle
  attr_reader :shieldBreaking

  def initialize(battler, doublebattle, viewport, battlerindex, battle)
    super(viewport)
    @battler = battler
    @battlerindex=battlerindex
    @battle = battle
    @frame = 0
    @showhp = true
    @animatingHP = false
    @starthp = 0
    @currenthp = 0
    @endhp = 0
    @appearing = false
    @appeared = true
    @doublebattle = doublebattle
    @shieldCount = battler.shieldCount
    @shieldBreaking = -1
    
    @statuses = AnimatedBitmap.new("Graphics/Pictures/Battle/bossbattleStatuses")
    @hpbox = Bitmap.new("Graphics/Pictures/Battle/boss_bar")
    if battler.barGraphic && battler.barGraphic != ""
      @hpbox = Bitmap.new("Graphics/Pictures/Battle/%s",battler.barGraphic)
    end
    
    # @hpboxX = 0
    # @hpboxY = 10
    # @hpGaugeY = 36
    # @shieldX = 90
    # @shieldY = 31
    # @shieldGaugeX = 20
    # @shieldGaugeY = 10
    if battlerindex==1
      @hpboxX = 0
      @hpboxY = @doublebattle ? 0 : 10
      @hpGaugeY = 36
      @shieldX = 46
      @shieldY = @hpboxY+12
      @shieldGaugeX = 20
      @shieldGaugeY = 10
    else
      @hpboxX = 0
      @hpboxY = 60
      @hpGaugeY = 36
      @shieldX = 90
      @shieldY = @hpboxY+12
      @shieldGaugeX = 20
      @shieldGaugeY = 50
    end
    self.bitmap = BitmapWrapper.new(@hpbox.width + 100, @hpbox.height + 100)
    self.visible = false
    self.x = ((Graphics.width - @hpbox.width) / 6)-27
    if @doublebattle
      self.y = 10
    else
      self.y = 1
    end
    self.z = 99999
    pbSetSmallFont(self.bitmap)

#    if @battle.raidbattle
#      pbUpdateShield(@shieldCount, self)
#    end
    
    refresh
  end

  def dispose
    @statuses.dispose
    @hpbox.dispose
    @shields.dispose
    super
  end

  def exp
    return 0
  end

  def hp
    return @animatingHP ? @currenthp : @battler.hp
  end

  def animateHP(oldhp,newhp)
    @starthp=oldhp
    @currenthp=oldhp
    @endhp=newhp
    @animatingHP=true
  end

  def animateEXP(oldexp,newexp)
  end

  def appear
    refresh
    self.visible = true
    self.opacity = 255
    @appearing = true
    @appeared = false
    @framesToAppear = 45
  end

  def refresh
    self.bitmap.clear
    
    return if !@appeared
    hpgauge = @battler.totalhp==0 ? 0 : (self.hp*HP_GAUGE_SIZE/@battler.totalhp)
    hpgauge=2 if hpgauge==0 && self.hp>0
    hpzone=0
    hpzone=1 if self.hp<=(@battler.totalhp/2).floor
    hpzone=2 if self.hp<=(@battler.totalhp/4).floor
    hpcolors=[
       PokeBattle_SceneConstants::HPCOLORGREENDARK,
       PokeBattle_SceneConstants::HPCOLORGREEN,
       PokeBattle_SceneConstants::HPCOLORYELLOWDARK,
       PokeBattle_SceneConstants::HPCOLORYELLOW,
       PokeBattle_SceneConstants::HPCOLORREDDARK,
       PokeBattle_SceneConstants::HPCOLORRED
    ]
#    self.bitmap.fill_rect(@spritebaseX+hpGaugeX,hpGaugeY,hpgauge,2,hpcolors[hpzone*2])
#    self.bitmap.fill_rect(@spritebaseX+hpGaugeX,hpGaugeY+2,hpgauge,4,hpcolors[hpzone*2+1])
    
    self.bitmap.blt(@hpboxX, @hpboxY, @hpbox, Rect.new(0, 0, @hpbox.width, @hpbox.height))
    self.bitmap.fill_rect(@hpboxX + 6, @hpboxY + @hpGaugeY, hpgauge, 1, hpcolors[hpzone*2])
    self.bitmap.fill_rect(@hpboxX + 6, @hpboxY + @hpGaugeY+1, hpgauge, 3, hpcolors[hpzone*2+1])

    base = PokeBattle_SceneConstants::BOXTEXTBASECOLOR
    shadow = PokeBattle_SceneConstants::BOXTEXTSHADOWCOLOR
    hpText = "#{self.hp} / #{@battler.totalhp}"
    battlerText = @battler.name
    textSize = self.bitmap.text_size(hpText)
    battlerTextSize = self.bitmap.text_size(battlerText)
    textpos = [
       ["#{@battler.name}", 4,
         @hpboxY+9, false, base, shadow]
#       [hpText, @hpboxX + @hpbox.width/2 - textSize.width/2,
#         @hpboxY + 32, false, base, shadow]
    ]
    @spritebaseX=0
    pbDrawTextPositions(self.bitmap, textpos)
    if @battler.status > 0
      self.bitmap.blt(176, @hpboxY+50, @statuses.bitmap, Rect.new(0,(@battler.status-1)*16,68,16))
    end
    pbDrawTextPositions(self.bitmap, textpos)
    shieldX=[150,166,182,198,214,230,246]
    @shields = Bitmap.new("Graphics/Pictures/Battle/bossbarshield")
    @shieldsBroken = Bitmap.new("Graphics/Pictures/Battle/bossbarshieldcracked")
    if @shieldCount > 0
      #for i in 0...@shieldCount
        count=0
        loop do
          if @shieldBreaking != count
            self.bitmap.blt(shieldX[count],@shieldY,@shields,Rect.new(0,16,44,16))
          else
            self.bitmap.blt(shieldX[count],@shieldY,@shieldsBroken,Rect.new(0,16,44,16))
          end
          count+=1
        break if count==@shieldCount
        end
      #end
    end 
  end

  def update
    super
    @frame += 1
    if @animatingHP
      if @currenthp < @endhp
        @currenthp += [1, (0.5 * @battler.totalhp / HP_GAUGE_SIZE).floor].max
        @currenthp = @endhp if @currenthp > @endhp
      elsif @currenthp > @endhp
        @currenthp -= [1, (0.5 * @battler.totalhp / HP_GAUGE_SIZE).floor].max
        @currenthp = @endhp if @currenthp<@endhp
      end
      @animatingHP = false if @currenthp==@endhp
      refresh
    end
    if @framesToAppear
      @framesToAppear -= 1 if @framesToAppear > 0
      if @framesToAppear <= 0
        @appearing = false
        @appeared = true
      end
    end
  end

  def fractureshield(shield)
    @shieldBreaking = shield
    self.refresh if @shieldBreaking > -1
  end
end

class PokeBattle_Battle
  def isBossBattle?
    return @battlers.any? {|pkmn| !pkmn.nil? && pkmn.isbossmon}
  end
end

class PokeBattle_Battler
  attr_accessor :bossdelayedeffect
  attr_accessor :bossdelaycounter

  def bossMoveCheck(thismove,user,target)
    immunitylist = target.immunities[:moves]
    if immunitylist.include?(thismove.id)
      pbDisplay(_INTL("{1} resisted the attack!",target.pbThis))
      return 0
    end
    return 1
  end
end

# def pbReduceHPDamage(damage,attacker,opponent)
class PokeBattle_Battle
  attr_accessor :typesequence
  def pbShieldDamage(battler,damage=0)
    shielddam = false
    hpthreshold = -1
    if battler.shieldCount>0 && battler.onBreakEffects
      onBreakdata = battler.onBreakEffects[battler.shieldCount]
      puts (onBreakdata) if $INTERNAL
      hpthreshold = (onBreakdata && onBreakdata[:threshold]) ? onBreakdata[:threshold] : 0
      if hpthreshold > 0
        if (battler.hp - damage) <= (battler.totalhp*hpthreshold).round
          damage = (battler.hp - (battler.totalhp*hpthreshold).round)
          shielddam = true
        end
      end
    end
    oldhp=battler.hp
    battler.hp-=damage
    effectiveness=0
    if battler.damagestate.typemod<4
      effectiveness=1   # "Not very effective"
    elsif battler.damagestate.typemod>4
      effectiveness=2   # "Super effective"
    end
    if battler.damagestate.typemod!=0
      scene.pbDamageAnimation(battler,effectiveness)
    end
    scene.pbHPChanged(battler,oldhp)
    battler.damagestate.hplost=damage
    if shielddam == true
      @scene.sprites["battlebox#{self.index}"].fractureshield(self.shieldCount-1)
      battler.pbRecoverHP((battler.totalhp).floor,true)
      pbShieldEffects(battler,onBreakdata) if onBreakdata 
      battler.shieldCount-=1 if battler.shieldCount>0
      @scene.sprites["battlebox#{self.index}"].fractureshield(-1)
      @scene.pbUpdateShield(battler.shieldCount,battler.index)
    end
    return damage
  end

  def pbShieldEffects(battler,onBreakdata,onEntry=false,delay=false)
    if battler.shieldsBroken[battler.shieldCount+1] && !onBreakdata[:delayedaction] && !pbAllFainted?(@party2)
      return 
    end
    @scene.pbUnVanishSprite(battler) if battler.vanished
    if onBreakdata[:animation]
      pbAnimation(onBreakdata[:animation],battler,nil)
    end
    if onBreakdata[:message] && onBreakdata[:message] != ""
      if onBreakdata[:message].start_with?("{1}") 
        pbDisplayPaused(_INTL(onBreakdata[:message],battler.pbThis))
      else
        pbDisplayPaused(_INTL(onBreakdata[:message],battler.pbThis(true)))
      end
    end
    if onBreakdata[:CustomMethod]
      eval(onBreakdata[:CustomMethod])
    end
    if onBreakdata[:fieldChange] && onBreakdata[:fieldChange] != $fefieldeffect
      $fefieldeffect = onBreakdata[:fieldChange]
      $febackup = $fefieldeffect
      pbChangeBGSprite
      fieldmessage = (onBreakdata[:fieldChangeMessage] && onBreakdata[:fieldChangeMessage] != "") ? onBreakdata[:fieldChangeMessage] : "The field was changed!"
      pbDisplay(_INTL("{1}",fieldmessage))
    end
    multiturnsymbols = [:CLAMP,:FIRESPIN,:SANDTOMB,:DESERTSMARK,:WRAP,:MAGMASTORM,:INFESTATION,:BIND,:WHIRLPOOL,:BINDINGWORD]
    if onBreakdata[:bossEffect]
      if onBreakdata[:bossEffect].is_a?(Array)
        for i in 0...onBreakdata[:bossEffect].length
          if multiturnsymbols.include?(onBreakdata[:bossEffect][i])
            battler.effects[:MultiTurnAttack] = getConst(PBMoves,onBreakdata[:bossEffect][i])
            if battler.effects[:MultiTurnAttack] == PBMoves::BINDINGWORD
              for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
                battler.effects[PBEffects::StatChangeHolder][i] = battler.stages[i]
                battler.stages[i] = 0
              end
            end
            battler.effects[:MultiTurn] = onBreakdata[:bossEffectduration] ? onBreakdata[:bossEffectduration][i] : 5
            pbCommonAnimation(onBreakdata[:bossEffectanimation][i].to_s,battler,nil) if onBreakdata[:bossEffectanimation]
          else
            battler.effects[onBreakdata[:bossEffect][i]] = onBreakdata[:bossEffectduration] ? onBreakdata[:bossEffectduration][i] : 5              
            pbAnimation(onBreakdata[:bossEffectanimation][i],battler,nil) if onBreakdata[:bossEffectanimation]
          end
        end
      else
        if multiturnsymbols.include?(onBreakdata[:bossEffect])
          battler.effects[:MultiTurnAttack] = onBreakdata[:bossEffect]
          if battler.effects[:MultiTurnAttack] == PBMoves::BINDINGWORD
            for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
              battler.effects[PBEffects::StatChangeHolder][i] = battler.stages[i]
              battler.stages[i] = 0
            end
          end
          battler.effects[:MultiTurn] = onBreakdata[:bossEffectduration] ? onBreakdata[:bossEffectduration] : 5
          pbCommonAnimation(onBreakdata[:bossEffectanimation].to_s,battler,nil) if onBreakdata[:bossEffectanimation]
        else
          battler.effects[onBreakdata[:bossEffect]] = onBreakdata[:bossEffectduration]
          pbAnimation(onBreakdata[:bossEffectanimation],battler,nil) if onBreakdata[:bossEffectanimation]
        end
      end
      if onBreakdata[:bossEffectMessage] 
        if onBreakdata[:bossEffectMessage].is_a?(Array)
          if onBreakdata[:bossEffectMessage][i].start_with?("{1}") 
            pbDisplay(_INTL(onBreakdata[:bossEffectMessage][i],battler.pbThis)) if onBreakdata[:bossEffectMessage][i] != ""
          else
            pbDisplay(_INTL(onBreakdata[:bossEffectMessage][i],battler.pbThis(true))) if onBreakdata[:bossEffectMessage][i] != ""
          end
        else
          if onBreakdata[:bossEffectMessage].start_with?("{1}") 
            pbDisplay(_INTL(onBreakdata[:bossEffectMessage],battler.pbThis)) if onBreakdata[:bossEffectMessage] != ""
          else
            pbDisplay(_INTL(onBreakdata[:bossEffectMessage],battler.pbThis(true))) if onBreakdata[:bossEffectMessage] != ""
          end
        end
      end
    end
    if onBreakdata[:playerEffects]
      if onBreakdata[:playerEffects].is_a?(Array)
        for i in 0...onBreakdata[:playerEffects].length
          if multiturnsymbols.include?(onBreakdata[:playerEffects][i])
            if !battler.pbOpposing1.isFainted?  && !battler.pbOpposing1.issossmon
              battler.pbOpposing1.effects[:MultiTurnAttack] = getConst(PBMoves,onBreakdata[:playerEffects][i])
              if battler.pbOpposing1.effects[:MultiTurnAttack] == PBMoves::BINDINGWORD
                for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
                  battler.pbOpposing1.effects[PBEffects::StatChangeHolder][i] = battler.pbOpposing1.stages[i]
                  battler.pbOpposing1.stages[i] = 0
                end
              end
              battler.pbOpposing1.effects[:MultiTurn] = onBreakdata[:playerEffectsduration] ?  onBreakdata[:playerEffectsduration][i] : 5
              pbCommonAnimation(onBreakdata[:playerEffectsAnimation[i].to_s],battler.pbOpposing1,nil) if onBreakdata[:playerEffectsAnimation][i]
            end
            if !battler.pbOpposing2.isFainted?  && !battler.pbOpposing2.issossmon
              battler.pbOpposing2.effects[:MultiTurnAttack] = getConst(PBMoves,onBreakdata[:playerEffects][i])
              if battler.pbOpposing2.effects[:MultiTurnAttack] == PBMoves::BINDINGWORD
                for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
                  battler.pbOpposing2.effects[PBEffects::StatChangeHolder][i] = battler.pbOpposing2.stages[i]
                  battler.pbOpposing2.stages[i] = 0
                end
              end
              battler.pbOpposing2.effects[:MultiTurn] = onBreakdata[:playerEffectsduration] ?  onBreakdata[:playerEffectsduration][i] : 5
              pbCommonAnimation(onBreakdata[:playerEffectsAnimation[i].to_s],battler.pbOpposing2,nil) if onBreakdata[:playerEffectsAnimation][i]
            end
          else
            if !battler.pbOpposing1.isFainted?  && !battler.pbOpposing1.issossmon
              battler.pbOpposing1.effects[onBreakdata[:playerEffects][i]] = onBreakdata[:playerEffectsduration][i]
              if onBreakdata[:playerEffects].include?(PBEffects::PerishSong)
                battler.pbOpposing1.effects[PBEffects::PerishSongUser]=battler.index
              end
              if onBreakdata[:playerEffects][i] == (PBEffects::FutureSightMove)
                battler.pbOpposing1.effects[PBEffects::FutureSightUser] = battler.index
                battler.pbOpposing1.effects[PBEffects::FutureSightPkmnIdx] = battler.pokemonIndex
              end
              pbAnimation(onBreakdata[:playerEffectsAnimation[i]],battler.pbOpposing1,nil) if onBreakdata[:playerEffectsAnimation][i]
            end
            if !battler.pbOpposing2.isFainted?  && !battler.pbOpposing2.issossmon
              battler.pbOpposing2.effects[onBreakdata[:playerEffects][i]] = onBreakdata[:playerEffectsduration][i]
              if onBreakdata[:playerEffects].include?(PBEffects::PerishSong)
                battler.pbOpposing2.effects[PBEffects::PerishSongUser]=battler.index
              end
              if onBreakdata[:playerEffects][i] == (PBEffects::FutureSightMove)
                battler.pbOpposing2.effects[PBEffects::FutureSightUser] = battler.index
                battler.pbOpposing2.effects[PBEffects::FutureSightPkmnIdx] = battler.pokemonIndex
              end
              pbAnimation(onBreakdata[:playerEffectsAnimation][i],battler.pbOpposing2,nil) if onBreakdata[:playerEffectsAnimation][i]
            end
          end
        end
      else
        if multiturnsymbols.include?(onBreakdata[:playerEffects])
          if !battler.pbOpposing1.isFainted? && !battler.pbOpposing1.issossmon
            battler.pbOpposing1.effects[:MultiTurnAttack] = getConst(PBMoves,onBreakdata[:playerEffects][i])
            if battler.pbOpposing1.effects[:MultiTurnAttack] == PBMoves::BINDINGWORD
              for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
                battler.pbOpposing1.effects[PBEffects::StatChangeHolder][i] = battler.pbOpposing1.stages[i]
                battler.pbOpposing1.stages[i] = 0
              end
            end
            battler.pbOpposing1.effects[:MultiTurn] = onBreakdata[:playerEffectsduration] ?  onBreakdata[:playerEffectsduration] : 5
            pbCommonAnimation(onBreakdata[:playerEffectsAnimation].to_s,battler.pbOpposing1,nil) if onBreakdata[:playerEffectsAnimation]
          end
          if !battler.pbOpposing2.isFainted?  && !battler.pbOpposing2.issossmon
            battler.pbOpposing2.effects[:MultiTurnAttack] = getConst(PBMoves,onBreakdata[:playerEffects][i])
            if battler.pbOpposing2.effects[:MultiTurnAttack] == PBMoves::BINDINGWORD
              for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
                battler.pbOpposing2.effects[PBEffects::StatChangeHolder][i] = battler.pbOpposing2.stages[i]
                battler.pbOpposing2.stages[i] = 0
              end
            end
            battler.pbOpposing2.effects[:MultiTurn] = onBreakdata[:playerEffectsduration] ?  onBreakdata[:playerEffectsduration] : 5
            pbCommonAnimation(onBreakdata[:playerEffectsAnimation].to_s,battler.pbOpposing2,nil) if onBreakdata[:playerEffectsAnimation]
          end
        else
          if !battler.pbOpposing1.isFainted?  && !battler.pbOpposing1.issossmon
            battler.pbOpposing1.effects[onBreakdata[:playerEffects]] = onBreakdata[:playerEffectsduration]
            if onBreakdata[:playerEffects] == (PBEffects::PerishSong)
              battler.pbOpposing1.effects[PBEffects::PerishSongUser]=battler.index
            end
            pbAnimation(onBreakdata[:playerEffectsAnimation],battler.pbOpposing1,nil) if onBreakdata[:playerEffectsAnimation]
          end
          if !battler.pbOpposing2.isFainted?  && !battler.pbOpposing2.issossmon
            battler.pbOpposing2.effects[onBreakdata[:playerEffects]] = onBreakdata[:playerEffectsduration]
            if onBreakdata[:playerEffects] == (PBEffects::PerishSong)
              battler.pbOpposing2.effects[PBEffects::PerishSongUser]=battler.index
            end
            pbAnimation(onBreakdata[:playerEffectsAnimation],battler.pbOpposing2,nil) if onBreakdata[:playerEffectsAnimation]
          end
        end
      end
      if onBreakdata[:playerEffectsMessage] && onBreakdata[:playerEffectsMessage] != ""
        if onBreakdata[:playerEffectsMessage].is_a?(Array)
          if onBreakdata[:playerEffectsMessage][i].start_with?("{1}") 
            pbDisplay(_INTL(onBreakdata[:playerEffectsMessage][i],battler.pbThis)) if onBreakdata[:playerEffectsMessage] != ""
          else
            pbDisplay(_INTL(onBreakdata[:playerEffectsMessage][i])) if onBreakdata[:playerEffectsMessage] != ""
          end
        else
          if onBreakdata[:playerEffectsMessage].start_with?("{1}") 
            pbDisplay(_INTL(onBreakdata[:playerEffectsMessage],battler.pbThis)) if onBreakdata[:playerEffectsMessage] != ""
          else
            pbDisplay(_INTL(onBreakdata[:playerEffectsMessage])) if onBreakdata[:playerEffectsMessage] != ""
          end
        end
      end
    end
    if onBreakdata[:speciesUpdate]
      battler.pokemon.species = onBreakdata[:speciesUpdate]
      battler.species = onBreakdata[:speciesUpdate]
      pbAnimation(PBMoves::TRANSFORM,battler,nil)
      battler.pbUpdate(true)
      @scene.pbChangePokemon(battler,battler.pokemon)
    end
    if onBreakdata[:formchange]
      battler.pokemon.form=onBreakdata[:formchange]
      battler.form = battler.pokemon.form 
      pbAnimation(PBMoves::TRANSFORM,battler,nil)
      battler.pbUpdate(true)
      @scene.pbChangePokemon(battler,battler.pokemon)
    end
    if onBreakdata[:bgmChange]
      pbBGMPlay(onBreakdata[:bgmChange]) if FileTest.audio_exist?("Audio/BGM/"+ onBreakdata[:bgmChange])
    end
    if onBreakdata[:abilitychange]
      battler.ability = onBreakdata[:abilitychange]
      battler.pokemon.abilityoverride = onBreakdata[:abilitychange]
      battler.pbAbilitiesOnSwitchIn(true)
    end
    if onBreakdata[:weatherChange]
      @weather=onBreakdata[:weatherChange]
      @weatherduration= onBreakdata[:weatherCount] ? onBreakdata[:weatherCount] : -1
      pbCommonAnimation(onBreakdata[:weatherChangeAnimation]) if onBreakdata[:weatherChangeAnimation]
      weathermessage = onBreakdata[:weatherChangeMessage] != "" ? onBreakdata[:weatherChangeMessage] : "The weather was changed!"
      pbDisplayBrief(_INTL("{1}",weathermessage))
      if $fefieldeffect == 35
        pbDisplay(_INTL("The weather disappeared into space!"))
        @weather=0
        @weatherduration=0
      elsif @weather==PBWeather::HAIL && ($fefieldeffect == 16 || $fefieldeffect == 7 || $fefieldeffect == 32 || $fefieldeffect == 45)
        pbDisplay(_INTL("The hail melted away."))
        @weather=0
        @weatherduration=0
      elsif @weather==PBWeather::RAINDANCE && $fefieldeffect == 45
        pbDisplay(_INTL("The rain evaporated away."))  
        @weather=0
        @weatherduration=0
      end
      if @weather==0 && @weatherbackup!=0  
        pbCommonAnimation(@weatherbackupanim,nil,nil)                    
        @weather=@weatherbackup
        @weatherduration=-1
        pbDisplay(_INTL("The initial weather took over again!"))
      end  
    end
    if onBreakdata[:statusCure]
      pbAnimation(PBMoves::REFRESH,battler,nil)
      battler.status = 0
      battler.statusCount = 0
      pbDisplayBrief(_INTL("{1} recovered from its status!",battler.pbThis))
    end
    animplay = false
    negativeEffects = [PBEffects::Curse,PBEffects::GastroAcid,PBEffects::Imprison,PBEffects::Nightmare,PBEffects::TarShot,PBEffects::SmackDown,PBEffects::Encore,PBEffects::ThroatChop,
    PBEffects::HealBlock,PBEffects::Octolock,PBEffects::MultiTurn,PBEffects::LeechSeed,PBEffects::Crushing,PBEffects::Attract,PBEffects::MultiTurnUser,PBEffects::Torment,PBEffects::Taunt,PBEffects::Confusion]
    if onBreakdata[:effectClear]
      for i in negativeEffects
        if [PBEffects::Curse,PBEffects::GastroAcid,PBEffects::Imprison,PBEffects::Nightmare,PBEffects::TarShot,PBEffects::SmackDown,PBEffects::Octolock,PBEffects::Torment].include?(i)
          if battler.effects[i] != false
            battler.effects[i] = false
            animplay = true
          end
        end
        if [PBEffects::Encore,PBEffects::HealBlock,PBEffects::MultiTurn,PBEffects::Taunt,PBEffects::ThroatChop,PBEffects::Confusion].include?(i)
          if battler.effects[i] != 0
            battler.effects[i] = 0
            if i == PBEffects::MultiTurn && battler.effects[PBEffects::MultiTurnAttack] == PBMoves::BINDINGWORD
              for j in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
                battler.stages[j] = battler.effects[PBEffects::StatChangeHolder][j]
                battler.effects[PBEffects::StatChangeHolder][j] = 0
              end
            end
            animplay = true
          end
        end
        if [PBEffects::LeechSeed,PBEffects::Crushing,PBEffects::Attract,PBEffects::MultiTurnUser].include?(i)
          if battler.effects[i] != -1          
            battler.effects[i] = -1
            animplay = true
          end
        end
        if [].include?(i) # For possible future effects
          if battler.effects[i] != nil          
            battler.effects[i] = nil
            animplay = true
          end
        end
      end
      battler.attack = battler.pokemon.attack
      battler.spatk = battler.pokemon.spatk
      battler.defense = battler.pokemon.defense
      battler.spdef = battler.pokemon.spdef
      pbAnimation(PBMoves::HEALBELL,battler,nil) if animplay
      pbDisplayBrief(_INTL("{1} cleared itself of negative effects!",battler.pbThis))
    end
    if onBreakdata[:statDropCure]
      for s in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED, PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
        battler.stages[s] = 0 if battler.stages[s]<0
        battler.effects[PBEffects::StatChangeHolder][s] = 0 if battler.effects[PBEffects::StatChangeHolder][s] < 0
      end
      pbDisplayBrief(_INTL("{1} cleared itself of stat drops!",battler.pbThis))
    end
    if onBreakdata[:ppRefresh]
      battler.moves.each do |move|
        next if move.nil?
        battler.pbSetPP(move,move.totalpp)
      end
      pp_message = onBreakdata[:ppRefreshMessage] || "{1} refreshed its PP!"
      pbDisplayBrief(_INTL(pp_message,battler.pbThis)) if pp_message && pp_message != ""
    end
    if onBreakdata[:statDropRefresh]
      for s in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED, PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
        battler.stages[s] = 0 if battler.stages[s]!=0
        battler.effects[PBEffects::StatChangeHolder][s] = 0 if battler.effects[PBEffects::StatChangeHolder][s] != 0
      end
      pbDisplayBrief(_INTL("{1} cleared itself of stat changes!",battler.pbThis))
    end
    if onBreakdata[:playerSideStatusChanges]
      for i in 0..3
        if i % 2 == 0
          next if @battlers[i].nil?
          next if @battlers[i].isFainted?
          canstatus = false
          case onBreakdata[:playerSideStatusChanges][0]
          when PBStatuses::SLEEP
            canstatus = @battlers[i].pbCanSleep?(false)
            statusname="sleep"
          when PBStatuses::PARALYSIS
            canstatus = @battlers[i].pbCanParalyze?(false)
            canstatus = false if onBreakdata[:playerSideStatusChanges][2] && @battlers[i].hasType?(:GROUND)
            statusname="paralysis"
          when PBStatuses::POISON
            canstatus = @battlers[i].pbCanPoison?(false)
            statusname="poison"
          when PBStatuses::FROZEN
            canstatus = @battlers[i].pbCanFreeze?(false)
            statusname="freeze"
          end
          if canstatus
            @battlers[i].status = onBreakdata[:playerSideStatusChanges][0]
            @battlers[i].statusCount=2 if onBreakdata[:playerSideStatusChanges][0] == PBStatuses::SLEEP
            pbCommonAnimation(onBreakdata[:playerSideStatusChanges][1],@battlers[i]) 
            pbDisplay(_INTL("{1} was afflicted with {2}!",@battlers[i].pbThis,statusname))
          end
        end
      end
    end
    if onBreakdata[:bossSideStatusChanges]
      for i in 0..3
        if i % 2 != 0
          next if @battlers[i].nil?
          next if @battlers[i].isFainted?
          canstatus = false
          case onBreakdata[:bossSideStatusChanges][0]
          when PBStatuses::SLEEP
            canstatus = @battlers[i].pbCanSleep?(false)
            statusname="sleep"
          when PBStatuses::PARALYSIS
            canstatus = @battlers[i].pbCanParalyze?(false)
            statusname="paralysis"
          when PBStatuses::POISON
            canstatus = @battlers[i].pbCanPoison?(false)
            statusname="poison"
          when PBStatuses::FROZEN
            canstatus = @battlers[i].pbCanFreeze?(false)
            statusname="freeze"
          end
          if canstatus 
            @battlers[i].status = onBreakdata[:bossSideStatusChanges][0]
            pbCommonAnimation(onBreakdata[:bossSideStatusChanges][1],@battlers[i]) 
            pbDisplay(_INTL("{1} was afflicted with {2}!",@battlers[i].pbThis,statusname))
          end
        end
      end
    end
    if onBreakdata[:playersideChanges]
      side = 0
      playerstatemessageplayed = false
      if onBreakdata[:playersideChanges].is_a?(Array)
        for i in 0...onBreakdata[:playersideChanges].length
          @sides[side].effects[onBreakdata[:playersideChanges][i]] = onBreakdata[:playersideChangeCount] ? onBreakdata[:playersideChangeCount][i] : 5
          pbAnimation(onBreakdata[:playersideChangeAnimation][i],battler,nil) if onBreakdata[:playersideChangeAnimation]
          if onBreakdata[:playersideChangeMessage].is_a?(Array)
            statemessage = onBreakdata[:playersideChangeMessage][i] != "" ? onBreakdata[:playersideChangeMessage][i] : "The state of the battle was changed!"
          else
            statemessage = onBreakdata[:playersideChangeMessage] != "" ? onBreakdata[:playersideChangeMessage] : "An effect was put up on !"
            playerstatemessageplayed = true
          end
          pbDisplay(_INTL("{1}",statemessage)) if !playerstatemessageplayed
        end
      else
        @sides[side].effects[onBreakdata[:playersideChanges]] = onBreakdata[:playersideChangeCount] ? onBreakdata[:playersideChangeCount] : 5
        pbAnimation(onBreakdata[:playersideChangeAnimation],battler,nil) if onBreakdata[:playersideChangeAnimation]
        statemessage = onBreakdata[:playersideChangeMessage] != "" ? onBreakdata[:playersideChangeMessage] : "An effect was put up on !"
        pbDisplay(_INTL("{1}",statemessage))
      end
    end
    if onBreakdata[:bosssideChanges]
      side = 1
      if onBreakdata[:bosssideChanges].is_a?(Array)
        bossstatemessageplayed = false
        for i in 0...onBreakdata[:bosssideChanges].length
          @sides[side].effects[onBreakdata[:bosssideChanges][i]] = onBreakdata[:bosssideChangeCount] ? onBreakdata[:bosssideChangeCount][i] : 5
          pbAnimation(onBreakdata[:bosssideChangeAnimation][i],battler,nil) if onBreakdata[:bosssideChangeAnimation]
          if onBreakdata[:bosssideChangeMessage].is_a?(Array)
            statemessage = onBreakdata[:bosssideChangeMessage][i] != "" ? onBreakdata[:bosssideChangeMessage][i] : "The state of the battle was changed!"
          else
            statemessage = onBreakdata[:bosssideChangeMessage] != "" ? onBreakdata[:bosssideChangeMessage] : "An effect was put up on !"
            statemessageplayed = true
          end
          pbDisplay(_INTL("{1}",statemessage)) if !statemessageplayed
        end
      else
        @sides[side].effects[onBreakdata[:bosssideChanges]] = onBreakdata[:bosssideChangeCount] ? onBreakdata[:bosssideChangeCount] : 5
        pbAnimation(onBreakdata[:bosssideChangeAnimation],battler,nil) if onBreakdata[:bosssideChangeAnimation]
        statemessage = onBreakdata[:bosssideChangeMessage] != "" ? onBreakdata[:bosssideChangeMessage] : "An effect was put up on !"
        pbDisplay(_INTL("{1}",statemessage))
      end
    end
    if onBreakdata[:stateChanges]
      if onBreakdata[:stateChanges].is_a?(Array)
        for i in 0...onBreakdata[:stateChanges].length
          if onBreakdata[:stateChanges][i] == :TrickRoom
            @trickroom = onBreakdata[:stateChangeCount] ? onBreakdata[:stateChangeCount][i] : 5
          else
            @field.effects[onBreakdata[:stateChanges][i]] = onBreakdata[:stateChangeCount] ? onBreakdata[:stateChangeCount][i] : 5
          end
          pbAnimation(onBreakdata[:stateChangeAnimation][i],battler,nil) if onBreakdata[:stateChangeAnimation]
          statemessage = onBreakdata[:stateChangeMessage][i] != "" ? onBreakdata[:stateChangeMessage][i] : "The state of the battle was changed!"
          pbDisplay(_INTL("{1}",statemessage))
        end
      else
        if onBreakdata[:stateChanges] == :TrickRoom
          @trickroom = onBreakdata[:stateChangeCount] ? onBreakdata[:stateChangeCount] : 5
        else
          @field.effects[onBreakdata[:stateChanges]] = onBreakdata[:stateChangeCount] ? onBreakdata[:stateChangeCount] : 5
        end
        pbAnimation(onBreakdata[:stateChangeAnimation],battler,nil) if onBreakdata[:stateChangeAnimation]
        statemessage = onBreakdata[:stateChangeMessage] != "" ? onBreakdata[:stateChangeMessage] : "The state of the battle was changed!"
        pbDisplay(_INTL("{1}",statemessage))
      end
    end
    boostlevel = ["","","sharply  ", "drastically "]
    statupanimplayed=false
    statdownanimplayed=false
    if battler.randomSetChanges
      items = battler.randomSetChanges.values
      setdetails=items[rand(items.length)]
      if setdetails[:typeChange]
        battler.type1 = setdetails[:typeChange][0]
        battler.type2 = setdetails[:typeChange][1] if setdetails[:typeChange][1]
      end
      if setdetails[:movesetUpdate]
        k=0
        for move in setdetails[:movesetUpdate]
          next if move.nil?
          battler.pokemon.moves[k]=PBMove.new(move)
          if battler.level >=100 && opponent.skill>=PokeBattle_AI::BESTSKILL
            battler.pokemon.moves[k].ppup=3
            battler.pokemon.moves[k].pp=battler.pokemon.moves[k].totalpp
          end
          k+=1
        end
        battler.moves = []
        for move in battler.pokemon.moves
          battler.moves.push(PokeBattle_Move.pbFromPBMove(self,move,battler.pokemon)) if move
        end
      end
      setdetails[:bossStatChanges].each_pair {|stat,statval|
        statval *= -1 if battler.ability == PBAbilities::CONTRARY
        if statval > 0 && !battler.pbTooHigh?(stat)
          battler.pbIncreaseStatBasic(stat,statval)
          pbCommonAnimation("StatUp",battler) if !statupanimplayed
          statupanimplayed=true
          pbDisplay(_INTL("{1}'s fracturing aura boosted its {3}!", battler.pbThis,boostlevel[statval.abs],battler.pbGetStatName(stat)))
        elsif statval < 0 && !battler.pbTooLow?(stat)
          battler.pbReduceStatBasic(stat,-statval)
          pbCommonAnimation("StatDown",battler) if !statdownanimplayed
          statdownanimplayed=true
          pbDisplay(_INTL("{1}'s fracturing aura lowered its {3}!", battler.pbThis,boostlevel[statval.abs],battler.pbGetStatName(stat)))
        end
      } if setdetails[:bossStatChanges]
      battler.randomSetChanges.delete(battler.randomSetChanges.key(setdetails))
    else
      if onBreakdata[:typeChange]
        battler.type1 = onBreakdata[:typeChange][0]
        battler.type2 = onBreakdata[:typeChange][1] if onBreakdata[:typeChange][1]
      end
      if onBreakdata[:movesetUpdate]
        k=0
        battler.pokemon.moves = []
        for move in onBreakdata[:movesetUpdate]
          next if move.nil?
          battler.pokemon.moves[k]=PBMove.new(move)
          if battler.level >=75 
            battler.pokemon.moves[k].ppup=3
            battler.pokemon.moves[k].pp=battler.pokemon.moves[k].totalpp
          end
          k+=1
        end
        battler.moves = []
        for move in battler.pokemon.moves
          battler.moves.push(PokeBattle_Move.pbFromPBMove(self,move,battler.pokemon)) if move
        end
      end
    end
    if onBreakdata[:typeSequence] 
      if delay
        typeset =  onBreakdata[:typeSequence].values
        battler.type1 = typeset[@typesequence][:typeChange][0]
        battler.type2 = typeset[@typesequence][:typeChange][1] if typeset[@typesequence][:typeChange][1]
        pbSet(1,@typesequence)
        @typesequence = (@typesequence + 1) % typeset.length
      end
    end
    if onBreakdata[:itemchange]
      battler.item = onBreakdata[:itemchange]
      battler.pokemon.setItem(onBreakdata[:itemchange])
    end
    onBreakdata[:bossStatChanges].each_pair {|stat,statval|
      statval *= -1 if battler.ability == PBAbilities::CONTRARY
      if statval > 0 && !battler.pbTooHigh?(stat)
        battler.pbIncreaseStatBasic(stat,statval)
        pbCommonAnimation("StatUp",battler) if !statupanimplayed
        statupanimplayed=true
        pbDisplay(_INTL("{1}'s fracturing aura boosted its {3}!", battler.pbThis,boostlevel[statval.abs],battler.pbGetStatName(stat)))
      elsif statval < 0 && !battler.pbTooLow?(stat)
        battler.pbReduceStatBasic(stat,-statval)
        pbCommonAnimation("StatDown",battler) if !statdownanimplayed
        statdownanimplayed=true
        pbDisplay(_INTL("{1}'s fracturing aura lowered its {3}!", battler.pbThis,boostlevel[statval.abs],battler.pbGetStatName(stat)))
      end
    } if onBreakdata[:bossStatChanges]
    onBreakdata[:playerSideStatChanges].each_pair {|stat,statval|
      for i in @battlers
        next if i.isFainted?
        next if !battler.pbIsOpposing?(i.index)
        next if i.issossmon
        statupanimplayed=false
        statdownanimplayed=false
        statval *= -1 if i.ability == PBAbilities::CONTRARY
        if statval > 0 && !i.pbTooHigh?(stat) && i.pbCanIncreaseStatStage?(stat)
          i.pbIncreaseStatBasic(stat,statval)
          pbCommonAnimation("StatUp",i) if !statupanimplayed
          statupanimplayed=true
          pbDisplay(_INTL("{1}'s fracturing aura boosted {2}'s {3}!", battler.pbThis,i.name,i.pbGetStatName(stat)))
        elsif statval < 0 && !i.pbTooLow?(stat) && i.pbCanReduceStatStage?(stat)
          i.pbReduceStatBasic(stat,-statval)
          pbCommonAnimation("StatDown",i) if !statdownanimplayed
          statdownanimplayed=true
          pbDisplay(_INTL("{1}'s fracturing aura lowered {2}'s {3}!", battler.pbThis,i.name,i.pbGetStatName(stat)))
        end
      end
    } if onBreakdata[:playerSideStatChanges]
    if delay
      if !onBreakdata[:CustomMethod]
        if onBreakdata[:repeat]
          battler.bossdelaycounter = onBreakdata[:delay]
        else
          battler.bossdelayedeffect = nil
          battler.bossdelaycounter = nil
        end
      end
    end
    if onBreakdata[:soscontinuous]
      if battler.sosDetails
        battler.sosDetails[:continuous] = true
      end
    end
    if onBreakdata[:delayedaction]
      battler.bossdelayedeffect = onBreakdata[:delayedaction]
      battler.bossdelaycounter = (onBreakdata[:delayedaction][:delay])
    end
    if onEntry == true
      pbBossSOS(@battlers,false,onEntry)
    else
      pbBossSOS(@battlers,shieldbreak=true,onEntry)
    end
  end

  def pbBossSOS(battlers,shieldbreak=false,onEntry=false)
    for i in pbPriority
      next if !i.isbossmon
      next if !i.sosDetails
      battler = i 
      sosData = battler.sosDetails
      battlerIndex = battler.index
      if sosData[:refreshingRequirement]
        if (shieldbreak && !onEntry && @sosbattle > 2 && sosData[:refreshingRequirement].include?(battler.shieldCount-1))
          variable = pbRefreshSOSPokemon(sosData) 
          return if variable == true
        end
      end
      if sosData[:clearingRequirement] # currently unused
        return pbResetBattlers  if (shieldbreak && !onEntry && @sosbattle > 2 && sosData[:clearingRequirement].include?(battler.shieldCount-1))
      end
      allowed = false
      allowed = (shieldbreak || onEntry || sosData[:continuous])
      if eval(sosData[:activationRequirement]) && @battlers[battlerIndex].pbPartner.isFainted?
        if (@opponent && pbPokemonCount(@party2)==1) || !(@opponent)
          if (allowed == true) 
            if sosData[:totalMonCount] 
              sosBattle(battler) if battler.currentSOS<sosData[:totalMonCount] 
            else
              sosBattle(battler)
            end
          end
        else
          return false
        end
      end
    end
  end 

  def pbRefreshSOSPokemon(sosData)
    return false if @sosbattle != 3
    for i in priority
      sosmon = i if i.issossmon
      bossmon = i if i.isbossmon
    end
    return false if !sosmon
    if sosmon.isFainted?
      pbCommonAnimation("ZPower",bossmon,nil)
      pbAnimation(PBMoves::HELPINGHAND,bossmon,sosmon)
      sosBattle(bossmon) 
      return true
    end
    bossmon.currentSOS += 1
    pbCommonAnimation("ZPower",bossmon,nil)
    pbAnimation(PBMoves::HELPINGHAND,bossmon,sosmon)
    pbDisplayPaused(_INTL("{1} revitalized its allies!",bossmon.name))
    if sosData[:moninfos][bossmon.currentSOS]
      pbAnimation(PBMoves::REFRESH,sosmon,nil)
      sosmon.pbRecoverHP(sosmon.totalhp,true) if sosmon.hp != sosmon.totalhp
      sosmon.status = 0 if sosmon.status != 0
      sosmon.statusCount = 0 
      sosmon.pokemon = pbLoadSOSMon(sosData[:moninfos][bossmon.currentSOS],sosmon)
      sosmon.species = sosmon.pokemon.species
      sosmon.form = sosmon.pokemon.form
      sosmon.ability = sosmon.pokemon.ability
      sosmon.pokemon.abilityoverride = sosmon.pokemon.ability
      sosmon.moves = []
      for move in sosmon.pokemon.moves
        sosmon.moves.push(PokeBattle_Move.pbFromPBMove(self,move,sosmon.pokemon)) if move
      end
      sosmon.item = sosmon.pokemon.item
      sosmon.pbUpdate(true)
    end
    return true
  end

  def pbResetBattlers(settonormal=false)
    # currently unused
  end

  def sosBattleSpecial(battler)
    # currently unused
  end

  def sosBattle(battler)
    sosData = battler.sosDetails
    return sosBattleSpecial(battler) if (sosData[:playerMons] || sosData[:playerParty]) # currently unused
    playerMon = battler.pbOppositeOpposing 
    if sosData
      battler.currentSOS += 1
      if sosData[:moninfos][battler.currentSOS]
        sosmon=sosData[:moninfos][battler.currentSOS]
      else
        items = sosData[:moninfos].values
        sosmon=items[rand(items.length)]
      end
      genwildpoke = pbLoadSOSMon(sosmon,battler)
      @party2.push(genwildpoke)
      @doublebattle=true
      if @opponent
        sosIndex = battler.pbPartner.index
      else
        sosIndex = 3
      end
      @sosbattle = $PokemonGlobal.partner ? 4 : 3
      @battlers[sosIndex].pbInitialize(@party2[-1],(@party2.length-1),false) 
      @scene.pbIntroBoss(self,sosIndex)
      pbOnActiveOne(@battlers[sosIndex])
      @battlers[sosIndex].pbAbilitiesOnSwitchIn(true)
      # @ai.aimondata[sosIndex] = AI_MonData.new(nil,sosIndex,@battle) if @ai.aimondata[sosIndex] == nil
      # @ai.aimondata[sosIndex].skill = 100
      if sosData[:entryMessage]
        if sosData[:entryMessage].is_a?(Array)
          if sosData[:entryMessage][battler.currentSOS-1].start_with?("{1}") 
            pbDisplay(_INTL(sosData[:entryMessage][battler.currentSOS-1],battler.pbThis)) if sosData[:entryMessage] != ""
          else
            pbDisplay(_INTL(sosData[:entryMessage][battler.currentSOS-1])) if sosData[:entryMessage] != ""
          end
        else
          if sosData[:entryMessage].start_with?("{1}") 
            pbDisplay(_INTL(sosData[:entryMessage],battler.pbThis)) if sosData[:entryMessage] != ""
          else
            pbDisplay(_INTL(sosData[:entryMessage])) if sosData[:entryMessage] != ""
          end
        end
      else
        pbDisplayPaused(_INTL("{1} called for help and\r\n{2} appeared!",
          battler.name,@party2[-1].name))
      end
    end
  end
end

def pbLoadWildBoss(poke,bossdata=$bosscache)
  boss = bossdata[poke]
  bossid = poke
  poke = boss.moninfo
  species = poke[:species]
  level = poke[:level]
  pokemon = PokeBattle_Pokemon.new(species,level,$Trainer,false) 
  bossFunction(boss,bossid,pokemon)
  pokemon.setItem(poke[:item])
  if poke[:moves]
    k=0
    for move in poke[:moves]
      next if move.nil?
      pokemon.moves[k]=PBMove.new(move)
      if level >=100
        pokemon.moves[k].ppup=3
        pokemon.moves[k].pp=pokemon.moves[k].totalpp
      end
      k+=1
    end
  else
    pokemon.resetMoves
  end
  pokemon.form = poke[:form] ? poke[:form] : 0
  pokemon.setAbility(0) # doesn't matter as it's getting replaced; same with SOS mons
  case poke[:gender]
    when "M" then pokemon.setGender(0)
    when "F" then pokemon.setGender(1)
    when "N" then pokemon.setGender(2)
    else
      pokemon.setGender(rand(2))
  end
  if !(boss.capturable)
    pokemon.shinyflag = poke[:shiny] || false
  end
  pokemon.setNature(poke.fetch(:nature,:HARDY))
  iv=poke.fetch(:iv,10)
  if iv==32 # Trick room IVs
    pokemon.iv=Array.new(6,31)
    pokemon.iv[5]=0
  else
    pokemon.iv=Array.new(6,iv)
  end
  evs = poke[:ev]
  evs = Array.new(6,[85,level*3/2].min) if !evs
  pokemon.ev = evs.clone
  pokemon.ev[PBStats::SPEED] = 0 if iv==32 #TR team, just to make sure!
  pokemon.happiness=poke.fetch(:happiness,70)
  pokemon.name=poke[:name] if poke[:name]
  if poke[:shadow]   # if this is a Shadow Pokémon
    pokemon.makeShadow rescue nil
    pokemon.pbUpdateShadowMoves(true) rescue nil
    pokemon.makeNotShiny
  end
  pokemon.ballused=poke.fetch(:ball,0) # Pokeball
  pokemon.calcStats
  return pokemon
end

def pbLoadSOSMon(sosdata,boss)
  poke = sosdata
  species = poke[:species]
  level = poke[:level]
  pokemon = PokeBattle_Pokemon.new(species,level,$Trainer,false) 
  pokemon.setItem(poke[:item])
  if poke[:moves]
    k=0
    for move in poke[:moves]
      next if move.nil?
      pokemon.moves[k]=PBMove.new(move)
      if level >=100
        pokemon.moves[k].ppup=3
        pokemon.moves[k].pp=pokemon.moves[k].totalpp
      end
      k+=1
    end
  else
    pokemon.resetMoves
  end
  pokemon.form = poke[:form] ? poke[:form] : 0
  pokemon.setAbility(0)
  pokemon.abilityoverride = poke[:ability]
  case poke[:gender]
    when "M" then pokemon.setGender(0)
    when "F" then pokemon.setGender(1)
    when "N" then pokemon.setGender(2)
    else
      pokemon.setGender(rand(2))
  end
  pokemon.shinyflag = poke[:shiny] || false
  pokemon.setNature(poke.fetch(:nature,:HARDY))
  iv=poke.fetch(:iv,10)
  if iv==32 # Trick room IVs
    pokemon.iv=Array.new(6,31)
    pokemon.iv[5]=0
  else
    pokemon.iv=Array.new(6,iv)
  end
  evs = poke[:ev]
  evs = Array.new(6,[85,level*3/2].min) if !evs
  pokemon.ev = evs.clone
  pokemon.ev[PBStats::SPEED] = 0 if iv==32 #TR team, just to make sure!
  pokemon.happiness=poke.fetch(:happiness,70)
  pokemon.name=poke[:name] if poke[:name]
  if poke[:shadow]   # if this is a Shadow Pokémon
    pokemon.makeShadow rescue nil
    pokemon.pbUpdateShadowMoves(true) rescue nil
    pokemon.makeNotShiny
  end
  pokemon.ot = boss.name
  pokemon.ballused=poke.fetch(:ball,0)
  pokemon.calcStats
  pokemon.sosmon = true
  return pokemon
end

# NOTE: unsure if flags are used for bosses yet, this will not be necessary if not. can delete class + inheritance
class DataObject
  attr_reader :flags

  def checkFlag?(flag,default=false)
    return @flags.fetch(flag,default)
  end
end
    
class BossData < DataObject
    attr_accessor :mon
    attr_accessor :name
    attr_accessor :barGraphic
    attr_accessor :entryText
    attr_accessor :immunities
    attr_accessor :shieldCount
    attr_accessor :capturable
    attr_accessor :canrun
    attr_accessor :onBreakEffects
    attr_accessor :onEntryEffects
    attr_accessor :moninfo
    attr_accessor :sosDetails
    attr_accessor :chargeAttack
    attr_accessor :randomSetChanges
    
    def initialize(monsym,data)
      @flags = {}
      @mon              = monsym
      data.each do |key, value|
        case key 
          when :name            then @name            = value
          when :barGraphic      then @barGraphic      = value
          when :entryText       then @entryText       = value
          when :shieldCount     then @shieldCount     = value
          when :immunities      then @immunities      = value
          when :capturable      then @capturable      = value
          when :canrun          then @canrun          = value
          when :moninfo         then @moninfo         = value
          when :onBreakEffects  then @onBreakEffects  = value
          when :onEntryEffects  then @onEntryEffects  = value
          when :sosDetails      then @sosDetails      = value
          when :chargeAttack      then @chargeAttack      = value
          when :randomSetChanges  then @randomSetChanges      = value
          else @flags[key] = value
        end
      end
    end
end

$bosscache = load_data("Data/bossdata.dat") if !$bosscache
