module AzureAbilityFixture
  def ability_damage(name,user=@user,target=@foe)
    target.damagestate.reset
    attack=move(name,user)
    attack.pbCalcDamage(user,target,PokeBattle_Move::NOCRITICAL | PokeBattle_Move::NOWEIGHTING)
  end

  def use_ability_test_move(user=@user,slot=0,target=@foe)
    user.pbUseMove([1,slot,user.moves[slot],target.index])
  end

  test(:HONEYGATHER) do
    battle(:HONEYGATHER,:NONE,user_moves: [:TACKLE])
    @user.hp=@user.totalhp/2
    damaged_hp=@user.hp
    round
    equal(damaged_hp+@user.totalhp/8,@user.hp)
    use_ability_test_move
    unchanged_hp=@user.hp
    round
    equal(unchanged_hp,@user.hp)
  end

  test(:UNNERVE) do
    battle(:UNNERVE,:NONE,foe_moves: [:SWALLOW])
    @foe.hp=@foe.totalhp/4
    damaged_hp=@foe.hp
    @foe.item=PBItems::LEFTOVERS
    @foe.pbBerryCureCheck(true)
    equal(damaged_hp,@foe.hp)
    @foe.item=PBItems::SITRUSBERRY
    @foe.pbBerryCureCheck
    equal(PBItems::SITRUSBERRY,@foe.item)
    equal(-1,move(:SWALLOW,@foe).pbEffect(@foe,nil,0,nil,false))
    @user.ability=0
    @foe.pbBerryCureCheck
    assert(@foe.hp>damaged_hp,"Sitrus Berry should work when Unnerve is gone")
  end

  test(:STALWART) do
    battle(:NONE,:STALWART,user_moves: [:DOUBLEHIT,:TACKLE],foe_species: :SNORLAX)
    baseline=ability_damage(:DOUBLEHIT)
    use_ability_test_move
    equal(1,@foe.effects[PBEffects::StalwartStacks])
    assert(ability_damage(:DOUBLEHIT)<baseline,"Repeat use should reduce damage")
    hit(:TACKLE)
    equal(PBMoves::TACKLE,@foe.effects[PBEffects::StalwartMove])
    equal(1,@foe.effects[PBEffects::StalwartStacks])
  end

  test(:BULLETPROOF) do
    battle(:NONE,:BULLETPROOF)
    [:FLEURCANNON,:SHADOWBALL,:SEEDBOMB].each do |name|
      attack=move(name)
      type=attack.pbType(attack.type,@user,@foe)
      equal(0,attack.pbTypeModMessages(type,@user,@foe))
    end
    assert(ability_damage(:TACKLE)>0,"Bulletproof should allow non-projectile attacks")
  end

  test(:MEGALAUNCHER) do
    battle(:MEGALAUNCHER,:NONE)
    [:AURASPHERE,:DARKPULSE,:FLEURCANNON].each do |name|
      equal(1.5,move(name).pbAbilityMovePowerMultiplier(@user))
    end
    equal(1.0,move(:TACKLE).pbAbilityMovePowerMultiplier(@user))
    @user.effects[PBEffects::GastroAcid]=true
    equal(1.0,move(:DARKPULSE).pbAbilityMovePowerMultiplier(@user))
  end

  test(:GLUTTONY) do
    battle(:GLUTTONY,:NONE)
    @user.hp=@user.totalhp/3
    equal(11,@user.pbRecoverHP(10))
    @user.hp=@user.totalhp/2
    @user.item=PBItems::LIECHIBERRY
    @user.pbBerryCureCheck
    equal(0,@user.item)
  end

  test(:BERSERK) do
    battle(:NONE,:BERSERK)
    damage=ability_damage(:TACKLE)
    @foe.hp=@foe.totalhp/2+1
    assert(damage<@foe.hp,"Berserk setup must survive the hit")
    hit(:TACKLE)
    assert(@foe.stages[PBStats::ATTACK]>0 && @foe.stages[PBStats::SPATK]>0,
           "Berserk should raise both offensive stats when crossing half HP")
  end

  test(:MAJESTY) do
    battle(:NONE,:MAJESTY,ally: :NONE,foe_ally: :NONE)
    spread=ability_damage(:ROCKSLIDE)
    single=ability_damage(:TACKLE)
    @foe.ability=0
    baseline=ability_damage(:ROCKSLIDE)
    assert((spread-baseline*0.7).abs<=1,"Majesty should reduce spread damage to 70%")
    equal(single,ability_damage(:TACKLE))

    battle(:NONE,:MAJESTY,outer_ally: :NONE,outer_foe: :NONE)
    $fefieldeffect=40
    attack=move(:FIRESPIN)
    assert(attack.pbSpreadMove?(@user),"the field makes Fire Spin a spread move")
    assert(attack.pbTargetsAll?(@user),"Fire Spin should reach the two nearby foes")
    spread=ability_damage(:FIRESPIN)
    @foe.effects[PBEffects::GastroAcid]=true
    baseline=ability_damage(:FIRESPIN)
    assert((spread-baseline*0.7).abs<=2,"Majesty must reduce field-induced spread damage while it works")
    @foe_ally.hp=0
    assert(!attack.pbTargetsAll?(@user),"the remaining outer foe is out of lane range")
    ai_baseline=@battle.pbRoughDamage(attack,@user,@foe,100,attack.basedamage)
    assert(ai_baseline>0,"the AI needs a positive spread damage baseline")
    guard=move(:WIDEGUARD,@foe)
    guard.pbEffect(@foe,nil,0,nil,false)
    guarded=ability_damage(:FIRESPIN)
    assert((guarded-baseline*0.5).abs<=2,"Wide Guard must halve spread damage even when one foe is reachable")
    ai_guarded=@battle.pbRoughDamage(attack,@user,@foe,100,attack.basedamage)
    assert((ai_guarded-ai_baseline*0.5).abs<=1,"the AI must account for Wide Guard against field-induced spread moves")
  end

  test(:STEELWORKER) do
    battle(:STEELWORKER,:NONE)
    offense=ability_damage(:IRONHEAD)
    @user.ability=0
    assert(offense>ability_damage(:IRONHEAD),"Steelworker should boost Steel moves")
    defense=ability_damage(:IRONHEAD)
    @foe.ability=PBAbilities::STEELWORKER
    assert(ability_damage(:IRONHEAD)<defense,"Steelworker should resist Steel moves")
  end

  test(:STENCH) do
    battle(:STENCH,:NONE)
    hit(:TACKLE)
    equal(true,@foe.effects[PBEffects::Flinch])
    @foe.effects[PBEffects::Flinch]=false
    hit(:TACKLE)
    equal(false,@foe.effects[PBEffects::Flinch])
  end

  test(:CUTECHARM) do
    battle(:NONE,:CUTECHARM)
    hit(:SWIFT)
    equal(@foe.index,@user.effects[PBEffects::Attract])

    battle(:NONE,:CUTECHARM,outer_ally: :NONE,outer_foe: :NONE)
    assert(@battle.pbShiftBattlers(@user.index,@outer_ally.index),"could not place the attacker in the outer lane")
    assert(@battle.pbShiftBattlers(@foe.index,@outer_foe.index),"could not place the Cute Charm holder opposite the attacker")
    hit(:SWIFT)
    equal(@foe.index,@user.effects[PBEffects::Attract])
    assert(@battle.pbShiftBattlers(@foe.index,@foe_ally.index),"could not shift the Cute Charm holder")
    equal(@foe.index,@user.effects[PBEffects::Attract])
    @foe.hp=0
    @foe.pbFaint
    equal(-1,@user.effects[PBEffects::Attract])
  end

  test(:HYPERCUTTER) do
    battle(:HYPERCUTTER,:NONE)
    assert(!@user.pbCanReduceStatStage?(PBStats::ATTACK,false),"Attack drops should be blocked")
    hit(:TACKLE)
    assert(@foe.effects[PBEffects::Wounded]>0,"Dealing damage should inflict wounds")
  end

  test(:PLUS) do
    battle(:PLUS,:NONE,ally: :MINUS,foe_ally: :NONE)
    entry
    equal(3,@user.pbOwnSide.effects[PBEffects::PlusSignal])
    assert(!@user.pbPlusMinusBoost?,"Plus requires an active Minus signal")
    entry(@ally)
    assert(@user.pbPlusMinusBoost?,"Minus signal should boost Plus")
    @user.pbOwnSide.effects[PBEffects::MinusSignal]=0
    assert(!@user.pbPlusMinusBoost?,"A living Minus ally alone is insufficient")
  end

  test(:MINUS) do
    battle(:MINUS,:NONE,ally: :PLUS,foe_ally: :NONE)
    entry
    equal(3,@user.pbOwnSide.effects[PBEffects::MinusSignal])
    assert(!@user.pbPlusMinusBoost?,"Minus requires an active Plus signal")
    entry(@ally)
    assert(@user.pbPlusMinusBoost?,"Plus signal should boost Minus")
  end

  test(:STICKYHOLD) do
    battle(:STICKYHOLD,:NONE)
    @user.item=PBItems::LEFTOVERS
    hit(:KNOCKOFF,@foe,@user)
    equal(PBItems::LEFTOVERS,@user.item)
    equal(@user.index,@foe.effects[PBEffects::MeanLook])
    @foe.effects[PBEffects::MeanLook]=-1
    hit(:TACKLE)
    equal(@user.index,@foe.effects[PBEffects::MeanLook])

    battle(:STICKYHOLD,:NONE,outer_ally: :NONE,outer_foe: :NONE)
    assert(@battle.pbShiftBattlers(@user.index,@outer_ally.index),"could not shift Sticky Hold to the outer lane")
    hit(:TACKLE,@user,@outer_foe)
    equal(@user.index,@outer_foe.effects[PBEffects::MeanLook])
    assert(@battle.pbShiftBattlers(@user.index,@ally.index),"could not shift the Sticky Hold source")
    equal(@user.index,@outer_foe.effects[PBEffects::MeanLook])
    @user.hp=0
    @user.pbFaint
    equal(-1,@outer_foe.effects[PBEffects::MeanLook])
  end

  test(:MARVELSCALE) do
    battle(:MARVELSCALE,:NONE)
    normal=[@user.pbCalcDefense,@user.pbCalcSpDef]
    @battle.field.effects[PBEffects::MistyTerrain]=3
    assert(@user.pbCalcDefense>normal[0] && @user.pbCalcSpDef>normal[1],"Misty Terrain should raise both defenses")
    @battle.field.effects[PBEffects::MistyTerrain]=0
    @user.status=PBStatuses::POISON
    assert(@user.pbCalcDefense>normal[0] && @user.pbCalcSpDef>normal[1],"A status condition should raise both defenses")
  end

  test(:SYMBIOSIS) do
    battle(:SYMBIOSIS,:NONE,user_moves: [:SWORDSDANCE],ally: :NONE,foe_ally: :NONE)
    @battle.pbRegisterMove(@user.index,0)
    @battle.pbAttackPhase
    assert(@user.stages[PBStats::ATTACK]>0,"Swords Dance should raise the user's Attack")
    equal(@user.stages[PBStats::ATTACK],@ally.stages[PBStats::ATTACK])

    battle(:SYMBIOSIS,:NONE,user_moves: [:SWORDSDANCE],ally: :NONE,foe_ally: :NONE)
    @user.speed=50
    @foe.speed=200
    @foe.moves[0]=move(:GASTROACID,@foe)
    @battle.pbRegisterMove(@foe.index,0)
    @battle.pbRegisterTarget(@foe.index,@user.index)
    @battle.pbRegisterMove(@user.index,0)
    @battle.pbAttackPhase
    assert(@user.effects[PBEffects::GastroAcid],"Gastro Acid did not suppress Symbiosis before its turn")
    assert(@user.stages[PBStats::ATTACK]>0,"The suppressed holder should still use Swords Dance")
    equal(0,@ally.stages[PBStats::ATTACK])
  end

  test(:ROCKYPAYLOAD) do
    battle(:ROCKYPAYLOAD,:NONE)
    offense=ability_damage(:ROCKTHROW)
    @user.ability=0
    assert(offense>ability_damage(:ROCKTHROW),"Rocky Payload should boost Rock moves")
    defense=ability_damage(:ROCKTHROW)
    @foe.ability=PBAbilities::ROCKYPAYLOAD
    assert(ability_damage(:ROCKTHROW)<defense,"Rocky Payload should resist Rock moves")
  end

  test(:MERCILESS) do
    battle(:MERCILESS,:NONE)
    attack=move(:TACKLE)
    @foe.effects[PBEffects::Wounded]=3
    assert(attack.pbIsCritical?(@user,@foe),"Wounds should guarantee a critical hit")
    @foe.effects[PBEffects::Wounded]=0
    @foe.status=PBStatuses::BURN
    assert(attack.pbIsCritical?(@user,@foe),"Burn should guarantee a critical hit")
  end

  test(:QUICKDRAW) do
    battle(:QUICKDRAW,:NONE)
    attack=move(:TACKLE)
    @user.turncount=1
    equal(1,@battle.pbMovePriority(@user,attack,@foe))
    @user.turncount=2
    equal(0,@battle.pbMovePriority(@user,attack,@foe))
  end

  test(:FRISK) do
    battle(:FRISK,:NONE)
    @foe.item=PBItems::LEFTOVERS
    entry
    equal(1,@foe.effects[PBEffects::FriskLock])
    assert(!@foe.hasWorkingItem(:LEFTOVERS),"Frisk should disable the held item")
    round
    assert(@foe.hasWorkingItem(:LEFTOVERS),"The item should work again after one turn")
  end

  test(:FOREWARN) do
    battle(:FOREWARN,:NONE,foe_moves: [:TACKLE,:CLOSECOMBAT])
    @user.type1=@user.type2=PBTypes::NORMAL
    entry
    equal(PBMoves::CLOSECOMBAT,@foe.effects[PBEffects::ForewarnDisableMove])
    assert(!@battle.pbCanChooseMove?(@foe.index,1,false),"The super-effective move should be disabled")
    round
    assert(@battle.pbCanChooseMove?(@foe.index,1,false),"The move should unlock after a turn")
  end

  test(:ANTICIPATION) do
    battle(:NONE,:ANTICIPATION)
    distant=ability_damage(:SWIFT)
    contact=ability_damage(:TACKLE)
    psychic=ability_damage(:PSYCHIC)
    @foe.ability=0
    assert((distant-ability_damage(:SWIFT)*0.5).abs<=1,"Non-contact damage should be halved")
    equal(contact,ability_damage(:TACKLE))
    assert((psychic-ability_damage(:PSYCHIC)*2).abs<=1,"Psychic damage should double")
  end

  test(:HEALER) do
    battle(:HEALER,:NONE,ally: :NONE,foe_ally: :NONE)
    @ally.hp=@ally.totalhp/3
    @ally.status=PBStatuses::BURN
    start=@ally.hp
    move(:HEALPULSE).pbEffect(@user,@ally,0,nil,false)
    equal(start+((@ally.totalhp+1)/2*1.1).floor,@ally.hp)
    equal(0,@ally.status)
  end

  test(:TELEPATHY) do
    battle(:TELEPATHY,:NONE,ally: :NONE,foe_ally: :NONE)
    targets=[]
    @user.pbFindUser([1,0,move(:TACKLE),@ally.index],targets)
    equal([@ally],targets)
    attack=move(:SURF)
    equal(0,attack.pbTypeModMessages(PBTypes::WATER,@user,@ally))
    equal(0,attack.pbTypeModMessages(PBTypes::WATER,@ally,@user))
    assert(attack.pbTypeModMessages(PBTypes::WATER,@foe,@user)>0,"Opponents should still hit Telepathy holders")

    battle(:LACERATE,:NONE,ally: :TELEPATHY,outer_ally: :NEUTRALIZINGGAS,outer_foe: :STORMDRAIN)
    tackle=move(:TACKLE)
    equal(PBTypes::NORMAL,tackle.pbType(tackle.type,@user,@ally))
    targets=[]
    @user.pbFindUser([1,0,tackle,@outer_foe.index],targets)
    assert(!targets.include?(@outer_foe),"An outer-lane Tackle must not reach the opposite outer lane")
    targets=[]
    helping_hand=move(:HELPINGHAND,@ally)
    @ally.pbFindUser([1,0,helping_hand,@outer_ally.index],targets)
    equal([@outer_ally],targets)
    scene=PokeBattle_Scene.allocate
    scene.instance_variable_set(:@battle,@battle)
    equal([@foe.index,@foe_ally.index,@ally.index],scene.pbSceneSelectableMoveTargets(@user.index,tackle))
    equal([@user.index,@outer_ally.index],scene.pbSceneSelectableMoveTargets(@ally.index,helping_hand))
    assert(hit(:SURF,@ally,@user)>0,"Neutralizing Gas must suppress allied Telepathy")
    assert(hit(:SURF,@ally,@outer_foe)>0,"Neutralizing Gas must suppress enemy Storm Drain")
    @outer_ally.effects[PBEffects::GastroAcid]=true
    equal(PBTypes::STEEL,tackle.pbType(tackle.type,@user,@ally))
    equal(0,hit(:SURF,@ally,@user))
    equal(0,hit(:SURF,@ally,@outer_foe))

    @foe.item=PBItems::AIRBALLOON
    equal(0,hit(:EARTHQUAKE,@ally,@foe))
    @battle.field.effects[PBEffects::MagicRoom]=3
    assert(hit(:EARTHQUAKE,@ally,@foe)>0,
           "Magic Room must disable Air Balloon in a triple battle")

    battle(:COMMANDER,:NEUTRALIZINGGAS,ally: :NONE,outer_ally: :NONE,outer_foe: :NONE,
           user_species: :TATSUGIRI)
    @ally.pbInitialize(pokemon(:NONE,@battle.player,[:ORDERUP],:DONDOZO),1,false)
    entry(@user)
    assert(!@user.effects[PBEffects::Commander],"Gas must suppress Commander")
    @foe.hp=0
    @foe.pbFaint
    assert(@user.effects[PBEffects::Commander],"Commander should activate when Gas wears off")
    assert(@battle.pbShiftBattlers(@outer_ally.index,@ally.index),"Dondozo could not shift to the outer lane")
    equal(2,@ally.stages[PBStats::ATTACK])
    @user.form=0
    order_up=move(:ORDERUP,@ally)
    @battle.pbWithStatChangeSource([:move,order_up.id]) do
      assert(order_up.pbEffect(@ally,@outer_foe,0,nil,false)>0,"Order Up should hit from the shifted lane")
    end
    equal(3,@ally.stages[PBStats::ATTACK])
    @ally.hp=0
    @ally.pbFaint
    assert(!@user.effects[PBEffects::Commander] && !@user.vanished,
           "Dondozo's faint should release its original Commander after a shift")

    battle(:NONE,:NONE,ally: :NONE,outer_ally: :COMMANDER,outer_foe: :NONE,
           user_species: :DONDOZO)
    @outer_ally.pbInitialize(pokemon(:COMMANDER,@battle.player,[:QUICKATTACK],:TATSUGIRI),2,false)
    entry(@outer_ally)
    assert(!@outer_ally.effects[PBEffects::Commander],"Opposite outer lanes should be out of Commander range")
    assert(@battle.pbRegisterMove(@outer_ally.index,0,false),"Could not queue Tatsugiri's attack")
    @battle.pbRegisterZMove(@outer_ally.index)
    @battle.pbRegisterTarget(@outer_ally.index,@foe_ally.index)
    assert(@battle.pbRegisterShift(@ally.index,@outer_ally.index),"Could not shift Tatsugiri into the middle lane")
    pp=@outer_ally.moves[0].pp
    @battle.pbAttackPhase
    equal(@user,@outer_ally.effects[PBEffects::Commander])
    equal(pp,@outer_ally.moves[0].pp)
    assert(!@outer_ally.moves[0].zmove,"Commander should clear the canceled move's Z-Power flag")
    @battle.pbClearChoices(@ally.index)
    assert(!@battle.pbCanShift?(@ally.index,@outer_ally.index,false),"A swallowed Tatsugiri cannot shift lanes")
  end

  test(:LIGHTMETAL) do
    battle(:LIGHTMETAL,:NONE)
    equal(@user.pokemon.weight/2,@user.weight)
    speed=@user.pbSpeed
    @battle.field.effects[PBEffects::Gravity]=3
    equal(speed*2,@user.pbSpeed)
  end

  test(:HEAVYMETAL) do
    battle(:NONE,:HEAVYMETAL)
    equal(@foe.pokemon.weight*2,@foe.weight)
    physical=ability_damage(:TACKLE)
    special=ability_damage(:SWIFT)
    @battle.field.effects[PBEffects::Gravity]=3
    assert(ability_damage(:TACKLE)<physical,"Gravity should raise Defense")
    assert(ability_damage(:SWIFT)<special,"Gravity should raise Sp. Def.")
  end

  test(:ARMORTAIL) do
    battle(:QUICKDRAW,:ARMORTAIL)
    @user.turncount=1
    assert(move(:TACKLE).pbArmorTailBlocks?(@user,@foe),"Armor Tail should recognize ability-generated priority")
    @user.turncount=2
    assert(!move(:TACKLE).pbArmorTailBlocks?(@user,@foe),"Neutral-priority moves should pass")
    assert(move(:SOLARBEAM).pbArmorTailBlocks?(@user,@foe),"Two-turn moves should be blocked")
    assert(move(:METEORBEAM).pbArmorTailBlocks?(@user,@foe),"Custom two-turn moves should be blocked")
  end

  test(:PRESSURE) do
    battle(:NONE,:PRESSURE)
    initial=@user.moves[0].pp
    use_ability_test_move
    equal(initial-2,@user.moves[0].pp)
    @battle.field.effects[PBEffects::Gravity]=3
    use_ability_test_move
    equal(initial-5,@user.moves[0].pp)
  end

  test(:BIGPECKS) do
    battle(:BIGPECKS,:NONE)
    @battle.pbWithStatChangeSource([:move,PBMoves::SWORDSDANCE]) do
      @foe.pbIncreaseStatBasic(PBStats::ATTACK,2)
    end
    equal(1,@user.stages[PBStats::DEFENSE])
    assert(!@user.pbCanReduceStatStage?(PBStats::DEFENSE,false),"Defense drops should be blocked")
  end

  test(:HUSTLE) do
    battle(:HUSTLE,:NONE)
    attack=@user.pbCalcAttack
    vulnerability=ability_damage(:SWIFT,@foe,@user)
    @user.ability=0
    assert((attack-@user.pbCalcAttack*1.5).abs<=1,"Hustle should raise Attack")
    assert(vulnerability>ability_damage(:SWIFT,@foe,@user),"Hustle should reduce Sp. Def.")
  end

  test(:TANGLEDFEET) do
    battle(:TANGLEDFEET,:NONE)
    speed=@user.pbSpeed
    incoming=ability_damage(:TACKLE,@foe,@user)
    @user.ability=0
    equal((@user.pbSpeed*1.5).floor,speed)
    assert(incoming>ability_damage(:TACKLE,@foe,@user),"The defensive penalty should apply without confusion")
  end

  test(:ZENMODE) do
    battle(:ZENMODE,:NONE,user_species: :DARMANITAN)
    @user.pbSleepSelf(3)
    equal(0,@user.status)
    equal(1,@user.form)
  end

  test(:COLORCHANGE) do
    battle(:COLORCHANGE,:NONE)
    @user.type1=PBTypes::WATER
    @user.type2=PBTypes::FLYING
    @battle.field.effects[PBEffects::MistyTerrain]=3
    entry
    equal([PBTypes::FAIRY,PBTypes::FAIRY],[@user.type1,@user.type2])
  end

  test(:EFFECTSPORE) do
    battle(:NONE,:EFFECTSPORE)
    @foe.hp=1
    hit(:TACKLE)
    equal(2,@user.effects[PBEffects::Yawn])
  end

  test(:MOODY) do
    battle(:MOODY,:NONE)
    pokemon=@user.pokemon
    pokemon.abilityoverride=PBAbilities::MOODY
    pokemon.setNature(PBNatures::ADAMANT)
    pokemon.calcStats
    boosted=[pokemon.attack,pokemon.spatk]
    pokemon.abilityoverride=PBAbilities::HUSTLE
    pokemon.calcStats
    assert(boosted[0]>pokemon.attack && boosted[1]<pokemon.spatk,"Moody should amplify both sides of Adamant")
  end

  test(:NOGUARD) do
    battle(:NOGUARD,:NONE)
    @foe.stages[PBStats::EVASION]=3
    @foe.type1=@foe.type2=PBTypes::WATER
    assert(move(:FIREBLAST).pbAccuracyCheck(@user,@foe),"No Guard should bypass accuracy checks")
    boost=ability_damage(:FOCUSBLAST)
    @user.ability=0
    assert((boost-ability_damage(:FOCUSBLAST)*1.2).abs<=1,"Low-accuracy moves should deal 20% more damage")
  end

  test(:PROPELLERTAIL) do
    battle(:PROPELLERTAIL,:NONE,user_moves: [:DEFENSECURL])
    @user.pbOwnSide.effects[PBEffects::Spikes]=2
    @user.pbOwnSide.effects[PBEffects::StealthRock]=true
    @user.effects[PBEffects::MeanLook]=@foe.index
    use_ability_test_move
    equal(0,@user.pbOwnSide.effects[PBEffects::Spikes])
    equal(false,@user.pbOwnSide.effects[PBEffects::StealthRock])
    equal(-1,@user.effects[PBEffects::MeanLook])
  end

  test(:CURSEDBODY) do
    battle(:NONE,:CURSEDBODY,user_moves: [:TACKLE])
    @foe.hp=1
    hit(:TACKLE)
    equal(PBMoves::TACKLE,@user.effects[PBEffects::DisableMove])
    assert(@user.effects[PBEffects::Disable]>0,"The knockout move should stay disabled")
  end

  test(:SHEDSKIN) do
    battle(:SHEDSKIN,:NONE)
    @user.status=PBStatuses::POISON
    round
    equal(0,@user.status)
    assert(!@user.pbShedSkinReady?,"AI should see that the first cure was used")
    @user.status=PBStatuses::BURN
    round
    equal(PBStatuses::BURN,@user.status)
  end
end
