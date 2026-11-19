# Reconcile the existing scorer's two AI allies before either registers an
# action. This does not inspect player commands or change battle turn order.
module AzureBattleAICoordination
  FIELD_MOVES={
    :REFLECT=>:reflect,:LIGHTSCREEN=>:light_screen,:AURORAVEIL=>:aurora_veil,
    :DUNEDEFENSE=>:arenite_wall,:TAILWIND=>:tailwind,:SAFEGUARD=>:safeguard,
    :MIST=>:mist,:LUCKYCHANT=>:lucky_chant,:WIDEGUARD=>:wide_guard,
    :QUICKGUARD=>:quick_guard,:CRAFTYSHIELD=>:crafty_shield,:MATBLOCK=>:mat_block,
    :SUNNYDAY=>:weather,:RAINDANCE=>:weather,:SANDSTORM=>:weather,
    :HAIL=>:weather,:SNOWSCAPE=>:weather,:ELECTRICTERRAIN=>:terrain,
    :GRASSYTERRAIN=>:terrain,:MISTYTERRAIN=>:terrain,:PSYCHICTERRAIN=>:terrain,
    :TRICKROOM=>:trick_room,:WONDERROOM=>:wonder_room,:MAGICROOM=>:magic_room,
    :GRAVITY=>:gravity,:HEALBELL=>:party_cure,:AROMATHERAPY=>:party_cure
  }.each_with_object({}) {|(name,group),result|
    result[PBMoves.const_get(name)]=group if PBMoves.const_defined?(name)
  }.freeze
  FIXED_DAMAGE_FUNCTIONS=[0x6A,0x6B,0x6C,0x6D,0x6E,0x6F,0x70,0x73,0xE1].freeze

  # Capture alternate ordinary-move targets while the real scorer is already
  # visiting them. Z candidates are deliberately left to the command planner.
  def pbGetMoveScore(move,user,target,*args)
    score=super
    slot=args[3]
    if @azureAICoordinationRecording && slot.is_a?(Integer) && slot.between?(0,3) &&
       user && target && @battlers[user.index].equal?(user) &&
       user.moves[slot].equal?(move) && score.is_a?(Numeric) && args[6].nil?
      @azureAICoordinationTargetScores[[user.index,slot,target.index]]=score
    end
    return score
  end

  def pbAIPrepareTurnCoordination
    @azureAICoordinationPlans={}
    @azureAICoordinationPairs={}
    @azureAICoordinationSelected={}
    @azureAICoordinationSignatures={}
    @azureAICoordinationTargetScores={}
    @azureAICoordinationDamage={}
    @azureAICoordinationForecast={}
    @azureAICoordinationRoosters={}
    return if !@doublebattle || [pbSideSize(0),pbSideSize(1)].max>2
    # The command phase historically applies this swap lazily. Do not score
    # the old defensive stats if the caller has not applied it yet.
    return if @field.effects[PBEffects::WonderRoom]>0 &&
      activeBattlerIndices.any? {|i| !@battlers[i].wonderroom }
    pairs=[[0,2],[1,3]].select {|pair| pair.all? {|i| pbAICoordinationEligible?(i) } }
    return if pairs.empty?
    saved=[@scores,@targets,@myChoices]
    begin
      @azureAICoordinationRecording=true
      pairs.flatten.each do |index|
        plan=pbAIComputeCommandPlan(index)
        next if !plan || !plan[:scores] || !plan[:choices]
        @azureAICoordinationPlans[index]=pbAICoordinationCopyPlan(plan)
        @azureAICoordinationSignatures[index]=pbAICoordinationSignature(index)
      end
    ensure
      @azureAICoordinationRecording=false
      @scores,@targets,@myChoices=saved
    end
    pairs.each do |left,right|
      next unless @azureAICoordinationPlans[left] && @azureAICoordinationPlans[right]
      pbAICoordinatePair(left,right)
    end
    return nil
  end

  def pbAIPlannedCommand(index)
    plan=@azureAICoordinationPlans && @azureAICoordinationPlans[index]
    return nil unless plan && pbAICoordinationEligible?(index)
    return nil unless @azureAICoordinationSignatures[index]==pbAICoordinationSignature(index)
    partner=@azureAICoordinationPairs[index]
    if partner
      return nil unless @azureAICoordinationSignatures[partner]==pbAICoordinationSignature(partner)
      choice=@choices[partner]
      if choice && choice[0]!=0
        selected=@azureAICoordinationSelected[partner]
        partner_plan=@azureAICoordinationPlans[partner]
        slot=selected[:slot]==4 ? partner_plan[:z_base_slot] : selected[:slot]
        return nil unless choice[0]==1 && choice[1]==slot
        side=partner&1
        owner=pbGetOwnerIndex(partner)
        registered_z=@zMove && @zMove[side] && @zMove[side][owner]==partner
        return nil unless !!registered_z==(selected[:slot]==4)
        if selected[:target]>=0 && pbAIMoveSelectsTarget?(@battlers[partner],selected[:move])
          return nil unless choice[3]==selected[:target]
        end
      end
    end
    return pbAICoordinationCopyPlan(plan)
  end

  def pbAICoordinationEligible?(index)
    user=@battlers[index]
    return false unless user && !user.isFainted? && pbCanShowCommands?(index) && pbCanShowFightMenu?(index)
    return false if pbOwnedByPlayer?(index) && !@controlPlayer
    return false unless @choices[index] && @choices[index][0]==0
    return false if respond_to?(:pbAIOrdinaryWild?) && pbAIOrdinaryWild?(user)
    return false if !@opponent && pbIsOpposing?(index) && !user.isbossmon && !user.issossmon
    return true
  end

  def pbAICoordinationCopyPlan(plan)
    copy=plan.dup
    [:scores,:targets,:choices].each {|key| copy[key]=plan[key].dup if plan[key] }
    return copy
  end

  def pbAICoordinationSignature(index)
    user=@battlers[index]
    return [user.pokemon.object_id,user.form,user.hp,user.status,user.item,
      user.stages.dup,user.moves.first(4).map {|move| move ? [move.id,move.pp] : nil }]
  end

  def pbAICoordinationCandidates(index)
    plan=@azureAICoordinationPlans[index]
    user=@battlers[index]
    candidates=[]
    plan[:choices].uniq.each do |slot|
      next unless slot.is_a?(Integer) && slot.between?(0,4)
      move=slot==4 ? plan[:z_move] : user.moves[slot]
      score=plan[:scores][slot]
      next unless move && score.is_a?(Numeric) && score>=0
      target=plan[:targets] && plan[:targets][slot]
      target=-1 if !target.is_a?(Integer)
      candidates << {:user=>user,:slot=>slot,:move=>move,:target=>target,:score=>score.to_f}
      next if slot==4 || move.id==PBMoves::MINIMIZE
      mode=pbAIScoreTargetMode(user,move)
      next unless [PBTargets::SingleNonUser,PBTargets::SingleOpposing].include?(mode)
      pbAIReachableTargets(user,move,pbAIOrderedFoes(user)).each do |foe|
        next if foe.index==target
        alternate=@azureAICoordinationTargetScores[[index,slot,foe.index]]
        next unless alternate.is_a?(Numeric) && alternate>0
        # An alternate target cannot inherit a benefit that the final scorer
        # rejected for this move (for example, an unsafe shared attack).
        candidates << {:user=>user,:slot=>slot,:move=>move,:target=>foe.index,
          :score=>[alternate.to_f,score.to_f].min}
      end
    end
    return candidates.sort_by {|entry| [-entry[:score],entry[:slot],entry[:target]] }.first(12)
  end

  def pbAICoordinatePair(left,right)
    lists=[pbAICoordinationCandidates(left),pbAICoordinationCandidates(right)]
    return if lists.any?(&:empty?)
    best=nil
    best_score=-Float::INFINITY
    lists[0].each do |first|
      lists[1].each do |second|
        next if first[:slot]==4 && second[:slot]==4 &&
          pbGetOwnerIndex(left)==pbGetOwnerIndex(right)
        score=pbAICoordinationPairScore(first,second)
        if score>best_score
          best_score=score
          best=[first,second]
        end
      end
    end
    return unless best
    [left,right].each_with_index do |index,side|
      partner=best[1-side]
      plan=@azureAICoordinationPlans[index]
      targets=plan[:targets] ||= Array.new(plan[:scores].length,-1)
      lists[side].group_by {|entry| entry[:slot] }.each do |slot,options|
        if slot==4 && partner[:slot]==4 && pbGetOwnerIndex(index)==pbGetOwnerIndex(partner[:user].index)
          plan[:choices].delete(4)
          plan[:scores][4]=-1
          targets[4]=-1
          plan[:z_move]=nil
          plan[:z_base_slot]=nil
          next
        end
        chosen=options.max_by {|entry| pbAICoordinationPairScore(entry,partner) }
        marginal=pbAICoordinationPairScore(chosen,partner)-partner[:score]
        plan[:scores][slot]=[marginal,0].max
        targets[slot]=chosen[:target]
      end
      chosen=best[side]
      # Preserve the selected target on a tie and let the normal selector use
      # this slot only if it is still among the legal, best-scoring choices.
      selected_marginal=[pbAICoordinationPairScore(chosen,partner)-partner[:score],0].max
      if (plan[:scores][chosen[:slot]]-selected_marginal).abs<0.00001
        targets[chosen[:slot]]=chosen[:target]
      end
      plan[:preferred_slot]=chosen[:slot]
      @azureAICoordinationSelected[index]=chosen
      @azureAICoordinationPairs[index]=partner[:user].index
    end
  end

  def pbAICoordinationDamageMove?(move,user)
    return move.basedamage>0 || (move.respond_to?(:pixie_tribute_power) && move.pixie_tribute_power(user)>0)
  end

  def pbAICoordinationFixedDamageMove?(move)
    return FIXED_DAMAGE_FUNCTIONS.include?(move.function)
  end

  def pbAICoordinationDamagingAction?(entry)
    if entry[:target]>=0 && !entry[:user].pbIsOpposing?(entry[:target]) &&
       (entry[:move].id==PBMoves::EGGBOMB || entry[:move].function==0x167)
      return false
    end
    return pbAICoordinationDamageMove?(entry[:move],entry[:user])
  end

  def pbAICoordinationTargets(entry)
    user,move=entry[:user],entry[:move]
    return [@battlers[entry[:target]]].compact if entry[:target]>=0
    mode=pbAIScoreTargetMode(user,move)
    return pbAIReachableTargets(user,move,pbAIOrderedFoes(user)) if
      [PBTargets::AllOpposing,PBTargets::AllNonUsers,PBTargets::RandomOpposing,
       PBTargets::DragonDarts,PBTargets::ThunderRaid,PBTargets::OppositeOpposing].include?(mode)
    return []
  end

  def pbAICoordinationBefore?(first,second,speeds=nil)
    a,b=first[:user],second[:user]
    priorities=[first,second].map do |entry|
      user=entry[:user]
      target=entry[:target]>=0 ? @battlers[entry[:target]] : nil
      user.hasWorkingAbility(:STALL) ? -Float::INFINITY : pbMovePriority(user,entry[:move],target)
    end
    return priorities[0]>priorities[1] if priorities[0]!=priorities[1]
    offsets=[pbAIItemPriority(a),pbAIItemPriority(b)]
    return offsets[0]>offsets[1] if offsets[0]!=offsets[1]
    speeds ||= [a.pbSpeed,b.pbSpeed]
    return @trickroom!=0 ? speeds[0]<speeds[1] : speeds[0]>speeds[1]
  end

  def pbAICoordinationDamage(entry,target)
    return 0 unless target && pbAICoordinationDamageMove?(entry[:move],entry[:user])
    @azureAICoordinationDamage ||= {}
    key=[entry[:user].index,entry[:move].object_id,target.object_id]
    owner=pbGetOwner(entry[:user].index)
    owner_skill=owner ? (owner.skill || PBTrainerAI.minimumSkill) : PBTrainerAI.bestSkill
    skill=pbAISkill(entry[:user].index,owner_skill)
    return @azureAICoordinationDamage[key] ||= pbRoughDamage(entry[:move],entry[:user],target,
      skill,entry[:move].basedamage)
  end

  def pbAICoordinationStatusGroup(move,user)
    return nil if pbAICoordinationDamageMove?(move,user)
    return :status if (PBStuff::BURNMOVE+PBStuff::PARAMOVE+PBStuff::SLEEPMOVE+
      PBStuff::POISONMOVE+[PBMoves::YAWN]).include?(move.id)
    return :confusion if PBStuff::CONFUMOVE.include?(move.id)
    return move.id if [PBMoves::TAUNT,PBMoves::ENCORE,PBMoves::TORMENT,PBMoves::DISABLE].include?(move.id)
    return nil
  end

  def pbAICoordinationPairScore(first,second)
    score=first[:score]+second[:score]
    group=FIELD_MOVES[first[:move].id]
    if group && group==FIELD_MOVES[second[:move].id] &&
       !pbAICoordinationDamageMove?(first[:move],first[:user]) &&
       !pbAICoordinationDamageMove?(second[:move],second[:user])
      score-=[first[:score],second[:score]].min*0.95
    end
    status=pbAICoordinationStatusGroup(first[:move],first[:user])
    if status && status==pbAICoordinationStatusGroup(second[:move],second[:user]) &&
       !(pbAICoordinationTargets(first)&pbAICoordinationTargets(second)).empty?
      score-=[first[:score],second[:score]].min*0.95
    end
    [[first,second],[second,first]].each do |entry,partner|
      move,user=entry[:move],entry[:user]
      other=partner[:move]
      if move.id==PBMoves::HELPINGHAND && !pbAICoordinationDamageMove?(move,user) &&
         (!pbAICoordinationDamagingAction?(partner) || pbAICoordinationFixedDamageMove?(other))
        score-=entry[:score]
      end
      if [0x4C,0x4F].include?(move.function) && !pbAICoordinationDamageMove?(move,user)
        same_target=!(pbAICoordinationTargets(entry)&pbAICoordinationTargets(partner)).empty?
        matching=pbAICoordinationDamagingAction?(partner) && !pbAICoordinationFixedDamageMove?(other)
        if matching
          target=pbAICoordinationTargets(partner).first || pbAIPrimaryTarget(partner[:user])
          physical=other.pbIsPhysical?(other.pbType(other.type,partner[:user],target))
          matching=(move.function==0x4C ? physical : !physical)
        end
        score-=entry[:score]*0.65 unless same_target && matching && pbAICoordinationBefore?(entry,partner)
      end
      if move.id==PBMoves::EARTHQUAKE && other.id==PBMoves::ROOST && pbAICoordinationBefore?(partner,entry)
        score-=pbAICoordinationRoostCost(entry,partner)
      end
      if pbAICoordinationDamagingAction?(entry) && pbAICoordinationDamagingAction?(partner) &&
         pbAICoordinationBefore?(entry,partner)
        targets=pbAICoordinationTargets(partner).select {|foe| foe && user.pbIsOpposing?(foe.index) }
        killed=targets.all? do |foe|
          next false unless pbAICoordinationTargets(entry).include?(foe)
          next false if move.pbBlockedBySubstitute?(user,foe)
          next false if foe.isbossmon && foe.shieldCount.to_i>0
          protected=pbAICanSurviveLethalHit?(foe) && !move.pbIsMultiHit
          !protected && (move.accuracy==0 || move.accuracy>=90) && pbAICoordinationDamage(entry,foe)>=foe.hp
        end
        score-=partner[:score]*0.8 if !targets.empty? && killed
      end
      score+=pbAICoordinationSpeedValue(entry,partner)
      score+=pbAICoordinationRedirectValue(entry,partner)
    end
    return score
  end

  def pbAICoordinationRoostCost(entry,partner)
    user=partner[:user]
    return 0 unless user.pbHasType?(:FLYING)
    @azureAICoordinationRoosters ||= {}
    clone=@azureAICoordinationRoosters[user.index] ||= begin
      copy=user.clone
      copy.instance_variable_set(:@effects,user.effects.dup)
      copy.instance_variable_set(:@stages,user.stages.dup)
      copy.instance_variable_set(:@pokemon,user.pokemon.clone)
      copy.effects[PBEffects::Roost]=true
      copy
    end
    return 0 if entry[:move].pbTelepathyBlocks?(entry[:user],clone)
    damage=pbAICoordinationDamage(entry,clone)
    return 100.0*damage/[user.hp,1].max
  end

  def pbAICoordinationRedirectValue(entry,partner)
    move,user=entry[:move],entry[:user]
    return 0 unless [PBMoves::FOLLOWME,PBMoves::RAGEPOWDER].include?(move.id)
    return 0 if pbAICoordinationDamageMove?(move,user)
    ally=partner[:user]
    return 0 if partner[:target]>=0 && partner[:target]!=ally.index
    return 0 unless (PBStuff::SETUPMOVE+PBStuff::DEFSETUPMOVE).include?(partner[:move].id)
    key=[:redirect,user.index,ally.index,partner[:move].object_id]
    @azureAICoordinationForecast ||= {}
    return @azureAICoordinationForecast[key] if @azureAICoordinationForecast.has_key?(key)
    value=0
    pbAIOrderedFoes(ally).each do |foe|
      next if foe.hasWorkingAbility(:OBLIVIOUS) || foe.hasWorkingAbility(:INNERFOCUS)
      next if foe.status==PBStatuses::SLEEP || foe.status==PBStatuses::FROZEN
      next if foe.effects[PBEffects::HyperBeam]>0 || foe.effects[PBEffects::Truant]
      if move.id==PBMoves::RAGEPOWDER
        next if foe.pbHasType?(:GRASS) || foe.hasWorkingAbility(:OVERCOAT) || foe.hasWorkingItem(:SAFETYGOGGLES)
      end
      threats=pbAISelectableMoves(foe).select do |attack|
        mode=pbAIScoreTargetMode(foe,attack)
        pbAICoordinationDamageMove?(attack,foe) &&
          [PBTargets::SingleNonUser,PBTargets::SingleOpposing,PBTargets::RandomOpposing,PBTargets::OppositeOpposing].include?(mode)
      end
      attack=threats.max_by {|candidate| pbAICoordinationDamage({:user=>foe,:move=>candidate},ally) }
      next unless attack
      threat={:user=>foe,:move=>attack,:target=>ally.index}
      next unless pbAICoordinationBefore?(entry,threat)
      incoming=pbAICoordinationDamage(threat,ally)
      next if incoming<ally.hp/4.0 || pbAICoordinationDamage(threat,user)>=user.hp
      value+=pbAICoordinationBefore?(threat,partner) ? 16 : 8
    end
    @azureAICoordinationForecast[key]=value
    return value
  end

  # Forecast the same turn when speed control can land before both attacks.
  # The opposing attack is estimated from available moves.
  def pbAICoordinationSpeedValue(entry,partner)
    key=[entry[:user].index,entry[:move].id,partner[:user].index,partner[:move].object_id,partner[:target]]
    @azureAICoordinationForecast ||= {}
    return @azureAICoordinationForecast[key] if @azureAICoordinationForecast.has_key?(key)
    user,move=entry[:user],entry[:move]
    ally=partner[:user]
    value=0
    tailwind=move.id==PBMoves::TAILWIND && user.pbOwnSide.effects[PBEffects::Tailwind]<=0
    icy=[PBMoves::ICYWIND,PBMoves::ELECTROWEB,PBMoves::GLACIATE].include?(move.id)
    if pbAICoordinationDamagingAction?(partner) && (tailwind || icy)
      pbAIOrderedFoes(ally).each do |foe|
        next if icy && (!pbAICoordinationTargets(entry).include?(foe) || pbAICoordinationDamage(entry,foe)<=0)
        speed=foe.pbSpeed
        if icy
          next unless respond_to?(:pbAIStatChangePreview)
          delta=pbAIStatChangePreview(move,user,foe,PBStats::SPEED,-1)
          next if delta==0
          clone=foe.clone
          clone.instance_variable_set(:@stages,foe.stages.dup)
          clone.stages[PBStats::SPEED]+=delta
          speed=clone.pbSpeed
        end
        threat=pbAISelectableMoves(foe).select {|attack| pbAICoordinationDamageMove?(attack,foe) }.max_by do |attack|
          pbAICoordinationDamage({:user=>foe,:move=>attack},ally)
        end
        next if !threat
        opposing={:user=>foe,:move=>threat,:target=>ally.index}
        before=pbAICoordinationBefore?(partner,opposing)
        after=pbAICoordinationBefore?(partner,opposing,[ally.pbSpeed*(tailwind ? 2 : 1),speed])
        next if before==after
        weight=8
        weight+=12 if pbAICoordinationDamage(partner,foe)>=foe.hp || pbAICoordinationDamage(opposing,ally)>=ally.hp
        if pbAICoordinationBefore?(entry,partner) && pbAICoordinationBefore?(entry,opposing)
          weight*=1.5
        end
        value+=after ? weight : -weight
      end
    end
    @azureAICoordinationForecast[key]=value
    return value
  end
end

PokeBattle_Battle.prepend(AzureBattleAICoordination)
