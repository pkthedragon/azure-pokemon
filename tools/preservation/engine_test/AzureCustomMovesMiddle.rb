module AzureCustomMovesMiddle
  module Helpers
    def custom_middle_power(attack,user=@user,target=@foe)
      attack.pbCalcDamage(user,target,PokeBattle_Move::NOCRITICAL | PokeBattle_Move::NOWEIGHTING)
    end

    def custom_middle_play(mon,move_name,target)
      slot=mon.moves.index { |known| known.id==PBMoves.const_get(move_name) }
      assert(slot && @battle.pbRegisterMove(mon.index,slot,false),"Could not queue #{move_name}")
      @battle.pbRegisterTarget(mon.index,target.index)
      @battle.pbAttackPhase
      @battle.instance_variable_set(:@turncount,@battle.turncount+1)
    end
  end

  def self.register(suite)
    AzureAbilityFixture::Scenario.include(Helpers)
    suite.test(:REDSUNSZENITH) do
      battle(:NOGUARD,:NONE,user_moves: [:REDSUNSZENITH],foe_species: :BLISSEY,ally: :NONE)
      attack=@user.moves.first
      assert(attack.isBeamMove?,"Red Sun's Zenith must be a Beam move")
      2.times do
        custom_middle_play(@user,:REDSUNSZENITH,@foe)
        assert(!@user.isFainted?,"Only the third use should knock out the user")
        @foe.hp=@foe.totalhp
      end
      equal(0,@battle.field.effects[PBEffects::Gravity])
      equal(300,@battle.pbBetterBaseDamage(attack,@user,@foe,100,100))
      custom_middle_play(@user,:REDSUNSZENITH,@foe)
      assert(@user.isFainted?,"Third use should knock out the user")
    end

    suite.test(:BLUESHIFT) do
      battle(:NONE,:NONE,user_moves: [:BLUESHIFT],ally: :NONE,foe_ally: :NONE)
      hit(:BLUESHIFT,@user,@user)
      assert(@user.isFainted?,"Blue Shift should sacrifice the user")
      equal(2,@battle.field.effects[PBEffects::BlueShift])
      round
      equal(1,@battle.field.effects[PBEffects::BlueShift])
      round
      equal(0,@battle.field.effects[PBEffects::BlueShift])
    end

    suite.test(:CORALBURST) do
      battle(:NOGUARD,:NONE,foe_species: :LAPRAS)
      @battle.player.party.push(pokemon(:NONE,@battle.player,[:TACKLE]))
      attack=move(:CORALBURST)
      assert(attack.hasHighCriticalRate?,"Coral Burst is high-critical")
      equal(80,attack.pbBaseDamage(80,@user,@foe))
      hit(:CORALBURST)
      assert(@user.userSwitch,"Coral Burst must pivot on a resisted hit")
    end

    suite.test(:CIRCADIANRRHYTHM) do
      battle(:NONE,:NONE)
      equal(0,move(:CIRCADIANRRHYTHM).accuracy)
      assert(move(:CIRCADIANRRHYTHM).isSoundBased?,"Circadian Rhythm is Sound")
      hit(:CIRCADIANRRHYTHM)
      equal(PBStatuses::SLEEP,@foe.status)
      equal(0,@user.status)
      round
      [PBStats::ATTACK,PBStats::SPATK,PBStats::SPEED].each { |stat| equal(1,@foe.stages[stat]) }
    end

    suite.test(:NEEDLEBLAST) do
      battle(:SKILLLINK,:NONE,foe_species: :CHARIZARD)
      attack=move(:NEEDLEBLAST)
      equal(20,attack.totalpp)
      equal(5,attack.pbNumHits(@user))
      hit(:NEEDLEBLAST)
      equal(1,@foe.effects[PBEffects::Needles])
      hit(:TACKLE,@foe,@user)
      equal(1,@foe.effects[PBEffects::Needles])
      hp=@foe.hp
      round
      equal(hp-@foe.totalhp/8,@foe.hp)
      equal(0,@foe.effects[PBEffects::Wounded])
    end

    suite.test(:MOLTENSTANCE) do
      battle(:NONE,:NONE)
      attack=move(:MOLTENSTANCE)
      equal(10,attack.totalpp)
      equal(2,attack.priority)
      hit(:MOLTENSTANCE,@user,@user)
      equal(1,@user.stages[PBStats::DEFENSE])
      hit(:TACKLE,@foe,@user)
      equal(PBStatuses::BURN,@foe.status)
      round
      equal(-1,@user.stages[PBStats::DEFENSE])
      equal(2,@user.stages[PBStats::SPEED])
    end

    suite.test(:PIERCETHEVEIL) do
      battle(:NOGUARD,:NONE)
      @user.attack=70
      @user.defense=60
      @user.spatk=90
      @user.spdef=80
      hit(:PIERCETHEVEIL)
      equal([60,70,80,90],[@user.attack,@user.defense,@user.spatk,@user.spdef])
    end

    suite.test(:PESTILENCE) do
      battle(:NOGUARD,:NONE,foe_species: :BLISSEY)
      attack=move(:PESTILENCE)
      equal(60,attack.pbBaseDamage(60,@user,@foe))
      @foe.pbReduceHP(1)
      equal(120,attack.pbBaseDamage(60,@user,@foe))
      @user.hp=10
      damage=hit(:PESTILENCE)
      equal(10+(damage+1)/2,@user.hp)
    end

    suite.test(:FERTILIZE) do
      battle(:NOGUARD,:NONE,user_moves: [:FERTILIZE,:ABSORB],foe_species: :BLISSEY)
      @user.hp=1
      custom_middle_play(@user,:ABSORB,@foe)
      custom_middle_play(@user,:FERTILIZE,@user)
      assert(@user.effects[PBEffects::Fertilize],"Grass on previous turn should enable Fertilize")
      hp=@foe.hp
      custom_middle_play(@user,:ABSORB,@foe)
      assert(@foe.hp<hp,"The next Grass-type attack should deal damage")
      assert(!@user.effects[PBEffects::Fertilize],"Fertilize should be consumed")
    end

    suite.test(:HORIZONFOCUS) do
      battle(:NOGUARD,:NONE,foe_species: :KLINK)
      attack=move(:HORIZONFOCUS)
      equal(2,attack.pbTypeModMessages(PBTypes::FLYING,@user,@foe))
      @battle.weather=PBWeather::SUNNYDAY
      equal(2,attack.pbTypeModMessages(PBTypes::FLYING,@user,@foe))
      @battle.field.effects[PBEffects::HarshSunlight]=true
      equal(8,attack.pbTypeModMessages(PBTypes::FLYING,@user,@foe))
    end

    suite.test(:SHELLSHOCK) do
      battle(:NOGUARD,:SUCTIONCUPS,foe_species: :SLOWBRO)
      equal(-6,move(:SHELLSHOCK).priority)
      hit(:SHELLSHOCK)
      equal(PBStatuses::PARALYSIS,@foe.status)
      equal(false,@foe.forcedSwitch)
    end

    suite.test(:FLAMEWREATH) do
      battle(:NOGUARD,:NONE,foe_species: :SLOWBRO)
      hit(:FLAMEWREATH)
      equal(2,@user.effects[PBEffects::FlameWreath])
      round
      hit(:TACKLE,@foe,@user)
      equal(PBStatuses::BURN,@foe.status)
      round
      equal(0,@user.effects[PBEffects::FlameWreath])
    end

    suite.test(:MYSTICHARVEST) do
      battle(:NONE,:NONE,user_species: :BULBASAUR)
      @user.item=PBItems::ORANBERRY
      hit(:MYSTICHARVEST,@user,@user)
      equal(1,@foe.pbOwnSide.effects[PBEffects::MysticTree])
      equal(0,@user.item)
      @user.hp=1
      @battle.pbOnActiveOne(@user)
      equal(1+@user.totalhp/12,@user.hp)
    end

    suite.test(:MUDBATH) do
      battle(:NONE,:NONE)
      @user.status=PBStatuses::BURN
      hit(:MUDBATH,@user,@user)
      equal(0,@user.status)
      equal(2,@user.effects[PBEffects::MudBath])
      round
      equal(1,@user.effects[PBEffects::MudBath])
      round
      equal(0,@user.effects[PBEffects::MudBath])
      equal(2,@user.stages[PBStats::DEFENSE])
      equal(2,@user.stages[PBStats::SPDEF])
    end

    suite.test(:THREEFOLDSTRIKE) do
      battle(:NOGUARD,:NONE)
      attack=move(:THREEFOLDSTRIKE)
      equal(3,attack.pbNumHits(@user))
      @user.attack=80
      @user.spatk=120
      assert(attack.pbIsSpecial?(attack.type),"Threefold Strike uses higher Special Attack")
      @user.stages[PBStats::ATTACK]=2
      assert(attack.pbIsPhysical?(attack.type),"Threefold Strike considers stages for higher Attack")
    end

    suite.test(:NATURALORDER) do
      battle(:NOGUARD,:NONE,user_species: :BULBASAUR,foe_moves: [:TACKLE])
      assert(hit(:NATURALORDER)>0,"Natural Order deals direct damage")
      equal(1,@foe.effects[PBEffects::NaturalOrder])
      custom_middle_play(@foe,:TACKLE,@user)
      equal(0,@foe.effects[PBEffects::NaturalOrder])
    end

    suite.test(:FIERYIMPULSE) do
      battle(:NOGUARD,:NONE,user_moves: [:FIERYIMPULSE,:TAILWHIP,:GROWL],foe_species: :BLISSEY)
      @user.attack=10
      @user.defense=@user.spdef=@user.spatk=@user.speed=100
      custom_middle_play(@user,:TAILWHIP,@foe)
      custom_middle_play(@user,:GROWL,@foe)
      custom_middle_play(@user,:FIERYIMPULSE,@user)
      equal(3,@user.stages[PBStats::ATTACK])
    end

    suite.test(:TIDEBREAK) do
      battle(:NONE,:NONE)
      attack=move(:TIDEBREAK)
      @foe.turncount=2
      equal(100,attack.pbBaseDamageMultiplier(100,@user,@foe))
      @foe.turncount=3
      equal(150,attack.pbBaseDamageMultiplier(100,@user,@foe))
    end

    suite.test(:CLEANCUT) do
      expected=[:NORMAL,:PSYCHIC,:FAIRY,:GROUND,:DARK,:POISON,:GRASS,:WATER,:FIRE,:DRAGON]
      expected.each_with_index do |type,form|
        battle(:NOGUARD,:NONE,user_species: :FURFROU,foe_species: :SLOWBRO)
        @user.form=form
        @user.gender=0
        @foe.gender=1
        equal(PBTypes::NORMAL,@user.pokemon.type1)
        equal(PBTypes.const_get(type),@user.pokemon.type2)
        equal(PBTypes::NORMAL,move(:CLEANCUT).type)
        hit(:CLEANCUT)
        case form
        when 1 then equal(@user.index,@foe.effects[PBEffects::Attract])
        when 2 then assert(@foe.effects[PBEffects::Confusion]>0,"Star trim confuses")
        when 3 then equal(PBStatuses::CRUSHED,@foe.status)
        when 4 then assert(@foe.effects[PBEffects::ThroatChop]>0,"Debutante trim silences")
        when 5 then equal(PBStatuses::POISON,@foe.status)
        when 6 then equal(2,@foe.effects[PBEffects::Yawn])
        when 7 then equal(PBStatuses::FROZEN,@foe.status)
        when 8 then equal(PBStatuses::BURN,@foe.status)
        when 9 then equal(PBStatuses::PARALYSIS,@foe.status)
        end
      end
    end

    suite.test(:DISHEARTEN) do
      battle(:NOGUARD,:LEVITATE,foe_species: :SLOWBRO)
      hit(:DISHEARTEN)
      equal(PBAbilities::LEVITATE,@foe.ability)
      @foe.effects[PBEffects::MeanLook]=@user.index
      hit(:DISHEARTEN)
      equal(PBAbilities::DEFEATIST,@foe.ability)
    end

    suite.test(:EPHEMERATE) do
      battle(:NOGUARD,:NONE)
      @battle.player.party.push(pokemon(:NONE,@battle.player,[:TACKLE]))
      @foe.effects[PBEffects::Confusion]=3
      hit(:EPHEMERATE)
      equal(0,@foe.effects[PBEffects::Confusion])
      assert(@user.userSwitch,"Ephemerate should pivot its user")
    end

    suite.test(:ANTICLINE) do
      battle(:NOGUARD,:NONE,foe_species: :SLOWBRO)
      @user.stages[PBStats::ATTACK]=2
      @user.stages[PBStats::SPDEF]=-3
      hit(:ANTICLINE)
      equal(-2,@user.stages[PBStats::ATTACK])
      equal(3,@user.stages[PBStats::SPDEF])
    end

    suite.test(:FOREBODE) do
      battle(:NOGUARD,:NONE,user_moves: [:FOREBODE],foe_species: :SLOWBRO)
      @user.turncount=0
      custom_middle_play(@user,:FOREBODE,@foe)
      hp=@foe.hp
      @battle.pbResolveForebode([@foe])
      assert(@foe.hp<hp,"Forebode should strike on the next turn")
      assert(@foe.effects[PBEffects::Flinch],"Forebode should flinch a hit target")
    end

    suite.test(:CARAPACESHOT) do
      battle(:NOGUARD,:NONE,user_species: :CHARIZARD,foe_species: :SLOWBRO)
      hit(:CARAPACESHOT)
      equal([PBTypes::FIRE,PBTypes::FIRE],[@user.type1,@user.type2])
      equal([PBTypes::FLYING,PBTypes::FLYING],[@foe.type1,@foe.type2])
      round
      equal(PBTypes::FLYING,@foe.type1)
      @battle.instance_variable_set(:@turncount,1)
      round
      equal(PBTypes::WATER,@foe.type1)
      equal(PBTypes::FLYING,@user.type2)
    end

    suite.test(:BLINDINGASSAULT) do
      battle(:NOGUARD,:NONE,foe_species: :SLOWBRO)
      @battle.lastMoveUsed=PBMoves::BLINDINGASSAULT
      @battle.lastMoveUser=@user.index
      attack=move(:BLINDINGASSAULT)
      assert(attack.hasHighCriticalRate?,"Blinding Assault has a high critical ratio")
      attack.lock_on_boost=true
      assert(attack.pbEffect(@user,@foe)>0,"Blinding Assault must hit")
      equal(-1,@foe.stages[PBStats::SPEED])
      equal(1,@user.stages[PBStats::SPEED])
    end

    suite.test(:EQUINOXHORN) do
      battle(:NOGUARD,:NONE,user_species: :SAWSBUCK)
      attack=move(:EQUINOXHORN)
      [PBWeather::RAINDANCE,PBWeather::SUNNYDAY,PBWeather::SANDSTORM,PBWeather::HAIL].each_with_index do |weather,form|
        @battle.weather=weather
        @user.form=form
        @battle.field.effects[PBEffects::HeavyRain]=form==0
        @battle.field.effects[PBEffects::HarshSunlight]=form==1
        equal(150,attack.pbBaseDamage(100,@user,@foe))
      end
    end

    suite.test(:BARRELBURST) do
      battle(:NOGUARD,:NONE,foe_species: :BLISSEY)
      hp=@user.hp
      damage=hit(:BARRELBURST)
      equal(hp-(damage+1)/2,@user.hp)
      equal(3,@user.stages[PBStats::SPEED])
    end
  end
end
