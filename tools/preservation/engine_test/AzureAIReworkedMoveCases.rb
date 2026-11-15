module AzureAIReworkedMoveCases
  def self.register(suite)
    suite.test(:AI_REWORKED_STATUS_BASELINES) do
      battle(:NONE)
      {BLUESHIFT: 15,CELEBRATE: 15,SWORDSDANCE: 35,SHELLSMASH: 40,SPORE: 60}.each do |name,score|
        equal(score,@battle.pbStatusDamage(move(name)))
      end
    end

    suite.test(:AI_REWORKED_LOCK_ON) do
      battle(:NONE,:NONE,user_moves: [:LOCKON,:FISSURE],foe_species: :LAPRAS)
      score=ai_score(:LOCKON)
      assert(score>5 && score<40,"Lock-On should value a low-accuracy follow-up (#{score})")
      @user.effects[PBEffects::LockOnMove]=true
      equal(100,@battle.pbRoughAccuracy(move(:FISSURE),@user,@foe,100))
      equal(0,ai_score(:LOCKON))
      @user.effects[PBEffects::LockOnMove]=false
      @foe.effects[PBEffects::Substitute]=15
      equal(0,ai_score(:LOCKON))
    end

    suite.test(:AI_REWORKED_CRUSH_AND_SKULL_BASH) do
      battle(:NONE,:NONE,user_moves: [:VICEGRIP,:SKULLBASH,:DEMORALIZE],foe_species: :SNORLAX)
      @foe.type1=@foe.type2=PBTypes::FIRE
      @foe.hp=(@foe.totalhp*0.6).floor
      open=ai_score(:VICEGRIP)
      @foe.pbOwnSide.effects[PBEffects::LuckyChant]=2
      screened=ai_score(:VICEGRIP)
      assert(open>screened && screened>0,"Vice Grip should favor an available secondary effect (#{open} vs #{screened})")
      assert(ai_score(:DEMORALIZE)>0,"Demoralize should be considered against a target that can be crushed")
      @foe.status=PBStatuses::POISON
      equal(0,ai_score(:DEMORALIZE))
      normal=ai_score(:SKULLBASH)
      @user.item=PBItems::POWERHERB
      assert(ai_score(:SKULLBASH)>normal,"Skull Bash should favor an immediate charge")
    end

    suite.test(:AI_REWORKED_GUARD_THREATS) do
      battle(:NONE,:NONE,user_moves: [:QUICKGUARD,:WIDEGUARD],ally: :NONE,
        foe_ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      @foe_ally.pokemon.moves[0]=PBMove.new(PBMoves::QUICKATTACK)
      @foe_ally.pokemon.moves[1]=PBMove.new(PBMoves::SURF)
      @foe_ally.pbInitialize(@foe_ally.pokemon,@foe_ally.pokemonIndex,false)
      quick=ai_score(:QUICKGUARD)
      wide=ai_score(:WIDEGUARD)
      @foe_ally.moves[0].pp=0
      assert(ai_score(:QUICKGUARD)<quick,"Quick Guard missed a reachable priority attack with PP")
      equal(wide,ai_score(:WIDEGUARD))
      @foe_ally.moves[1].pp=0
      assert(ai_score(:WIDEGUARD)<wide,"Wide Guard missed a reachable spread attack with PP")
      @user.pbOwnSide.effects[PBEffects::QuickGuard]=2
      @user.pbOwnSide.effects[PBEffects::WideGuard]=2
      equal(0,ai_score(:QUICKGUARD))
      equal(0,ai_score(:WIDEGUARD))
    end

    suite.test(:AI_REWORKED_LUCKY_CHANT) do
      battle(:NONE,:NONE,user_moves: [:LUCKYCHANT],foe_moves: [:TACKLE,:FROSTBREATH])
      active=ai_score(:LUCKYCHANT)
      @foe.moves[1].pp=0
      baseline=ai_score(:LUCKYCHANT)
      assert(active>baseline,"Lucky Chant must recognize unused guaranteed critical hits with PP")
      @user.pbOwnSide.effects[PBEffects::LuckyChant]=2
      equal(0,ai_score(:LUCKYCHANT))
    end

    suite.test(:AI_REWORKED_RAZOR_WIND) do
      battle(:NONE,:NONE,user_moves: [:RAZORWIND],ally: :NONE,foe_species: :LAPRAS)
      base=ai_score(:RAZORWIND)
      @ally.ability=PBAbilities::WINDRIDER
      assert(ai_score(:RAZORWIND)>base,"Razor Wind should value a Wind Rider ally during charge")
      @user.effects[PBEffects::TwoTurnAttack]=PBMoves::RAZORWIND
      release=ai_score(:RAZORWIND)
      @ally.ability=PBAbilities::BALLFETCH
      equal(release,ai_score(:RAZORWIND))
    end

    suite.test(:AI_REWORKED_HIT_AND_CRIT) do
      battle(:NONE,:NONE,foe_species: :LAPRAS)
      fire=move(:FIREBLAST)
      @user.stages[PBStats::ACCURACY]=-1
      accuracy=@battle.pbRoughAccuracy(fire,@user,@foe,100)
      assert((accuracy-85*2.0/3).abs<0.01,"Expected the actual accuracy stage formula, got #{accuracy}")
      @foe.effects[PBEffects::Blinded]=2
      equal(100,@battle.pbRoughAccuracy(fire,@user,@foe,100))
      @foe.effects[PBEffects::Blinded]=0
      @user.stages[PBStats::ACCURACY]=0
      @foe.level=@user.level-9
      equal(50,@battle.pbRoughAccuracy(move(:FISSURE),@user,@foe,100))
      @foe.level=@user.level-10
      equal(100,@battle.pbRoughAccuracy(move(:FISSURE),@user,@foe,100))
      @foe.effects[PBEffects::Attract]=@user.index
      equal(3,@battle.pbAICritRate(@user,@foe,fire))
      @foe.effects[PBEffects::Attract]=-1
      guaranteed=[:FLOWERTRICK,:SURGINGSTRIKES].map { |name| move(name) }
      guaranteed.each do |attack|
        equal(3,@battle.pbAICritRate(@user,@foe,attack))
        equal(true,attack.pbIsCritical?(@user,@foe))
      end
      @foe.effects[PBEffects::HardenGuard]=@battle.turncount
      equal(0,@battle.pbAICritRate(@user,@foe,fire))
      guaranteed.each do |attack|
        equal(0,@battle.pbAICritRate(@user,@foe,attack))
        equal(false,attack.pbIsCritical?(@user,@foe))
      end
    end

    suite.test(:AI_REWORKED_VARIABLE_POWER) do
      battle(:NONE,:NONE,foe_species: :LAPRAS)
      slam=move(:SLAM)
      kick=move(:TRIPLEKICK)
      @user.speed=10
      @foe.speed=300
      equal(120,@battle.pbBetterBaseDamage(slam,@user,@foe,100,slam.basedamage))
      @user.speed=400
      equal(80,@battle.pbBetterBaseDamage(slam,@user,@foe,100,slam.basedamage))
      equal(114,@battle.pbBetterBaseDamage(kick,@user,@foe,100,kick.basedamage))
      @user.ability=PBAbilities::NOGUARD
      equal(120,@battle.pbBetterBaseDamage(kick,@user,@foe,100,kick.basedamage))
    end

    suite.test(:AI_REWORKED_SWALLOW) do
      battle(:NONE,:NONE,user_moves: [:SWALLOW],foe_species: :LAPRAS)
      equal(0,ai_score(:SWALLOW))
      @user.hp=(@user.totalhp/5).floor
      base=ai_score(:SWALLOW)
      assert(base>0,"Swallow should heal with no Stockpile")
      @user.effects[PBEffects::Stockpile]=1
      assert(ai_score(:SWALLOW)>base,"Swallow should value larger possible healing with Stockpile")
      @user.effects[PBEffects::HealBlock]=2
      equal(0,ai_score(:SWALLOW))
    end

    suite.test(:AI_REWORKED_CAMOUFLAGE) do
      battle(:NONE,:NONE,user_moves: [:CAMOUFLAGE,:TACKLE],foe_species: :LAPRAS)
      $fefieldeffect=0
      equal(0,ai_score(:CAMOUFLAGE))
      $fefieldeffect=24
      camouflage=move(:CAMOUFLAGE)
      equal([:FLYING],camouflage.pbCamouflageTypeChoices)
      assert(ai_score(:CAMOUFLAGE)>0,"Camouflage should value changing the user on this field")
      equal(0,camouflage.pbEffect(@user,@user,0,[],false))
      equal(PBTypes::FLYING,@user.type1)
      equal(0,ai_score(:CAMOUFLAGE))
    end

    suite.test(:AI_REWORKED_GUARD_SETUP) do
      battle(:NONE,:NONE,user_moves: [:HARDEN,:FOCUSENERGY],foe_moves: [:TACKLE,:FROSTBREATH],foe_species: :LAPRAS)
      guarded=ai_score(:HARDEN)
      @foe.moves[1].pp=0
      assert(guarded>ai_score(:HARDEN),"Harden should value next-turn protection against critical hits with PP")
      @user.effects[PBEffects::FocusEnergy]=2
      equal(0,ai_score(:FOCUSENERGY))
      $fefieldeffect=50
      assert(ai_score(:FOCUSENERGY)>0,"The higher critical stage should be available on this field")
    end

    suite.test(:AI_REWORKED_FEVER_PITCH) do
      battle(:NONE,:NONE,user_moves: [:RAGE,:PUNISHMENT],foe_species: :SNORLAX)
      initial=ai_score(:RAGE)
      punishment=move(:PUNISHMENT)
      equal(50,@battle.pbBetterBaseDamage(punishment,@user,@foe,100,punishment.basedamage))
      @user.effects[PBEffects::FeverPitchBoost]=true
      equal(150,@battle.pbBetterBaseDamage(punishment,@user,@foe,100,punishment.basedamage))
      assert(ai_score(:RAGE)<initial,"Fever Pitch should account for the boost it already provided")
    end
  end
end
