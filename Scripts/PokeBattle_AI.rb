  def pbTempoMultiplierFromRepeat(battler, item_works=true)
    return 1.0 if battler.nil?
    mult = 1.0
    met_count = (battler.respond_to?(:effects) && battler.effects) ? battler.effects[PBEffects::Metronome] : 0
    met_count ||= 0
    ability_active = battler.respond_to?(:hasWorkingAbility) ? battler.hasWorkingAbility(:OWNTEMPO) :
      (battler.respond_to?(:ability) && battler.ability == PBAbilities::OWNTEMPO)
    if ability_active
      mult *= [1.0 + met_count*0.1, 2.0].min
    end
    if item_works && battler.respond_to?(:item) && battler.item == PBItems::METRONOME
      mult *= (met_count>4) ? 2.0 : (1.0 + met_count*0.2)
    end
    return mult
  end

  def pbHasQuickCharge(battler, item_works=true)
    return false if battler.nil?
    return true if battler.hasWorkingAbility(:INSOMNIA)
    return (item_works && battler.hasWorkingItem(:POWERHERB))
  end

      if !pbHasQuickCharge(attacker, attitemworks) && !($fefieldeffect == 43)
      if !pbHasQuickCharge(attacker, attitemworks) && pbWeather!=PBWeather::SUNNYDAY
      if !pbHasQuickCharge(attacker, attitemworks)
      if !pbHasQuickCharge(attacker, attitemworks)
      if (!pbHasQuickCharge(attacker) && $fefieldeffect!=43)
      if !pbHasQuickCharge(attacker, attitemworks)
        if pbHasQuickCharge(attacker, attitemworks)
        if pbHasQuickCharge(attacker, attitemworks)
        if pbHasQuickCharge(attacker, attitemworks)
        if pbHasQuickCharge(attacker, attitemworks)
        if pbHasQuickCharge(attacker, attitemworks)
      if thisinitial<100
        score*=0.85
      end
      if (attitemworks && attacker.item == PBItems::LUMBERRY) || (attitemworks && attacker.item == PBItems::PERSIMBERRY)
        score*=1.3
      end
      if attacker.stages[PBStats::ATTACK]>0
        miniscore = (-5)*attacker.stages[PBStats::ATTACK]
        miniscore+=100
        miniscore/=100.0
        score*=miniscore
      end
      if livecount1>2
        miniscore=100
        miniscore*=(livecount1-1)
        miniscore*=0.01
        miniscore*=0.05
        miniscore=1-miniscore
        score*=miniscore
      end
      score*=0.7 if checkAImoves(PBStuff::PROTECTMOVE,aimem)
      score*=0.7 if checkAIhealing(aimem)
      if skill>=PBTrainerAI.highSkill
        if $fefieldeffect==16 # Superheated Field
          score*=0.8
      end
      if attacker.hasWorkingAbility(:OWNTEMPO)
        score*=1.1
      tempo_mult=pbTempoMultiplierFromRepeat(opponent, oppitemworks)
      score/=tempo_mult if tempo_mult>1.0
      tempo_mult=pbTempoMultiplierFromRepeat(opponent, oppitemworks)
      score/=tempo_mult if tempo_mult>1.0
      tempo_mult=pbTempoMultiplierFromRepeat(opponent, oppitemworks)
      score/=tempo_mult if tempo_mult>1.0
      if !pbHasQuickCharge(attacker, attitemworks)
      tempo_mult=pbTempoMultiplierFromRepeat(opponent, oppitemworks)
      score/=tempo_mult if tempo_mult>1.0
      if !pbHasQuickCharge(attacker, attitemworks) && !(move.id == PBMoves::ELECTROSHOT && pbWeather == PBWeather::RAINDANCE) && !(move.id == PBMoves::BRAINSTORM && pbWeather == PBWeather::HAIL) && !(move.id == PBMoves::METEORBEAM && $fefieldeffect == 35)
        if pbHasQuickCharge(attacker, attitemworks)
      tempo_mult=pbTempoMultiplierFromRepeat(opponent, oppitemworks)
      score/=tempo_mult if tempo_mult>1.0
      tempo_mult=pbTempoMultiplierFromRepeat(opponent, oppitemworks)
      score/=tempo_mult if tempo_mult>1.0
            if !(pbHasQuickCharge(attacker) || $fefieldeffect==43)
            if !(pbHasQuickCharge(attacker) || $fefieldeffect==43)
        tempo_mult=pbTempoMultiplierFromRepeat(battler, true)
        monscore+=10
        monscore+=(tempo_mult*10).round if tempo_mult>1.0
        if (battler.ability == PBAbilities::OWNTEMPO)
          tempo_mult=pbTempoMultiplierFromRepeat(battler, true)
          monscore+=10
          monscore+=(tempo_mult*5).round if tempo_mult>1.0
        end
  end
