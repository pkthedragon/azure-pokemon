module AzureCustomMovesEarly
  module Actions
    def use_move(name,target=@foe,user=@user)
      slot=user.moves.index { |attack| attack.id==PBMoves.const_get(name) }
      assert(@battle.pbRegisterMove(user.index,slot,false),"Could not select #{name}")
      @battle.pbRegisterTarget(user.index,target.index)
      @battle.pbAttackPhase
      @battle.instance_variable_set(:@turncount,@battle.turncount+1)
    end

    def register_early_move(name,target,user)
      slot=user.moves.index { |attack| attack.id==PBMoves.const_get(name) }
      assert(@battle.pbRegisterMove(user.index,slot,false),"Could not select #{name}")
      @battle.pbRegisterTarget(user.index,target.index)
    end
  end

  def self.test(suite,name,&test)
    suite.test(name) do
      extend Actions
      instance_exec(&test)
    end
  end

  def self.register(suite)
    test(suite,:CATHARSIS) do
      battle(:NOGUARD,:NONE,user_moves: [:CATHARSIS,:CELEBRATE,:TACKLE],foe_species: :SNORLAX)
      check=move(:CATHARSIS)
      assert(check.pbMoveFailed(@user,@foe),"Catharsis must wait for the other known moves")
      use_move(:CATHARSIS)
      equal(@foe.totalhp,@foe.hp)
      @user.movesUsed.push(PBMoves::CELEBRATE)
      assert(check.pbMoveFailed(@user,@foe),"Catharsis succeeded with an unused move")
      @user.movesUsed.push(PBMoves::TACKLE)
      use_move(:CATHARSIS)
      assert(@foe.hp<@foe.totalhp,"Catharsis should hit after all other moves have been used")
    end

    test(suite,:PERFORATE) do
      battle(:NOGUARD,:NONE,user_moves: [:PERFORATE],foe_species: :SNORLAX)
      use_move(:PERFORATE)
      2.times { round }
      equal(@foe.totalhp,@foe.hp)
      reserve=pokemon(:NONE,@battle.opponent,[:CELEBRATE],:LAPRAS)
      @battle.pbParty(@foe.index).push(reserve)
      @battle.pbReplace(@foe.index,1)
      round
      assert(@foe.hp<@foe.totalhp,"Perforate missed the replacement")
      equal(0,@foe.effects[PBEffects::FutureSight])
    end

    test(suite,:BREAKDOWN) do
      battle(:NOGUARD,:NONE,user_moves: [:BREAKDOWN],foe_species: :SNORLAX)
      @foe.effects[PBEffects::Protect]=true
      @foe.pbOwnSide.effects[PBEffects::WideGuard]=1
      @foe.pbOwnSide.effects[PBEffects::QuickGuard]=1
      use_move(:BREAKDOWN)
      assert(@foe.hp<@foe.totalhp,"Breakdown could not hit through Protect")
      equal(true,@foe.effects[PBEffects::ProtectNegation])
      equal(0,@foe.pbOwnSide.effects[PBEffects::WideGuard])
      equal(0,@foe.pbOwnSide.effects[PBEffects::QuickGuard])
    end

    test(suite,:BATTLECRY) do
      battle(:NOGUARD,:NONE,user_moves: [:BATTLECRY,:CELEBRATE,:TACKLE],foe_species: :SNORLAX)
      use_move(:BATTLECRY)
      equal(1,@user.pbOwnSide.effects[PBEffects::BattleCry])
      use_move(:CELEBRATE,@user)
      equal(1,@user.pbOwnSide.effects[PBEffects::BattleCry])
      tackle=@user.moves.find { |attack| attack.id==PBMoves::TACKLE }
      use_move(:TACKLE)
      equal(true,tackle.battle_cry_boost)
      equal(0,@user.pbOwnSide.effects[PBEffects::BattleCry])
      use_move(:TACKLE)
      equal(false,tackle.battle_cry_boost)
    end

    test(suite,:PYROCLASM) do
      battle(:NOGUARD,:NONE,user_moves: [:PYROCLASM],foe_species: :SNORLAX,
        ally: :NONE,foe_ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      friends=[@user,@ally,@outer_ally]
      enemies=[@foe,@foe_ally,@outer_foe]
      friends.each { |battler| battler.hp=1 }
      use_move(:PYROCLASM)
      friends.each { |battler| equal(1+battler.totalhp/4,battler.hp) }
      enemies.each { |battler| assert(battler.hp<battler.totalhp,"Pyroclasm skipped a foe") }
    end

    test(suite,:TORPEDO) do
      battle(:NOGUARD,:NONE,user_moves: [:TORPEDO],foe_species: :SNORLAX,
        ally: :NONE,foe_ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      @foe_ally.hp=@foe_ally.totalhp/2
      previous=@foe_ally.hp
      use_move(:TORPEDO)
      equal(@foe_ally.totalhp/16,previous-@foe_ally.hp)
      equal(@outer_foe.totalhp,@outer_foe.hp)
      assert(move(:TORPEDO).hasHighCriticalRate?,"Torpedo is missing high critical ratio")
    end

    test(suite,:STORMHOLD) do
      battle(:NOGUARD,:NOGUARD,user_moves: [:STORMHOLD],foe_moves: [:TACKLE])
      turn(:STORMHOLD,:TACKLE)
      equal(@user.totalhp,@user.hp)
      equal(PBStatuses::PARALYSIS,@foe.status)
      equal(false,@user.effects[PBEffects::Stormhold])
    end

    test(suite,:SWANDIVE) do
      battle(:NONE,:NONE,user_moves: [:SWANDIVE],foe_moves: [:TACKLE],foe_species: :SHUCKLE)
      turn(:SWANDIVE,:TACKLE)
      equal(@user.totalhp,@user.hp)
      equal(PBMoves::SWANDIVE,@user.effects[PBEffects::TwoTurnAttack])
      @battle.pbAttackPhase
      offensive=[@user.stages[PBStats::ATTACK],@user.stages[PBStats::SPATK]]
      defensive=[@user.stages[PBStats::DEFENSE],@user.stages[PBStats::SPDEF]]
      equal([0,2],offensive.sort)
      equal([0,2],defensive.sort)
    end

    test(suite,:MOONRISE) do
      battle(:NOGUARD,:NONE,user_moves: [:MOONRISE],user_species: :UMBREON,
        ally: :NONE,foe_ally: :NONE,outer_ally: :NONE,outer_foe: :NONE)
      @outer_ally.type1=PBTypes::FAIRY
      @outer_foe.type1=PBTypes::DARK
      use_move(:MOONRISE,@user)
      [@user,@outer_ally,@outer_foe].each do |battler|
        equal(1,battler.stages[PBStats::SPEED])
        equal(1,battler.stages[PBStats::SPDEF])
        equal(0,battler.stages[PBStats::SPATK])
      end
      equal(0,@ally.stages[PBStats::SPEED])
    end

    test(suite,:REBUILD) do
      battle(:NOGUARD,:NONE,user_moves: [:REBUILD])
      @user.hp=1
      @user.stages[PBStats::ATTACK]=-1
      use_move(:REBUILD,@user)
      equal(1,@user.stages[PBStats::DEFENSE])
      equal(1,@user.stages[PBStats::SPDEF])
      round
      equal(1,@user.hp)
      round
      equal(1+@user.totalhp*2/5,@user.hp)
      equal(0,@user.stages[PBStats::DEFENSE])
      equal(0,@user.stages[PBStats::SPDEF])
      equal(-1,@user.stages[PBStats::ATTACK])
    end

    test(suite,:SPRITZ) do
      battle(:NOGUARD,:NONE,user_moves: [:SPRITZ],foe_species: :SNORLAX)
      use_move(:SPRITZ)
      equal(1,@foe.effects[PBEffects::Spritz])
      equal(false,@foe.pbCanBurn?(false))
      round
      equal(0,@foe.effects[PBEffects::Spritz])
      equal(true,@foe.pbCanBurn?(false))
    end

    test(suite,:SWEETTOOTH) do
      battle(:NOGUARD,:NONE,user_moves: [:SWEETTOOTH],foe_moves: [:CELEBRATE],foe_species: :SNORLAX)
      @user.hp=1
      turn(:SWEETTOOTH,:CELEBRATE)
      equal(0,@user.status)
      assert(@user.hp>1,"Sweet Tooth failed to drain HP")
      turn(:SWEETTOOTH,:CELEBRATE)
      equal(PBStatuses::SLEEP,@user.status)
    end

    test(suite,:MIRACLE) do
      battle(:NOGUARD,:NONE,user_moves: [:MIRACLE],foe_moves: [:TACKLE],ally: :NONE,foe_ally: :NONE)
      @ally.hp=1
      old_hp=@user.hp
      register_early_move(:MIRACLE,@ally,@user)
      register_early_move(:TACKLE,@ally,@foe)
      @battle.pbAttackPhase
      equal(@user.totalhp/4,old_hp-@user.hp)
      equal(1,@ally.hp)
      equal(false,@ally.effects[PBEffects::MiracleGuard])
    end

    test(suite,:ROCKYVERDICT) do
      battle(:NOGUARD,:NONE,user_moves: [:ROCKYVERDICT],foe_species: :SNORLAX,
        ally: :NONE,foe_ally: :NONE)
      @foe.pbOwnSide.effects[PBEffects::Spikes]=1
      @foe.pbOwnSide.effects[PBEffects::StickyWeb]=true
      use_move(:ROCKYVERDICT)
      equal(-1,@foe.stages[PBStats::SPEED])
      equal(-1,@foe_ally.stages[PBStats::SPEED])
      equal(@foe_ally.totalhp/8,@foe_ally.totalhp-@foe_ally.hp)
    end

    test(suite,:ELECTROGENESIS) do
      battle(:NOGUARD,:NONE,user_moves: [:ELECTROGENESIS])
      @user.hp=1
      @battle.field.effects[PBEffects::ElectricTerrain]=3
      use_move(:ELECTROGENESIS,@user)
      equal(1+@user.totalhp*2/3,@user.hp)
    end

    test(suite,:DUNEDEFENSE) do
      battle(:NOGUARD,:NONE,user_moves: [:DUNEDEFENSE])
      use_move(:DUNEDEFENSE,@user)
      equal(5,@user.pbOwnSide.effects[PBEffects::DuneDefense])
    end

    test(suite,:BINDINGWORD) do
      [0,1].each do |roll|
        battle(:NOGUARD,:REGENERATOR,user_moves: [:BINDINGWORD],foe_species: :SNORLAX)
        @battle.define_singleton_method(:pbRandom) { |limit| roll % limit }
        @foe.item=PBItems::LEFTOVERS
        @foe.stages[PBStats::ATTACK]=2
        use_move(:BINDINGWORD)
        equal(5+roll,@foe.effects[PBEffects::MultiTurn])
        equal(false,@foe.hasWorkingAbility(:REGENERATOR))
        equal(false,@foe.hasWorkingItem(:LEFTOVERS))
        equal(0,@foe.stages[PBStats::ATTACK])
        @foe.pbClearMultiTurn
        equal(true,@foe.hasWorkingAbility(:REGENERATOR))
        equal(true,@foe.hasWorkingItem(:LEFTOVERS))
        equal(2,@foe.stages[PBStats::ATTACK])
      end
    end

    test(suite,:DELUGE) do
      battle(:NOGUARD,:NONE,user_moves: [:DELUGE],foe_species: :SNORLAX)
      attack=move(:DELUGE)
      equal(60,attack.pbBaseDamage(60,@user,@foe))
      @user.effects[PBEffects::DamagingMoveThisTurn]=true
      @user.lastAttacker=3
      equal(120,attack.pbBaseDamage(60,@user,@foe))
      equal(-4,attack.priority)
    end

    test(suite,:SHOWSTOPPER) do
      battle(:NOGUARD,:NONE,user_moves: [:SHOWSTOPPER],foe_species: :SNORLAX)
      @user.instance_variable_set(:@totalhp,100)
      @user.hp=50
      @foe.effects[PBEffects::Substitute]=20
      @foe.pbOwnSide.effects[PBEffects::Reflect]=3
      attack=move(:SHOWSTOPPER)
      equal(120,attack.pbBaseDamage(80,@user,@foe))
      use_move(:SHOWSTOPPER)
      equal(50,@user.hp)
      equal(20,@foe.effects[PBEffects::Substitute])
      assert(@foe.hp<@foe.totalhp,"Showstopper failed to bypass Substitute at half HP")
    end

    test(suite,:VILETOUCH) do
      battle(:NOGUARD,:NONE,user_moves: [:VILETOUCH],foe_species: :SNORLAX)
      @foe.status=PBStatuses::POISON
      attack=move(:VILETOUCH)
      @user.attack=100
      @user.defense=100
      equal(70,attack.pbBaseDamage(70,@user,@foe))
      @user.attack=101
      equal(140,attack.pbBaseDamage(70,@user,@foe))
      @user.defense=102
      @user.hp=1
      start_hp=@foe.hp
      use_move(:VILETOUCH)
      damage=start_hp-@foe.hp
      equal(1+[1,damage*3/4].max,@user.hp)
    end

    test(suite,:CURTAINSCALL) do
      battle(:NOGUARD,:NONE,user_moves: [:CURTAINSCALL],foe_species: :SNORLAX)
      attack=move(:CURTAINSCALL)
      @foe.instance_variable_set(:@totalhp,200)
      @foe.hp=100
      equal(100,attack.pbBaseDamageMultiplier(100,@user,@foe))
      @foe.hp=99
      equal(130,attack.pbBaseDamageMultiplier(100,@user,@foe))
    end

    test(suite,:CELLSPLITTER) do
      battle(:NOGUARD,:NONE,user_moves: [:CELLSPLITTER,:CELEBRATE],foe_species: :SNORLAX)
      attack=move(:CELLSPLITTER)
      equal(2,attack.pbNumHits(@user))
      use_move(:CELLSPLITTER)
      equal(4,attack.pbNumHits(@user))
      use_move(:CELLSPLITTER)
      equal(6,attack.pbNumHits(@user))
      use_move(:CELEBRATE,@user)
      equal(2,attack.pbNumHits(@user))
    end

    test(suite,:UNSTABLEMATTER) do
      battle(:NOGUARD,:NONE,user_moves: [:UNSTABLEMATTER],foe_species: :SNORLAX)
      $fefieldeffect=1
      use_move(:UNSTABLEMATTER)
      assert(@foe.hp<@foe.totalhp,"Electric terrain alone stopped Unstable Matter")
      battle(:NOGUARD,:NONE,user_moves: [:UNSTABLEMATTER],foe_species: :SNORLAX)
      $fefieldeffect=50
      @user.effects[PBEffects::DamagingMoveThisTurn]=true
      use_move(:UNSTABLEMATTER)
      equal(@foe.totalhp,@foe.hp)
    end
  end
end
