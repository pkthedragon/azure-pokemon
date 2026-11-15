module AzureAICustomMoveCases
  def self.register(suite)
    suite.test(:CUSTOM_BATTLE_CRY_DAMAGE) do
      battle(:NONE,:NONE,user_moves: [:BATTLECRY,:TACKLE])
      tackle=move(:TACKLE)
      baseline=@battle.pbRoughDamage(tackle,@user,@foe,100,tackle.basedamage)
      @user.pbOwnSide.effects[PBEffects::BattleCry]=1
      boosted=@battle.pbRoughDamage(tackle,@user,@foe,100,tackle.basedamage)
      assert(boosted>baseline,"Battle Cry should raise a pending attack's estimated damage")
      equal(1,@user.pbOwnSide.effects[PBEffects::BattleCry])
    end

    suite.test(:CUSTOM_DOUBLE_DOSE_ITEMS) do
      battle(:NONE,:NONE,user_moves: [:DOUBLEDOSE,:RAZORWIND],ally: :NONE,foe_ally: :NONE)
      equal(0,ai_score(:DOUBLEDOSE))
      @user.item=PBItems::POWERHERB
      herb=ai_score(:DOUBLEDOSE)
      assert(herb>0,"Double Dose should value Power Herb with a two-turn move")
      @ally.item=PBItems::FOCUSSASH
      combined=ai_score(:DOUBLEDOSE)
      assert(combined>herb,"Double Dose should also value a full-health ally's Focus Sash")
      @ally.type1=@ally.type2=PBTypes::STEEL
      assert(ai_score(:DOUBLEDOSE)>combined,"Double Dose should prefer a recipient immune to its poison")
      @user.pbOwnSide.effects[PBEffects::DoubleDose]=3
      equal(0,ai_score(:DOUBLEDOSE))
    end

    suite.test(:CUSTOM_BINDING_WORD_SUPPRESSION) do
      battle(:NONE,:REGENERATOR,user_moves: [:BINDINGWORD],foe_species: :LAPRAS)
      neutral=ai_score(:BINDINGWORD)
      @foe.stages[PBStats::ATTACK]=3
      @foe.item=PBItems::LEFTOVERS
      valuable=ai_score(:BINDINGWORD)
      assert(valuable>neutral,"Binding Word should prefer suppressing useful stages and a held item")
      @foe.effects[PBEffects::MultiTurn]=3
      assert(valuable>ai_score(:BINDINGWORD),"Binding Word should not value reapplying an active trap")
    end

    suite.test(:CUSTOM_GLACIAL_STATE_DAMAGE) do
      battle(:NONE,:AROMAVEIL,user_moves: [:GLACIALSTATE],foe_moves: [:TACKLE],foe_species: :LAPRAS)
      blocked=ai_score(:GLACIALSTATE)
      assert(blocked>0,"Aroma Veil should remove only the Disable utility")
      @foe.ability=PBAbilities::BALLFETCH
      assert(ai_score(:GLACIALSTATE)>blocked,"A known attack used before Glacial State should add Disable utility")
    end

    suite.test(:CUSTOM_RECOVERY_CONDITIONS) do
      battle(:NONE,:NONE,user_moves: [:ELECTROGENESIS,:STRATOSPHERE,:REBUILD,:CATNAP])
      equal(0,ai_score(:ELECTROGENESIS))
      @user.hp=1
      normal=ai_score(:ELECTROGENESIS)
      equal(normal,ai_score(:STRATOSPHERE))
      @battle.field.effects[PBEffects::ElectricTerrain]=4
      assert(ai_score(:ELECTROGENESIS)>normal,"Electric Terrain should increase Electrogenesis utility")
      @battle.weather=PBWeather::RAINDANCE
      rain=ai_score(:STRATOSPHERE)
      assert(rain>normal,"Rain should increase Stratosphere utility")
      @user.item=PBItems::UTILITYUMBRELLA
      equal(normal,ai_score(:STRATOSPHERE))
      assert(ai_score(:CATNAP)<rain,"Catnap should account for becoming drowsy")
      assert(ai_score(:REBUILD)>0,"Rebuild should value delayed healing")
      @user.effects[PBEffects::Rebuild]=2
      equal(0,ai_score(:REBUILD))
      @user.effects[PBEffects::HealBlock]=2
      equal(0,ai_score(:ELECTROGENESIS))
    end

    suite.test(:CUSTOM_PYROCLASM_RING) do
      battle(:NONE,:NONE,user_moves: [:PYROCLASM],outer_ally: :NONE,outer_foe: :NONE)
      healthy=ai_score(:PYROCLASM)
      @outer_ally.hp=1
      assert(ai_score(:PYROCLASM)>healthy,"Pyroclasm should value healing an outer ally")
      @outer_ally.effects[PBEffects::HealBlock]=2
      equal(healthy,ai_score(:PYROCLASM))
    end

    suite.test(:CUSTOM_MOONRISE_NET_BOOSTS) do
      battle(:NONE,:NONE,user_moves: [:MOONRISE],outer_ally: :NONE,outer_foe: :NONE)
      @outer_foe.type1=@outer_foe.type2=PBTypes::DARK
      equal(0,ai_score(:MOONRISE))
      @outer_ally.type1=@outer_ally.type2=PBTypes::FAIRY
      equal(0,ai_score(:MOONRISE))
      @user.type1=@user.type2=PBTypes::FAIRY
      assert(ai_score(:MOONRISE)>0,"Moonrise should prefer a net allied boost")
    end

    suite.test(:CUSTOM_MIRACLE_LETHAL_HIT) do
      battle(:NONE,:NONE,user_moves: [:MIRACLE],foe_moves: [:CELEBRATE],ally: :NONE,foe_ally: :NONE)
      @ally.hp=1
      @foe_ally.moves[0]=move(:CELEBRATE,@foe_ally)
      equal(0,ai_score(:MIRACLE))
      equal(0,ai_score(:MIRACLE,@user,@ally))
      @foe.moves[0]=move(:TACKLE,@foe)
      assert(ai_score(:MIRACLE,@user,@ally)>0,"Miracle should protect an ally from a known lethal attack")
      @user.hp=@user.totalhp/4
      equal(0,ai_score(:MIRACLE,@user,@ally))
    end

    suite.test(:CUSTOM_KNOWN_TURN_RISK) do
      battle(:NONE,:NONE,user_moves: [:CALMINGWAKE,:UNSTABLEMATTER,:DELUGE],foe_moves: [:CELEBRATE],foe_species: :LAPRAS)
      cold=ai_score(:CALMINGWAKE)
      unstable=ai_score(:UNSTABLEMATTER)
      deluge=ai_score(:DELUGE)
      @foe.moves[0]=move(:TACKLE,@foe)
      assert(ai_score(:CALMINGWAKE)<cold,"A known hit before Calming Wake should lower its score")
      assert(ai_score(:UNSTABLEMATTER)<unstable,"A known hit before Unstable Matter should lower its score")
      assert(ai_score(:DELUGE)>deluge,"A known survivable hit before Deluge should improve its score")
      @user.effects[PBEffects::Confusion]=2
      assert(ai_score(:CALMINGWAKE)>cold,"Calming Wake should value acting through and curing confusion")
      @user.effects[PBEffects::DamagingMoveThisTurn]=true
      equal(0,ai_score(:UNSTABLEMATTER))
    end

    suite.test(:CUSTOM_HAZARD_UTILITY) do
      battle(:NONE,:NONE,user_moves: [:CALTROPS,:UNDERTOW,:ROCKYVERDICT])
      equal(0,ai_score(:CALTROPS))
      equal(0,ai_score(:UNDERTOW))
      @battle.party2.push(pokemon(:NONE,@battle.opponent,[:TACKLE]))
      assert(ai_score(:CALTROPS)>0,"Caltrops should value a real reserve on the opposing side")
      assert(ai_score(:UNDERTOW)>0,"Undertow should value a real reserve on the opposing side")
      dry=ai_score(:ROCKYVERDICT)
      @foe.pbOwnSide.effects[PBEffects::Spikes]=1
      assert(ai_score(:ROCKYVERDICT)>dry,"Rocky Verdict should value triggering current hazards")
      @foe.pbOwnSide.effects[PBEffects::Undertow]=3
      equal(0,ai_score(:UNDERTOW))
    end

    suite.test(:CUSTOM_BRAINSTORM_CHARGE) do
      battle(:NONE,:NONE,user_moves: [:BRAINSTORM],foe_species: :LAPRAS)
      charged=ai_score(:BRAINSTORM)
      @battle.weather=PBWeather::HAIL
      immediate=ai_score(:BRAINSTORM)
      assert(immediate>charged,"Hail should raise Brainstorm utility by removing the charge")
      @battle.weather=0
      @user.item=PBItems::POWERHERB
      equal(immediate,ai_score(:BRAINSTORM))
      equal(PBItems::POWERHERB,@user.item)
    end

    suite.test(:CUSTOM_TORPEDO_AND_AFTERSHOCK) do
      battle(:NONE,:NONE,user_moves: [:TORPEDO,:AFTERSHOCK],foe_species: :LAPRAS,
        outer_ally: :NONE,outer_foe: :NONE)
      splash=ai_score(:TORPEDO)
      @foe_ally.hp=0
      assert(splash>ai_score(:TORPEDO),"Torpedo should value an adjacent foe, not the outer foe two lanes away")
      aftershock=ai_score(:AFTERSHOCK)
      @foe.effects[PBEffects::Substitute]=80
      assert(aftershock>ai_score(:AFTERSHOCK),"Aftershock should account for its second hit only when it can be scheduled")
    end

    suite.test(:CUSTOM_OVERCHARGE_AND_CLEAN_CUT) do
      battle(:NONE,:NONE,user_moves: [:OVERCHARGE,:CLEANCUT],user_species: :FURFROU,foe_species: :HIPPOWDON)
      assert(ai_score(:OVERCHARGE)>0,"Overcharge should value burning a Ground type")
      @foe.status=PBStatuses::POISON
      equal(0,ai_score(:OVERCHARGE))
      natural=ai_score(:CLEANCUT)
      @user.form=7
      @foe.status=0
      assert(ai_score(:CLEANCUT)>natural,"La Reine Clean Cut should value freezing an eligible foe")
      @foe.status=PBStatuses::BURN
      equal(natural,ai_score(:CLEANCUT))
    end

    suite.test(:CUSTOM_TRAPS_AND_DRAIN) do
      battle(:NONE,:NONE,user_moves: [:TOUGHLOVE,:SHELLSHOCK,:VILETOUCH,:BELLOW],foe_species: :SNORLAX)
      @user.attack=60
      @user.defense=100
      healthy=ai_score(:TOUGHLOVE)
      @user.hp=@user.totalhp/3
      assert(ai_score(:TOUGHLOVE)>healthy,"Tough Love should prefer recovering missing HP")
      drain=ai_score(:VILETOUCH)
      @user.hp=@user.totalhp
      assert(drain>ai_score(:VILETOUCH),"Defensive Vile Touch should value its healing")
      finish=ai_score(:SHELLSHOCK)
      @foe.status=PBStatuses::BURN
      assert(finish>ai_score(:SHELLSHOCK),"Shell Shock should value paralyzing the last Pokémon")
      bellow=ai_score(:BELLOW)
      @foe.ability=PBAbilities::SHIELDDUST
      assert(bellow>ai_score(:BELLOW),"Shield Dust should block Bellow's stat-drop utility")
    end
  end
end
