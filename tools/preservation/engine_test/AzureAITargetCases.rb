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

    suite.test(:TARGET_Z_MOVE_COMPARES_COMPATIBLE_ATTACKS) do
      battle(:NONE,:NONE,foe_moves: [:HYPERVOICE,:HEADBUTT],user_species: :CHANSEY)
      @foe.item=PBItems::NORMALIUMZ2
      @battle.define_singleton_method(:pbHasZRing) { |_| true }
      @foe.attack=110
      @foe.spatk=35
      @user.defense=50
      @user.spdef=200
      choice=ai_command(@foe)
      equal(PBMoves::HEADBUTT,choice[2].id)
      equal(1,choice[1])
      equal(@foe.index,@battle.zMove[1][0])
      equal(4,@foe.moves.length)
    end

    suite.test(:AI_WILD_SAMPLES_LEGAL_MOVES) do
      battle(:NONE,:NONE,foe_moves: [:TACKLE,:QUICKATTACK,:BITE],wild: true)
      @foe.moves[1].pp=0
      srand(390)
      commands=32.times.map { ai_command(@foe)[2].id }
      equal([PBMoves::TACKLE,PBMoves::BITE].sort,commands.uniq.sort)
      @foe.moves[0].pp=0
      @foe.moves[2].pp=0
      equal(PBMoves::STRUGGLE,ai_command(@foe)[2].id)
    end

    suite.test(:AI_ITEM_RESERVATIONS_USE_TRAINER_INVENTORY) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE)
      item=PBItems::POTION
      @battle.choices[@foe.index]=[3,item,nil,-1]
      @battle.items=[item]
      assert(@battle.pbEnemyItemAlreadyUsed?(@foe_ally.index,item,@battle.items),
        "The second battler must respect the first battler's reservation")
      @battle.items << item
      equal(false,@battle.pbEnemyItemAlreadyUsed?(@foe_ally.index,item,@battle.items))
      other_owner=PokeBattle_Trainer.new("Other trainer",0)
      @battle.instance_variable_set(:@opponent,[@battle.opponent,other_owner])
      @battle.items=[[item],[item]]
      items=@battle.pbGetOwnerItems(@foe_ally.index)
      equal(false,@battle.pbEnemyItemAlreadyUsed?(@foe_ally.index,item,items))
    end

    suite.test(:AI_SETUP_FORECAST_RESPECTS_CAP_HEADROOM) do
      battle(:NONE,:NONE,user_moves: [:SWORDSDANCE,:TACKLE],foe_moves: [:GROWL])
      stat=PBStats::ATTACK
      setup=@user.moves[0]
      @battle.pbWithStatChangeSource([:move,setup.id]) do
        assert(@user.pbIncreaseStat(stat,2,false),"Could not establish the boost cap")
      end
      @battle.lastMoveUsed=PBMoves::GROWL
      @battle.lastMoveUser=@foe.index
      assert(@user.pbReduceStat(stat,1,false,PBMoves::GROWL,@foe),"Could not restore headroom")
      forecast=@user.clone
      forecast.stages=@user.stages.dup
      forecast.stages[stat]+=2
      @battle.pbAIClampSetupForecast(setup,@user,forecast,[stat])
      equal(2,forecast.stages[stat])
      equal(1,@user.stages[stat])
      equal(PBMoves::GROWL,@battle.lastMoveUsed)
      equal(@foe.index,@battle.lastMoveUser)
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

    suite.test(:AI_COORDINATION_LIVE_COMMANDS_AND_INVALIDATION) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE)
      ai_prepare
      [@foe,@foe_ally].each do |user|
        user.moves=[:TAILWIND,:TACKLE,nil,nil].map {|name| name ? move(name,user) : PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(0),user) }
      end
      plans={}
      [@foe,@foe_ally].each do |user|
        plans[user.index]={scores: [160,140,-1,-1],targets: [-1,@user.index,-1,-1],choices: [0,1],z_move: nil,z_base_slot: nil}
      end
      @battle.define_singleton_method(:pbAIComputeCommandPlan) {|index| plans.fetch(index) }
      @battle.choices[@user.index]=[1,0,@user.moves[0],@foe.index]
      human=@battle.choices[@user.index].dup
      @battle.pbAIPrepareTurnCoordination
      equal(human,@battle.choices[@user.index])
      left=@battle.pbAIPlannedCommand(@foe.index)
      right=@battle.pbAIPlannedCommand(@foe_ally.index)
      equal([0,1],[left[:preferred_slot],right[:preferred_slot]])
      @battle.pbDefaultChooseEnemyCommand(@foe.index)
      equal(PBMoves::TAILWIND,@battle.choices[@foe.index][2].id)
      @battle.pbDefaultChooseEnemyCommand(@foe_ally.index)
      equal(PBMoves::TACKLE,@battle.choices[@foe_ally.index][2].id)
      equal(human,@battle.choices[@user.index])
      @battle.choices[@foe.index]=[0,0,nil,-1]
      @battle.choices[@foe_ally.index]=[0,0,nil,-1]
      @battle.pbAIPrepareTurnCoordination
      @battle.choices[@foe.index]=[3,PBItems::POTION,nil,-1]
      equal(nil,@battle.pbAIPlannedCommand(@foe_ally.index))
    end

    suite.test(:AI_COORDINATION_SUPPORT_AND_TIMING) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE)
      entry=lambda {|user,name,score,target| {user: user,move: move(name,user),slot: 0,score: score,target: target} }
      helper=entry.call(@foe,:HELPINGHAND,100,-1)
      status=entry.call(@foe_ally,:GROWL,100,@user.index)
      fixed=entry.call(@foe_ally,:DRAGONRAGE,100,@user.index)
      equal(100.0,@battle.pbAICoordinationPairScore(helper,status))
      equal(100.0,@battle.pbAICoordinationPairScore(helper,fixed))
      @foe.speed=400
      @foe_ally.speed=100
      screech=entry.call(@foe,:SCREECH,100,@user.index)
      physical=entry.call(@foe_ally,:TACKLE,100,@user.index)
      special=entry.call(@foe_ally,:WATERGUN,100,@user.index)
      good=@battle.pbAICoordinationPairScore(screech,physical)
      assert(good>@battle.pbAICoordinationPairScore(screech,special),'Screech should complement physical attacks')
      @foe.speed=20
      assert(good>@battle.pbAICoordinationPairScore(screech,physical),'A late Screech must not gain immediate partner benefit')
    end

    suite.test(:AI_COORDINATION_SUBSTITUTE_AND_ALWAYS_HIT_KO) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE)
      @foe.speed=400
      @foe_ally.speed=100
      first={user: @foe,move: move(:AERIALACE,@foe),slot: 0,score: 100,target: @user.index}
      second={user: @foe_ally,move: move(:TACKLE,@foe_ally),slot: 0,score: 100,target: @user.index}
      @battle.define_singleton_method(:pbAICoordinationDamage) {|entry,target| 10000 }
      open=@battle.pbAICoordinationPairScore(first,second)
      assert(open<200,'Always-hit attacks must receive reliable KO credit')
      @user.effects[PBEffects::Substitute]=30
      equal(200.0,@battle.pbAICoordinationPairScore(first,second))
    end

    suite.test(:AI_COORDINATION_ROOST_GROUND_AND_TELEPATHY) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE)
      @foe_ally.type1=PBTypes::FLYING
      @foe_ally.type2=PBTypes::FLYING
      @foe_ally.speed=400
      @foe.speed=20
      quake={user: @foe,move: move(:EARTHQUAKE,@foe),slot: 0,score: 100,target: -1}
      roost={user: @foe_ally,move: move(:ROOST,@foe_ally),slot: 0,score: 100,target: -1}
      assert(@battle.pbAICoordinationPairScore(quake,roost)<200,'Roost before Earthquake should expose friendly damage')
      @foe_ally.ability=PBAbilities::TELEPATHY
      @battle.instance_variable_set(:@azureAICoordinationRoosters,{})
      @battle.instance_variable_set(:@azureAICoordinationDamage,{})
      equal(200.0,@battle.pbAICoordinationPairScore(quake,roost))
    end

    suite.test(:AI_COORDINATION_REDIRECTION_SETUP_RESPECTS_POWDER_AND_SPREAD) do
      battle(:NONE,:NONE,user_moves: [:TACKLE],ally: :NONE,foe_ally: :NONE)
      @ally.hp=0
      @foe.hp=500
      @user.speed=200
      @foe_ally.speed=20
      redirect={user: @foe,move: move(:RAGEPOWDER,@foe),slot: 0,score: 100,target: -1}
      setup={user: @foe_ally,move: move(:SWORDSDANCE,@foe_ally),slot: 0,score: 100,target: -1}
      ally_index=@foe_ally.index
      @battle.define_singleton_method(:pbAICoordinationDamage) {|entry,target| target.index==ally_index ? 60 : 10 }
      @foe_ally.hp=100
      assert(@battle.pbAICoordinationRedirectValue(redirect,setup)>0,'Fast redirection should protect a setup ally')
      @user.item=PBItems::SAFETYGOGGLES
      @battle.instance_variable_set(:@azureAICoordinationForecast,{})
      equal(0,@battle.pbAICoordinationRedirectValue(redirect,setup))
      @user.item=0
      @user.moves[0]=move(:SURF,@user)
      @battle.instance_variable_set(:@azureAICoordinationForecast,{})
      equal(0,@battle.pbAICoordinationRedirectValue(redirect,setup))
    end

    suite.test(:AI_COORDINATION_TRIPLES_BYPASS) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      @battle.define_singleton_method(:pbAIComputeCommandPlan) {|_| raise 'Triples should retain their existing planner' }
      @battle.pbAIPrepareTurnCoordination
      equal(nil,@battle.pbAIPlannedCommand(@foe.index))
    end

    suite.test(:AI_COORDINATION_SHARED_OWNER_Z_RESERVATION) do
      battle(:NONE,:NONE,ally: :NONE,foe_ally: :NONE)
      ai_prepare
      @battle.define_singleton_method(:pbHasZRing) {|_| true }
      plans={}
      [@foe,@foe_ally].each do |user|
        user.item=PBItems::NORMALIUMZ2
        zmove=PokeBattle_ZMoves.new(@battle,user,user.moves[0],user.item,false,true,0)
        plans[user.index]={scores: [90,-1,-1,-1,150],targets: [@user.index,-1,-1,-1,@user.index],
          choices: [0,4],z_move: zmove,z_base_slot: 0}
      end
      @battle.define_singleton_method(:pbAIComputeCommandPlan) {|index| plans.fetch(index) }
      @battle.define_singleton_method(:pbAICoordinationDamage) {|entry,target| 1 }
      @battle.pbAIPrepareTurnCoordination
      chosen=[@foe,@foe_ally].map {|user| @battle.pbAIPlannedCommand(user.index) }
      equal(1,chosen.count {|plan| plan[:preferred_slot]==4 })
      reserved=chosen.find {|plan| plan[:preferred_slot]!=4 }
      assert(!reserved[:choices].include?(4),'Marginal rescoring restored an unavailable shared Z candidate')
      equal(nil,reserved[:z_move])
      [@foe,@foe_ally].each {|user| @battle.pbDefaultChooseEnemyCommand(user.index) }
      registrations=@battle.zMove[1].count {|index| index && index>=0 }
      equal(1,registrations)
      equal([4,4],[@foe.moves.length,@foe_ally.moves.length])
    end
  end
end
