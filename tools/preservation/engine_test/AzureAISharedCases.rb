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
  end
end
