module AzureAISharedCases
  def self.register(suite)
    suite.test(:AI_MIMIC_AND_SKETCH_COPY_SCORES) do
      battle(:NONE,:NONE,user_moves: [:MIMIC,:SKETCH,:TACKLE])
      @user.speed=500
      @foe.speed=10
      [[:MIMIC,:lastMoveUsed=],[:SKETCH,:lastMoveUsedSketch=]].each do |name,set_last_move|
        @foe.public_send(set_last_move,PBMoves::PROTECT)
        status_score=ai_score(name)
        @foe.public_send(set_last_move,PBMoves::GIGAIMPACT)
        assert(ai_score(name)>status_score,"#{name} should value a powerful copy over a status move")
        [PBMoves::TACKLE,PBMoves::SKETCH,-1].each do |uncopyable|
          @foe.public_send(set_last_move,uncopyable)
          equal(0,ai_score(name))
        end
      end
      @foe.lastMoveUsed=PBMoves::METRONOME
      equal(0,ai_score(:MIMIC))
    end

    suite.test(:AI_FLOWER_GARDEN_DAMAGE_DOES_NOT_ADVANCE_STAGE) do
      battle(:NONE,:NONE,user_moves: [:PETALBLIZZARD])
      $fefieldeffect=33
      candidate=move(:PETALBLIZZARD)
      damage=[0,2,4].map do |stage|
        $fecounter=stage
        result=@battle.pbRoughDamage(candidate,@user,@foe,100,candidate.basedamage)
        equal(stage,$fecounter)
        result
      end
      assert(damage[0]<damage[1] && damage[1]<damage[2],"Flower Garden damage should follow its current stage")
    end

    suite.test(:AI_STARLIGHT_ARENA_DRACO_METEOR_DAMAGE) do
      battle(:NONE,:NONE,user_moves: [:DRACOMETEOR])
      candidate=move(:DRACOMETEOR)
      damage=[0,34].map do |field|
        $fefieldeffect=field
        @battle.pbRoughDamage(candidate,@user,@foe,100,candidate.basedamage)
      end
      assert(damage[1]>=damage[0]*1.5,"Starlight Arena should boost Draco Meteor")
    end

    suite.test(:MODERN_HAZARD_ATTACK) do
      battle(:NONE,:NONE,user_moves: [:STONEAXE,:ROCKTOMB])
      @battle.party2.push(pokemon(:NONE,@battle.opponent,[:TACKLE]))
      open=ai_score(:STONEAXE)
      @foe.pbOwnSide.effects[PBEffects::StealthRock]=true
      assert(open>ai_score(:STONEAXE),"A fresh hazard should improve Stone Axe's score")
    end

    suite.test(:MODERN_RESIDUAL_ATTACK) do
      battle(:NONE,:NONE,user_moves: [:SALTCURE],foe_species: :LAPRAS)
      unmarked=ai_score(:SALTCURE)
      @foe.effects[PBEffects::SaltCure]=true
      assert(unmarked>ai_score(:SALTCURE),"Salt Cure should value applying its residual damage once")
    end

    suite.test(:ALLURING_VOICE_AND_THUNDER_RAID) do
      battle(:NOGUARD,:NONE,user_moves: [:ALLURINGVOICE,:THUNDERRAID],foe_species: :LAPRAS)
      voice=move(:ALLURINGVOICE)
      raid=move(:THUNDERRAID)
      equal(false,voice.pbIsMultiHit)
      @foe.azureStatsRaisedThisRound=true
      assert(voice.pbAdditionalEffect(@user,@foe),"Alluring Voice should confuse a target that raised a stat")
      assert(@foe.effects[PBEffects::Confusion]>0,"The target should be confused")
      equal(PBTargets::ThunderRaid,@user.pbTarget(raid))
      equal(5,raid.pbNumHits(@user))
      equal(100,@battle.pbBetterBaseDamage(raid,@user,@foe,100,raid.basedamage))
    end

    suite.test(:EGGBOMB_HEALING) do
      battle(:GRENADIER,:NONE,ally: :NONE,user_moves: [:EGGBOMB])
      equal(0,ai_score(:EGGBOMB,@user,@ally))
      @ally.hp=1
      assert(ai_score(:EGGBOMB,@user,@ally)>40,"Egg Bomb should value healing a low-HP ally")
      @ally.effects[PBEffects::HealBlock]=2
      equal(0,ai_score(:EGGBOMB,@user,@ally))
      assert(ai_score(:EGGBOMB)>0,"Egg Bomb should still damage an opponent")
    end

    suite.test(:AI_FULL_KNOWLEDGE_ACTIVE_AND_RESERVE) do
      battle(:NONE,:NONE,user_moves: [:TACKLE,:PROTECT],foe_moves: [:THUNDERCLAP],
        outer_ally: :NONE,outer_foe: :NONE)
      equal([PBMoves::TACKLE,PBMoves::PROTECT],@battle.pbAIKnownMoves(@user).map(&:id))
      @user.moves[1].pp=0
      equal([PBMoves::TACKLE,PBMoves::PROTECT],@battle.pbAIKnownMoves(@user).map(&:id))
      equal(0,@battle.pbAIKnownMoves(@user).last.pp)
      reserve=pokemon(:STURDY,@battle.player,[:FLASHCANNON,:ROAR],:AGGRON)
      reserve.item=PBItems::LEFTOVERS
      reserve.moves[0].pp=3
      @battle.party1.push(reserve)
      party_moves=@battle.pbAIKnownPartyMoves(@user.index,3)
      equal([PBMoves::FLASHCANNON,PBMoves::ROAR],party_moves.map(&:id))
      equal(3,party_moves.first.pp)
      equal(PBTypes::STEEL,party_moves.first.type)
      equal(PBSpecies::AGGRON,party_moves.first.user.species)
      equal(PBItems::LEFTOVERS,party_moves.first.user.item)
      equal(PBAbilities::STURDY,party_moves.first.user.ability)
      equal([],@battle.pbAIKnownPartyMoves(@user.index,4))
      assert(@battle.pbShiftBattlers(@outer_ally.index,@ally.index),"Could not move the battler between lanes")
      equal([PBMoves::TACKLE],@battle.pbAIKnownMoves(@outer_ally).map(&:id))
      @battle.pbReplace(@user.index,3)
      equal([PBMoves::FLASHCANNON,PBMoves::ROAR],@battle.pbAIKnownMoves(@user).map(&:id))
      equal(@user.moves[0],@battle.pbAIKnownPartyMoves(@user.index,3).first)
      equal([PBMoves::TACKLE,PBMoves::PROTECT],@battle.pbAIKnownPartyMoves(@user.index,0).map(&:id))
    end

    suite.test(:AI_FULL_KNOWLEDGE_WITHOUT_QUEUED_ACTIONS) do
      battle(:NONE,:NONE,user_moves: [:TACKLE,:PROTECT],user_species: :LAPRAS,
        foe_moves: [:THUNDERCLAP,:CELEBRATE],foe_species: :PIKACHU)
      @foe.spatk=500
      score=ai_score(:THUNDERCLAP,@foe,@user)
      low_skill=ai_score(:THUNDERCLAP,@foe,@user,PBTrainerAI.minimumSkill)
      assert(score>0,"An unrevealed damaging move should count as a potential Thunderclap target")
      @battle.choices[@user.index]=[1,1,@user.moves[1],@user.index]
      equal(score,ai_score(:THUNDERCLAP,@foe,@user))
      protected_choices=ai_choices(@foe)
      assert(protected_choices[:THUNDERCLAP][0]>protected_choices[:CELEBRATE][0],
        "The AI should favor the potential knockout when selecting its command")
      equal(PBMoves::THUNDERCLAP,ai_command(@foe)[2].id)
      @battle.choices[@user.index]=[1,0,@user.moves[0],@foe.index]
      equal(score,ai_score(:THUNDERCLAP,@foe,@user))
      equal(protected_choices,ai_choices(@foe))
      equal(PBMoves::THUNDERCLAP,ai_command(@foe)[2].id)
      @user.effects[PBEffects::Encore]=2
      @user.effects[PBEffects::EncoreIndex]=1
      assert(ai_score(:THUNDERCLAP,@foe,@user)<score,"Encore into Protect should remove the legal attack threat")
      @user.effects[PBEffects::Encore]=0
      @user.moves[0].pp=0
      assert(ai_score(:THUNDERCLAP,@foe,@user)<score,"A known move with no PP should no longer count as a threat")
      assert(ai_score(:THUNDERCLAP,@foe,@user,PBTrainerAI.minimumSkill)<low_skill,
        "Minimum-skill scoring should use the unrevealed moveset and its remaining PP")
      @user.lastRoundMoved=@battle.turncount
      equal(0,ai_score(:THUNDERCLAP,@foe,@user))
    end

    suite.test(:AI_FULL_KNOWLEDGE_PRESERVES_JAW_LOCK) do
      battle(:NONE,:NONE,user_moves: [:JAWLOCK],foe_moves: [:SPIKES])
      @battle.party1.push(pokemon(:NONE,@battle.player,[:RAPIDSPIN]))
      assert(hit(:JAWLOCK)>0,"Jaw Lock needs to hit for this setup")
      equal(true,@user.effects[PBEffects::JawLock])
      equal(true,@foe.effects[PBEffects::JawLock])
      equal([PBMoves::RAPIDSPIN],@battle.pbAIKnownPartyMoves(@user.index,1).map(&:id))
      ai_choices(@foe)
      equal(true,@user.effects[PBEffects::JawLock])
      equal(true,@foe.effects[PBEffects::JawLock])
      equal(@user.index,@foe.effects[PBEffects::JawLockUser])
    end

    suite.test(:AI_FULL_KNOWLEDGE_HELD_ITEM) do
      battle(:NONE,:NONE,user_moves: [:CELEBRATE],user_species: :RATTATA,
        foe_moves: [:TACKLE],foe_species: :SNORLAX)
      @foe.attack=500
      attack=@foe.moves[0]
      without_sash=@battle.pbAIRoughDamagePercentForTarget(attack,@foe,@user,100)
      @user.item=PBItems::FOCUSSASH
      with_sash=@battle.pbAIRoughDamagePercentForTarget(attack,@foe,@user,100)
      assert(with_sash<without_sash,"The AI should account for an unactivated player's Focus Sash")
      @user.effects[PBEffects::Embargo]=2
      equal(without_sash,@battle.pbAIRoughDamagePercentForTarget(attack,@foe,@user,100))
    end

    suite.test(:AI_FULL_KNOWLEDGE_RESERVE_HAZARD_CLEAR) do
      battle(:NONE,:NONE,user_moves: [:CELEBRATE],foe_moves: [:SPIKES,:TACKLE],user_species: :LAPRAS)
      @foe.attack=140
      reserve=pokemon(:NONE,@battle.player,[:CELEBRATE],:SANDSLASH)
      2.times { @battle.party1.push(pokemon(:NONE,@battle.player,[:CELEBRATE])) }
      @battle.party1.push(reserve)
      unopposed=ai_score(:SPIKES,@foe,@user)
      unopposed_choices=ai_choices(@foe)
      equal(PBMoves::SPIKES,ai_command(@foe)[2].id)
      reserve.moves[0]=PBMove.new(PBMoves::RAPIDSPIN)
      assert(unopposed>ai_score(:SPIKES,@foe,@user),
        "The AI should account for hazard removal in an unrevealed reserve moveset")
      contestable_choices=ai_choices(@foe)
      assert(unopposed_choices[:SPIKES][0]>unopposed_choices[:TACKLE][0] &&
        contestable_choices[:SPIKES][0]<contestable_choices[:TACKLE][0],
        "Expected Spikes without removal and Tackle with removal, got #{unopposed_choices} and #{contestable_choices}")
      equal(PBMoves::TACKLE,ai_command(@foe)[2].id)
      reserve.moves[0].pp=0
      equal(unopposed,ai_score(:SPIKES,@foe,@user))
      reserve.moves[0].pp=1
      reserve.hp=0
      without_reserve=ai_score(:SPIKES,@foe,@user)
      reserve.moves[0]=PBMove.new(PBMoves::CELEBRATE)
      equal(without_reserve,ai_score(:SPIKES,@foe,@user))
    end

    suite.test(:AI_FULL_KNOWLEDGE_ILLUSION) do
      battle(:ILLUSION,:NONE,user_moves: [:SHADOWBALL],user_species: :ZOROARK,
        foe_moves: [:CLOSECOMBAT,:ZENHEADBUTT],foe_species: :GALLADE)
      disguise=pokemon(:NONE,@battle.player,[:CELEBRATE],:GARDEVOIR)
      @battle.party1.push(disguise)
      @user.effects[PBEffects::Illusion]=disguise
      equal(PBSpecies::GARDEVOIR,@user.species)
      equal(PBSpecies::ZOROARK,@user.real_species)
      equal([PBMoves::SHADOWBALL],@battle.pbAIKnownMoves(@user).map(&:id))
      equal([PBMoves::CELEBRATE],@battle.pbAIKnownPartyMoves(@user.index,1).map(&:id))
      zen=@foe.moves[1]
      equal(0,@battle.pbTypeModNoMessages(zen.type,@foe,@user,zen,PBTrainerAI.minimumSkill))
      assert(ai_score(:CLOSECOMBAT,@foe,@user)>ai_score(:ZENHEADBUTT,@foe,@user),
        "The AI should use the real Dark-type matchup without breaking the visible illusion")
      equal(PBSpecies::GARDEVOIR,@user.species)
      equal(PBMoves::CLOSECOMBAT,ai_command(@foe)[2].id)
    end

    suite.test(:PRIORITY_UNDER_TRICK_ROOM) do
      battle(:NONE,:NONE,user_species: :SHUCKLE,foe_species: :ELECTRODE)
      @battle.trickroom=4
      assert(@battle.pbAIActsBefore?(@user,@foe,100,move(:TACKLE),move(:TACKLE,@foe)),
        "The slow battler should lead inside its priority bracket")
      assert(!@battle.pbAIActsBefore?(@user,@foe,100,move(:TACKLE),move(:QUICKATTACK,@foe)),
        "Trick Room must preserve higher-priority brackets")
      @foe.item=PBItems::LAGGINGTAIL
      @user.item=PBItems::FULLINCENSE
      @user.effects[PBEffects::AbsoluteZeroTurn]=@battle.turncount
      assert(!@battle.pbAIActsBefore?(@user,@foe,100,move(:TACKLE),move(:TACKLE,@foe)),
        "Absolute Zero should act after other effects in the same priority bracket")
    end

    suite.test(:MODERN_MULTI_HIT_AND_POWER) do
      battle(:NONE,:NONE,user_moves: [:FICKLEBEAM,:SURGINGSTRIKES,:TACHYONCUTTER,:RAGEFIST])
      expected={ FICKLEBEAM: 1.3, SURGINGSTRIKES: 3, TACHYONCUTTER: 2, RAGEFIST: 1 }
      expected.each do |name,multiplier|
        attack=move(name)
        equal((attack.basedamage*multiplier).round,
          @battle.pbBetterBaseDamage(attack,@user,@foe,100,attack.basedamage))
      end
    end

    suite.test(:STATCAP_PREVIEW_AND_REUSE_AFTER_HAZE) do
      battle(:NONE,:NONE,user_moves: [:SWORDSDANCE,:HOWL,:HAZE,:TACKLE])
      candidate=move(:SWORDSDANCE)
      equal(2,@battle.pbAIStatChangePreview(candidate,@user,@user,PBStats::ATTACK,2))
      hit(:SWORDSDANCE,@user,@user)
      equal(2,@user.stages[PBStats::ATTACK])
      equal(0,@battle.pbAIStatChangePreview(candidate,@user,@user,PBStats::ATTACK,2))
      hit(:HOWL,@user,@user)
      equal(3,@user.stages[PBStats::ATTACK])
      hit(:HAZE,@user,@user)
      before=Marshal.dump([@user.stages,@user.effects[PBEffects::StatCapContributors],@user.effects[PBEffects::StatCapPositive]])
      equal(2,@battle.pbAIStatChangePreview(candidate,@user,@user,PBStats::ATTACK,2))
      equal(before,Marshal.dump([@user.stages,@user.effects[PBEffects::StatCapContributors],@user.effects[PBEffects::StatCapPositive]]))
    end
    suite.test(:STATCAP_SOURCE_DISTINCTION_AND_WRAPPER) do
      battle(:NONE,:NONE,user_moves: [:SWORDSDANCE,:TACKLE])
      @battle.lastMoveUsed=PBMoves::PROTECT
      @battle.lastMoveUser=@foe.index
      candidate=move(:SWORDSDANCE)
      fresh=ai_score(:SWORDSDANCE)
      assert(fresh>0,'fresh setup must be eligible')
      hit(:SWORDSDANCE,@user,@user)
      @battle.lastMoveUsed=PBMoves::PROTECT
      @battle.lastMoveUser=@foe.index
      equal(0,ai_score(:SWORDSDANCE))
      equal(PBMoves::PROTECT,@battle.lastMoveUsed)
      equal(@foe.index,@battle.lastMoveUser)
      previous=[:item,PBItems::MIRRORHERB]
      @battle.pbWithStatChangeSource(previous) do
        ai_score(:SWORDSDANCE)
        equal(previous,@battle.statChangeSource)
        @battle.instance_variable_set(:@aiStatMoveContext,[candidate,@user])
        assert(@user.pbCanIncreaseStatStage?(PBStats::ATTACK,false),'independent item source can expand cap')
        @battle.instance_variable_set(:@aiStatMoveContext,nil)
      end
    end
    suite.test(:STATCAP_SUBSTITUTE_SOUND_AND_STALE_HISTORY) do
      battle(:NONE,:NONE,user_moves: [:TAILWHIP,:METALSOUND])
      @foe.effects[PBEffects::Substitute]=20
      @battle.lastMoveUsed=PBMoves::TACKLE
      @battle.lastMoveUser=@foe.index
      equal(0,@battle.pbAIStatChangePreview(move(:TAILWHIP),@user,@foe,PBStats::DEFENSE,-1))
      equal(-2,@battle.pbAIStatChangePreview(move(:METALSOUND),@user,@foe,PBStats::SPDEF,-2))
      equal(PBMoves::TACKLE,@battle.lastMoveUsed)
      equal(@foe.index,@battle.lastMoveUser)
    end
    suite.test(:STATCAP_MIST_INFILTRATOR_SOURCE) do
      battle(:INFILTRATOR,:NONE,user_moves: [:TAILWHIP])
      @foe.pbOwnSide.effects[PBEffects::Mist]=4
      @battle.lastMoveUsed=PBMoves::TACKLE
      @battle.lastMoveUser=@foe.index
      equal(-1,@battle.pbAIStatChangePreview(move(:TAILWHIP),@user,@foe,PBStats::DEFENSE,-1))
      @user.ability=PBAbilities::BALLFETCH
      equal(0,@battle.pbAIStatChangePreview(move(:TAILWHIP),@user,@foe,PBStats::DEFENSE,-1))
    end
    suite.test(:STATCAP_CONTRARY_SIMPLE_AND_SPEED_DROP) do
      battle(:SIMPLE,:CONTRARY,user_moves: [:SWORDSDANCE,:ICYWIND])
      equal(3,@battle.pbAIStatChangePreview(move(:SWORDSDANCE),@user,@user,PBStats::ATTACK,2))
      equal(1,@battle.pbAIStatChangePreview(move(:ICYWIND),@user,@foe,PBStats::SPEED,-1))
      @foe.ability=PBAbilities::SIMPLE
      equal(-2,@battle.pbAIStatChangePreview(move(:ICYWIND),@user,@foe,PBStats::SPEED,-1))
      @battle.pbWithStatChangeSource([:move,PBMoves::ICYWIND]) do
        @battle.lastMoveUsed=PBMoves::ICYWIND
        @battle.lastMoveUser=@user.index
        @foe.pbReduceStat(PBStats::SPEED,1,false,PBMoves::ICYWIND,@user)
      end
      equal(-2,@foe.stages[PBStats::SPEED])
      equal(0,@battle.pbAIStatChangePreview(move(:ICYWIND),@user,@foe,PBStats::SPEED,-1))
    end
    suite.test(:STATCAP_SECONDARY_DAMAGE_REMAINS) do
      battle(:NONE,:NONE,user_moves: [:POWERUPPUNCH])
      candidate=move(:POWERUPPUNCH)
      hit(:POWERUPPUNCH)
      equal(0,@battle.pbAIStatChangePreview(candidate,@user,@user,PBStats::ATTACK,1))
      assert(ai_score(:POWERUPPUNCH)>0,'spent stat secondary must not erase damage')
    end
    suite.test(:STATCAP_MULTISTAT_AND_OTHER_TARGET) do
      battle(:NONE,:NONE,ally: :NONE,user_moves: [:DECORATE,:TACKLE])
      candidate=move(:DECORATE)
      hit(:DECORATE,@user,@ally)
      equal(0,@battle.pbAIStatChangePreview(candidate,@user,@ally,PBStats::ATTACK,2))
      equal(0,@battle.pbAIStatChangePreview(candidate,@user,@ally,PBStats::SPATK,2))
      equal(2,@battle.pbAIStatChangePreview(candidate,@user,@user,PBStats::ATTACK,2))
      equal(2,@battle.pbAIStatChangePreview(candidate,@user,@user,PBStats::SPATK,2))
    end
    suite.test(:STATCAP_HAZE_SIGNED_AND_MISTY_BONUS) do
      battle(:NONE,:NONE,user_moves: [:HAZE,:TACKLE])
      @user.stages[PBStats::ATTACK]=2
      equal(0,ai_score(:HAZE))
      @user.stages[PBStats::ATTACK]=0
      @foe.stages[PBStats::ATTACK]=2
      assert(ai_score(:HAZE)>0,'erase useful foe boost')
      @foe.stages[PBStats::ATTACK]=0
      $fefieldeffect=3
      assert(ai_score(:HAZE)>0,'Misty Haze retains custom defense benefits')
    end
    suite.test(:STATCAP_UNAWARE_STOREDPOWER_AND_SPEED) do
      battle(:NONE,:UNAWARE,user_moves: [:SWORDSDANCE,:AGILITY,:STOREDPOWER,:TACKLE])
      candidate=move(:SWORDSDANCE)
      equal(1,@battle.pbAIUnawareSetupMultiplier(candidate,@user))
      @user.moves[2]=move(:TACKLE)
      equal(0.05,@battle.pbAIUnawareSetupMultiplier(candidate,@user))
      equal(1,@battle.pbAIUnawareSetupMultiplier(move(:AGILITY),@user))
      equal(1,@battle.pbAIUnawareSetupMultiplier(move(:SHARPEN),@user))
      equal(1,@battle.pbAIUnawareSetupMultiplier(move(:MEDITATE),@user))
      @user.moves=[move(:SWORDSDANCE),move(:STOREDPOWER),move(:PROTECT),move(:RECOVER)]
      assert(ai_score(:SWORDSDANCE)>0,'Swords Dance can increase Stored Power base damage without physical attacks')
    end
    suite.test(:STATCAP_HELPING_HAND_RECIPIENT) do
      battle(:NONE,:NONE,ally: :NONE,user_moves: [:HELPINGHAND,:TACKLE])
      assert(ai_score(:HELPINGHAND,@user,@ally)>0,'awake attacker can benefit')
      @ally.status=PBStatuses::SLEEP
      @ally.statusCount=3
      equal(0,ai_score(:HELPINGHAND,@user,@ally))
      @ally.moves[1]=move(:SLEEPTALK,@ally)
      assert(ai_score(:HELPINGHAND,@user,@ally)>0,'Sleep Talk may call a boosted attack')
      @ally.effects[PBEffects::HyperBeam]=1
      equal(0,ai_score(:HELPINGHAND,@user,@ally))
    end
    suite.test(:STATCAP_CLERIC_HEALTHY_GUTS) do
      battle(:NONE,:NONE,user_moves: [:HEALBELL])
      patient=pokemon(:NONE,@battle.player,[:TACKLE]);patient.status=PBStatuses::POISON
      healthy=pokemon(:NONE,@battle.player,[:TACKLE])
      @battle.party1.push(patient,healthy)
      normal=ai_score(:HEALBELL)
      healthy.abilityoverride=PBAbilities::GUTS
      equal(normal,ai_score(:HEALBELL))
      patient.hp=0
      equal(0,ai_score(:HEALBELL))
    end
    suite.test(:STATCAP_SCREEN_OVERLAP_AND_CATEGORY) do
      battle(:NONE,:NONE,user_moves: [:REFLECT,:LIGHTSCREEN,:AURORAVEIL],foe_moves: [:PSYCHIC])
      @foe.spatk=300;@foe.attack=50
      assert(ai_score(:LIGHTSCREEN)>ai_score(:REFLECT),'prefer relevant screen category')
      @user.pbOwnSide.effects[PBEffects::AuroraVeil]=4
      equal(0,ai_score(:REFLECT));equal(0,ai_score(:LIGHTSCREEN))
      @user.pbOwnSide.effects[PBEffects::AuroraVeil]=0
      @battle.instance_variable_set(:@weather,PBWeather::HAIL)
      open=ai_score(:AURORAVEIL)
      @user.pbOwnSide.effects[PBEffects::Reflect]=4
      @user.pbOwnSide.effects[PBEffects::LightScreen]=4
      assert(ai_score(:AURORAVEIL)<open,'overlapping screens reduce Veil value')
    end
    suite.test(:STATCAP_Z_SOURCE_AND_CONTRARY) do
      battle(:CONTRARY,:NONE,user_moves: [:SPLASH,:TACKLE])
      splash=move(:SPLASH)
      equal(3,@battle.pbAIStatChangePreview(splash,@user,@user,PBStats::ATTACK,3,[:move,splash.id,:z_status]))
      @battle.pbWithStatChangeSource([:move,splash.id,:z_status]) { @user.pbIncreaseStat(PBStats::ATTACK,3,false,nil,nil,false,true,false) }
      equal(3,@user.stages[PBStats::ATTACK])
      equal(0,@battle.pbAIStatChangePreview(splash,@user,@user,PBStats::ATTACK,3,[:move,splash.id,:z_status]))
      @user.stages[PBStats::ATTACK]=0
      equal(-3,@battle.pbAIStatChangePreview(splash,@user,@user,PBStats::ATTACK,3))
      assert(@user.effects[PBEffects::StatCapContributors].has_key?([:move,splash.id,:z_status]),'Z source recorded separately')
      assert(!@user.effects[PBEffects::StatCapContributors].has_key?([:move,splash.id]),'ordinary source not spent')
    end

    suite.test(:STATCAP_SAME_MOVE_TWO_USERS_AND_SPREAD_RECIPIENTS) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE,user_moves: [:TAILWHIP])
      @ally.moves[0]=move(:TAILWHIP,@ally)
      hit(:TAILWHIP,@user,@foe)
      equal(0,@battle.pbAIStatChangePreview(move(:TAILWHIP,@ally),@ally,@foe,PBStats::DEFENSE,-1))
      equal(-1,@battle.pbAIStatChangePreview(move(:TAILWHIP,@ally),@ally,@foe_ally,PBStats::DEFENSE,-1))
      @battle.lastMoveUsed=PBMoves::TACKLE
      @battle.lastMoveUser=@foe.index
      snapshots=@battle.battlers.map { |b| Marshal.dump([b.stages,b.effects[PBEffects::StatCapContributors]]) }
      ai_choices(@ally)
      equal(snapshots,@battle.battlers.map { |b| Marshal.dump([b.stages,b.effects[PBEffects::StatCapContributors]]) })
      equal(PBMoves::TACKLE,@battle.lastMoveUsed)
      equal(@foe.index,@battle.lastMoveUser)
    end
    suite.test(:STATCAP_SPEED_DROP_UTILITY_RETAINS_DAMAGE) do
      battle(:NONE,:NONE,user_moves: [:ICYWIND])
      @user.spatk=100;@foe.spdef=100
      @user.speed=100;@foe.speed=150
      initial=ai_score(:ICYWIND)
      hit(:ICYWIND)
      @foe.hp=@foe.totalhp
      spent=ai_score(:ICYWIND)
      assert(initial>spent,"fresh speed drop must have utility: #{initial} > #{spent}")
      assert(spent>0,'spent speed drop retains attack damage')
    end
    suite.test(:STATCAP_TARGETED_Z_BONUS_AND_ACTIVATION) do
      battle(:CONTRARY,:NONE,user_moves: [:THUNDERWAVE,:TACKLE])
      @user.item=PBItems::ELECTRIUMZ2
      z=PokeBattle_ZMoves.new(@battle,@user,@user.moves[0],@user.item,false,true,0)
      assert(@battle.pbAIZStatBonus(z,@user)>0,'targeted Z move has a separate cap-aware self bonus')
      @battle.pbRegisterMove(@user.index,0,false)
      @battle.pbRegisterTarget(@user.index,@foe.index)
      @battle.pbUseZMove(@user.index,@user.moves[0],@user.item,0)
      equal(1,@user.stages[PBStats::SPDEF])
      equal(0,@battle.pbAIZStatBonus(z,@user))
      assert(@user.effects[PBEffects::StatCapContributors].has_key?([:move,PBMoves::THUNDERWAVE,:z_status]),'targeted Z activation uses distinct source')
      equal(nil,@battle.statChangeSource)
      battle(:CONTRARY,:NONE,user_moves: [:SPLASH,:TACKLE])
      @user.item=PBItems::NORMALIUMZ2
      @battle.pbRegisterMove(@user.index,0,false)
      @battle.pbRegisterTarget(@user.index,@user.index)
      @battle.pbUseZMove(@user.index,@user.moves[0],@user.item,0)
      equal(3,@user.stages[PBStats::ATTACK])
      assert(@user.effects[PBEffects::StatCapContributors].has_key?([:move,PBMoves::SPLASH,:z_status]),'self Z activation uses distinct source')
    end
    suite.test(:STATCAP_NESTED_ABILITY_SOURCE_RESTORES_MOVE) do
      battle(:NONE,:WELLBAKEDBODY,user_moves: [:EMBER])
      attack=move(:EMBER)
      source=[:move,attack.id]
      @battle.pbWithStatChangeSource(source) do
        @battle.instance_variable_set(:@aiStatMoveContext,[attack,@user])
        assert(attack.pbApplyTypeAbsorption(PBTypes::FIRE,@user,@foe),'Fire absorption should trigger')
        equal(source,@battle.statChangeSource)
        @battle.instance_variable_set(:@aiStatMoveContext,nil)
      end
      equal(2,@foe.stages[PBStats::DEFENSE])
      assert(@foe.effects[PBEffects::StatCapContributors].has_key?([:ability,PBAbilities::WELLBAKEDBODY]),'ability has independent cap key')
      assert(!@foe.effects[PBEffects::StatCapContributors].has_key?(source),'trigger move did not spend stat contribution')
      equal(nil,@battle.statChangeSource)
    end

    suite.test(:STATCAP_STALE_SUBSTITUTE_HIT_STATE) do
      battle(:NONE,:NONE,user_moves: [:TAILWHIP,:METALSOUND])
      @foe.damagestate.substitute=true
      @foe.effects[PBEffects::Substitute]=0
      equal(-1,@battle.pbAIStatChangePreview(move(:TAILWHIP),@user,@foe,PBStats::DEFENSE,-1))
      equal(true,@foe.damagestate.substitute)
      @foe.effects[PBEffects::Substitute]=20
      equal(0,@battle.pbAIStatChangePreview(move(:TAILWHIP),@user,@foe,PBStats::DEFENSE,-1))
      equal(-2,@battle.pbAIStatChangePreview(move(:METALSOUND),@user,@foe,PBStats::SPDEF,-2))
      equal(true,@foe.damagestate.substitute)
      equal(20,@foe.effects[PBEffects::Substitute])
    end

    suite.test(:STATCAP_Z_BULK_UP_MATCHING_STAT_OVERLAP) do
      battle(:NONE,:NONE,user_moves: [:BULKUP,:SWORDSDANCE,:TACKLE])
      @user.item=PBItems::FIGHTINIUMZ2
      z=PokeBattle_ZMoves.new(@battle,@user,@user.moves[0],@user.item,false,true,0)
      equal(18,@battle.pbAIZStatBonus(z,@user))
      hit(:SWORDSDANCE,@user,@user)
      equal(2,@user.stages[PBStats::ATTACK])
      before=Marshal.dump([@user.stages,@user.effects[PBEffects::StatCapPositive],@user.effects[PBEffects::StatCapContributors]])
      equal(0,@battle.pbAIZStatBonus(z,@user))
      equal(before,Marshal.dump([@user.stages,@user.effects[PBEffects::StatCapPositive],@user.effects[PBEffects::StatCapContributors]]))
      @battle.pbRegisterMove(@user.index,0,false)
      @battle.pbRegisterTarget(@user.index,@user.index)
      @battle.pbUseZMove(@user.index,@user.moves[0],@user.item,0)
      equal(3,@user.stages[PBStats::ATTACK])
      equal(1,@user.stages[PBStats::DEFENSE])
      assert(@user.effects[PBEffects::StatCapContributors][[:move,PBMoves::BULKUP,:z_status]].has_key?(PBStats::ATTACK),'Z raised Attack to the shared ceiling')
      assert(!@user.effects[PBEffects::StatCapContributors][[:move,PBMoves::BULKUP]].has_key?(PBStats::ATTACK),'normal effect did not add Attack twice')
    end
  end
end
