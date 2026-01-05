module BallHandlers
  IsUnconditional=ItemHandlerHash.new
  ModifyCatchRate=ItemHandlerHash.new
  OnCatch=ItemHandlerHash.new
  OnFailCatch=ItemHandlerHash.new

  def self.isUnconditional?(ball,battle,battler)
    if !IsUnconditional[ball]
      return false
    end
    return IsUnconditional.trigger(ball,battle,battler)
  end

  def self.modifyCatchRate(ball,catchRate,battle,battler)
    if !ModifyCatchRate[ball]
      return catchRate
    end
    return ModifyCatchRate.trigger(ball,catchRate,battle,battler)
  end

  def self.onCatch(ball,battle,pokemon)
    if OnCatch[ball]
      OnCatch.trigger(ball,battle,pokemon)
    end
  end

  def self.onFailCatch(ball,battle,pokemon)
    if OnFailCatch[ball]
      OnFailCatch.trigger(ball,battle,pokemon)
    end
  end
end



def pbBallTypeToBall(balltype)
  if $BallTypes[balltype]
    ret=getID(PBItems,$BallTypes[balltype])
    return ret if ret!=0
  end
  if $BallTypes[0]
    ret=getID(PBItems,$BallTypes[0])
    return ret if ret!=0
  end
  return getID(PBItems,:POKEBALL)
end

def pbGetBallType(ball)
  ball=getID(PBItems,ball)
  for key in $BallTypes.keys
    return key if isConst?(ball,PBItems,$BallTypes[key])
  end
  return 0
end

def pbIsUltraBeast?(battler)  
  if isConst?(battler.species,PBSpecies,:NIHILEGO) ||  
    isConst?(battler.species,PBSpecies,:BUZZWOLE) ||  
    isConst?(battler.species,PBSpecies,:PHEROMOSA) ||  
    isConst?(battler.species,PBSpecies,:XURKITREE) ||  
    isConst?(battler.species,PBSpecies,:CELESTEELA) ||  
    isConst?(battler.species,PBSpecies,:KARTANA) ||  
    isConst?(battler.species,PBSpecies,:GUZZLORD) ||  
    isConst?(battler.species,PBSpecies,:POIPOLE) ||  
    isConst?(battler.species,PBSpecies,:NAGANADEL) ||  
    isConst?(battler.species,PBSpecies,:STAKATAKA) ||  
    isConst?(battler.species,PBSpecies,:BLACEPHALON)   
    return true  
  else  
    return false  
  end  
end


################################

$BallTypes={
   0=>:POKEBALL,
   1=>:GREATBALL,
   2=>:SAFARIBALL,
   3=>:ULTRABALL,
   4=>:MASTERBALL,
   5=>:NETBALL,
   6=>:DIVEBALL,
   7=>:NESTBALL,
   8=>:REPEATBALL,
   9=>:TIMERBALL,
   10=>:LUXURYBALL,
   11=>:PREMIERBALL,
   12=>:DUSKBALL,
   13=>:HEALBALL,
   14=>:QUICKBALL,
   15=>:CHERISHBALL,
   16=>:FASTBALL,
   17=>:LEVELBALL,
   18=>:LUREBALL,
   19=>:HEAVYBALL,
   20=>:LOVEBALL,
   21=>:FRIENDBALL,
   22=>:MOONBALL,
   23=>:SPORTBALL,
   24=>:STEAMBALL,
   25=>:MINERALBALL,
   26=>:BEASTBALL,
   27=>:DREAMBALL,
   28=>:MAGMABALL,
   29=>:STORMBALL,
   30=>:HEXBALL,
   31=>:TERRABALL,
   32=>:ENIGMABALL,
   33=>:BRAWLBALL,
   34=>:MIRRORBALL,
   35=>:FEATHERBALL,
   36=>:APEXBALL,
   37=>:POCKETBALL,
   38=>:VIRUSBALL,
   39=>:BANDITBALL
}

def pbBallHPConditionMet?(battler,threshold)
  return false if !battler
  return battler.hp<= (battler.totalhp*threshold).floor
end

BallHandlers::ModifyCatchRate.add(:GREATBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   next (catchRate*1.5).floor
})

BallHandlers::ModifyCatchRate.add(:SAFARIBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   next (catchRate*1.5).floor
})

BallHandlers::ModifyCatchRate.add(:ULTRABALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   next (catchRate*2).floor
})

BallHandlers::IsUnconditional.add(:MASTERBALL,proc{|ball,battle,battler|
   next true
})

BallHandlers::IsUnconditional.add(:POKEBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next pbBallHPConditionMet?(battler,0.25)
})

BallHandlers::IsUnconditional.add(:PREMIERBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next pbBallHPConditionMet?(battler,0.25)
})

BallHandlers::IsUnconditional.add(:GREATBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next pbBallHPConditionMet?(battler,0.5)
})

BallHandlers::IsUnconditional.add(:ULTRABALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next pbBallHPConditionMet?(battler,0.75)
})

BallHandlers::IsUnconditional.add(:NESTBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.level<=30
})

BallHandlers::IsUnconditional.add(:REPEATBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battle.pbPlayer.owned[battler.species]
})

BallHandlers::IsUnconditional.add(:TIMERBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battle.turncount>=3
})

BallHandlers::IsUnconditional.add(:NETBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.pbHasType?(:WATER) || battler.pbHasType?(:BUG)
})

BallHandlers::IsUnconditional.add(:MOONBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.pbHasType?(:DARK) || battler.pbHasType?(:FAIRY)
})

BallHandlers::IsUnconditional.add(:MAGMABALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.pbHasType?(:ROCK) || battler.pbHasType?(:FIRE)
})

BallHandlers::IsUnconditional.add(:STORMBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.pbHasType?(:ELECTRIC) || battler.pbHasType?(:FLYING)
})

BallHandlers::IsUnconditional.add(:HEXBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.pbHasType?(:GHOST) || battler.pbHasType?(:POISON)
})

BallHandlers::IsUnconditional.add(:TERRABALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.pbHasType?(:GRASS) || battler.pbHasType?(:GROUND)
})

BallHandlers::IsUnconditional.add(:ENIGMABALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.pbHasType?(:DRAGON) || battler.pbHasType?(:PSYCHIC)
})

BallHandlers::IsUnconditional.add(:BRAWLBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.pbHasType?(:NORMAL) || battler.pbHasType?(:FIGHTING)
})

BallHandlers::IsUnconditional.add(:MIRRORBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.pbHasType?(:STEEL) || battler.pbHasType?(:ICE)
})

BallHandlers::ModifyCatchRate.add(:NETBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate=(catchRate*3.5).floor if battler.pbHasType?(:BUG) || battler.pbHasType?(:WATER)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:STEAMBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate=(catchRate*3.5).floor if battler.pbHasType?(:FIRE) || battler.pbHasType?(:WATER)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:MINERALBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate=(catchRate*3.5).floor if battler.pbHasType?(:ROCK) || battler.pbHasType?(:GROUND) || battler.pbHasType?(:STEEL)
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:DIVEBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate=(catchRate*3.5).floor if battle.environment==PBEnvironment::Underwater
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:NESTBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   if battler.level<=29
     catchRate=(catchRate*((41-battler.level)/10)).floor
   end
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:REPEATBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate=(catchRate*3.5).floor if battle.pbPlayer.owned[battler.species]
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:TIMERBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   multiplier=[1+(0.3*battle.turncount),4].min
   catchRate=(catchRate*multiplier).floor
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:DUSKBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate=(catchRate*3.5).floor if PBDayNight.isNight?(pbGetTimeNow)
   next catchRate
})

BallHandlers::OnCatch.add(:HEALBALL,proc{|ball,battle,pokemon|
   pokemon.heal
})

BallHandlers::IsUnconditional.add(:HEALBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next pbBallHPConditionMet?(battler,0.5)
})

BallHandlers::ModifyCatchRate.add(:QUICKBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate*=5 if battle.turncount<=1
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:FASTBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate*=4 if $pkmn_dex[battler.species][5][3]>=100
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:LEVELBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   pbattler=battle.battlers[0].level
   pbattler=battle.battlers[2].level if battle.battlers[2] &&
                                        battle.battlers[2].level>pbattler
   if pbattler>=battler.level*4
     catchRate*=8
   elsif pbattler>=battler.level*2
     catchRate*=4
   elsif pbattler>battler.level
     catchRate*=2
   end
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:LUREBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   catchRate*=5 if $PokemonTemp.encounterType==EncounterTypes::OldRod ||
                   $PokemonTemp.encounterType==EncounterTypes::GoodRod ||
                   $PokemonTemp.encounterType==EncounterTypes::SuperRod
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:HEAVYBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   weight=battler.weight
#   if weight>=4096
#     catchRate+=40
   if weight>=3000
     catchRate+=30
   elsif weight>=2000
     catchRate+=20
   elsif weight>=1000
     catchRate+=0
   else
     catchRate-=20
   end
   catchRate=[catchRate,1].max
   next [catchRate,255].min
})

BallHandlers::IsUnconditional.add(:HEAVYBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.weight>=2000
})

BallHandlers::IsUnconditional.add(:FEATHERBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.weight<=500
})

BallHandlers::IsUnconditional.add(:APEXBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.pokemon && battler.pokemon.height>=200
})

BallHandlers::IsUnconditional.add(:POCKETBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next battler.pokemon && battler.pokemon.height<=50
})

BallHandlers::ModifyCatchRate.add(:LOVEBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   pbattler=battle.battlers[0]
   pbattler2=battle.battlers[2] if battle.battlers[2]
   if pbattler.species==battler.species &&
      ((battler.gender==0 && pbattler.gender==1) ||
      (battler.gender==1 && pbattler.gender==0))
     catchRate*=8
   elsif pbattler2 && pbattler2.species==battler.species &&
      ((battler.gender==0 && pbattler2.gender==1) ||
       (battler.gender==1 && pbattler2.gender==0))
     catchRate*=8
   end
   next catchRate
})

BallHandlers::OnCatch.add(:FRIENDBALL,proc{|ball,battle,pokemon|
   pokemon.happiness=255
})

BallHandlers::IsUnconditional.add(:FRIENDBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next pbBallHPConditionMet?(battler,0.5)
})

BallHandlers::ModifyCatchRate.add(:MOONBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   if isConst?(battler.species,PBSpecies,:NIDORANfE) ||
      isConst?(battler.species,PBSpecies,:NIDORINA) ||
      isConst?(battler.species,PBSpecies,:NIDOQUEEN) ||
      isConst?(battler.species,PBSpecies,:NIDORANmA) ||
      isConst?(battler.species,PBSpecies,:NIDORINO) ||
      isConst?(battler.species,PBSpecies,:NIDOKING) ||
      isConst?(battler.species,PBSpecies,:CLEFFA) ||
      isConst?(battler.species,PBSpecies,:CLEFAIRY) ||
      isConst?(battler.species,PBSpecies,:CLEFABLE) ||
      isConst?(battler.species,PBSpecies,:IGGLYBUFF) ||
      isConst?(battler.species,PBSpecies,:JIGGLYPUFF) ||
      isConst?(battler.species,PBSpecies,:WIGGLYTUFF) ||
      isConst?(battler.species,PBSpecies,:SKITTY) ||
      isConst?(battler.species,PBSpecies,:DELCATTY) ||
      isConst?(battler.species,PBSpecies,:MUNNA) ||
      isConst?(battler.species,PBSpecies,:MUSHARNA)
     catchRate*=4
   end
   next catchRate
})

BallHandlers::ModifyCatchRate.add(:SPORTBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   next (catchRate*1.5).floor
})

BallHandlers::ModifyCatchRate.add(:BEASTBALL,proc{|ball,catchRate,battle,battler|
   if pbIsUltraBeast?(battler)
     next (catchRate*5).floor
   else
     next (catchRate*0.1).floor
   end   
})

BallHandlers::ModifyCatchRate.add(:DREAMBALL,proc{|ball,catchRate,battle,battler|
   next (catchRate*0.1).floor if pbIsUltraBeast?(battler)
   next (catchRate*3).floor if battler.status==PBStatuses::SLEEP
   next catchRate
})

BallHandlers::OnCatch.add(:VIRUSBALL,proc{|ball,battle,pokemon|
   pokemon.givePokerus
})

BallHandlers::IsUnconditional.add(:VIRUSBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next pbBallHPConditionMet?(battler,0.5)
})

BallHandlers::OnCatch.add(:BANDITBALL,proc{|ball,battle,pokemon|
   $Trainer.money+=100 if $Trainer
})

BallHandlers::IsUnconditional.add(:BANDITBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next pbBallHPConditionMet?(battler,0.5)
})

BallHandlers::OnCatch.add(:LUXURYBALL,proc{|ball,battle,pokemon|
   pokemon.makeShiny
})

BallHandlers::IsUnconditional.add(:LUXURYBALL,proc{|ball,battle,battler|
   next false if battle.opponent
   next pbBallHPConditionMet?(battler,0.5)
})
