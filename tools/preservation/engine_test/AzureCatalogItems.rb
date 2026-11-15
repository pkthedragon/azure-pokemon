module AzureCatalogItems
  HEALING={
    POTION: 20, SUPERPOTION: 60, CHINESEFOOD: 40, HYPERPOTION: 120, ULTRAPOTION: 200,
    MAXPOTION: :full, BERRYJUICE: 20, RAGECANDYBAR: 20, SWEETHEART: 20,
    FRESHWATER: 30, SODAPOP: 50, VANILLAIC: 30, CHOCOLATEIC: 70, STRAWBIC: 90,
    BLUEMIC: 200, LEMONADE: 70, MOOMOOMILK: 100, STRAWCAKE: 150, ORANBERRY: 10,
    SITRUSBERRY: :quarter, ENERGYPOWDER: 50, ENERGYROOT: 200,CHESTNUT: 20
  }.freeze
  STATUS={
    AWAKENING: :SLEEP, CHESTOBERRY: :SLEEP, BLUEFLUTE: :SLEEP, POKEFLUTE: :SLEEP,
    POPROCKS: :SLEEP, ANTIDOTE: :POISON, PECHABERRY: :POISON, PEPPERMINT: :POISON,
    BURNHEAL: :BURN, RAWSTBERRY: :BURN, SALTWATERTAFFY: :BURN,
    PARLYZHEAL: :PARALYSIS, CHERIBERRY: :PARALYSIS, CHEWINGGUM: :PARALYSIS,
    ICEHEAL: :FROZEN, ASPEARBERRY: :FROZEN, REDHOTS: :FROZEN, LEVIABERRY: :CRUSHED,
    FULLHEAL: :POISON, FULLRESTORE: :POISON, LAVACOOKIE: :POISON, OLDGATEAU: :POISON,
    CASTELIACONE: :POISON, BIGMALASADA: :POISON, LUMBERRY: :POISON, RAZZTART: :POISON,
    HEALPOWDER: :POISON,LUMIOSEGALETTE: :POISON
  }.freeze
  REVIVE={
    REVIVE: :half_plus_one, FUNNELCAKE: :half_plus_one, COTTONCANDY: :half,
    MAXREVIVE: :full, HERBALTEA: :full, REVIVALHERB: :full
  }.freeze
  PP={ETHER: 10, LEPPABERRY: 10, MAXETHER: :full, ELIXIR: 10, MAXELIXIR: :full,ROSETEA: 10,
      HOPOBERRY: 2}.freeze
  STAT={"XATTACK"=>:ATTACK,"XDEFEND"=>:DEFENSE,"XSPECIAL"=>:SPATK,
        "XSPDEF"=>:SPDEF,"XSPEED"=>:SPEED,"XACCURACY"=>:ACCURACY}.freeze
  WEATHER={HEATROCK: :SUNNYDAY,DAMPROCK: :RAINDANCE,SMOOTHROCK: :SANDSTORM,ICYROCK: :HAIL}.freeze
  HELD_DAMAGE={
    CHOICEBAND: [:TACKLE,:user,:SLOWBRO], CHOICESPECS: [:WATERGUN,:user,:SLOWBRO],
    MUSCLEBAND: [:TACKLE,:user,:SLOWBRO], WISEGLASSES: [:WATERGUN,:user,:SLOWBRO],
    EXPERTBELT: [:WATERGUN,:user,:RAPIDASH], SHARPTALONS: [:METALCLAW,:user,:SLOWBRO],
    HEAVYMACE: [:POUND,:user,:SLOWBRO], STEELWHIP: [:POWERWHIP,:user,:SLOWBRO],
    LODESTONE: [:HEADBUTT,:user,:SLOWBRO],
    QUICKCLAW: [:QUICKATTACK,:user,:SLOWBRO],
    ASSAULTVEST: [:WATERGUN,:foe,:SLOWBRO], EVIOLITE: [:TACKLE,:foe,:CHANSEY],
    METALPOWDER: [:TACKLE,:foe,:DITTO]
  }.freeze
  HELD_SPEED={
    CHOICESCARF: [:RATTATA,:up], QUICKPOWDER: [:DITTO,:up], MACHOBRACE: [:RATTATA,:down],
    IRONBALL: [:RATTATA,:down], POWERWEIGHT: [:RATTATA,:down], POWERBRACER: [:RATTATA,:down],
    POWERBELT: [:RATTATA,:down], POWERLENS: [:RATTATA,:down], POWERBAND: [:RATTATA,:down],
    POWERANKLET: [:RATTATA,:down]
  }.freeze
  TYPE_BOOSTS={
    TACKLE: [:SILKSCARF], ROCKSMASH: [:BLACKBELT,:FISTPLATE], GUST: [:SHARPBEAK,:SKYPLATE],
    POISONSTING: [:POISONBARB,:TOXICPLATE], MUDSLAP: [:SOFTSAND,:EARTHPLATE],
    ROCKTHROW: [:HARDSTONE,:STONEPLATE,:ROCKINCENSE], STRUGGLEBUG: [:SILVERPOWDER,:INSECTPLATE],
    LICK: [:SPELLTAG,:SPOOKYPLATE], METALCLAW: [:METALCOAT,:IRONPLATE],
    EMBER: [:CHARCOAL,:FLAMEPLATE], WATERGUN: [:MYSTICWATER,:SPLASHPLATE,:SEAINCENSE,:WAVEINCENSE],
    ABSORB: [:MIRACLESEED,:MEADOWPLATE,:ROSEINCENSE], THUNDERSHOCK: [:MAGNET,:ZAPPLATE],
    CONFUSION: [:TWISTEDSPOON,:MINDPLATE,:ODDINCENSE], POWDERSNOW: [:NEVERMELTICE,:ICICLEPLATE],
    TWISTER: [:DRAGONFANG,:DRACOPLATE], BITE: [:BLACKGLASSES,:DREADPLATE],
    FAIRYWIND: [:PIXIEPLATE]
  }.freeze
  TYPE_CRYSTALS={
    NORMALIUMZ2: :TACKLE,FIGHTINIUMZ2: :ROCKSMASH,FLYINIUMZ2: :GUST,POISONIUMZ2: :POISONSTING,
    GROUNDIUMZ2: :MUDSLAP,ROCKIUMZ2: :ROCKTHROW,BUGINIUMZ2: :STRUGGLEBUG,GHOSTIUMZ2: :LICK,
    STEELIUMZ2: :METALCLAW,FIRIUMZ2: :EMBER,WATERIUMZ2: :WATERGUN,GRASSIUMZ2: :ABSORB,
    ELECTRIUMZ2: :THUNDERSHOCK,PSYCHIUMZ2: :CONFUSION,ICIUMZ2: :POWDERSNOW,
    DRAGONIUMZ2: :TWISTER,DARKINIUMZ2: :BITE,FAIRIUMZ2: :FAIRYWIND
  }.freeze
  SIGNATURE_CRYSTALS={
    ALORAICHIUMZ2: [:RAICHU,:THUNDERBOLT,1], DECIDIUMZ2: [:DECIDUEYE,:SPIRITSHACKLE],
    INCINIUMZ2: [:INCINEROAR,:DARKESTLARIAT], PRIMARIUMZ2: [:PRIMARINA,:SPARKLINGARIA],
    EEVIUMZ2: [:EEVEE,:LASTRESORT], PIKANIUMZ2: [:PIKACHU,:VOLTTACKLE],
    SNORLIUMZ2: [:SNORLAX,:GIGAIMPACT], MEWNIUMZ2: [:MEW,:PSYCHIC],
    TAPUNIUMZ2: [:TAPUKOKO,:NATURESMADNESS], MARSHADIUMZ2: [:MARSHADOW,:SPECTRALTHIEF],
    KOMMONIUMZ2: [:KOMMOO,:CLANGINGSCALES], LYCANIUMZ2: [:LYCANROC,:STONEEDGE],
    MIMIKIUMZ2: [:MIMIKYU,:PLAYROUGH], SOLGANIUMZ2: [:SOLGALEO,:SUNSTEELSTRIKE],
    LUNALIUMZ2: [:LUNALA,:MOONGEISTBEAM], ULTRANECROZIUMZ2: [:NECROZMA,:PHOTONGEYSER,3]
  }.freeze
  ITEM_FORMS={
    DOUSEDRIVE: [:GENESECT,:TECHNOBLAST,:WATER,4], SHOCKDRIVE: [:GENESECT,:TECHNOBLAST,:ELECTRIC,1],
    BURNDRIVE: [:GENESECT,:TECHNOBLAST,:FIRE,2], CHILLDRIVE: [:GENESECT,:TECHNOBLAST,:ICE,3],
    WELLSPRINGMASK: [:OGERPON,:IVYCUDGEL,:WATER,2], HEARTHFLAMEMASK: [:OGERPON,:IVYCUDGEL,:FIRE,3],
    CORNERSTONEMASK: [:OGERPON,:IVYCUDGEL,:ROCK,4], GRISEOUSORB: [:GIRATINA,nil,nil,1],
    LUSTROUSGLOBE: [:PALKIA,nil,nil,1], ADAMANTCRYSTAL: [:DIALGA,nil,nil,1]
  }.freeze
  ESCAPE_ITEMS=[:POKEDOLL,:FLUFFYTAIL,:POKETOY].freeze
  SCENTS=[:JOYSCENT,:EXCITESCENT,:VIVIDSCENT].freeze
  DETECTED_HELD_MISMATCHES=[:PUNCHINGGLOVE,:COVERTCLOAK,:CLEARAMULET,:DROWSYORB].freeze
  SPECIAL_HELD=[:GRIPCLAW,:BINDINGBAND,:METRONOME,:SAFETYGOGGLES,:ABILITYSHIELD,
                :ANTIGRAVITYCORE,:GOLDENHELIX,:MIXTAPE,:MEGARING,:VENGEANTDIADEM].freeze
  CONDITIONAL_BALLS={
    SAFARIBALL: 150, SPORTBALL: 150, DIVEBALL: 350, QUICKBALL: 500,
    FASTBALL: 400, LEVELBALL: 200, LUREBALL: 500, LOVEBALL: 800,
    BEASTBALL: 500, DREAMBALL: 300
  }.freeze

  class Cases
    attr_reader :cases

    def initialize
      @cases={}
    end

    def test(item,&block)
      @cases[item]=block
    end
  end

  class Scenario < AzureAbilityFixture::Scenario
    def battle(*args,**settings)
      super
      @battle.define_singleton_method(:pbRandom) { |limit| limit-1 }
      return @battle
    end

    def equip(id,battler=@user)
      battler.item=id
      battler.pokemon.itemInitial=id
    end

    def compare_damage(id,attack,holder=:user,species=:SLOWBRO)
      losses=[0,id,id].map.with_index do |item,index|
        battle(:NOGUARD,:NONE,foe_species: species)
        @user.attack=@user.spatk=125
        @foe.defense=@foe.spdef=110
        equip(item,holder==:user ? @user : @foe)
        @battle.field.effects[PBEffects::MagicRoom]=3 if index==2
        hit(attack)
      end
      return losses
    end

    def item_form(symbol,id)
      species,attack,type,expected_form=ITEM_FORMS.fetch(symbol) do
        memory_type=symbol.to_s.delete_suffix("MEMORY").to_sym
        [:SILVALLY,:MULTIATTACK,memory_type,PBTypes.const_get(memory_type)]
      end
      moves=[attack || :TACKLE]
      battle(:NONE,:NONE,user_species: species,user_moves: moves,foe_moves: [:CELEBRATE],foe_species: :SLOWBRO)
      original_form=@user.pokemon.form
      equip(id)
      pokemon_form=@user.pokemon.form
      @user.pbInitialize(@user.pokemon,@user.pokemonIndex,false)
      holder_form=@user.form
      holder_types=@user.pbCurrentTypes
      candidate=@user.moves[0]
      move_type=candidate.pbType(candidate.type,@user,@foe) if attack
      turn(moves[0],:CELEBRATE)
      return [:mismatch,"#{species} form stayed #{holder_form} (base=#{original_form}, Pokémon=#{pokemon_form}); #{attack || 'attack'} type=#{move_type.inspect}"] if holder_form!=expected_form || pokemon_form!=expected_form
      if type
        type_id=PBTypes.const_get(type)
        if move_type!=type_id || ([:SILVALLY,:OGERPON].include?(species) && !holder_types.include?(type_id))
          return [:mismatch,"#{species} form=#{holder_form} types=#{holder_types.join(',')}; #{attack} type=#{move_type} expected #{type}"]
        end
      end
      return [:pass,"#{species} form=#{holder_form} types=#{holder_types.join(',')}; #{attack || :TACKLE} type=#{move_type.inspect}; completed turn"]
    end

    def contextual_turn(id)
      battle(:NONE,:NONE,user_moves: [:TACKLE],foe_moves: [:CELEBRATE],foe_species: :SNORLAX)
      equip(id)
      entry(@user)
      if @user.item==id && !@user.isFainted?
        assert(@user.itemWorks?,"Held item never became available")
        @battle.field.effects[PBEffects::MagicRoom]=3
        assert(!@user.itemWorks?,"Magic Room failed to disable held item gate")
        @battle.field.effects[PBEffects::MagicRoom]=0
        assert(@user.itemWorks?,"Held item gate did not restore")
      end
      turn(:TACKLE,:CELEBRATE)
      return "completed a normal equipped turn; hp=#{@user.hp} item=#{@user.item}; item availability suppressed and restored when held"
    end

    def special_held(symbol,id)
      case symbol
      when :GRIPCLAW,:BINDINGBAND
        results=[0,id,id].map.with_index do |held,index|
          battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
          equip(held)
          @battle.field.effects[PBEffects::MagicRoom]=3 if index==2
          assert(hit(:BIND)>0,"Bind did not land")
          turns=@foe.effects[PBEffects::MultiTurn]
          hp=@foe.hp
          round
          [turns,hp-@foe.hp]
        end
        base,held,suppressed=results
        equal(base,suppressed)
        symbol==:GRIPCLAW ? assert(held[0]>base[0],"Grip Claw did not extend Bind") :
                            assert(held[1]>base[1],"Binding Band did not increase chip damage")
        return "[duration, round HP loss] control/held/suppressed=#{results.inspect}"
      when :METRONOME
        values=[0,id,id].map.with_index do |held,index|
          battle(:NOGUARD,:NONE,user_moves: [:TACKLE],foe_moves: [:CELEBRATE],foe_species: :SNORLAX)
          @user.attack=125
          @foe.defense=110
          equip(held)
          @battle.field.effects[PBEffects::MagicRoom]=3 if index==2
          3.times.map do
            hp=@foe.hp
            turn(:TACKLE,:CELEBRATE)
            hp-@foe.hp
          end
        end
        assert(values[1].last>values[0].last,"Repeated attacks were not boosted")
        equal(values[0],values[2])
        return "Tackle damage per turn control/held/suppressed=#{values.inspect}"
      when :SAFETYGOGGLES
        battle(:NOGUARD,:NONE,user_moves: [:SPORE],foe_moves: [:CELEBRATE],foe_species: :SNORLAX)
        equip(id,@foe)
        turn(:SPORE,:CELEBRATE)
        equal(0,@foe.effects[PBEffects::Yawn])
        @battle.field.effects[PBEffects::MagicRoom]=3
        turn(:SPORE,:CELEBRATE)
        assert(@foe.effects[PBEffects::Yawn]>0,"Spore did not cause drowsiness with the goggles suppressed")
        return "blocked Spore until Magic Room"
      when :ANTIGRAVITYCORE
        battle(:NONE,:NONE)
        @battle.field.effects[PBEffects::Gravity]=3
        assert(!@user.isAirborne?,"Control should be grounded")
        equip(id)
        assert(@user.isAirborne?,"Core failed to levitate the holder")
        @battle.field.effects[PBEffects::MagicRoom]=3
        assert(!@user.isAirborne?,"Core still levitated the holder in Magic Room")
        return "levitated with Gravity; grounded after suppression"
      when :ABILITYSHIELD
        battle(:NOGUARD,:HUGEPOWER,user_moves: [:DOODLE],foe_moves: [:CELEBRATE])
        equip(id)
        original=@user.ability
        turn(:DOODLE,:CELEBRATE)
        equal(original,@user.ability)
        @battle.field.effects[PBEffects::MagicRoom]=3
        turn(:DOODLE,:CELEBRATE)
        equal(@foe.ability,@user.ability)
        return "protected the holder from Doodle's ability change until Magic Room"
      when :MEGARING
        battle(:NONE,:NONE,user_species: :GOLEM)
        equip(PBItems::DEMONSTONE)
        assert(!@battle.pbCanMegaEvolve?(@user.index),"Player Mega was already available")
        $PokemonBag.pbStoreItem(id)
        assert(@battle.pbCanMegaEvolve?(@user.index),"Mega Ring did not permit Rift Golem")
        return "bag enabled standard player Mega eligibility"
      when :VENGEANTDIADEM
        [false,true].each do |reserve|
          battle(:NONE,:NONE)
          @battle.party1.push(pokemon(:NONE,$Trainer,[:TACKLE])) if reserve
          @user.attack=200
          @user.spdef=5
          equip(id)
          entry
          expected=reserve ? PBStats::SPDEF : PBStats::ATTACK
          equal(1,@user.stages[expected])
          assert(@scene.messages.any? { |message| message.include?("Vengeant Diadem") },
                 "Entry did not announce the boost")
        end
        return "boosted highest stat as last member and lowest stat with a healthy reserve"
      when :GOLDENHELIX
        base,held,suppressed=compare_damage(id,:DOUBLEKICK)
        assert(held>base,"Double Kick did not gain power")
        equal(base,suppressed)
        return "Double Kick damage control=#{base} held=#{held} suppressed=#{suppressed}"
      when :MIXTAPE
        results=[0,id,id].map.with_index do |held,index|
          battle(:NOGUARD,:NONE,user_moves: [:TACKLE,:WATERGUN],foe_moves: [:CELEBRATE],foe_species: :SNORLAX)
          @user.attack=@user.spatk=125
          @foe.defense=@foe.spdef=110
          equip(held)
          @battle.field.effects[PBEffects::MagicRoom]=4 if index==2
          turn(:TACKLE,:CELEBRATE)
          hp=@foe.hp
          turn(:WATERGUN,:CELEBRATE)
          hp-@foe.hp
        end
        base,held,suppressed=results
        assert(held>base,"A special move that followed a physical move did not gain power")
        equal(base,suppressed)
        return "alternating damage control=#{base} held=#{held} suppressed=#{suppressed}"
      end
    ensure
      $PokemonBag.pbDeleteItem(id) if symbol==:MEGARING && $PokemonBag.pbQuantity(id)>0
    end

    def secondary_held(symbol,id)
      case symbol
      when :LEFTOVERS,:BLACKSLUDGE,:STICKYBARB,:FLAMEORB,:TOXICORB,:SHOCKORB,
           :FROSTORB,:DROWSYORB,:PRESSUREORB
        species=symbol==:BLACKSLUDGE ? :GRIMER : :SNORLAX
        battle(:NONE,:NONE,user_species: species)
        equip(id)
        baseline=@user.totalhp/2
        @user.hp=baseline
        round
        case symbol
        when :LEFTOVERS,:BLACKSLUDGE then equal(baseline+@user.totalhp/16,@user.hp)
        when :STICKYBARB then equal(baseline-@user.totalhp/8,@user.hp)
        when :FLAMEORB then equal(PBStatuses::BURN,@user.status)
        when :TOXICORB then equal(PBStatuses::POISON,@user.status)
        when :SHOCKORB then equal(PBStatuses::PARALYSIS,@user.status)
        when :FROSTORB then equal(PBStatuses::FROZEN,@user.status)
        when :PRESSUREORB then equal(PBStatuses::CRUSHED,@user.status)
        when :DROWSYORB
          assert(@user.effects[PBEffects::Yawn]>0 && @user.status!=PBStatuses::SLEEP,
                 "drowsy timer=#{@user.effects[PBEffects::Yawn]} status=#{@user.status}; Drowsy Orb should apply drowsiness first")
        end
        return "end of round hp=#{@user.hp}/#{@user.totalhp} status=#{@user.status}"
      when :ROCKYHELMET,:PROTECTIVEPADS,:PUNCHINGGLOVE
        battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
        equip(PBItems::ROCKYHELMET,@foe)
        equip(id) if symbol!=:ROCKYHELMET
        attack=symbol==:PUNCHINGGLOVE ? :DRAINPUNCH : :TACKLE
        assert(hit(attack)>0,"Contact attack did not land")
        expected=symbol==:ROCKYHELMET ? @user.totalhp-@user.totalhp/6 : @user.totalhp
        assert(expected==@user.hp,"#{attack} contact cost #{expected-@user.hp} extra HP with #{symbol}")
        return "#{attack} contact HP=#{@user.hp}/#{@user.totalhp}"
      when :LIFEORB,:SHELLBELL,:COUNTERWEIGHT,:BIGROOT
        attack={COUNTERWEIGHT: :ROLLOUT,BIGROOT: :DRAINPUNCH}.fetch(symbol,:TACKLE)
        trial=[0,id].map do |held|
          battle(:NOGUARD,:NONE,user_moves: [attack],foe_moves: [:CELEBRATE],foe_species: :SNORLAX)
          @user.hp=@user.totalhp/2
          initial=@user.hp
          equip(held)
          turn(attack,:CELEBRATE)
          [@foe.totalhp-@foe.hp,@user.hp-initial,@user.stages[PBStats::SPEED]]
        end
        base,held=trial
        case symbol
        when :LIFEORB
          assert(held[0]>base[0],"Life Orb did not increase damage")
          equal(-(@user.totalhp/10),held[1])
        when :SHELLBELL,:BIGROOT then assert(held[1]>base[1],"Expected an increase in healing")
        when :COUNTERWEIGHT then equal(1,held[2])
        end
        return "damage, HP change, and speed stage = #{trial.inspect}"
      when :HEAVYDUTYBOOTS
        battle(:NONE,:NONE)
        equip(id)
        @user.pbOwnSide.effects[PBEffects::Spikes]=3
        @battle.pbApplyEntryHazards(@user)
        equal(@user.totalhp,@user.hp)
        @battle.field.effects[PBEffects::MagicRoom]=3
        @battle.pbApplyEntryHazards(@user)
        equal(@user.totalhp-@user.totalhp/4,@user.hp)
        return "Spikes protection removed while Magic Room was active"
      when :FLOATSTONE
        battle(:NONE,:NONE,user_species: :SNORLAX)
        baseline=@user.weight
        equip(id)
        equal(baseline/2,@user.weight)
        @battle.field.effects[PBEffects::MagicRoom]=3
        equal(baseline,@user.weight)
        return "weight #{baseline} -> #{baseline/2}; suppressed to baseline"
      when :LOADEDDICE
        battle(:NONE,:NONE)
        @battle.define_singleton_method(:pbRandom) { |_limit| 0 }
        attack=move(:BULLETSEED)
        baseline=attack.pbNumHits(@user)
        equip(id)
        held=attack.pbNumHits(@user)
        assert(baseline==2 && held>=4,"Unexpected multistrike counts #{baseline} -> #{held}")
        return "Bullet Seed rolled #{baseline} hits without the item and #{held} with it"
      when :COVERTCLOAK
        battle(:NOGUARD,:NONE,foe_species: :SNORLAX)
        equip(id,@foe)
        assert(hit(:MUDSLAP)>0,"Mud Slap did not hit")
        equal(0,@foe.stages[PBStats::ACCURACY])
        return "Mud Slap damaged the holder without lowering accuracy"
      when :CLEARAMULET
        battle(:NONE,:INTIMIDATE)
        equip(id)
        entry(@foe)
        equal(0,@user.stages[PBStats::ATTACK])
        return "Intimidate did not lower holder's Attack"
      when :LIGHTCLAY,:AMPLIFIELDROCK
        attack,effect=symbol==:LIGHTCLAY ? [:REFLECT,PBEffects::Reflect] : [:TRICKROOM,nil]
        durations=[0,id,id].map.with_index do |held,index|
          battle(:NONE,:NONE)
          equip(held)
          @battle.field.effects[PBEffects::MagicRoom]=3 if index==2
          equal(0,move(attack).pbEffect(@user,@foe))
          effect ? @user.pbOwnSide.effects[effect] : @battle.trickroom
        end
        assert(durations[1]>durations[0],"No duration boost: #{durations.inspect}")
        return durations
      end
    end

    def party_item(symbol,id)
      battle(:NONE,:NONE,user_moves: [:TACKLE,:WATERGUN],user_species: :SNORLAX)
      target_index=0
      mon=@user.pokemon
      menu=PokeBattle_Scene.allocate
      menu.instance_variable_set(:@battle,@battle)
      menu.define_singleton_method(:pbChooseMove) { |*_args| 0 }
      if HEALING.key?(symbol)
        @user.hp=10
      elsif STATUS.key?(symbol)
        @user.status=PBStatuses.const_get(STATUS.fetch(symbol))
        @user.statusCount=3
        @user.hp=10 if symbol==:FULLRESTORE
      elsif REVIVE.key?(symbol)
        target_index=1
        mon=pokemon(:NONE,$Trainer,[:TACKLE],:SNORLAX)
        @battle.party1.push(mon)
        mon.hp=0
      elsif PP.key?(symbol)
        mon.moves.first(2).each_with_index do |candidate,index|
          candidate.pp=1
          @user.moves[index].pp=1
        end
      elsif symbol==:PERSIMBERRY || symbol==:YELLOWFLUTE
        @user.effects[PBEffects::Confusion]=3
      elsif symbol==:REDFLUTE
        @user.effects[PBEffects::Attract]=@foe.index
      end
      $achievements["MAX_FRIENDSHIP"]["level"]=1 if symbol==:BLUEMIC
      $PokemonBag.pbStoreItem(id)
      initial_pp=mon.moves.first(2).map(&:pp)
      menu_allowed=menu.pbCanUseBattleItem(target_index,id)
      precheck_pp=mon.moves.first(2).map(&:pp)
      move_index=ItemHandlers.single_move_pp_item?(id) ? 0 : nil
      # Blocked items still get a direct dispatch probe so the report can tell
      # whether the missing link is the menu or the effect itself.
      pbConsumeItemInBattle($PokemonBag,id)
      assert(@battle.pbRegisterItem(@user.index,id,target_index,move_index),"Battle did not register item")
      if [1,3].include?(PBItemData.get(id).battle_use)
        @battle.pbAttackPhase
      else
        @battle.pbUseItemOnPokemon(id,target_index,@user,@scene,move_index)
      end
      assert($game_variables[536]==1,"Party item did not apply")
      if HEALING.key?(symbol)
        recover=HEALING.fetch(symbol)
        recover=mon.totalhp if recover==:full
        recover=mon.totalhp/4 if recover==:quarter
        equal([10+recover,mon.totalhp].min,mon.hp)
      elsif STATUS.key?(symbol)
        equal(0,mon.status)
        equal(0,@user.status)
        equal(mon.totalhp,mon.hp) if symbol==:FULLRESTORE
      elsif REVIVE.key?(symbol)
        expected={half_plus_one: mon.totalhp/2+1,half: mon.totalhp/2,full: mon.totalhp}
        equal(expected.fetch(REVIVE.fetch(symbol)),mon.hp)
      elsif PP.key?(symbol)
        amount=PP.fetch(symbol)
        count=[:ELIXIR,:MAXELIXIR,:HOPOBERRY].include?(symbol) ? 2 : 1
        count.times do |index|
          total=mon.moves[index].totalpp
          expected=amount==:full ? total : [1+amount,total].min
          equal(expected,mon.moves[index].pp)
          equal(expected,@user.moves[index].pp)
        end
        equal(1,mon.moves[1].pp) if count==1
      elsif symbol==:PERSIMBERRY || symbol==:YELLOWFLUTE
        equal(0,@user.effects[PBEffects::Confusion])
      elsif symbol==:REDFLUTE
        equal(-1,@user.effects[PBEffects::Attract])
      elsif symbol==:COCONBERRY
        equal(@user.totalhp/3,@user.pbShieldHP)
      end
      return [menu_allowed,initial_pp!=precheck_pp]
    ensure
      $PokemonBag.pbDeleteItem(id) while $PokemonBag.pbQuantity(id)>0
    end

    def battler_item(symbol,id)
      battle(:NONE,:NONE,wild: ESCAPE_ITEMS.include?(symbol))
      if symbol==:DECOMPRESSOR
        @user.status=PBStatuses::CRUSHED
      elsif symbol==:RESETURGE
        @user.stages[PBStats::ATTACK]=-1
      elsif symbol==:ABILITYURGE
        @user.ability=PBAbilities::INTIMIDATE
      elsif symbol==:ITEMURGE
        @user.hp=10
        equip(PBItems::ORANBERRY)
      elsif symbol==:ITEMDROP
        equip(PBItems::ORANBERRY)
      elsif SCENTS.include?(symbol)
        equal(false,ItemHandlers.triggerBattleUseOnBattler(id,@user,@scene))
        @user.pokemon.shadow=true
        @user.pokemon.heartgauge=500
        @user.pokemon.hypermode=true
      end
      assert(@battle.pbRegisterItem(@user.index,id,@user.index),"Battle did not register item")
      if ESCAPE_ITEMS.include?(symbol)
        equal(3,@battle.decision)
        return "escaped wild battle"
      end
      if [2,4].include?(PBItemData.get(id).battle_use)
        @battle.pbAttackPhase
      else
        @battle.pbUseItemOnBattler(id,@user.index,@user,@scene)
      end
      equal(1,$game_variables[536])
      stat_match=symbol.to_s.match(/\A(XATTACK|XDEFEND|XSPECIAL|XSPDEF|XSPEED|XACCURACY)([236])?\z/)
      if stat_match
        stages=(stat_match[2] || 2).to_i
        equal([stages,3].min,@user.stages[PBStats.const_get(STAT.fetch(stat_match[1]))])
      elsif symbol.to_s.match?(/\ADIREHIT[23]?\z/)
        equal(symbol.to_s[-1].to_i.nonzero? || 1,@user.effects[PBEffects::FocusEnergy])
      elsif symbol==:GUARDSPEC
        equal(5,@user.pbOwnSide.effects[PBEffects::Mist])
      elsif symbol==:DECOMPRESSOR
        equal(0,@user.status)
      elsif symbol==:SNARE
        equal(@user.index,@foe.effects[PBEffects::MeanLook])
      elsif symbol==:MAGNETWAND
        equal(5,@user.effects[PBEffects::MagnetRise])
      elsif symbol==:RESETURGE
        equal(0,@user.stages[PBStats::ATTACK])
      elsif symbol==:ABILITYURGE
        equal(-1,@foe.stages[PBStats::ATTACK])
      elsif symbol==:ITEMURGE
        equal(0,@user.item)
        equal(20,@user.hp)
      elsif symbol==:ITEMDROP
        equal(0,@user.item)
        equal(0,@user.pokemon.itemRecycle)
      elsif SCENTS.include?(symbol)
        equal(false,@user.inHyperMode?)
        equal(200,@user.pokemon.heartgauge)
      end
      return "turn applied one successful item use#{stat_match && stat_match[2]=='6' ? "; global stage cap reduced +6 request to +3" : ""}"
    end

    def capture(symbol,id)
      foe_species={BEASTBALL: :NIHILEGO,FASTBALL: :JOLTEON}.fetch(symbol,:RATTATA)
      battle(:NONE,:NONE,wild: true,foe_species: foe_species)
      @foe.hp=1
      @foe.status=PBStatuses::SLEEP
      if CONDITIONAL_BALLS.key?(symbol)
        @battle.environment=PBEnvironment::Underwater if symbol==:DIVEBALL
        if symbol==:LEVELBALL
          @user.pokemon.level=75
          @user.pbUpdate
        end
        if symbol==:LOVEBALL
          @user.gender=0
          @foe.gender=1
        end
        $PokemonTemp.encounterType=EncounterTypes::OldRod if symbol==:LUREBALL
        equal(CONDITIONAL_BALLS.fetch(symbol),BallHandlers.modifyCatchRate(id,100,@battle,@foe))
      end
      captured=nil
      @battle.define_singleton_method(:pbStorePokemon) { |member| captured=member }
      money=$Trainer.money
      assert(@battle.pbRegisterItem(@user.index,id,@user.index),"Ball registration failed")
      equal(4,@battle.decision)
      equal(@foe.pokemon,captured)
      equal(id,pbBallTypeToBall(captured.ballused))
      case symbol
      when :FRIENDBALL then equal(255,captured.happiness)
      when :HEALBALL
        equal(captured.totalhp,captured.hp)
        equal(0,captured.status)
      when :VIRUSBALL then assert(captured.pokerusStage>0,"Pokérus was not applied")
      when :BANDITBALL then equal(100,$Trainer.money-money)
      when :LUXURYBALL then assert(captured.isShiny?,"Shiny flag was not applied")
      end
      return "wild status-assisted capture; ball type=#{captured.ballused}; conditional modifier checked=#{CONDITIONAL_BALLS.key?(symbol)}"
    ensure
      $PokemonTemp.encounterType=nil if symbol==:LUREBALL
    end

    def crystal(symbol,id)
      species,attack,form=SIGNATURE_CRYSTALS.fetch(symbol,[:RATTATA,TYPE_CRYSTALS[symbol]])
      attack=:TACKLE if symbol==:INTERCEPTZ2
      return nil if !attack
      battle(:NONE,:NONE,foe_species: species,foe_moves: [attack],user_species: :SLOWBRO)
      @foe.form=form if form
      @foe.pbUpdate(true) if form
      equip(id,@foe)
      $game_variables[646]=96 if symbol==:INTERCEPTZ2
      assert(@battle.pbCanZMove?(@foe.index),"Holder cannot use supplied crystal on #{attack}")
      assert(@foe.pbCompatibleZMoveFromMove?(@foe.moves[0]),"Crystal rejects #{attack}")
      if symbol!=:INTERCEPTZ2
        preview=PokeBattle_ZMoves.new(@battle,@foe,@foe.moves[0],id,false,true,0)
        assert(preview.zmove && preview.id>0,"Crystal did not produce a Z-Move")
      end
      return "#{species}/#{attack} passed availability and move compatibility#{form ? " form=#{form}" : ""}"
    ensure
      $game_variables[646]=0 if symbol==:INTERCEPTZ2
    end

    def mega_stone(id,species)
      battle(:NONE,:NONE,foe_species: species)
      base_stats=@foe.pokemon.baseStats.dup
      original_ability=@foe.ability
      equip(id,@foe)
      return [:mismatch,"the advertised holder #{species} cannot enter standard Mega Evolution"] if !@battle.pbCanMegaEvolve?(@foe.index)
      current_form=@foe.form
      @battle.pbRegisterMegaEvolution(@foe.index)
      @battle.pbMegaEvolve(@foe.index)
      if !@foe.isMega? || @foe.form==current_form
        return [:mismatch,"Mega Evolution did not change #{species} from form #{current_form}"]
      end
      mega_form=@foe.form
      mega_stats=@foe.pokemon.baseStats.dup
      assert(mega_stats!=base_stats,"Mega form kept all base stats")
      form_names=PBSpeciesData.get(@foe.pokemon.species).form_names.to_s.split(",",-1)
      render_form=AzureMegaForms.sprite_form(@foe.pokemon.species,mega_form)
      filename=pbCheckPokemonBitmapFiles([@foe.pokemon.species,false,false,false,mega_form,false])
      if id!=PBItems::DEMONSTONE
        assert(form_names[mega_form] && !form_names[mega_form].empty?,"Mega form name is missing")
      end
      @foe.pokemon.makeUnmega
      equal(current_form,@foe.pokemon.form)
      equal(base_stats,@foe.pokemon.baseStats)
      equal(original_ability,@foe.pokemon.ability)
      detail="#{species} changed from form #{current_form} to #{mega_form}, gained form stats and restored base state on reversal"
      return [:pass,detail] if id==PBItems::DEMONSTONE
      suffix=filename && File.basename(filename).match?(/_#{render_form}(?:\.png)?\z/i)
      return [:pass,detail,suffix ? nil : "dedicated front sprite for render form #{render_form} was not resolved; base artwork may be used"]
    end

    def reserved_mega_stone(id,species)
      battle(:NONE,:NONE,foe_species: species)
      equip(id,@foe)
      assert(!@battle.pbCanMegaEvolve?(@foe.index),"Reserved stone unexpectedly permits Mega Evolution")
      return "inactive as described; #{species} has no complete authored Mega profile for this stone"
    end

    def fling(id,power)
      battle(:NOGUARD,:NONE,foe_species: :SLOWBRO)
      equip(id)
      attack=move(:FLING)
      assert(!attack.pbMoveFailed(@user,@foe),"Fling rejected a catalogued throwable item")
      equal(power,attack.pbBaseDamage(1,@user,@foe))
      assert(hit(:FLING)>0,"Fling did not land")
      equal(0,@user.item)
      equal(id,@user.pokemon.itemRecycle)
      return "move hit and consumed held item; power=#{power}"
    end
  end

  def self.existing_cases
    suite=Cases.new
    %w[AzureDoubleDoseSurvival AzureDoubleDoseDamageItems AzureDoubleDoseHitItems AzureDoubleDoseTurnItems].each do |name|
      load File.join(File.dirname(__FILE__),name+".rb")
      Object.const_get(name).register(suite)
    end
    return suite.cases
  end

  def self.run(audit)
    coverage=existing_cases
    type_boosts=TYPE_BOOSTS.each_with_object({}) { |(attack,items),map| items.each { |item| map[item]=attack } }
    scenario=Scenario.new
    fling_tables=scenario.instance_eval { battle(:NONE); move(:FLING).flingarray }
    fling_powers=fling_tables.each_with_object({}) { |(power,items),map| items.each { |item| map[item] ||= power } }
    catalog=audit.catalog(:item,PBItems)
    extra=PBItemData.each.map(&:id).select { |id| id>0 }-catalog.map(&:last)
    extra.each { |id| audit.record(:item,id,:mismatch,"runtime-data","compiled item row has no PBItems symbol") }
    catalog.each do |symbol,id|
      item=PBItemData.try_get(id)
      if !item
        audit.record(:item,symbol,:mismatch,"runtime-data","id=#{id} has no compiled item record")
        next
      end
      audit_bag(audit,symbol,item)
      exercised=audit_held(audit,symbol,item,coverage,type_boosts)
      fling_power=fling_powers[symbol] || (pbIsBerry?(id) ? 10 : nil)
      if fling_power
        audit.check(:item,symbol,"fling") { Scenario.new.fling(id,fling_power) }
      end
      next if exercised || item.battle_use.to_i>0
      if pbTributeItemIDs.include?(id)
        audit.check(:item,symbol,"equipped-turn") { Scenario.new.contextual_turn(id) }
        audit.record(:item,symbol,:skip,"dedicated-tribute-suite","see the tributes catalog section for #{symbol} effects")
        next
      end
      if item.field_use.to_i>=3 || pbIsZCrystal2?(id)
        audit.record(:item,symbol,:skip,"field-use","id=#{id} field use=#{item.field_use}; no bag battle route or verified held effect")
      elsif pbIsCrest?(id) || pbIsZCrystal?(id) ||
         item.description.to_s.match?(/\b(held|holder|in battle|during battle)\b/i) ||
         [:MEGARING,:BATTLEBELT,:CATCHINGCHARM].include?(symbol)
        if !pbIsImportantItem?(id)
          audit.check(:item,symbol,"equipped-turn") { Scenario.new.contextual_turn(id) }
        end
        audit.record(:item,symbol,:gap,"contextual-item","id=#{id} specific item effect requires a matching species, move, condition, or battle-mode fixture")
      elsif item.field_use.to_i>0 || ItemHandlers.hasOutHandler(id) || ItemHandlers.hasKeyItemHandler(id) || pbIsZCrystal2?(id)
        audit.record(:item,symbol,:skip,"field-use","id=#{id} field use=#{item.field_use}; no bag battle route or verified held effect")
      else
        audit.record(:item,symbol,:skip,"no-native-battle-route","id=#{id} no declared battle-menu route or dedicated effect identified by this audit")
      end
    end
  end

  def self.audit_bag(audit,symbol,item)
    id=item.id
    declared=item.battle_use.to_i
    pokemon_route=ItemHandlers.hasBattleUseOnPokemon(id)
    battler_route=ItemHandlers.hasBattleUseOnBattler(id)
    if declared>0
      allowed=[1,3].include?(declared) ? pokemon_route : battler_route
      if !allowed
        expected=[1,3].include?(declared) ? "party Pokémon" : "active battler"
        registered=pokemon_route || battler_route ? "; handler exists for a different target route" : ""
        audit.record(:item,symbol,:mismatch,"battle-menu-routing","battle_use=#{declared} selects #{expected} but no matching handler#{registered}")
      end
    elsif pokemon_route || battler_route
      audit.record(:item,symbol,:mismatch,"battle-menu-routing","battle_use=0 hides a registered battle handler")
    end
    if pbIsPokeBall?(id)
      audit.check(:item,symbol,"capture") { Scenario.new.capture(symbol,id) }
    elsif pokemon_route
      result=audit.check(:item,symbol,"bag-party-item") { Scenario.new.party_item(symbol,id) }
      if result
        menu_allowed,early_pp=result
        if !menu_allowed && [1,3].include?(declared)
          audit.record(:item,symbol,:mismatch,"battle-menu-eligibility","menu rejected a suitable target; forced dispatch applied the effect")
        end
        if early_pp
          audit.record(:item,symbol,:mismatch,"battle-menu-eligibility","target eligibility changes move PP before item registration and turn resolution")
        end
      end
    elsif battler_route
      audit.check(:item,symbol,"bag-active-item") { Scenario.new.battler_item(symbol,id) }
    end
  end

  def self.audit_held(audit,symbol,item,coverage,type_boosts)
    id=item.id
    mega_descriptor=item.description.to_s.match(/\bHave ([A-Za-z .’'-]+?) hold it, and this stone will enable it to Mega Evolve\b/)
    mega_species=mega_descriptor && mega_descriptor[1].upcase.gsub(/[^A-Z]/,"").to_sym
    reserved_descriptor=item.description.to_s.match(/\bA reserved Mega Stone for ([A-Za-z .’'-]+?)\./)
    reserved_species=reserved_descriptor && reserved_descriptor[1].upcase.gsub(/[^A-Z]/,"").to_sym
    mega_species={BANETTITE: :BANETTE,HERACRONITE: :HERACROSS}.fetch(symbol,mega_species)
    mega_species=:GOLEM if symbol==:DEMONSTONE
    if coverage.key?(symbol)
      audit.check(:item,symbol,"held-double-dose") do
        AzureAbilityFixture::Scenario.new.instance_exec(&coverage.fetch(symbol))
        "native held activation and Double Dose assertions passed"
      end
    elsif type_boosts.key?(symbol) || HELD_DAMAGE.key?(symbol)
      audit.check(:item,symbol,"held-damage-boost") do
        attack,holder,species=HELD_DAMAGE.fetch(symbol,[type_boosts[symbol],:user,:SLOWBRO])
        base,held,suppressed=Scenario.new.compare_damage(id,attack,holder,species)
        changed=holder==:user ? held>base : held<base
        raise "No expected damage change (#{base} -> #{held})" unless base>0 && changed
        raise "Magic Room did not restore baseline damage (#{base} vs #{suppressed})" unless base==suppressed
        "move=#{attack} base=#{base} held=#{held} suppressed=#{suppressed}"
      end
    elsif HELD_SPEED.key?(symbol)
      speeds=audit.check(:item,symbol,"held-speed") do
        species,direction=HELD_SPEED.fetch(symbol)
        Scenario.new.instance_eval do
          battle(:NONE,:NONE,user_species: species)
          baseline=@user.pbSpeed
          equip(id)
          held=@user.pbSpeed
          @battle.field.effects[PBEffects::MagicRoom]=3
          suppressed=@user.pbSpeed
          changed=direction==:up ? held>baseline : held<baseline
          assert(changed,"No held speed change (#{baseline} -> #{held})")
          [baseline,held,suppressed]
        end
      end
      if speeds && speeds[0]!=speeds[2]
        audit.record(:item,symbol,:mismatch,"held-suppression","Magic Room did not restore Speed: #{speeds.inspect}")
      end
    elsif WEATHER.key?(symbol)
      durations=audit.check(:item,symbol,"held-weather") do
        [0,id,id].map.with_index do |held,index|
          Scenario.new.instance_eval do
            battle(:NONE,:NONE)
            equip(held)
            @battle.field.effects[PBEffects::MagicRoom]=3 if index==2
            equal(0,move(WEATHER.fetch(symbol)).pbEffect(@user,@foe))
            @battle.weatherduration
          end
        end.tap { |base,held,_suppressed| raise "No duration boost (#{base} -> #{held})" unless held>base }
      end
      if durations && durations[2]!=durations[0]
        audit.record(:item,symbol,:mismatch,"held-suppression","Magic Room should restore weather duration; base=#{durations[0]} held=#{durations[1]} suppressed=#{durations[2]}")
      end
    elsif TYPE_CRYSTALS.key?(symbol) || SIGNATURE_CRYSTALS.key?(symbol) || symbol==:INTERCEPTZ2
      audit.check(:item,symbol,"held-z-crystal") { Scenario.new.crystal(symbol,id) }
    elsif SPECIAL_HELD.include?(symbol)
      audit.check(:item,symbol,"held-specific-effect") { Scenario.new.special_held(symbol,id) }
    elsif reserved_species && PBSpecies.const_defined?(reserved_species,false)
      detail=audit.check(:item,symbol,"held-mega-reserved") { Scenario.new.reserved_mega_stone(id,reserved_species) }
      audit.record(:item,symbol,:gap,"held-mega-profile",detail) if detail
    elsif ITEM_FORMS.key?(symbol) || symbol.to_s.end_with?("MEMORY")
      begin
        status,detail=Scenario.new.item_form(symbol,id)
        audit.record(:item,symbol,status,"held-form",detail)
      rescue StandardError => error
        audit.record(:item,symbol,:error,"held-form","#{error.class}: #{error.message}")
      end
    elsif mega_species && PBSpecies.const_defined?(mega_species)
      begin
        status,detail,sprite_gap=Scenario.new.mega_stone(id,mega_species)
        audit.record(:item,symbol,status,"held-mega-stone",detail)
        audit.record(:item,symbol,:gap,"held-mega-sprite",sprite_gap) if sprite_gap
      rescue StandardError => error
        audit.record(:item,symbol,:error,"held-mega-stone","#{error.class}: #{error.message}")
      end
    elsif [:LEFTOVERS,:BLACKSLUDGE,:STICKYBARB,:FLAMEORB,:TOXICORB,:ROCKYHELMET,
           :PROTECTIVEPADS,:PUNCHINGGLOVE,:LIFEORB,:SHELLBELL,:COUNTERWEIGHT,:BIGROOT,
           :HEAVYDUTYBOOTS,:LIGHTCLAY,:AMPLIFIELDROCK,:SHOCKORB,:FROSTORB,:DROWSYORB,
           :PRESSUREORB,:FLOATSTONE,:LOADEDDICE,:COVERTCLOAK,:CLEARAMULET].include?(symbol)
      if DETECTED_HELD_MISMATCHES.include?(symbol)
        begin
          detail=Scenario.new.secondary_held(symbol,id)
          audit.record(:item,symbol,:pass,"held-context",detail)
        rescue RuntimeError => error
          audit.record(:item,symbol,:mismatch,"held-description",error.message)
        end
      else
        detail=audit.check(:item,symbol,"held-context") { Scenario.new.secondary_held(symbol,id) }
      end
      if detail.is_a?(Array) && detail[0]!=detail[2]
        audit.record(:item,symbol,:mismatch,"held-suppression","Magic Room did not restore duration: #{detail.inspect}")
      end
    else
      return false
    end
    return true
  end
end
