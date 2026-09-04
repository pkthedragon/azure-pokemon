# Compatibility adapters for move-effect classes whose original class names were
# authored as base-36 identifiers. PokeBattle_Move.pbFromPBMove converts the PBS
# LegacyFunctionCode to hexadecimal, so these are the constants it actually asks
# Ruby to resolve at runtime.

# Heal Order (base-36 29G == decimal 2932 == hexadecimal B74).
class PokeBattle_Move_B74 < PokeBattle_Move_29G
end

# Razor Wind (base-36 29H == decimal 2933 == hexadecimal B75).
class PokeBattle_Move_B75 < PokeBattle_Move_29H
end

# Poison Tail (base-36 25Z == decimal 2807 == hexadecimal AF7).
class PokeBattle_Move_AF7 < PokeBattle_Move_25Z
end

# Snuff Out's authored effect class was named after its move ID (897), rather
# than its hexadecimal function code (27B). Keep the implementation in one
# place and expose it under the constant the move factory resolves.
class PokeBattle_Move_27B < PokeBattle_Move_897
end


# Shared canonical critical-hit behavior for moves which always crit. This keeps
# Azure's Shell Armor and Lucky Chant protections, which are checked before the
# engine's normal function-code shortcut for Frost Breath-style moves.
module AzureAlwaysCriticalMove
  def pbIsCritical?(attacker,opponent)
    if opponent.hasWorkingAbility(:SHELLARMOR) && !opponent.moldbroken
      return false
    end
    return false if opponent.pbOwnSide.effects[PBEffects::LuckyChant]>0
    return true
  end
end

# Surging Strikes: exactly three hits, all of which are critical hits.
class PokeBattle_Move_231 < PokeBattle_Move
  include AzureAlwaysCriticalMove

  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 3
  end
end

# Flower Trick: its zero accuracy already makes it unmissable; this supplies the
# guaranteed critical hit while retaining Azure's anti-critical protections.
class PokeBattle_Move_28B < PokeBattle_Move
  include AzureAlwaysCriticalMove
end

# Triple Dive: three equal-power hits.
class PokeBattle_Move_250 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 3
  end
end

# Tachyon Cutter: its zero accuracy already makes it unmissable; this supplies
# the two hits.
class PokeBattle_Move_284 < PokeBattle_Move_0BD
end

# Collision Course / Electro Drift: 4/3 power on a super-effective matchup.
class PokeBattle_Move_260 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if pbTypeModifier(@type,attacker,opponent)>4
      return (damagemult*4.0/3.0).round
    end
    return damagemult
  end
end

# Fickle Beam: a single 30% roll per use doubles its power.
class PokeBattle_Move_288 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @azure_fickle_power = (@battle.pbRandom(10)<3)
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return @azure_fickle_power ? basedmg*2 : basedmg
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @azure_fickle_power
      @battle.pbDisplay(_INTL("{1} is going all out for this attack!",attacker.pbThis))
    end
    return super
  end
end

# Make It Rain: lower the user's Special Attack once damage is dealt and add the
# same post-battle payout scale used by modern implementations of the move.
class PokeBattle_Move_271 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @azure_make_it_rain_drop_applied = false
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.extramoney += 5*attacker.level
      end
      if !@azure_make_it_rain_drop_applied
        @azure_make_it_rain_drop_applied = true
        if attacker.hasWorkingAbility(:TEMPORALSHIFT)
          @battle.pbDisplay(_INTL("{1}'s stats can't be lowered due to Temporal Shift!",attacker.pbThis))
        elsif attacker.pbCanReduceStatStage?(PBStats::SPATK,false,true)
          attacker.pbReduceStat(PBStats::SPATK,1,false,@id,attacker,true,true)
        end
        @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
      end
    end
    return ret
  end
end

# Spin Out: harshly lower the user's Speed after a damaging hit.
class PokeBattle_Move_254 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @azure_spin_out_drop_applied = false
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !@azure_spin_out_drop_applied
      @azure_spin_out_drop_applied = true
      if attacker.hasWorkingAbility(:TEMPORALSHIFT)
        @battle.pbDisplay(_INTL("{1}'s stats can't be lowered due to Temporal Shift!",attacker.pbThis))
      elsif attacker.pbCanReduceStatStage?(PBStats::SPEED,false,true)
        attacker.pbReduceStat(PBStats::SPEED,2,false,@id,attacker,true,true)
      end
    end
    return ret
  end
end

# Bitter Malice uses Azure's established Attack-lowering damage effect.
class PokeBattle_Move_227 < PokeBattle_Move_042
end

# Barb Barrage: double power against a poisoned target and use its PBS secondary
# effect chance to apply poison.
class PokeBattle_Move_226 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status==PBStatuses::POISON && opponent.effects[PBEffects::Substitute]==0
      return basedmg*2
    end
    return basedmg
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanPoison?(false)
    opponent.pbPoison(attacker)
    @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
    return true
  end
end

# Infernal Parade: double power against any statused target and use its PBS
# secondary effect chance to apply burn.
class PokeBattle_Move_230 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status>0 && opponent.effects[PBEffects::Substitute]==0
      return basedmg*2
    end
    return basedmg
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanBurn?(false)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end


# Shared status-cure messaging for modern moves. Spritz intentionally blocks
# the cure because Azure defines it as preventing status changes.
module AzureMoveStatusCure
  def azureCureStatus(target)
    return false if target.status==0
    return false if target.effects[PBEffects::Spritz]==1
    oldstatus=target.status
    target.status=0
    target.statusCount=0
    case oldstatus
    when PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",target.pbThis))
    when PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1} woke up!",target.pbThis))
    when PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",target.pbThis))
    when PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1} was cured of its burn.",target.pbThis))
    when PBStatuses::FROZEN
      @battle.pbDisplay(_INTL("{1} was defrosted.",target.pbThis))
    else
      @battle.pbDisplay(_INTL("{1}'s status condition was healed.",target.pbThis))
    end
    return true
  end
end

# Victory Dance: raise Attack, Defense, and Speed by one stage.
class PokeBattle_Move_225 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    stats=[PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED]
    if stats.all? { |stat| !attacker.pbCanIncreaseStatStage?(stat,false) }
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    showanim=true
    stats.each do |stat|
      next if !attacker.pbCanIncreaseStatStage?(stat,false)
      attacker.pbIncreaseStat(stat,1,false,@id,attacker,showanim)
      showanim=false
    end
    return 0
  end
end

# Spicy Extract: sharply raise the target's Attack and harshly lower Defense.
class PokeBattle_Move_253 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    canraise=opponent.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
    canlower=opponent.pbCanReduceStatStage?(PBStats::DEFENSE,false)
    if !canraise && !canlower
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if canraise
      opponent.pbIncreaseStat(PBStats::ATTACK,2,false,@id,attacker,showanim)
      showanim=false
    end
    if canlower
      opponent.pbReduceStat(PBStats::DEFENSE,2,false,@id,attacker,showanim)
    end
    return 0
  end
end

# Take Heart: cure the user and raise Special Attack and Special Defense.
class PokeBattle_Move_233 < PokeBattle_Move
  include AzureMoveStatusCure

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    canheal=(attacker.status>0 && attacker.effects[PBEffects::Spritz]!=1)
    canraise=attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false) ||
             attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
    if !canheal && !canraise
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    azureCureStatus(attacker) if canheal
    showanim=true
    for stat in [PBStats::SPATK,PBStats::SPDEF]
      next if !attacker.pbCanIncreaseStatStage?(stat,false)
      attacker.pbIncreaseStat(stat,1,false,@id,attacker,showanim)
      showanim=false
    end
    return 0
  end
end

# Jungle Healing / Lunar Blessing: restore one quarter of max HP and cure status
# for the user and its active ally.
class PokeBattle_Move_232 < PokeBattle_Move
  include AzureMoveStatusCure

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    recipients=attacker.sameSideLivingBattlers(true)
    canhelp=recipients.any? do |target|
      target.hp<target.totalhp ||
        (target.status>0 && target.effects[PBEffects::Spritz]!=1)
    end
    if !canhelp
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    recipients.each do |target|
      if target.hp<target.totalhp
        hpgain=((target.totalhp+1)/4).floor
        hpgain=apply_tribute_healing(attacker,hpgain,target) if defined?(apply_tribute_healing)
        hpgain=(hpgain*1.1).floor if attacker.hasWorkingAbility(:HEALER)
        target.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
      end
      azureCureStatus(target)
    end
    return 0
  end
end

# Eerie Spell: its guaranteed PBS secondary effect removes three PP from the
# target's last-used move.
class PokeBattle_Move_246 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    for move in opponent.moves
      next if move.id!=opponent.lastMoveUsed || move.id<=0 || move.pp<=0
      reduction=[3,move.pp].min
      move.pp-=reduction
      if move.thismove && move.id==move.thismove.id
        move.thismove.pp=move.pp
      end
      @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",opponent.pbThis(true),move.name,reduction))
      return true
    end
    return false
  end
end

# Stone Axe: set Stealth Rock after a successful damaging hit.
class PokeBattle_Move_220 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @azure_stone_axe_hazard_applied=false
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !@azure_stone_axe_hazard_applied
      @azure_stone_axe_hazard_applied=true
      if !attacker.pbOpposingSide.effects[PBEffects::StealthRock]
        attacker.pbOpposingSide.effects[PBEffects::StealthRock]=true
        @battle.pbDisplay(_INTL("Pointed stones float in the air around the opposing team!"))
      end
    end
    return ret
  end
end

# Ceaseless Edge: add one layer of Spikes after a successful damaging hit.
class PokeBattle_Move_221 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @azure_ceaseless_edge_hazard_applied=false
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !@azure_ceaseless_edge_hazard_applied
      @azure_ceaseless_edge_hazard_applied=true
      if attacker.pbOpposingSide.effects[PBEffects::Spikes]<3
        attacker.pbOpposingSide.effects[PBEffects::Spikes]+=1
        @battle.pbDisplay(_INTL("Spikes were scattered around the opposing team's feet!"))
      end
    end
    return ret
  end
end


# Rising Voltage: double power only when Electric Terrain is active and the
# target is grounded.
class PokeBattle_Move_228 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    electricterrain=($fefieldeffect==1 ||
      @battle.field.effects[PBEffects::ElectricTerrain]>0)
    return basedmg*2 if electricterrain && !opponent.isAirborne?
    return basedmg
  end
end

# Expanding Force / Coaching share a legacy function code in Azure. Dispatch by
# move ID so each keeps its unrelated intended behavior.
class PokeBattle_Move_245 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if @id==PBMoves::EXPANDINGFORCE && !attacker.isAirborne? &&
       ($fefieldeffect==37 || @battle.field.effects[PBEffects::PsychicTerrain]>0)
      return (damagemult*1.5).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super if @id!=PBMoves::COACHING
    partner=attacker.pbPartner
    if !partner || partner.isFainted? ||
       (!partner.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
        !partner.pbCanIncreaseStatStage?(PBStats::DEFENSE,false))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,partner,hitnum,alltargets,showanimation)
    showanim=true
    for stat in [PBStats::ATTACK,PBStats::DEFENSE]
      next if !partner.pbCanIncreaseStatStage?(stat,false)
      partner.pbIncreaseStat(stat,1,false,@id,attacker,showanim)
      showanim=false
    end
    return 0
  end
end

# Expand Expanding Force's target on Psychic Terrain before Azure builds the
# target list. This is isolated here rather than modifying the core battler file.
class PokeBattle_Battler
  unless method_defined?(:azureMoveCompatibilityTarget)
    alias azureMoveCompatibilityTarget pbTarget
    def pbTarget(move)
      if move && move.id==PBMoves::EXPANDINGFORCE && !isAirborne? &&
         ($fefieldeffect==37 || @battle.field.effects[PBEffects::PsychicTerrain]>0)
        return PBTargets::AllOpposing
      end
      return azureMoveCompatibilityTarget(move)
    end
  end
end

# Steel Roller: require and remove a temporary terrain overlay after a damaging
# hit. Permanent field effects are intentionally not erased.
class PokeBattle_Move_235 < PokeBattle_Move
  def azureTemporaryTerrains
    return [
      PBEffects::ElectricTerrain,PBEffects::GrassyTerrain,
      PBEffects::MistyTerrain,PBEffects::PsychicTerrain,
      PBEffects::DampTerrain,PBEffects::MuddyTerrain
    ]
  end

  def pbOnStartUse(attacker)
    @azure_steel_roller_cleared=false
    if azureTemporaryTerrains.all? { |effect| @battle.field.effects[effect]<=0 }
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !@azure_steel_roller_cleared
      @azure_steel_roller_cleared=true
      azureTemporaryTerrains.each { |effect| @battle.field.effects[effect]=0 }
      @battle.pbDisplay(_INTL("The temporary terrain was destroyed!"))
    end
    return ret
  end
end

# Scale Shot: 2-5 hits, followed by one Speed increase and one Defense decrease.
class PokeBattle_Move_236 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 5 if attacker.hasWorkingAbility(:SKILLLINK) || attacker.hasWorkingItem(:LOADEDDICE)
    chances=[2,2,3,3,4,5]
    return chances[@battle.pbRandom(chances.length)]
  end

  def pbOnStartUse(attacker)
    @azure_scale_shot_changes_applied=false
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !@azure_scale_shot_changes_applied
      @azure_scale_shot_changes_applied=true
      showanim=true
      if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
        attacker.pbIncreaseStat(PBStats::SPEED,1,false,@id,attacker,showanim)
        showanim=false
      end
      if attacker.hasWorkingAbility(:TEMPORALSHIFT)
        @battle.pbDisplay(_INTL("{1}'s stats can't be lowered due to Temporal Shift!",attacker.pbThis))
      elsif attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
        attacker.pbReduceStat(PBStats::DEFENSE,1,false,@id,attacker,showanim,true)
      end
    end
    return ret
  end
end

# Misty Explosion: the standard self-faint behavior plus doubled power on Misty
# Terrain (per Azure's PBS description).
class PokeBattle_Move_234 < PokeBattle_Move_0E0
  def pbBaseDamage(basedmg,attacker,opponent)
    if $fefieldeffect==3 || @battle.field.effects[PBEffects::MistyTerrain]>0
      return basedmg*2
    end
    return basedmg
  end
end

# Grassy Glide: gain one priority on Grassy Terrain while the user is grounded.
class PokeBattle_Move_239 < PokeBattle_Move
  def priority
    pri=super
    if @user && !@user.isAirborne? &&
       ($fefieldeffect==2 || @battle.field.effects[PBEffects::GrassyTerrain]>0)
      pri+=1
    end
    return pri
  end
end

# Terrain Pulse: double power and adopt the type of the four standard terrains.
class PokeBattle_Move_240 < PokeBattle_Move
  def azureTerrainPulseType
    # Temporary overlays take precedence over the permanent field beneath them.
    return PBTypes::ELECTRIC if @battle.field.effects[PBEffects::ElectricTerrain]>0
    return PBTypes::GRASS    if @battle.field.effects[PBEffects::GrassyTerrain]>0
    return PBTypes::FAIRY    if @battle.field.effects[PBEffects::MistyTerrain]>0
    return PBTypes::PSYCHIC  if @battle.field.effects[PBEffects::PsychicTerrain]>0
    return PBTypes::ELECTRIC if $fefieldeffect==1
    return PBTypes::GRASS    if $fefieldeffect==2
    return PBTypes::FAIRY    if $fefieldeffect==3
    return PBTypes::PSYCHIC  if $fefieldeffect==37
    return nil
  end

  def pbType(type,attacker,opponent)
    terrain_type=azureTerrainPulseType
    return terrain_type if terrain_type
    return type
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return azureTerrainPulseType ? basedmg*2 : basedmg
  end
end

# Lash Out: Azure already records whether the user's stats were lowered during
# the round; consume that signal only for the damage calculation.
class PokeBattle_Move_242 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return attacker.statLowered ? basedmg*2 : basedmg
  end
end

# Poltergeist: fail if the target has no held item.
class PokeBattle_Move_243 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return !opponent || opponent.item==0
  end
end


# Chloroblast pays half max HP once per use, even if an ability adds another hit.
class PokeBattle_Move_222 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @azure_chloroblast_recoil_applied=false
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !@azure_chloroblast_recoil_applied &&
       !attacker.hasWorkingAbility(:MAGICGUARD)
      @azure_chloroblast_recoil_applied=true
      recoil=attacker.pbAdjustAbilityRecoilCrashDamage((attacker.totalhp/2.0).ceil)
      attacker.pbReduceHP(recoil) if recoil>0
      @battle.pbDisplay(_INTL("{1} was hurt by the recoil!",attacker.pbThis)) if recoil>0
    end
    return ret
  end
end

# Ice Spinner removes temporary terrain like Steel Roller, but never requires a
# terrain in order to be used.
class PokeBattle_Move_255 < PokeBattle_Move_235
  def pbOnStartUse(attacker)
    @azure_steel_roller_cleared=false
    return true
  end
end

# Fillet Away: pay half max HP and sharply raise both offenses and Speed.
class PokeBattle_Move_257 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    stats=[PBStats::ATTACK,PBStats::SPATK,PBStats::SPEED]
    if attacker.hp<=(attacker.totalhp/2).floor ||
       stats.all? { |stat| !attacker.pbCanIncreaseStatStage?(stat,false) }
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbReduceHP((attacker.totalhp/2).floor)
    showanim=true
    stats.each do |stat|
      next if !attacker.pbCanIncreaseStatStage?(stat,false)
      attacker.pbIncreaseStat(stat,2,false,@id,attacker,showanim)
      showanim=false
    end
    return 0
  end
end

# Snowscape maps to Azure's Hail weather implementation.
class PokeBattle_Move_262 < PokeBattle_Move_102
end

# Double Shock follows Azure's authored PBS description and removes Fire typing
# through the same Burn Up state used by the existing engine.
class PokeBattle_Move_264 < PokeBattle_Move_15E
end

# Mighty Cleave bypasses Protect-family checks.
class PokeBattle_Move_285 < PokeBattle_Move
  def canProtectAgainst?
    return false
  end
end

# Dragon Cheer raises the active ally's critical-hit stage, with the stronger
# two-stage boost for Dragon-type allies.
class PokeBattle_Move_286 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent || opponent.isFainted? || opponent.effects[PBEffects::FocusEnergy]>=3
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    increment=opponent.pbHasType?(:DRAGON) ? 2 : 1
    opponent.effects[PBEffects::FocusEnergy]=[
      opponent.effects[PBEffects::FocusEnergy]+increment,3
    ].min
    @battle.pbDisplay(_INTL("{1} became fired up!",opponent.pbThis))
    return 0
  end
end

# Psychic Noise: its guaranteed secondary effect prevents healing for two turns.
class PokeBattle_Move_287 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    opponent.effects[PBEffects::HealBlock]=2
    @battle.pbDisplay(_INTL("{1} was prevented from healing!",opponent.pbThis))
    return true
  end
end

# Upper Hand succeeds only against a not-yet-used positive-priority move and
# then flinches through its guaranteed PBS secondary effect.
class PokeBattle_Move_289 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return true if !opponent || opponent.hasMovedThisRound?
    return true if @battle.switchedOut[opponent.index] || opponent.itemUsed
    choice=@battle.choices[opponent.index]
    chosenmove=(choice && choice[0]==1) ? choice[2] : nil
    return true if !chosenmove || chosenmove.priority<=0
    return false
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if opponent.effects[PBEffects::Substitute]>0
    return false if opponent.hasWorkingAbility(:INNERFOCUS) && !opponent.moldbroken
    opponent.effects[PBEffects::Flinch]=true
    return true
  end
end

# Matcha Gotcha reuses Azure's half-damage draining rules and adds its PBS burn
# chance as a normal secondary effect.
class PokeBattle_Move_28C < PokeBattle_Move_0DD
  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanBurn?(false)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end

# Corrosive Gas suppresses a removable held item for the rest of the battle.
# Azure represents that suppression the same way Knock Off does: clear the
# battler's current item while leaving the Pokemon's initial item untouched.
class PokeBattle_Move_244 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0 || opponent.item==0 ||
       @battle.pbIsUnlosableItem(opponent,opponent.item)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.hasWorkingAbility(:STICKYHOLD) && !opponent.moldbroken
      @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,
        PBAbilities.getName(opponent.ability),@name))
      return -1
    end
    itemname=PBItems.getName(opponent.item)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.item=0
    opponent.effects[PBEffects::ChoiceBand]=-1
    @battle.pbDisplay(_INTL("{1}'s {2} was corroded!",opponent.pbThis,itemname))
    return 0
  end
end

# Raging Bull uses Azure's complete Brick Break behavior, including Aurora Veil
# and Dune Defense, and selects its type from Paldean Tauros's battle form.
class PokeBattle_Move_258 < PokeBattle_Move_10A
  def pbType(type,attacker,opponent)
    if isConst?(attacker.species,PBSpecies,:TAUROS)
      return PBTypes::FIGHTING if attacker.form==1
      return PBTypes::FIRE     if attacker.form==2
      return PBTypes::WATER    if attacker.form==3
    end
    return type
  end
end

# Doodle copies the target's copyable Ability to the user and its active ally.
# Fixed Abilities and Ability Shield retain the same protections used elsewhere
# in Azure's Ability-changing move implementations.
class PokeBattle_Move_263 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    copiedability=opponent ? opponent.ability : 0
    if copiedability==0 || PBStuff::ABILITYBLACKLIST.include?(copiedability)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    recipients=[attacker,attacker.pbPartner].compact.uniq
    recipients.reject! { |battler| battler.isFainted? }
    eligible=recipients.select do |battler|
      !PBStuff::FIXEDABILITIES.include?(battler.ability) &&
        battler.ability!=copiedability && !battler.hasWorkingItem(:ABILITYSHIELD)
    end
    if eligible.empty?
      recipients.each do |battler|
        next if !battler.hasWorkingItem(:ABILITYSHIELD)
        @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!",battler.pbThis,
          PBItems.getName(battler.item)))
      end
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    recipients.each do |battler|
      if battler.hasWorkingItem(:ABILITYSHIELD)
        @battle.pbDisplay(_INTL("{1}'s Ability is protected by its {2}!",battler.pbThis,
          PBItems.getName(battler.item)))
        next
      end
      next if PBStuff::FIXEDABILITIES.include?(battler.ability)
      next if battler.ability==copiedability
      battler.ability=copiedability
      @battle.pbDisplay(_INTL("{1} copied {2}'s {3}!",battler.pbThis,
        opponent.pbThis(true),PBAbilities.getName(copiedability)))
      battler.pbAbilitiesOnSwitchIn(true)
    end
    return 0
  end
end

# Tidy Up removes every active substitute and all Azure entry hazards from both
# sides, then raises the user's Attack and Speed. Custom Caltrops and Mystic
# Trees are included so the authored "all entry hazards" promise stays true.
class PokeBattle_Move_259 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    battlers=@battle.battlers.compact
    substituteactive=battlers.any? { |battler| battler.effects[PBEffects::Substitute]>0 }
    hazardactive=@battle.sides.any? do |side|
      side.effects[PBEffects::StealthRock] || side.effects[PBEffects::StickyWeb] ||
        side.effects[PBEffects::Spikes]>0 || side.effects[PBEffects::ToxicSpikes]>0 ||
        side.effects[PBEffects::Caltrops]>0 || side.effects[PBEffects::MysticTree]>0
    end
    stats=[PBStats::ATTACK,PBStats::SPEED]
    canraise=stats.any? { |stat| attacker.pbCanIncreaseStatStage?(stat,false) }
    if !substituteactive && !hazardactive && !canraise
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    battlers.each do |battler|
      next if battler.effects[PBEffects::Substitute]<=0
      battler.effects[PBEffects::Substitute]=0
      @battle.scene.pbUnSubstituteSprite(battler,battler.pbIsOpposing?(1))
      @battle.pbDisplay(_INTL("{1}'s substitute faded!",battler.pbThis))
    end
    @battle.sides.each do |side|
      side.effects[PBEffects::StealthRock]=false
      side.effects[PBEffects::StickyWeb]=false
      side.effects[PBEffects::Spikes]=0
      side.effects[PBEffects::ToxicSpikes]=0
      side.effects[PBEffects::Caltrops]=0
      side.effects[PBEffects::MysticTree]=0
    end
    @battle.pbDisplay(_INTL("Tidying up complete!")) if substituteactive || hazardactive
    showanim=true
    stats.each do |stat|
      next if !attacker.pbCanIncreaseStatStage?(stat,false)
      attacker.pbIncreaseStat(stat,1,false,@id,attacker,showanim)
      showanim=false
    end
    return 0
  end
end

# Ivy Cudgel follows the held mask directly, with form-based fallbacks for maps
# or scripted battlers which already initialize Ogerpon in a mask form.
class PokeBattle_Move_272 < PokeBattle_Move
  def pbType(type,attacker,opponent)
    return type if !isConst?(attacker.species,PBSpecies,:OGERPON)
    return PBTypes::WATER if isConst?(attacker.item,PBItems,:WELLSPRINGMASK) || [1,5].include?(attacker.form)
    return PBTypes::FIRE  if isConst?(attacker.item,PBItems,:HEARTHFLAMEMASK) || [2,6].include?(attacker.form)
    return PBTypes::ROCK  if isConst?(attacker.item,PBItems,:CORNERSTONEMASK) || [3,7].include?(attacker.form)
    return type
  end
end

# Mortal Spin poisons each damaged target through Azure's normal secondary-
# effect pipeline, then clears the user's trapping effects and hazards once per
# use. Unlike Rapid Spin, it intentionally provides no Speed increase.
class PokeBattle_Move_256 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @azure_mortal_spin_cleanup_applied=false
    return true
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanPoison?(false)
    opponent.pbPoison(attacker)
    @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !@azure_mortal_spin_cleanup_applied && !attacker.isFainted? &&
       opponent.damagestate.calcdamage>0 && !attacker.hasWorkingAbility(:SHEERFORCE)
      @azure_mortal_spin_cleanup_applied=true
      azureMortalSpinCleanup(attacker,opponent)
    end
    return ret
  end

  def azureMortalSpinCleanup(attacker,opponent)
    if attacker.effects[PBEffects::MultiTurn]>0
      mtattack=PBMoves.getName(attacker.effects[PBEffects::MultiTurnAttack])
      mtuser=@battle.battlers[attacker.effects[PBEffects::MultiTurnUser]]
      @battle.pbDisplay(_INTL("{1} got free of {2}'s {3}!",attacker.pbThis,
        mtuser.pbThis(true),mtattack))
      attacker.effects[PBEffects::MultiTurn]=0
      if attacker.effects[PBEffects::MultiTurnAttack]==PBMoves::BINDINGWORD
        [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,
         PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION].each do |stat|
          attacker.stages[stat]=attacker.effects[PBEffects::StatChangeHolder][stat]
          attacker.effects[PBEffects::StatChangeHolder][stat]=0
        end
      end
      attacker.effects[PBEffects::MultiTurnAttack]=0
      attacker.effects[PBEffects::MultiTurnUser]=-1
    end
    if attacker.effects[PBEffects::LeechSeed]>=0
      attacker.effects[PBEffects::LeechSeed]=-1
      @battle.pbDisplay(_INTL("{1} shed Leech Seed!",attacker.pbThis))
    end
    side=attacker.pbOwnSide
    if side.effects[PBEffects::StealthRock]
      side.effects[PBEffects::StealthRock]=false
      @battle.pbDisplay(_INTL("{1} cleared away the pointed stones!",attacker.pbThis))
    end
    if side.effects[PBEffects::Spikes]>0
      side.effects[PBEffects::Spikes]=0
      @battle.pbDisplay(_INTL("{1} cleared away the Spikes!",attacker.pbThis))
    end
    if side.effects[PBEffects::ToxicSpikes]>0
      side.effects[PBEffects::ToxicSpikes]=0
      @battle.pbDisplay(_INTL("{1} cleared away the poison barbs!",attacker.pbThis))
    end
    if side.effects[PBEffects::StickyWeb]
      side.effects[PBEffects::StickyWeb]=false
      @battle.pbDisplay(_INTL("{1} cleared away the sticky webbing!",attacker.pbThis))
    end
    if side.effects[PBEffects::Caltrops]>0
      side.effects[PBEffects::Caltrops]=0
      @battle.pbDisplay(_INTL("{1} cleared away the Caltrops!",attacker.pbThis))
    end
    if side.effects[PBEffects::MysticTree]>0
      side.effects[PBEffects::MysticTree]=0
      @battle.pbDisplay(_INTL("{1} cleared away the mystical trees!",attacker.pbThis))
    end
  end
end

# Chilly Reception reuses Azure's complete Hail setup (weather locks, duration,
# field extensions and Eiscue restoration) and independently performs its pivot.
# This lets the pivot still work when Hail is already active, and lets the
# weather still start when the user has no eligible reserve Pokemon.
class PokeBattle_Move_261 < PokeBattle_Move_102
  def azureCanStartHail?
    return false if @battle.field.effects[PBEffects::HeavyRain]
    return false if @battle.field.effects[PBEffects::HarshSunlight]
    if @battle.weather==PBWeather::STRONGWINDS
      deltastream=@battle.battlers.any? do |battler|
        battler && battler.hasWorkingAbility(:DELTASTREAM)
      end
      return false if $fefieldeffect==43 || deltastream
    end
    return false if @battle.weather==PBWeather::HAIL
    return false if [7,16,32,35,38].include?($fefieldeffect)
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    canweather=azureCanStartHail?
    canswitch=@battle.pbCanChooseNonActive?(attacker.index)
    if !canweather && !canswitch
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.vanished=true if canswitch
    if canweather
      super(attacker,opponent,hitnum,alltargets,showanimation)
    else
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    end
    attacker.userSwitch=true if canswitch
    return 0
  end
end

# Runtime state shared by Rage Fist and Glaive Rush. Rage Fist's counter is
# stored on the battle and keyed by the actual Pokemon object, so it survives a
# switch but cannot leak into a replacement battler or a later battle.
class PokeBattle_Battler
  attr_accessor :azureGlaiveRush
  attr_accessor :azureStatsRaisedThisRound
  attr_accessor :azureJetstream

  # Counterpoise's temporary doubling is deliberately exposed through the
  # normal Defense reader, so every physical damage path sees the same value.
  def defense
    value=@defense
    if @effects && @effects[PBEffects::CounterpoiseDouble]
      value*=2
    end
    return value
  end

  def azureHitsTaken
    counts=@battle.instance_variable_get(:@azure_hits_taken) || {}
    return counts[@pokemon.object_id] || 0
  end

  unless method_defined?(:azure_move_compat_pbInitialize)
    alias azure_move_compat_pbInitialize pbInitialize
    def pbInitialize(pkmn,index,batonpass)
      azureReleaseCommander
      azure_move_compat_pbInitialize(pkmn,index,batonpass)
      @azureGlaiveRush=false
      @azureStatsRaisedThisRound=false
      @azureJetstream=false
    end
  end

  def azureReleaseCommander
    return if !@battle || !@effects
    commander=@effects[PBEffects::Commander]
    commandee=@effects[PBEffects::Commandee]
    return if !commander && !commandee
    partner=pbPartner
    if commandee && partner && partner.effects[PBEffects::Commander]
      partner.effects[PBEffects::Commander]=false
      partner.vanished=false
      @battle.scene.pbUnVanishSprite(partner)
    elsif commander && partner && partner.effects[PBEffects::Commandee]
      partner.effects[PBEffects::Commandee]=false
    end
    @effects[PBEffects::Commander]=false
    @effects[PBEffects::Commandee]=false
  end

  def azureCommanderCheck
    return if isFainted? || !@battle.doublebattle
    partner=pbPartner
    return if !partner || partner==self || partner.isFainted?
    return if @battle.pbGetOwnerIndex(index)!=@battle.pbGetOwnerIndex(partner.index)
    if isConst?(species,PBSpecies,:TATSUGIRI) && isConst?(partner.species,PBSpecies,:DONDOZO)
      tatsugiri=self; dondozo=partner
    elsif isConst?(species,PBSpecies,:DONDOZO) && isConst?(partner.species,PBSpecies,:TATSUGIRI)
      tatsugiri=partner; dondozo=self
    else
      return
    end
    return if !tatsugiri.hasWorkingAbility(:COMMANDER)
    return if tatsugiri.effects[PBEffects::Commander] || dondozo.effects[PBEffects::Commandee]
    return if [tatsugiri,dondozo].any? { |battler| battler.effects[PBEffects::TwoTurnAttack]>0 }
    if tatsugiri.effects[PBEffects::Substitute]>0
      tatsugiri.effects[PBEffects::Substitute]=0
      @battle.scene.pbUnSubstituteSprite(tatsugiri,tatsugiri.pbIsOpposing?(1))
    end
    @battle.scene.pbVanishSprite(tatsugiri)
    tatsugiri.vanished=true
    @battle.pbDisplay(_INTL("{1} was swallowed by {2} and became its commander!",
      tatsugiri.pbThis,dondozo.pbThis(true)))
    @battle.pbClearChoices(tatsugiri.index)
    tatsugiri.pbCancelMoves
    tatsugiri.effects[PBEffects::Commander]=true
    dondozo.effects[PBEffects::Commandee]=true
    [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF].each do |stat|
      next if !dondozo.pbCanIncreaseStatStage?(stat,false)
      dondozo.pbIncreaseStat(stat,2,false,:ABILITY,dondozo)
    end
  end

  unless method_defined?(:azure_move_compat_pbAbilitiesOnSwitchIn)
    alias azure_move_compat_pbAbilitiesOnSwitchIn pbAbilitiesOnSwitchIn
    def pbAbilitiesOnSwitchIn(onactive,megad=false)
      ret=azure_move_compat_pbAbilitiesOnSwitchIn(onactive,megad)
      azureCommanderCheck
      return ret
    end
  end

  unless method_defined?(:azure_move_compat_pbFaint)
    alias azure_move_compat_pbFaint pbFaint
    def pbFaint(showMessage=true)
      wascommander=@effects[PBEffects::Commander]
      wascommandee=@effects[PBEffects::Commandee]
      partner=pbPartner
      ret=azure_move_compat_pbFaint(showMessage)
      if ret && partner
        if wascommandee && partner.effects[PBEffects::Commander]
          partner.effects[PBEffects::Commander]=false
          partner.vanished=false
          @battle.scene.pbUnVanishSprite(partner)
        elsif wascommander && partner.effects[PBEffects::Commandee]
          partner.effects[PBEffects::Commandee]=false
        end
      end
      return ret
    end
  end

  unless method_defined?(:azure_move_compat_pbBeginTurn)
    alias azure_move_compat_pbBeginTurn pbBeginTurn
    def pbBeginTurn(choice)
      @azureGlaiveRush=false
      azure_move_compat_pbBeginTurn(choice)
    end
  end

  unless method_defined?(:azure_move_compat_pbIncreaseStatBasic)
    alias azure_move_compat_pbIncreaseStatBasic pbIncreaseStatBasic
    def pbIncreaseStatBasic(stat,increment)
      beforestage=@stages[stat]
      holder=@effects[PBEffects::StatChangeHolder]
      beforestored=holder ? holder[stat] : nil
      ret=azure_move_compat_pbIncreaseStatBasic(stat,increment)
      holder=@effects[PBEffects::StatChangeHolder]
      if @stages[stat]>beforestage ||
         (holder && !beforestored.nil? && holder[stat]>beforestored)
        @azureStatsRaisedThisRound=true
      end
      return ret
    end
  end

  unless method_defined?(:azure_move_compat_pbReducePP)
    alias azure_move_compat_pbReducePP pbReducePP
    def pbReducePP(move)
      beforepp=move.pp
      ret=azure_move_compat_pbReducePP(move)
      if ret && beforepp>0 && move.pp==beforepp-1 && move.pp>0 &&
         pbOwnSide.effects[PBEffects::PressurePlate]>0
        pbSetPP(move,move.pp-1)
      end
      return ret
    end
  end

  def azureConsumeNeedle
    return false if @effects[PBEffects::Needles]<=0 || isFainted?
    @effects[PBEffects::Needles]-=1
    @battle.scene.pbDamageAnimation(self,0)
    if !hasWorkingAbility(:MAGICGUARD) &&
       !(hasWorkingAbility(:WONDERGUARD) && $fefieldeffect==44)
      pbReduceHP([(@totalhp/8).floor,1].max)
    end
    @effects[PBEffects::Wounded]=[@effects[PBEffects::Wounded],3].max
    @battle.pbDisplay(_INTL("A needle tore into {1} and left grievous wounds!",pbThis(true)))
    return true
  end
end

class PokeBattle_Battle
  def azureJetstreamWeatherExtended?
    return @battlers.any? { |battler| battler && !battler.isFainted? && battler.azureJetstream }
  end

  def azureJetstreamForSide?(side)
    return @battlers.any? do |battler|
      battler && !battler.isFainted? && battler.azureJetstream &&
        (pbIsOpposing?(battler.index) ? 1 : 0)==side
    end
  end
end

class PokeBattle_Move
  unless method_defined?(:azure_move_compat_pbOnDamageLost)
    alias azure_move_compat_pbOnDamageLost pbOnDamageLost
    def pbOnDamageLost(damage,attacker,opponent)
      azure_move_compat_pbOnDamageLost(damage,attacker,opponent)
      if damage>0 && attacker && opponent && attacker.index!=opponent.index && opponent.pokemon
        opponent.effects[PBEffects::DamagingMoveThisTurn]=true
        counts=@battle.instance_variable_get(:@azure_hits_taken) || {}
        key=opponent.pokemon.object_id
        counts[key]=[counts.fetch(key,0)+1,6].min
        @battle.instance_variable_set(:@azure_hits_taken,counts)
      end
      if damage>0 && attacker && opponent && isContactMove? &&
         !attacker.hasWorkingAbility(:LONGREACH) &&
         !attacker.hasWorkingItem(:PROTECTIVEPADS)
        attacker.azureConsumeNeedle if attacker.effects[PBEffects::Needles]>0
        if !attacker.isFainted? && opponent.effects[PBEffects::MoltenStance] &&
           attacker.pbCanBurn?(false)
          attacker.pbBurn(opponent)
          @battle.pbDisplay(_INTL("{1}'s molten stance burned {2}!",opponent.pbThis,attacker.pbThis(true)))
        end
      end
    end
  end

  unless method_defined?(:azure_move_compat_pbAccuracyCheck)
    alias azure_move_compat_pbAccuracyCheck pbAccuracyCheck
    def pbAccuracyCheck(attacker,opponent)
      return true if opponent && opponent.azureGlaiveRush
      return azure_move_compat_pbAccuracyCheck(attacker,opponent)
    end
  end

  unless method_defined?(:azure_move_compat_pbCalcDamage)
    alias azure_move_compat_pbCalcDamage pbCalcDamage
    def pbCalcDamage(attacker,opponent,options=0)
      damage=azure_move_compat_pbCalcDamage(attacker,opponent,options)
      if damage>0 && opponent && opponent.azureGlaiveRush
        damage*=2
      end
      if damage>0 && @battle.field.effects[PBEffects::VileMercy]>0
        damage=[(damage*0.8).floor,1].max
      end
      if damage>0 && attacker && attacker.pbOwnSide.effects[PBEffects::PressurePlate]>0
        damage=[(damage*1.2).round,1].max
      end
      opponent.damagestate.calcdamage=damage if opponent
      return damage
    end
  end
end

# Glaive Rush leaves the user exposed after a successful hit. The shared hooks
# above make attacks unmissable and double their calculated damage, and clear
# the state when the exposed Pokemon next begins a turn or leaves its slot.
class PokeBattle_Move_267 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.azureGlaiveRush=true if opponent.damagestate.calcdamage>0
    return ret
  end
end

# Rage Fist gains 50 power for each damaging hit the user has taken in this
# battle, capped after six hits at the canonical 350 base power.
class PokeBattle_Move_268 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return basedmg+(50*[attacker.azureHitsTaken,6].min)
  end
end

# Salt Cure marks a directly damaged target. Its residual damage is processed
# in Azure's normal end-of-round sequence immediately after Curse damage.
class PokeBattle_Move_269 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !opponent.effects[PBEffects::SaltCure]
      opponent.effects[PBEffects::SaltCure]=true
      @battle.pbDisplay(_INTL("{1} is being salt cured!",opponent.pbThis))
    end
    return ret
  end
end

# Syrup Bomb records three end-of-round Speed drops and the battler slot which
# caused them. Reapplying the move while syrup is active does not reset its timer.
class PokeBattle_Move_276 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       opponent.effects[PBEffects::SyrupBombTurns]<=0
      opponent.effects[PBEffects::SyrupBombTurns]=3
      opponent.effects[PBEffects::SyrupBombUser]=attacker.index
      @battle.pbDisplay(_INTL("{1} got covered in sticky syrup!",opponent.pbThis))
    end
    return ret
  end
end

# Shell Side Arm compares Azure's fully modified offensive and defensive stats
# and uses the category with the better attack/defense ratio for this target.
# Its contact flag follows the selected physical category.
class PokeBattle_Move_238 < PokeBattle_Move
  def pbCalcDamage(attacker,opponent,options=0)
    physicalscore=attacker.pbCalcAttack.to_f/[opponent.pbCalcDefense,1].max
    specialscore=attacker.pbCalcSpAtk.to_f/[opponent.pbCalcSpDef,1].max
    @azure_shell_side_arm_physical=physicalscore>specialscore
    return super(attacker,opponent,options)
  end

  def pbIsPhysical?(type)
    return @azure_shell_side_arm_physical unless @azure_shell_side_arm_physical.nil?
    return super(type)
  end

  def pbIsSpecial?(type)
    return !@azure_shell_side_arm_physical unless @azure_shell_side_arm_physical.nil?
    return super(type)
  end

  def isContactMove?
    return true if @azure_shell_side_arm_physical
    return super
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanPoison?(false)
    opponent.pbPoison(attacker)
    @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
    return true
  end
end

# Triple Arrows's authored 30% Speed drop is handled by Azure's standard
# additional-effect roll. Its independent 50% Defense drop mirrors the same
# Shield Dust, Lucky Chant, Sheer Force, Serene Grace and terrain rules.
class PokeBattle_Move_229 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanReduceStatStage?(PBStats::SPEED,false)
    return opponent.pbReduceStat(PBStats::SPEED,1,false,@id,attacker)
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    return ret if opponent.damagestate.calcdamage<=0 || opponent.damagestate.substitute
    return ret if attacker.grazed || opponent.damagestate.partialhit
    return ret if attacker.hasWorkingAbility(:SHEERFORCE) || @battle.SilvallyCheck(attacker,PBTypes::GROUND)
    return ret if opponent.hasWorkingAbility(:SHIELDDUST) && !opponent.moldbroken && !hasFlags?("m")
    return ret if opponent.pbOwnSide.effects[PBEffects::LuckyChant]>0
    chance=50
    chance*=2 if attacker.hasWorkingAbility(:SERENEGRACE) || $fefieldeffect==9 ||
      @battle.field.effects[PBEffects::Rainbow]>0
    chance=100 if chance>100 || ($DEBUG && Input.press?(Input::CTRL))
    if @battle.pbRandom(100)<chance && opponent.pbCanReduceStatStage?(PBStats::DEFENSE,false)
      opponent.pbReduceStat(PBStats::DEFENSE,1,false,@id,attacker)
    end
    return ret
  end
end

# Burning Jealousy burns only opponents whose stats actually rose during the
# current round. The normal 100% secondary-effect pipeline supplies all of
# Azure's substitute, Shield Dust, Lucky Chant and Sheer Force protections.
class PokeBattle_Move_241 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.azureStatsRaisedThisRound
    return false if !opponent.pbCanBurn?(false)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end

# Shared Azure Protect-family activation. Azure intentionally gives consecutive
# Protect-family uses a hard failure, and also rejects use by the last battler
# to act; the new reactive shields retain those established rules.
module AzureReactiveProtectMove
  def pbEffect(attacker,opponent)
    if !PBStuff::RATESHARER.include?(attacker.previousMove)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    priority=@battle.pbPriority
    movinglast=(@battle.doublebattle && attacker==priority[3]) ||
      (!@battle.doublebattle && attacker==priority[1])
    if movinglast || attacker.effects[PBEffects::ProtectRate]!=1
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.effects[azureReactiveProtectEffect]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbAnimation(@id,attacker,nil)
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end

class PokeBattle_Move_252 < PokeBattle_Move
  include AzureReactiveProtectMove

  def azureReactiveProtectEffect
    return PBEffects::SilkTrap
  end
end

class PokeBattle_Move_283 < PokeBattle_Move
  include AzureReactiveProtectMove

  def azureReactiveProtectEffect
    return PBEffects::BurningBulwark
  end
end

# Shed Tail pays half of the user's maximum HP, queues a quarter-HP substitute
# for the replacement, and pivots through Azure's normal post-move switch path.
# The existing Orthworm tribute handoff uses the same state and therefore gains
# the same hazard-before-substitute ordering and faint safety.
class PokeBattle_Move_265 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    hpcost=(attacker.totalhp/2.0).ceil
    if !@battle.pbCanChooseNonActive?(attacker.index) ||
       attacker.effects[PBEffects::Substitute]>0 || attacker.hp<=hpcost
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbReduceHP(hpcost)
    sublife=[(attacker.totalhp/4.0).floor,1].max
    sheddata=@battle.instance_variable_get(:@tributeOrthwormShedHP) || {}
    sheddata[attacker.index]=sublife
    @battle.instance_variable_set(:@tributeOrthwormShedHP,sheddata)
    @battle.pbDisplay(_INTL("{1} shed its tail to create a decoy!",attacker.pbThis))
    attacker.pbBerryCureCheck
    attacker.vanished=true
    attacker.userSwitch=true
    return 0
  end
end

# Order Up grants Dondozo the form-dependent boost only while its active
# Tatsugiri partner is actually inside it via Commander.
class PokeBattle_Move_270 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @azure_order_up_boost_applied=false
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    partner=attacker.pbPartner
    if !@azure_order_up_boost_applied && opponent.damagestate.calcdamage>0 &&
       attacker.effects[PBEffects::Commandee] && partner &&
       partner.effects[PBEffects::Commander]
      stat=[PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED][partner.form]
      if stat && attacker.pbCanIncreaseStatStage?(stat,false)
        @azure_order_up_boost_applied=true
        attacker.pbIncreaseStat(stat,1,false,@id,attacker)
      end
    end
    return ret
  end
end

# Foul Gambit restores three quarters of the damage it dealt, but only when
# that hit actually knocks out the target. This is recovery rather than a
# draining effect, so Liquid Ooze and Big Root intentionally do not alter it.
class PokeBattle_Move_21F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.isFainted? && opponent.damagestate.hplost>0 && !attacker.isFainted?
      hpgain=[(opponent.damagestate.hplost*3/4.0).floor,1].max
      hpgain=apply_tribute_healing(attacker,hpgain,attacker) if defined?(apply_tribute_healing)
      recovered=attacker.pbRecoverHP(hpgain,true)
      @battle.pbDisplay(_INTL("{1}'s gambit restored its HP!",attacker.pbThis)) if recovered>0
    end
    return ret
  end
end

# Sweltering Strike is explicitly marked "Placeholder" in Azure's PBS. It is
# therefore a normal damaging move until its designers assign another effect.
class PokeBattle_Move_22C < PokeBattle_Move
end

# Ergo Proxy copies the target's original types to the user and changes the
# target to pure Ghost after a direct damaging hit. Multitype/RKS System keep
# their established Azure immunity to forced type changes.
class PokeBattle_Move_22D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    copiedtype1=opponent.type1
    copiedtype2=opponent.type2
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    return ret if opponent.damagestate.calcdamage<=0 || opponent.damagestate.substitute
    return ret if opponent.isFainted?
    if !isConst?(attacker.ability,PBAbilities,:MULTITYPE) &&
       !isConst?(attacker.ability,PBAbilities,:RKSSYSTEM)
      attacker.type1=copiedtype1
      attacker.type2=copiedtype2
      @battle.pbDisplay(_INTL("{1}'s type changed to match {2}'s!",attacker.pbThis,opponent.pbThis(true)))
    end
    if !isConst?(opponent.ability,PBAbilities,:MULTITYPE) &&
       !isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
      opponent.type1=PBTypes::GHOST
      opponent.type2=PBTypes::GHOST
      @battle.pbDisplay(_INTL("{1} transformed into the Ghost type!",opponent.pbThis))
    end
    return ret
  end
end

# Dust Bowl cannot miss in Sandstorm. Its PBS 10% additional-effect roll calls
# this method to apply the same five-turn trapping state as Sand Tomb.
class PokeBattle_Move_22E < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true if @battle.pbWeather==PBWeather::SANDSTORM
    return super
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if opponent.isFainted? || opponent.damagestate.substitute
    return false if opponent.effects[PBEffects::MultiTurn]>0
    opponent.effects[PBEffects::MultiTurn]=5
    opponent.effects[PBEffects::MultiTurn]=7 if attacker.hasWorkingItem(:GRIPCLAW)
    opponent.effects[PBEffects::MultiTurn]=8 if $fefieldeffect==46
    opponent.effects[PBEffects::MultiTurnAttack]=@id
    opponent.effects[PBEffects::MultiTurnUser]=attacker.index
    @battle.pbDisplay(_INTL("{1} was trapped in a raging Dust Bowl!",opponent.pbThis))
    $bindingband=attacker.hasWorkingItem(:BINDINGBAND) ? 1 : 0
    return true
  end
end

# Coral Burst halves its base power against a resistant target, then pivots the
# user after a successful resisted hit. Its high critical ratio remains driven
# by the PBS flag and the engine's standard critical-hit pipeline.
class PokeBattle_Move_24A < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    type=pbType(@type,attacker,opponent)
    typemod=pbTypeModifier(type,attacker,opponent)
    @azure_coral_burst_resisted=(typemod>0 && typemod<4)
    return @azure_coral_burst_resisted ? [basedmg/2,1].max : basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if @azure_coral_burst_resisted && opponent.damagestate.calcdamage>0 &&
       !attacker.isFainted? && @battle.pbCanChooseNonActive?(attacker.index) &&
       !@battle.pbAllFainted?(@battle.pbParty(opponent.index)) &&
       !(attacker.hasWorkingAbility(:PARENTALBOND) && hitnum==0)
      if !attacker.effects[PBEffects::Pursuit]
        attacker.vanished=true
        attacker.userSwitch=true
      end
    end
    return ret
  end
end

# Pestilence uses Azure's standard half-damage drain behavior and doubles in
# power if the target had already taken direct move damage during this round.
class PokeBattle_Move_24F < PokeBattle_Move_0DD
  def pbBaseDamage(basedmg,attacker,opponent)
    return opponent.effects[PBEffects::DamagingMoveThisTurn] ? basedmg*2 : basedmg
  end
end

# Glacial Slam uses the established Jump Kick crash path on both a full miss
# and a grazing miss. Its PBS 10% additional-effect roll supplies the freeze.
class PokeBattle_Move_26F < PokeBattle_Move
  def function
    return 0x10B
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanFreeze?(false)
    opponent.pbFreeze
    @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
    return true
  end
end

# Spirit Fist is physical for the user's Attack stat and all physical/contact
# interactions, but function 205 makes damage use the target's Special Defense.
class PokeBattle_Move_278 < PokeBattle_Move
  def pbCalcDamage(attacker,opponent,options=0)
    oldfunction=@function
    @function=0x205
    begin
      return super(attacker,opponent,options)
    ensure
      @function=oldfunction
    end
  end
end

# Function 277 is shared by Azure's Jetstream and Battle Cry. Jetstream keeps
# finite weather and the user's side of Tailwind from counting down while its
# user remains active. Battle Cry reuses Azure's pre-existing two-round bitmask:
# 2 means queued for next round, 1 means the 1.3x boost is currently active.
class PokeBattle_Move_277 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    return ret if opponent.damagestate.calcdamage<=0
    if @id==PBMoves::BATTLECRY
      if attacker.pbOwnSide.effects[PBEffects::BattleCry]<2
        attacker.pbOwnSide.effects[PBEffects::BattleCry]+=2
        if !@battle.pbIsOpposing?(attacker.index)
          @battle.pbDisplay(_INTL("{1} invigorated your team!",attacker.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} invigorated the opposing team!",attacker.pbThis))
        end
      end
    else
      attacker.azureJetstream=true
      @battle.pbDisplay(_INTL("{1}'s jetstream sustained the wind and weather!",attacker.pbThis))
    end
    return ret
  end
end

# Function 282 is shared by Vile Mercy and Bellow. Vile Mercy establishes the
# four-round field state consumed by the global damage and end-round hooks;
# Bellow retains Azure's existing independent one-stage drops to all five stats.
class PokeBattle_Move_282 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super if @id==PBMoves::BELLOW
    if @battle.field.effects[PBEffects::VileMercy]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::VileMercy]=4
    @battle.pbDisplay(_INTL("A vile miasma spread across the battlefield!"))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if @id!=PBMoves::BELLOW
    showanim=true
    lowered=false
    [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF].each do |stat|
      next if !opponent.pbCanReduceStatStage?(stat,false)
      opponent.pbReduceStat(stat,1,false,@id,attacker,showanim)
      showanim=false
      lowered=true
    end
    return lowered
  end
end

# Function 224 is shared by Pierce the Veil and Counterpoise (PBS symbol
# POWERSHIFT). Both use Azure's established Power Trick state for the lasting
# Attack/Defense swap. Counterpoise also grants its authored +1 Defense and
# doubles Defense until the end-of-round hook performs the swap.
class PokeBattle_Move_224 < PokeBattle_Move
  def pbOnStartUse(attacker)
    @azure_pierce_swap_applied=false
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @id==PBMoves::POWERSHIFT
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,1,false,@id,attacker)
      end
      attacker.effects[PBEffects::CounterpoiseDouble]=true
      attacker.effects[PBEffects::CounterpoiseSwap]=true
      @battle.pbDisplay(_INTL("{1} steadied its counterpoise!",attacker.pbThis))
      return 0
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !@azure_pierce_swap_applied && opponent.damagestate.calcdamage>0
      @azure_pierce_swap_applied=true
      attacker.effects[PBEffects::PowerTrick]=!attacker.effects[PBEffects::PowerTrick]
      @battle.pbDisplay(_INTL("{1} swapped its Attack and Defense!",attacker.pbThis))
    end
    return ret
  end
end

# Aftershock schedules one full-power second hit against the struck battler at
# the end of this round. The core hook clears the schedule before executing it,
# preventing the echo from recursively scheduling another echo.
class PokeBattle_Move_27D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !@azure_aftershock_echo && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && !opponent.isFainted?
      opponent.effects[PBEffects::Aftershock]=1
      opponent.effects[PBEffects::AftershockMove]=@id
      opponent.effects[PBEffects::AftershockUser]=attacker.index
      @battle.pbDisplay(_INTL("An aftershock gathered around {1}!",opponent.pbThis))
    end
    return ret
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(false)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",opponent.pbThis))
    return true
  end
end

# Pressure Plate empowers the afflicted side's attacks by 1.2x while its
# battlers' normal move uses consume one additional PP. Side duration and PP
# behavior are handled in the shared battle and battler hooks above.
class PokeBattle_Move_281 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    side=attacker.pbOpposingSide
    if side.effects[PBEffects::PressurePlate]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    side.effects[PBEffects::PressurePlate]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("A pressure plate was placed beneath the opposing team!"))
    else
      @battle.pbDisplay(_INTL("A pressure plate was placed beneath your team!"))
    end
    return 0
  end
end

# Gilded Bargain combines Pain Split's HP averaging with a permanent Dragon
# type conversion for the target. A substitute blocks both effects, matching
# the engine's other direct type-changing status moves.
class PokeBattle_Move_22B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if !isConst?(opponent.ability,PBAbilities,:MULTITYPE) &&
       !isConst?(opponent.ability,PBAbilities,:RKSSYSTEM)
      opponent.type1=getConst(PBTypes,:DRAGON)
      opponent.type2=getConst(PBTypes,:DRAGON)
      @battle.pbDisplay(_INTL("{1} transformed into the Dragon type!",opponent.pbThis))
    end
    olda=attacker.hp
    oldo=opponent.hp
    sharedhp=((attacker.hp+opponent.hp)/2).floor
    attacker.hp=[sharedhp,attacker.totalhp].min
    opponent.hp=[sharedhp,opponent.totalhp].min
    @battle.scene.pbHPChanged(attacker,olda)
    @battle.scene.pbHPChanged(opponent,oldo)
    @battle.pbDisplay(_INTL("The battlers struck a gilded bargain!"))
    return 0
  end
end

# Each successful Tale's End embeds one blade, up to four. The target is
# executed only when its remaining HP is strictly below the accumulated
# 1/16-per-blade threshold, as specified by Azure's PBS description.
class PokeBattle_Move_23A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !opponent.isFainted?
      opponent.effects[PBEffects::TalesEndBlades]=[
        opponent.effects[PBEffects::TalesEndBlades]+1,4
      ].min
      blades=opponent.effects[PBEffects::TalesEndBlades]
      threshold=(opponent.totalhp*blades/16.0).floor
      if opponent.hp<threshold
        @battle.pbDisplay(_INTL("The blades brought {1}'s tale to an end!",opponent.pbThis(true)))
        opponent.pbReduceHP(opponent.hp)
      end
    end
    return ret
  end
end

# Lotus Bloom is Azure's slot-persistent delayed attack. Its counters are
# permanent battler-position effects, so a replacement inherits the seed if
# the original target faints. The delayed strike flag bypasses rescheduling.
class PokeBattle_Move_21E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super if @azure_lotus_bloom_strike
    if opponent.effects[PBEffects::LotusBloom]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::LotusBloom]=3
    opponent.effects[PBEffects::LotusBloomMove]=@id
    opponent.effects[PBEffects::LotusBloomUser]=attacker.index
    opponent.effects[PBEffects::LotusBloomPkmnIdx]=attacker.pokemonIndex
    @battle.pbDisplay(_INTL("A lotus seed was planted around {1}!",opponent.pbThis(true)))
    return 0
  end
end

# Sunfury charges normally, but fires immediately in usable sunshine (and with
# the engine's established two-turn bypasses). A successful strike clears all
# entry hazards from the user's side and scorches the opposing side for three
# end-of-round Fire-type damage ticks.
class PokeBattle_Move_22F < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if attacker.effects[PBEffects::TwoTurnAttack]==0
      @immediate=true if @battle.pbWeather==PBWeather::SUNNYDAY &&
                         !attacker.hasWorkingItem(:UTILITYUMBRELLA)
    end
    if !@immediate
      if attacker.hasWorkingAbility(:INSOMNIA)
        @immediate=true
      elsif attacker.hasWorkingItem(:POWERHERB)
        @immediate=true
        if !checking
          itemname=PBItems.getName(attacker.item)
          attacker.pokemon.itemRecycle=attacker.item
          attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
          attacker.item=0
          @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
        end
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::TwoTurnAttack]>0
      @battle.pbDisplay(_INTL("{1} gathered the fury of the sun!",attacker.pbThis))
      return 0
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      side=attacker.pbOwnSide
      cleared=side.effects[PBEffects::StealthRock] || side.effects[PBEffects::StickyWeb] ||
              side.effects[PBEffects::Spikes]>0 || side.effects[PBEffects::ToxicSpikes]>0 ||
              side.effects[PBEffects::Caltrops]>0 || side.effects[PBEffects::MysticTree]>0
      side.effects[PBEffects::StealthRock]=false
      side.effects[PBEffects::StickyWeb]=false
      side.effects[PBEffects::Spikes]=0
      side.effects[PBEffects::ToxicSpikes]=0
      side.effects[PBEffects::Caltrops]=0
      side.effects[PBEffects::MysticTree]=0
      @battle.pbDisplay(_INTL("{1} burned away the hazards!",attacker.pbThis)) if cleared
      opponent.pbOwnSide.effects[PBEffects::Sunfury]=3
      @battle.pbDisplay(_INTL("The opposing battlefield was engulfed in solar fire!")) if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your battlefield was engulfed in solar fire!")) if @battle.pbIsOpposing?(attacker.index)
    end
    return ret
  end
end

# Red Sun's Zenith stores independently expiring stars on the target's side.
# The third-star attack is tripled and consumes the user, while every new star
# keeps the engine's ordinary Gravity effect active for its five-turn orbit.
class PokeBattle_Move_23F < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    stars=opponent.pbOwnSide.effects[PBEffects::RedSunStars]
    stars=[] if !stars.is_a?(Array)
    stars=stars.find_all { |turns| turns>0 }
    @azure_red_sun_triple=(stars.length>=2)
    return @azure_red_sun_triple ? basedmg*3 : basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      side=opponent.pbOwnSide
      stars=side.effects[PBEffects::RedSunStars]
      stars=[] if !stars.is_a?(Array)
      stars=stars.find_all { |turns| turns>0 }
      stars.push(6) if stars.length<3
      side.effects[PBEffects::RedSunStars]=stars
      @battle.field.effects[PBEffects::Gravity]=[
        @battle.field.effects[PBEffects::Gravity],6
      ].max
      @battle.pbDisplay(_INTL("A red star began orbiting above {1}'s battlefield!",opponent.pbThis(true)))
      if @azure_red_sun_triple && !attacker.isFainted?
        @battle.pbDisplay(_INTL("The three stars reached their zenith!"))
        attacker.pbReduceHP(attacker.hp)
      end
    end
    return ret
  end
end


# Blue Shift sacrifices the user for a battle-wide inverse matchup state that
# lasts through the end of the following turn.
class PokeBattle_Move_249 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::BlueShift]=2
    @battle.pbDisplay(_INTL("The type chart was shifted into reverse!"))
    attacker.pbReduceHP(attacker.hp)
    return 0
  end
end

# Circadian Rhythm is self-targeted in Azure's PBS. It sleeps the user and
# marks it to gain one stage in both offenses and Speed at each sleeping EOR.
class PokeBattle_Move_24B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanSleep?(true)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbSleep
    attacker.effects[PBEffects::CircadianRhythm]=true
    @battle.pbDisplay(_INTL("{1} fell into a powerful circadian rhythm!",attacker.pbThis))
    return 0
  end
end

# Needle Blast records one embedded needle for every damaging hit. Needles are
# consumed by the shared contact hook or by the end-of-round processor.
class PokeBattle_Move_24D < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 5 if attacker.hasWorkingAbility(:SKILLLINK) || attacker.hasWorkingItem(:LOADEDDICE)
    chances=[2,2,3,3,4,5]
    return chances[@battle.pbRandom(chances.length)]
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      opponent.effects[PBEffects::Needles]+=1
      @battle.pbDisplay(_INTL("A needle lodged in {1}!",opponent.pbThis(true)))
    end
    return ret
  end
end

# Molten Stance grants immediate defensive stages, burns contact attackers via
# the shared damage hook, then converts the stance into -2 defenses and +2
# Speed at the end of the same turn.
class PokeBattle_Move_24E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    showanim=true
    [PBStats::DEFENSE,PBStats::SPDEF].each do |stat|
      next if !attacker.pbCanIncreaseStatStage?(stat,false)
      attacker.pbIncreaseStat(stat,1,false,@id,attacker,showanim)
      showanim=false
    end
    attacker.effects[PBEffects::MoltenStance]=true
    @battle.pbDisplay(_INTL("{1} assumed a molten stance!",attacker.pbThis))
    return 0
  end
end
