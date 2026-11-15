module AzureAITargetCases
  def self.register(suite)
    suite.test(:TARGET_AI_KNOWS_ILLUSION_TYPING) do
      battle(:NONE,:ILLUSION,user_moves: [:PSYCHIC,:BRICKBREAK],foe_species: :ZOROARK)
      disguise=pokemon(:NONE,$Trainer,[:WATERGUN],:SQUIRTLE)
      @foe.effects[PBEffects::Illusion]=disguise
      @foe.turncount=0
      psychic=move(:PSYCHIC)
      fighting=move(:BRICKBREAK)
      equal(0,@battle.pbTypeModNoMessages(psychic.type,@user,@foe,psychic,100))
      assert(@battle.pbTypeModNoMessages(fighting.type,@user,@foe,fighting,100)>4,
             "AI should exploit Zoroark's actual Fighting weakness")
      equal(PBMoves::BRICKBREAK,ai_command[2].id)
      equal(disguise,@foe.effects[PBEffects::Illusion])
    end

    suite.test(:TARGET_AI_PROTEAN_FORECAST_IGNORES_QUEUED_MOVE) do
      battle(:NONE,:PROTEAN,user_moves: [:THUNDERBOLT,:ENERGYBALL],
             foe_moves: [:SURF,:EMBER],foe_species: :FROGADIER)
      @foe.speed=@user.speed*2
      @foe.turncount=3
      @battle.define_singleton_method(:pbAIRandom) { |limit| limit-1 }
      equal(PBTypes::WATER,@battle.pbAIForecastProteanType(@foe,@user,100))
      original=@foe.pbCurrentTypes
      assert(@battle.pbRegisterMove(@foe.index,0,false),"Could not queue Surf")
      surf_scores=ai_choices
      assert(@battle.pbRegisterMove(@foe.index,1,false),"Could not queue Ember")
      equal(surf_scores,ai_choices)
      equal(original,@foe.pbCurrentTypes)
    end

    suite.test(:TARGET_AI_OWN_MEGA_PREVIEW_RESTORES_BATTLE_STATE) do
      battle(:NONE,:NONE,foe_species: :GOLEM,foe_moves: [:EARTHQUAKE,:ROCKSLIDE])
      @foe.item=PBItems::DEMONSTONE
      assert(@battle.pbCanMegaEvolve?(@foe.index),"Rift Golem should be eligible for an AI preview")
      original=@foe.pokemon
      @foe.attack+=5
      @foe.hp-=11
      stats=[@foe.form,@foe.attack,@foe.hp,@foe.totalhp,@foe.ability,@foe.pbCurrentTypes]
      ai_choices(@foe)
      equal(original,@foe.pokemon)
      equal(stats,[ @foe.form,@foe.attack,@foe.hp,@foe.totalhp,@foe.ability,@foe.pbCurrentTypes ])
      equal(stats.first,original.form)
      equal(PBItems::DEMONSTONE,original.item)
    end

    suite.test(:TARGET_AI_IGNORES_QUEUED_PLAYER_MEGA) do
      battle(:NONE,:NONE,user_species: :GOLEM,foe_moves: [:WATERGUN,:TACKLE])
      @user.item=PBItems::DEMONSTONE
      @battle.define_singleton_method(:pbAIRandom) { |limit| limit-1 }
      before=ai_choices(@foe)
      form=@user.form
      @battle.pbRegisterMegaEvolution(@user.index)
      equal(before,ai_choices(@foe))
      equal(form,@user.form)
      equal(form,@user.pokemon.form)
    end

    suite.test(:TARGET_AI_Z_MOVE_FORECAST_USES_PARTY_ITEMS) do
      battle(:NONE,:NONE,user_moves: [:NATUREPOWER],ally: :NONE,foe_ally: :NONE)
      @battle.define_singleton_method(:pbHasZRing) { |_index| true }
      damage=@battle.checkAIdamage(@foe,@user,100,true,true).first
      @user.item=PBItems::NORMALIUMZ2
      potential=@battle.checkAIdamage(@foe,@user,100,true,true).first
      assert(potential>damage,"The held Z-Crystal should increase the forecast for Nature Power")
      @battle.pbRegisterZMove(@ally.index)
      equal(potential,@battle.checkAIdamage(@foe,@user,100,true,true).first)
    end

    suite.test(:TARGET_AI_SWITCH_CHECKS_SPARSE_PLAYER_PARTY) do
      battle(:NORMALIZE,:NONE,user_moves: [:EMBER],foe_moves: [:QUICKATTACK,:TACKLE])
      player_reserve=pokemon(:NONE,$Trainer,[:EXTREMESPEED,:AQUAJET],:AZUMARILL)
      fainted_reserve=pokemon(:NONE,$Trainer,[:TACKLE],:SQUIRTLE)
      fainted_reserve.hp=0
      $Trainer.party.concat([nil,fainted_reserve,player_reserve])
      ai_owner=@battle.pbGetOwner(@foe.index)
      ai_owner.party.push(pokemon(:NONE,ai_owner,[:WATERGUN],:SQUIRTLE))
      viewed=[]
      fake_battler=@battle.method(:pbMakeFakeBattler)
      @battle.define_singleton_method(:pbMakeFakeBattler) do |member,*args|
        viewed.push(member)
        fake_battler.call(member,*args)
      end
      original_type=@user.moves[0].type
      ai_choices(@foe)
      @battle.pbShouldSwitch?(@foe.index)
      assert(viewed.include?(player_reserve),"Switch scoring skipped the healthy player reserve")
      assert(!viewed.include?(fainted_reserve),"Switch scoring included a fainted player reserve")
      equal(original_type,@user.moves[0].type)
    end

    suite.test(:TARGET_HIGH_ID_ORDINARY_ATTACK) do
      battle(:NONE,:NONE,foe_moves: [:ALLURINGVOICE],foe_species: :SNORLAX,
             ally: :NONE,foe_ally: :NONE)
      choice=ai_command(@foe)
      equal(PBMoves::ALLURINGVOICE,choice[2].id)
      assert(choice[2].id>=1000 && !choice[2].zmove,"Expected an ordinary high-ID move")
      assert(@foe.effects[PBEffects::Attacking],"The high-ID attack was not recorded")
      equal(-1,@battle.zMove[1][0])
      equal(-1,choice[3])
      targets=[]
      @foe.pbFindUser(choice,targets)
      equal([@user.index,@ally.index].sort,targets.map(&:index).sort)
    end

    suite.test(:TARGET_ACCURACY_TIE) do
      battle(:NONE,:NONE,user_moves: [:AERIALACE,:TACKLE],foe_species: :SNORLAX)
      base_scores=[70,70,0,0]
      @battle.targets=[@foe.index,@foe.index,-1,-1]
      @battle.myChoices=[0,1]
      [73,150].each do |seed|
        srand(seed)
        @battle.scores=base_scores.dup
        @battle.pbChooseMoves(@user.index)
        choice=@battle.choices[@user.index]
        equal(PBMoves::AERIALACE,choice[2].id)
        equal(@foe.index,choice[3])
      end
    end

    suite.test(:TARGET_Z_MOVE_COMMAND) do
      battle(:NONE,:NONE,foe_moves: [:THUNDERBOLT,:CELEBRATE],foe_species: :PIKACHU)
      @foe.item=PBItems::ELECTRIUMZ2
      @user.type1=PBTypes::WATER
      @user.type2=PBTypes::WATER
      @user.spdef*=2
      choice=ai_command(@foe)
      equal(PBMoves::THUNDERBOLT,choice[2].id)
      equal(4,@foe.moves.length)
      equal(@foe.index,@battle.zMove[1][0])
      equal(@user.index,choice[3])
      assert(@foe.effects[PBEffects::Attacking],"The selected Z-Move was not recorded")
    end

    suite.test(:TARGET_Z_SCORE_TIE_CONSERVES_Z) do
      battle(:NONE,:NONE,foe_moves: [:THUNDERBOLT],foe_species: :PIKACHU)
      @foe.item=PBItems::ELECTRIUMZ2
      preview=PokeBattle_ZMoves.new(@battle,@foe,@foe.moves[0],@foe.item,false,true,0)
      @foe.moves.push(preview)
      @battle.scores=[70,0,0,0,70]
      @battle.targets=[@user.index,-1,-1,-1,@user.index]
      @battle.myChoices=[0,4]
      @battle.pbChooseMoves(@foe.index,0)
      equal(PBMoves::THUNDERBOLT,@battle.choices[@foe.index][2].id)
      equal(-1,@battle.zMove[1][0])
      assert(@foe.effects[PBEffects::Attacking],"The ordinary attack was not recorded")
    end

    suite.test(:AI_TRIPLE_LANE_REACH) do
      battle(:NONE,:NONE,user_moves: [:TACKLE,:GUST],foe_species: :GASTLY,
             ally: :NONE,foe_ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      @outer_foe.hp=1
      scores=ai_choices
      equal(@foe_ally.index,scores.fetch(:TACKLE)[1])
      equal(@outer_foe.index,scores.fetch(:GUST)[1])
      choice=ai_command
      equal(PBMoves::GUST,choice[2].id)
      equal(@outer_foe.index,choice[3])
      actual_targets=[]
      @user.pbFindUser(choice,actual_targets)
      equal([@outer_foe.index],actual_targets.map(&:index))
    end

    suite.test(:AI_TRIPLE_FRIENDLY_FIRE) do
      battle(:NONE,:NONE,user_moves: [:EARTHQUAKE,:ROCKSLIDE],ally: :NONE,
             foe_ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      @ally.hp=1
      unsafe=ai_choices
      @ally.ability=PBAbilities::TELEPATHY
      safe=ai_choices
      assert(safe.fetch(:EARTHQUAKE)[0]>unsafe.fetch(:EARTHQUAKE)[0],
             "Earthquake ignored imminent ally damage")
      equal(-1,safe.fetch(:EARTHQUAKE)[1])
      equal(-1,safe.fetch(:ROCKSLIDE)[1])
      actual_targets=[]
      @user.pbFindUser([1,0,@user.moves[0],-1],actual_targets)
      equal([@foe.index,@ally.index,@foe_ally.index].sort,actual_targets.map(&:index).sort)
    end

    suite.test(:AI_DOUBLE_FRIENDLY_FIRE) do
      battle(:NONE,:NONE,user_moves: [:EARTHQUAKE,:ROCKSLIDE],ally: :NONE,foe_ally: :NONE)
      @ally.hp=1
      unsafe=ai_choices
      @ally.ability=PBAbilities::TELEPATHY
      safe=ai_choices
      assert(safe.fetch(:EARTHQUAKE)[0]>unsafe.fetch(:EARTHQUAKE)[0],
             "Earthquake ignored imminent ally damage in doubles")
      equal(-1,safe.fetch(:EARTHQUAKE)[1])
      equal(-1,safe.fetch(:ROCKSLIDE)[1])
    end

    suite.test(:AI_EFFECTIVE_TARGETS) do
      battle(:NONE,:NONE,user_moves: [:TOXIC,:REFRACTINGSTRIKE],ally: :NONE,foe_ally: :NONE)
      clear=ai_choices
      equal(-1,clear.fetch(:TOXIC)[1])
      assert([@foe.index,@foe_ally.index].include?(clear.fetch(:REFRACTINGSTRIKE)[1]),
             "Refracting Strike did not choose a foe without screens")
      @user.type1=PBTypes::POISON
      @user.type2=PBTypes::POISON
      @user.pbOwnSide.effects[PBEffects::Reflect]=3
      screened=ai_choices
      assert([@foe.index,@foe_ally.index].include?(screened.fetch(:TOXIC)[1]),
             "Poison-type Toxic did not choose a foe")
      equal(-1,screened.fetch(:REFRACTINGSTRIKE)[1])
      actual_targets=[]
      @user.pbFindUser([1,1,@user.moves[1],-1],actual_targets)
      equal([@foe.index,@foe_ally.index].sort,actual_targets.map(&:index).sort)
    end

    suite.test(:AI_EGGBOMB_SUPPORT_TARGET) do
      battle(:NONE,:NONE,user_moves: [:EGGBOMB],foe_species: :GASTLY,ally: :NONE,
             foe_ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      @foe_ally.type1=PBTypes::GHOST
      @foe_ally.type2=PBTypes::GHOST
      @ally.hp=1
      @outer_ally.hp=1
      choice=ai_command
      equal(PBMoves::EGGBOMB,choice[2].id)
      equal(@ally.index,choice[3])
      actual_targets=[]
      @user.pbFindUser(choice,actual_targets)
      equal([@ally.index],actual_targets.map(&:index))
      @ally.effects[PBEffects::HealBlock]=2
      @foe.type1=PBTypes::NORMAL
      @foe.type2=PBTypes::NORMAL
      @foe.hp=1
      equal(@foe.index,ai_choices.fetch(:EGGBOMB)[1])
    end

    suite.test(:AI_MINIMIZE_SINGLE_FOE_TARGET) do
      battle(:NONE,:NONE,user_moves: [:MINIMIZE],foe_species: :SNORLAX)
      @user.effects[PBEffects::StatCapPositive][PBStats::EVASION]=3
      @user.stages[PBStats::EVASION]=3
      choice=ai_command
      equal(PBMoves::MINIMIZE,choice[2].id)
      equal(@foe.index,choice[3])
      actual_targets=[]
      @user.pbFindUser(choice,actual_targets)
      equal([@foe.index],actual_targets.map(&:index))
    end

    suite.test(:AI_MINIMIZE_SINGLE_SELF_TARGET) do
      battle(:NONE,:CONTRARY,user_moves: [:MINIMIZE,:TACKLE],foe_species: :SNORLAX)
      choices=ai_choices
      equal(@user.index,choices.fetch(:MINIMIZE)[1])
    end

    suite.test(:AI_CANNOT_TARGET_COMMANDER) do
      battle(:NONE,:NONE,user_moves: [:TACKLE],foe_species: :SNORLAX,foe_ally: :NONE,
             ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      @foe.hp=1
      @foe.effects[PBEffects::Commander]=@foe_ally
      equal(@foe_ally.index,ai_choices.fetch(:TACKLE)[1])
    end

    suite.test(:AI_TRIPLE_THUNDER_RAID_TARGET_POOL) do
      battle(:NONE,:NONE,user_moves: [:THUNDERRAID],foe_species: :SANDSHREW,
             ally: :NONE,foe_ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      evaluated=[]
      score,target=@battle.pbAIBestMoveTarget(@user,@user.moves[0],[@foe,@foe_ally,@outer_foe],
                                            [@ally,@outer_ally],100) do |candidate|
        evaluated.push(candidate.index)
        12
      end
      equal([@foe_ally.index],evaluated)
      equal([12,-1],[score,target])
      choice=ai_command
      equal(-1,choice[3])
      actual_targets=[]
      @user.pbFindUser(choice,actual_targets)
      equal([@foe_ally.index],actual_targets.map(&:index))
    end
  end
end
