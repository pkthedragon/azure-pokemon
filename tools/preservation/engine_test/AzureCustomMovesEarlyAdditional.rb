module AzureCustomMovesEarlyAdditional
  def self.test(suite,name,&test)
    AzureCustomMovesEarly.test(suite,name,&test)
  end

  def self.register(suite)
    test(suite,:BEAUTIFY) do
      battle(:NONE,:NONE,user_moves: [:BEAUTIFY])
      @user.defense=[@user.attack,@user.speed,@user.spatk,@user.spdef].max+1
      use_move(:BEAUTIFY,@user)
      equal(2,@user.stages[PBStats::DEFENSE])
      equal(0.5,@user.effects[PBEffects::WeightMultiplier])
    end

    test(suite,:BELLOW) do
      battle(:NOGUARD,:NONE,user_moves: [:BELLOW],foe_species: :SNORLAX)
      @battle.define_singleton_method(:pbRandom) { |limit| 0 }
      attack=move(:BELLOW)
      equal(10,attack.addlEffect)
      assert(attack.isSoundBased? && hit(:BELLOW)>0,"Bellow failed to hit as sound")
      [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF].each do |stat|
        equal(-1,@foe.stages[stat])
      end
    end

    test(suite,:BIORHYTHM) do
      battle(:NOGUARD,:NONE,user_moves: [:BIORHYTHM],foe_species: :SNORLAX)
      attack=move(:BIORHYTHM)
      equal(150,attack.pbBaseDamage(150,@user,@foe))
      @user.hp=@user.totalhp/3
      equal(150*@user.hp/@user.totalhp,attack.pbBaseDamage(150,@user,@foe))
      assert(hit(:BIORHYTHM)>0,"Biorhythm did not damage the foe")
    end

    test(suite,:BOAST) do
      battle(:NOGUARD,:NONE,user_moves: [:BOAST],foe_species: :SNORLAX)
      assert(move(:BOAST).isSoundBased? && hit(:BOAST)>0,"Boast failed to hit as sound")
      equal(1,@user.stages[PBStats::ATTACK])
    end

    test(suite,:BRAINSTORM) do
      [0,PBWeather::HAIL].each do |weather|
        battle(:NOGUARD,:NONE,user_moves: [:BRAINSTORM],foe_species: :SNORLAX)
        @battle.instance_variable_set(:@weather,weather)
        use_move(:BRAINSTORM)
        equal(1,@user.stages[PBStats::SPATK])
        if weather==0
          equal(@foe.totalhp,@foe.hp)
          equal(PBMoves::BRAINSTORM,@user.effects[PBEffects::TwoTurnAttack])
          @battle.pbAttackPhase
        else
          equal(0,@user.effects[PBEffects::TwoTurnAttack])
        end
        assert(@foe.hp<@foe.totalhp,"Brainstorm never attacked")
        equal(1,@user.stages[PBStats::SPATK])
      end
    end

    test(suite,:COLDVEIN) do
      battle(:NOGUARD,:NONE,user_moves: [:COLDVEIN],foe_species: :SNORLAX)
      equal(90,move(:COLDVEIN).accuracy)
      use_move(:COLDVEIN)
      equal(PBStatuses::FROZEN,@foe.status)
    end

    test(suite,:CONDESCEND) do
      battle(:NOGUARD,:NONE,user_moves: [:CONDESCEND],foe_species: :SNORLAX)
      attack=move(:CONDESCEND)
      equal(65,attack.pbBaseDamage(65,@user,@foe))
      @foe.stages[PBStats::ATTACK]=-2
      @foe.stages[PBStats::SPDEF]=2
      equal(130,attack.pbBaseDamage(65,@user,@foe))
      assert(hit(:CONDESCEND)>0,"Condescend did not hit")
      equal(0,@foe.stages[PBStats::ATTACK])
      equal(2,@foe.stages[PBStats::SPDEF])
    end

    test(suite,:DRAGONJAUNT) do
      battle(:NOGUARD,:NONE,user_moves: [:DRAGONJAUNT],foe_moves: [:QUICKATTACK],foe_species: :SNORLAX)
      @foe.speed=@user.speed+100
      equal(2,@battle.pbMovePriority(@user,move(:DRAGONJAUNT),@foe))
      turn(:DRAGONJAUNT,:QUICKATTACK)
      jaunt=@scene.messages.index { |line| line.include?("Dragon Jaunt") }
      quick=@scene.messages.index { |line| line.include?("Quick Attack") }
      assert(jaunt && quick && jaunt<quick,"Dragon Jaunt did not beat priority +1")
    end

    test(suite,:ESSENCEFEED) do
      battle(:NOGUARD,:NONE,user_moves: [:ESSENCEFEED],foe_species: :LAPRAS)
      @user.hp=1
      damage=hit(:ESSENCEFEED)
      assert(damage>0,"Essence Feed did not hit")
      equal(1+(damage+1)/2,@user.hp)
    end

    test(suite,:EVISCERATE) do
      battle(:NOGUARD,:NONE,user_moves: [:EVISCERATE],foe_species: :SNORLAX)
      @battle.define_singleton_method(:pbRandom) { |limit| 0 }
      assert(move(:EVISCERATE).hasHighCriticalRate? && hit(:EVISCERATE)>0,"Eviscerate failed to hit")
      equal(true,@foe.damagestate.critical)
    end

    test(suite,:FLASHFREEZE) do
      battle(:NONE,:NONE,user_moves: [:FLASHFREEZE],foe_species: :LAPRAS)
      @battle.define_singleton_method(:pbRandom) { |limit| limit-1 }
      attack=move(:FLASHFREEZE)
      equal(true,attack.pbAccuracyCheck(@user,@foe))
      equal(140,attack.pbBaseDamage(70,@user,@foe))
      assert(hit(:FLASHFREEZE)>0,"Flash Freeze did not hit an Ice-resistant foe")
    end

    test(suite,:GLACIALSTATE) do
      battle(:NOGUARD,:NONE,user_moves: [:GLACIALSTATE],foe_moves: [:CELEBRATE],foe_species: :SNORLAX)
      attack=move(:GLACIALSTATE)
      equal(-6,@battle.pbMovePriority(@user,attack,@foe))
      equal(true,attack.isPunchingMove?)
      turn(:GLACIALSTATE,:CELEBRATE)
      equal(PBMoves::CELEBRATE,@foe.effects[PBEffects::DisableMove])
      assert(@foe.effects[PBEffects::Disable]>0,"Glacial State did not disable the last move")
    end

    test(suite,:IRRITATION) do
      battle(:NOGUARD,:NONE,user_moves: [:IRRITATION],foe_species: :SNORLAX)
      attack=move(:IRRITATION)
      equal(true,attack.pbIsPhysical?(attack.type))
      equal(60,attack.pbBaseDamage(60,@user,@foe))
      @foe.status=PBStatuses::PARALYSIS
      equal(120,attack.pbBaseDamage(60,@user,@foe))
      assert(hit(:IRRITATION)>0,"Irritation did not damage the statused foe")
    end

    test(suite,:LITHOFORM) do
      battle(:NOGUARD,:NONE,user_moves: [:LITHOFORM],foe_species: :SNORLAX)
      @battle.define_singleton_method(:pbRandom) { |limit| 0 }
      equal(10,move(:LITHOFORM).addlEffect)
      assert(hit(:LITHOFORM)>0,"Lithoform failed to damage the foe")
      equal(PBStatuses::CRUSHED,@foe.status)
      equal(false,@foe.effects[PBEffects::Flinch])
    end

    test(suite,:LUCKYSTAR) do
      battle(:NONE,:NONE,user_moves: [:LUCKYSTAR],foe_species: :SNORLAX)
      @battle.define_singleton_method(:pbRandom) { |limit| limit-1 }
      attack=move(:LUCKYSTAR)
      equal(true,attack.isPunchingMove?)
      equal(false,attack.isContactMove?)
      equal(true,attack.pbAccuracyCheck(@user,@foe))
      use_move(:LUCKYSTAR)
      equal(true,@foe.damagestate.critical)
      assert(@scene.messages.include?("Hit 5 times!"),"Lucky Star did not land five hits")
    end

    test(suite,:MAGMADRIFT) do
      battle(:NOGUARD,:NONE,user_moves: [:MAGMADRIFT],foe_species: :SNORLAX)
      attack=move(:MAGMADRIFT)
      equal(4096,attack.pbModifyDamage(4096,@user,@foe))
      @foe.effects[PBEffects::TwoTurnAttack]=PBMoves::DIVE
      equal(8192,attack.pbModifyDamage(4096,@user,@foe))
      assert(hit(:MAGMADRIFT)>0,"Magma Drift failed to hit a diving foe")
    end

    test(suite,:MISTYSTEP) do
      battle(:NONE,:NONE,user_moves: [:MISTYSTEP],foe_species: :SNORLAX)
      @battle.pbParty(@user.index).push(pokemon(:NONE,@battle.player,[:CELEBRATE],:LAPRAS))
      @battle.define_singleton_method(:pbSwitchInBetween) { |_index,_lax,_can_cancel| 1 }
      @battle.define_singleton_method(:pbRandom) { |limit| limit-1 }
      equal(0,move(:MISTYSTEP).accuracy)
      use_move(:MISTYSTEP)
      assert(@foe.hp<@foe.totalhp,"Misty Step failed to damage the foe")
      equal(1,@user.pokemonIndex)
    end

    test(suite,:NATURESCALL) do
      battle(:NOGUARD,:NONE,user_moves: [:NATURESCALL],foe_species: :KLINKLANG)
      @battle.define_singleton_method(:pbRandom) { |limit| 0 }
      attack=move(:NATURESCALL)
      equal(true,attack.isSoundBased?)
      assert(hit(:NATURESCALL)>0,"Nature's Call did not damage a Steel-type")
      equal(8,@foe.damagestate.typemod)
      equal(8,@battle.pbTypeModNoMessages(attack.type,@user,@foe,attack,PBTrainerAI.highSkill))
      equal(PBStatuses::PARALYSIS,@foe.status)
    end

    test(suite,:NIGHTFALL) do
      battle(:NOGUARD,:NONE,user_moves: [:NIGHTFALL],user_species: :LAPRAS,foe_species: :SNORLAX,
        ally: :NONE,foe_ally: :NONE)
      @user.hp=1
      targets=[@foe,@ally,@foe_ally]
      hp_before=targets.map(&:hp)
      use_move(:NIGHTFALL)
      damage=targets.each_with_index.map { |battler,index| hp_before[index]-battler.hp }
      assert(damage.all? { |amount| amount>0 },"Nightfall missed an adjacent Pokémon")
      equal(1+damage.sum { |amount| (amount+1)/2 },@user.hp)
    end

    test(suite,:PESTER) do
      battle(:NOGUARD,:NONE,user_moves: [:PESTER],foe_species: :SNORLAX)
      attack=move(:PESTER)
      equal(true,attack.pbIsPhysical?(attack.type))
      equal(45,attack.basedamage)
      assert(hit(:PESTER)>0,"Pester did not damage the foe")
    end
  end
end
