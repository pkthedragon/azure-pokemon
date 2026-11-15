module AzureCatalogMoves
  MULTI_TARGET=[PBTargets::AllOpposing,PBTargets::AllNonUsers,PBTargets::DragonDarts,
    PBTargets::ThunderRaid].freeze
  SELECTABLE=[PBTargets::SingleNonUser,PBTargets::SingleOpposing,
    PBTargets::Partner,PBTargets::UserOrPartner].freeze
  TEAM_MOVES=%i[AFTERYOU ALLYSWITCH AROMATICMIST COACHING DEFOG DOODLE EERIESPELL HEALBELL AROMATHERAPY
    FAIRYLOCK FOLLOWME GEARUP HAPPYHOUR HOLDHANDS IONDELUGE LIFEDEW MAGNETICFLUX QUASH
    POLLENPUFF PURIFY RAGEPOWDER REVIVALBLESSING SPOTLIGHT TEATIME].freeze
  HEALING=%i[ACUPRESSURE BEAUTIFY COLDVEIN DRAININGKISS EGGBOMB FERTILIZE GLACIALSTATE
    HEALORDER HEALPULSE HEALINGWISH JUNGLEHEALING LIFEDEW LUNARDANCE
    LUNARBLESSING MIRACLE MILKDRINK MOONLIGHT MORNINGSUN PAINSPLIT POLLENPUFF
    RECOVER REST ROOST SHOREUP SLACKOFF SOFTBOILED STRENGTHSAP SWALLOW SYNTHESIS WISH].freeze
  PIVOTS=%i[ASSIST BATONPASS CHILLYRECEPTION CIRCLETHROW DRAGONTAIL FLIPTURN
    HEALINGWISH LUNARDANCE MEMENTO PARTINGSHOT PURSUIT ROAR SHEDTAIL UTURN
    VOLTSWITCH WHIRLWIND].freeze
  LAST_MOVE=%i[COPYCAT DISABLE ENCORE INSTRUCT MIMIC MIRRORMOVE PSYCHOSHIFT SKETCH SPITE].freeze
  LEGACY_MOVE_FIELDS={
    ORIGINPULSE: [46,21,"The beach flooded!"],
    PRECIPICEBLADES: [38,45,"The field went up in flames!"],
    DRAGONASCENT: [29,29,"The legendary energy resonated"],
    THOUSANDARROWS: [43,27,"The battle has been brought down to the mountains!"],
    THOUSANDWAVES: [12,12,"The desert strengthened the attack!"],
    DIAMONDSTORM: [25,25,"The crystals strengthened the attack!"],
    STEAMERUPTION: [12,12,"The desert strengthened the attack!"]
  }.freeze
  Z_FIXTURES=[
    [:NORMALIUMZ2,:TACKLE],[:FIGHTINIUMZ2,:AURASPHERE],[:FLYINIUMZ2,:GUST],
    [:POISONIUMZ2,:ACIDSPRAY],[:GROUNDIUMZ2,:MUDSHOT],[:ROCKIUMZ2,:ROCKTHROW],
    [:BUGINIUMZ2,:BUGBUZZ],[:GHOSTIUMZ2,:SHADOWBALL],[:STEELIUMZ2,:FLASHCANNON],
    [:FIRIUMZ2,:FLAMETHROWER],[:WATERIUMZ2,:SURF],[:GRASSIUMZ2,:ENERGYBALL],
    [:ELECTRIUMZ2,:THUNDERBOLT],[:PSYCHIUMZ2,:PSYCHIC],[:ICIUMZ2,:ICEBEAM],
    [:DRAGONIUMZ2,:DRAGONPULSE],[:DARKINIUMZ2,:DARKPULSE],[:FAIRIUMZ2,:MOONBLAST],
    [:ALORAICHIUMZ2,:THUNDERBOLT,:RAICHU,1],[:DECIDIUMZ2,:SPIRITSHACKLE,:DECIDUEYE],
    [:INCINIUMZ2,:DARKESTLARIAT,:INCINEROAR],[:PRIMARIUMZ2,:SPARKLINGARIA,:PRIMARINA],
    [:EEVIUMZ2,:LASTRESORT,:EEVEE],[:PIKANIUMZ2,:VOLTTACKLE,:PIKACHU],
    [:SNORLIUMZ2,:GIGAIMPACT,:SNORLAX],[:MEWNIUMZ2,:PSYCHIC,:MEW],
    [:TAPUNIUMZ2,:NATURESMADNESS,:TAPUKOKO],[:MARSHADIUMZ2,:SPECTRALTHIEF,:MARSHADOW],
    [:KOMMONIUMZ2,:CLANGINGSCALES,:KOMMOO],[:LYCANIUMZ2,:STONEEDGE,:LYCANROC],
    [:MIMIKIUMZ2,:PLAYROUGH,:MIMIKYU],[:SOLGANIUMZ2,:SUNSTEELSTRIKE,:SOLGALEO],
    [:LUNALIUMZ2,:MOONGEISTBEAM,:LUNALA],[:ULTRANECROZIUMZ2,:PHOTONGEYSER,:NECROZMA,3],
    [:INTERCEPTZ2,:TACKLE],[:INTERCEPTZ2,:TACKLE],
    [:INTERCEPTZ2,:TACKLE],[:INTERCEPTZ2,:TACKLE]
  ].freeze

  module Trace
    def pbUseMove(choice,*args)
      @battle.scene.uses << [@index,choice[2].id]
      super
    end

    def pbProcessMoveAgainstTarget(move,user,target,*args)
      @battle.scene.targets << [move.id,target && target.index]
      super
    end
  end

  module NoFrameDelay
    def pbWait(_frames); end
  end

  class Scenario < AzureAbilityFixture::Scenario
    def initialize(name,data,format=nil,species=nil,base=nil,form=nil)
      @name=name
      @data=data
      @base=base || name
      format ||= if MULTI_TARGET.include?(data.target) || name==:SHADOWHALF
        :triple
      elsif [PBTargets::Partner,PBTargets::UserOrPartner].include?(data.target) ||
            TEAM_MOVES.include?(name) || name==:KOMMONIUMZ2
        :double
      else
        :single
      end
      @format=format
      species ||= { AURAWHEEL: :MORPEKO, HYPERSPACEFURY: :HOOPA,
        DARKVOID: :DARKRAI, SKETCH: :SMEARGLE }.fetch(name,:EEVEE)
      opposing_move={ UPPERHAND: :QUICKATTACK, PURSUIT: :TACKLE, MEFIRST: :TACKLE,
        THUNDERCLAP: :TACKLE, SHELLTRAP: :TACKLE,
        COMEUPPANCE: :TACKLE, METALBURST: :TACKLE, SUCKERPUNCH: :TACKLE }.fetch(name,:CELEBRATE)
      foe_species=if %i[REFLECTTYPE SKILLSWAP ROLEPLAY ENTRAINMENT].include?(name)
        :UMBREON
      elsif data.type==PBTypes::NORMAL || data.type==PBTypes::FIGHTING || name==:SYNCHRONOISE
        :SLAKING
      else
        :MILOTIC
      end
      foe_ability=%i[DOODLE ENTRAINMENT ROLEPLAY SKILLSWAP].include?(name) ? :INNERFOCUS : :NONE
      battle(:NONE,foe_ability,user_species: species,foe_species: foe_species,
        user_moves: [@base,:TACKLE,:VINEWHIP,:CELEBRATE,:QUICKATTACK].uniq.first(4),
        foe_moves: [opposing_move,:TACKLE].uniq,
        outer_ally: (format==:triple ? :NONE : nil),foe_ally: (format==:double ? :NONE : nil),
        wild: name==:TELEPORT)
      @battle.extend(NoFrameDelay)
      @battle.battlers.each { |battler| battler.extend(NoFrameDelay) }
      @uses=[]
      @targets=[]
      uses=@uses
      targets=@targets
      @scene.define_singleton_method(:uses) { uses }
      @scene.define_singleton_method(:targets) { targets }
      @scene.define_singleton_method(:pbVanishSprite) { |battler| battler.vanished=true }
      @scene.define_singleton_method(:pbUnVanishSprite) { |battler,_fade=true| battler.vanished=false }
      @scene.define_singleton_method(:pbDisplayConfirmMessage) { |_message| false }
      @scene.define_singleton_method(:partyBetweenKO1) { |_opposing=true| }
      @battle.activeBattlerIndices.each do |index|
        @battle.battlers[index].extend(Trace)
        @battle.battlers[index].turncount=0
      end
      if data.type==PBTypes::GHOST
        @battle.activeBattlerIndices.select(&:odd?).each do |index|
          @battle.battlers[index].type1=@battle.battlers[index].type2=PBTypes::WATER
        end
      end
      form=1 if name==:HYPERSPACEFURY
      if !form.nil?
        @user.pokemon.form=form
        @user.form=@user.pokemon.form
        @user.pbUpdate(true)
      end
    end

    def add_reserve(battler, fainted=false)
      reserve=pokemon(:NONE,@battle.pbGetOwner(battler.index),[:TACKLE],:RALTS)
      reserve.hp=0 if fainted
      @battle.pbParty(battler.index).push(reserve)
      reserve
    end

    def prepare
      add_reserve(@user,@name==:REVIVALBLESSING) if PIVOTS.include?(@name) || @name==:REVIVALBLESSING
      add_reserve(@foe) if %i[CIRCLETHROW DRAGONTAIL PURSUIT ROAR WHIRLWIND SPIKES
        STEALTHROCK TOXICSPIKES STICKYWEB UNDERTOW].include?(@name)
      @user.pbReduceHP(@user.totalhp/4,false) if HEALING.include?(@name)
      @user.pbReduceHP(@user.totalhp/4,false) if @name==:FILLETAWAY
      if HEALING.include?(@name) && @ally.pokemon
        @ally.pbReduceHP(@ally.totalhp/3,false)
      end
      if @data.type==PBTypes::SHADOW
        @user.pokemon.shadow=true
        @user.pokemon.heartgauge=1000
      end
      if LAST_MOVE.include?(@name)
        @user.speed=150
        @foe.speed=30
        @foe.lastMoveUsed=PBMoves::QUICKATTACK
        @foe.lastMoveUsedSketch=PBMoves::QUICKATTACK
        @foe.lastRegularMoveUsed=PBMoves::QUICKATTACK
        @foe.moves[1]=move(:QUICKATTACK,@foe)
        @battle.lastMoveUsed=PBMoves::QUICKATTACK
      end
      case @name
      when :SNORE,:SLEEPTALK
        @user.status=PBStatuses::SLEEP
        @user.statusCount=3
      when :DREAMEATER,:NIGHTMARE,:WAKEUPSLAP
        @foe.status=PBStatuses::SLEEP
        @foe.statusCount=3
      when :SMELLINGSALTS
        @foe.status=PBStatuses::PARALYSIS
      when :JUNGLEHEALING,:LUNARBLESSING,:PSYCHOSHIFT,:REFRESH
        @user.status=PBStatuses::BURN
      when :PURIFY,:VENOMDRENCH,:VENOSHOCK,:BARBBARRAGE
        @foe.status=PBStatuses::POISON
      when :BURNUP,:DOUBLESHOCK
        @user.type1=PBTypes::FIRE
        @user.type2=PBTypes::FIRE
      when :POLLENPUFF,:HEALPULSE
        @ally.pbReduceHP(@ally.totalhp/3,false) if @ally.pokemon
      when :SPITUP,:SWALLOW
        @user.effects[PBEffects::Stockpile]=2
      when :RECYCLE
        @user.pokemon.itemRecycle=PBItems::SITRUSBERRY
      when :BELCH
        $belch=true
      when :FLING,:NATURALGIFT,:STUFFCHEEKS,:BESTOW,:BUGBITE,:PLUCK,:TEATIME,:MYSTICHARVEST
        @user.item=PBItems::SITRUSBERRY
        @foe.item=PBItems::ORANBERRY if %i[BUGBITE PLUCK TEATIME].include?(@name)
      when :TRICK,:SWITCHEROO,:KNOCKOFF,:POLTERGEIST,:CORROSIVEGAS,:THIEF,:COVET,:EMBARGO
        @foe.item=PBItems::LEFTOVERS
      when :SHADOWSHED,:DEFOG,:BRICKBREAK,:PSYCHICFANGS,:COURTCHANGE,:RAGINGBULL,:TIDYUP
        @foe.pbOwnSide.effects[PBEffects::Reflect]=4
        @foe.pbOwnSide.effects[PBEffects::LightScreen]=4
        @user.pbOwnSide.effects[PBEffects::StealthRock]=true
      when :HEARTSWAP,:PSYCHUP,:POWERSWAP,:GUARDSWAP,:TOPSYTURVY,:SPECTRALTHIEF
        @foe.stages[PBStats::ATTACK]=2
        @foe.stages[PBStats::DEFENSE]=2
        @foe.stages[PBStats::SPDEF]=2
      when :LASTRESORT,:CATHARSIS
        @user.movesUsed.concat(@user.moves.map(&:id)-[0,@data.id])
      when :LASTRESPECTS
        add_reserve(@user,true)
      when :AURORAVEIL
        @battle.weather=PBWeather::HAIL
        @battle.weatherduration=5
      when :CAMOUFLAGE
        $fefieldeffect=2
      when :STEELROLLER
        @battle.field.effects[PBEffects::GrassyTerrain]=5
      when :MUDBATH
        @user.status=PBStatuses::PARALYSIS
      when :FLOWERSHIELD,:ROTOTILLER
        @foe.type1=PBTypes::GRASS
      when :MOONRISE
        @user.type1=PBTypes::FAIRY
        @foe.type1=PBTypes::DARK
      when :FERTILIZE
        @user.moveHistory.push([-1,PBMoves::VINEWHIP,PBTypes::GRASS])
      when :COMEUPPANCE,:METALBURST,:FOCUSPUNCH,:SHELLTRAP
        @user.speed=10
        @foe.speed=90
      when :THUNDERCLAP,:SUCKERPUNCH,:UPPERHAND,:MEFIRST
        @user.speed=150
        @foe.speed=30
      when :GEARUP,:MAGNETICFLUX
        @user.ability=PBAbilities::PLUS
        @ally.ability=PBAbilities::MINUS
      when :AFTERYOU,:INSTRUCT,:HELPINGHAND
        @user.speed=150
        @foe.speed=30
      when :QUASH
        @user.speed=150
        @foe.speed=120
        @ally.speed=90
        @foe_ally.speed=60
      end
    end

    def target_for(battler,move)
      target_mode=battler.pbTarget(move)
      if battler==@user && @ally.pokemon &&
         (target_mode==PBTargets::Partner ||
         %i[ACUPRESSURE AFTERYOU AROMATICMIST HEALPULSE INSTRUCT MIRACLE POLLENPUFF SPOTLIGHT].include?(@name))
        return 2
      end
      return -1 if [PBTargets::Partner,PBTargets::UserOrPartner].include?(target_mode)
      return battler.index^1 if SELECTABLE.include?(target_mode)
      -1
    end

    def register(battler,index)
      raise "Move slot #{index} rejected for battler #{battler.index}" if
        !@battle.pbRegisterMove(battler.index,index,false)
      choice=@battle.choices[battler.index]
      target=target_for(battler,choice[2])
      @battle.pbRegisterTarget(battler.index,target) if target>=0
    end

    def other_commands
      @battle.activeBattlerIndices.each do |index|
        next if index==0 || @battle.battlers[index].isFainted?
        battler=@battle.battlers[index]
        if @name==:PURSUIT && index==1 && @battle.turncount==0
          raise "Pursuit fixture could not register opposing switch" if
            !@battle.pbRegisterSwitch(index,@battle.pbParty(index).length-1)
        elsif index==1
          register(battler,0)
        else
          battler.moves[0]=move(:CELEBRATE,battler)
          register(battler,0)
        end
      end
    end

    def advance
      @battle.pbAttackPhase
      @battle.pbEndOfRoundPhase if @battle.decision==0
      @battle.instance_variable_set(:@turncount,@battle.turncount+1)
    end

    def use_saved_move(legacy_id)
      stored=PBMove.allocate
      stored.instance_variable_set(:@id,legacy_id)
      stored.ppup=2
      stored.pp=3
      restored=Marshal.load(Marshal.dump(stored))
      raise "Legacy save lost its move ID before loading" if restored.instance_variable_get(:@id)!=legacy_id
      raise "Legacy save lost PP or PP Ups" unless restored.pp==3 && restored.ppup==2
      @user.pokemon.moves[0]=restored
      @user.moves[0]=PokeBattle_Move.pbFromPBMove(@battle,restored,@user)
      raise "Legacy save loaded a different move" if @user.moves[0].id!=@data.id
      fields=LEGACY_MOVE_FIELDS.fetch(@name)
      result=execute do
        $fefieldeffect,$febackup=[fields[0]]*2
      end
      raise "Migrated move spent wrong PP" if restored.id!=@data.id || restored.pp!=2 || restored.ppup!=2
      if $fefieldeffect!=fields[1] || !result[:messages].any? { |msg| msg.include?(fields[2]) }
        raise "Migrated move did not apply canonical field effect: #{result[:detail]}"
      end
      result[:detail]
    end

    def legacy_move_queries(old_id)
      pokemon=@user.pokemon
      pokemon.moves[3]=PBMove.new(0)
      @user.moves[3]=PokeBattle_Move.pbFromPBMove(@battle,pokemon.moves[3],@user)
      @battle.pbRegisterMove(@user.index,0,false)
      if !pokemon.knowsMove?(old_id) || !pbHasMove?(pokemon,old_id) ||
         pbCheckMove(old_id)!=pokemon || !@user.pbHasMove?(old_id) || !@battle.pbChoseMove?(@user.index,old_id)
        raise "Legacy ID did not match its canonical move through the Pokémon, party, and battle queries"
      end
      starting_ids=pokemon.moves.map(&:id).sort
      pokemon.pbLearnMove(old_id)
      pbAutoLearnMove(pokemon,old_id)
      @battle.pbLearnMove(@user.pokemonIndex,old_id)
      raise "Learning a known legacy move added a duplicate or replaced another move" if pokemon.moves.map(&:id).sort!=starting_ids
      pokemon.pbDeleteMove(old_id)
      raise "Deleting a legacy ID did not remove its canonical move" if pokemon.knowsMove?(@name)
      "old_id=#{old_id} id=#{@data.id} lookup, duplicate-safe learning, and deletion verified"
    end

    def snapshot
      @battle.activeBattlerIndices.map do |index|
        battler=@battle.battlers[index]
        [battler.hp,battler.status,battler.item,battler.pokemonIndex]
      end
    end

    def report(before,used)
      after=snapshot
      changes=before.zip(after).each_with_index.filter_map do |(original,final),index|
        next if original==final
        "#{index}:#{original.join('/')}>#{final.join('/')}"
      end
      msgs=@scene.messages.map { |msg| msg.to_s.gsub(/[[:space:]]+/," ") }
      relevant=move_messages(msgs,used.name)
      failures=relevant.drop(1).take_while { |msg| !msg.match?(/ used | is struggling!/i) }
        .grep(/failed|no target|doesn't affect|^.*'s attack missed/i).reject { |msg| msg.include?("foe") && msg.include?("attack missed") }
      if @name==:QUASH
        order=@uses.map(&:first)
        expected=[0,2,3,1]
        raise "Quash should postpone the second-fastest battler. Expected #{expected}, got #{order}" if order!=expected
        relevant.push("action_order=#{order.join(',')}")
      end
      {
        detail: "id=#{used.id} function=#{used.function} handler=#{used.class} format=#{@format} " +
          "rounds=#{@battle.turncount} pp=#{used.pp.inspect} targets=#{@targets.select { |id,_| id==used.id }.map(&:last).join(',')} " +
          "actor_state_hp_status_item_party=#{changes.join(';')} weather=#{@battle.pbWeather} field=#{$fefieldeffect} " +
          "outcome=#{@battle.decision} messages=#{relevant.join(' / ')}",
        failures: failures,
        messages: msgs,
        before: before,
        after: after
      }
    end

    def move_messages(messages,name)
      first=messages.index { |msg| !name.to_s.empty? && msg.include?(name) }
      first ? messages[first,4] : messages.first(4)
    end

    def execute
      prepare
      yield self if block_given?
      original=@user.moves.first
      before=snapshot
      if @name==:STRUGGLE
        @user.moves.each { |move| move.pp=0 }
        @battle.pbAutoChooseMove(@user.index,false)
        raise "No-PP fallback selected a different move" unless @battle.choices[0][2].id==@data.id
      else
        register(@user,0)
      end
      other_commands
      advance
      raise "Move never reached the execution pipeline" unless @uses.include?([0,@data.id])
      if @name!=:STRUGGLE && original.totalpp>0 && original.pp>=original.totalpp
        raise "Registered move did not spend PP"
      end
      if @name!=:SHADOWHALF && @battle.decision==0 && (@user.effects[PBEffects::TwoTurnAttack]>0 ||
          @user.effects[PBEffects::HyperBeam]>0 || @user.effects[PBEffects::Outrage]>0 ||
          [PBMoves::FUTURESIGHT,PBMoves::DOOMDESIRE,PBMoves::FOREBODE,PBMoves::WISH,PBMoves::BIDE].include?(@data.id))
        3.times do
          break if @battle.decision>0 || @user.isFainted?
          register(@user,@user.moves.index { |move| move.id==PBMoves::TACKLE } || 0)
          other_commands
          advance
        end
      end
      report(before,original)
    end

    def lane_probe
      case @name
      when :HAZE
        @battle.battlers.values_at(0,2,4).each { |battler| battler.stages[PBStats::ATTACK]=2 }
        @outer_ally.effects[PBEffects::MultiTurn]=3
        @outer_ally.effects[PBEffects::MultiTurnAttack]=PBMoves::BINDINGWORD
        @outer_ally.effects[PBEffects::MultiTurnUser]=@foe.index
        @outer_ally.effects[PBEffects::StatChangeHolder][PBStats::ATTACK]=4
      when :FLOWERSHIELD,:ROTOTILLER
        @battle.battlers.values_at(2,4,5).each { |battler| battler.type1=battler.type2=PBTypes::GRASS }
      end
      execute
      case @name
      when :HAZE
        @outer_ally.pbClearMultiTurn
        values=@battle.battlers.values_at(0,2,4).map { |battler| battler.stages[PBStats::ATTACK] }
        [values==[0,0,0],"expected Attack stages 0,0,0 after Binding Word releases; actual #{values.join(',')} at lanes 0,2,4"]
      when :SHADOWHALF
        values=@battle.activeBattlerIndices.map { |i| @battle.battlers[i].hp }
        expected=@battle.activeBattlerIndices.map { |i| (@battle.battlers[i].totalhp+1)/2 }
        [values==expected,"expected halved HP #{expected.join(',')}; actual #{values.join(',')}"]
      when :PERISHSONG
        values=@battle.activeBattlerIndices.map { |i| @battle.battlers[i].effects[PBEffects::PerishSong] }
        [values.all? { |count| count>0 },"expected countdown on six battlers; actual #{values.join(',')}"]
      when :FLOWERSHIELD
        values=@battle.battlers.values_at(2,4,5).map { |battler| battler.stages[PBStats::DEFENSE] }
        [values==[1,1,1],"expected Defense stages 1,1,1 at lanes 2,4,5; actual #{values.join(',')}"]
      when :ROTOTILLER
        stats=[PBStats::ATTACK,PBStats::SPATK,PBStats::SPDEF]
        values=@battle.battlers.values_at(2,4,5).map { |battler| battler.stages.values_at(*stats).join('/') }
        [values==["1/1/0"]*3,
          "expected Attack/Sp.Atk/Sp.Def 1/1/0 at lanes 2,4,5; actual #{values.join(',')}"]
      when :COACHING
        values=@battle.battlers.values_at(2,4).map { |battler| battler.stages[PBStats::ATTACK] }
        [values==[1,1],"expected both allies' Attack stages 1,1; actual #{values.join(',')}"]
      end
    end

    def charge_probe(weather,item=0)
      @battle.weather=weather
      @battle.weatherduration=5
      @user.item=item
      @user.speed=150
      before=@foe.hp
      register(@user,0)
      other_commands
      advance
      first=@foe.hp
      first_stage=@user.stages[PBStats::SPATK]
      charging=@user.effects[PBEffects::TwoTurnAttack]>0
      if charging
        register(@user,0)
        other_commands
        advance
      end
      charged=weather!=PBWeather::RAINDANCE || item==PBItems::UTILITYUMBRELLA
      final=@foe.hp
      final_stage=@user.stages[PBStats::SPATK]
      consistent=first_stage==1 && final_stage==1 && charging==charged && final<before &&
        (charged ? first==before : first<before)
      [consistent,"charged=#{charging} first_hp=#{first} final_hp=#{final} initial_hp=#{before} Sp.Atk=#{first_stage},#{final_stage}"]
    end

    def hot_tempo_probe
      samples=[0,99,100,299,300,324,325]
      move=@user.moves.first
      actual=samples.map do |hype|
        $game_variables[115]=hype
        [
          move.pbBaseDamage(move.basedamage,@user,@foe),
          @battle.pbBetterBaseDamage(move,@user,@foe,100,move.basedamage)
        ]
      end
      expected=[50,50,70,70,100,100,130].map { |power| [power,power] }
      [actual==expected,"battle/AI powers #{actual.map { |pair| pair.join('/') }.join(',')}"]
    end

    def field_probe
      case @name
      when :THUNDERCLAP
        @battle.field.effects[PBEffects::PsychicTerrain]=5
        initial=@foe.hp
        execute
        [@foe.hp==initial,"grounded foe HP #{initial} -> #{@foe.hp} on Psychic Terrain"]
      when :EXPANDINGFORCE
        @battle.field.effects[PBEffects::PsychicTerrain]=5
        execute
        hits=@targets.filter_map { |move_id,index| index if move_id==@data.id }.uniq.sort
        [hits==[1,3],"expected Psychic Terrain spread in reachable lanes 1,3; actual #{hits.join(',')}"]
      when :POLTERGEIST
        initial=@foe.hp
        outcome=execute { @foe.item=0 }
        [@foe.hp==initial && !outcome[:failures].empty?,
          "target without a held item HP #{initial} -> #{@foe.hp}; #{outcome[:failures].first}"]
      when :AROMATICMIST
        execute
        actual=@ally.stages[PBStats::SPDEF]
        [actual==1,"selected ally's Special Defense expected +1, actual #{actual}"]
      when :ALLYSWITCH
        names=[@user.name,@ally.name]
        user_hp=@user.hp
        ally_hp=@ally.hp
        execute { @foe.moves[0]=move(:TACKLE,@foe) }
        actual=[@battle.battlers[0].name,@battle.battlers[2].name]
        redirected=@user.hp==user_hp && @ally.hp<ally_hp
        [actual==names.reverse && redirected,
          "expected lanes #{names.reverse.join(',')}, actual #{actual.join(',')}; queued hit followed lane=#{redirected}"]
      end
    end

    def confusion
      before=@user.hp
      @user.pbConfusionDamage
      raise "Confusion did not remove HP" if @user.hp>=before
      "native confusion path damage=#{before-@user.hp}"
    end

    def execute_z(expected_id, crystal, slot)
      @user.item=PBItems.const_get(crystal,false)
      if crystal==:KOMMONIUMZ2
        @foe.hp=@foe.totalhp
        @foe.defense=@foe.spdef=300
        @foe_ally.defense=@foe_ally.spdef=300
        @foe_ally.type1=@foe_ally.type2=PBTypes::NORMAL
      end
      @user.moves[slot]=move(:TACKLE) if crystal==:INTERCEPTZ2
      $game_variables[646]=95 if crystal==:INTERCEPTZ2
      $PokemonBag.pbStoreItem(PBItems::MEGARING) unless $PokemonBag.pbQuantity(PBItems::MEGARING)>0
      raise "Z-Move not legal for configured battler" unless @battle.pbCanZMove?(@user.index)
      original=@user.moves[slot]
      preview=PokeBattle_ZMoves.new(@battle,@user,original,@user.item,false,true,slot)
      raise "Expected Z-Move #{expected_id}, got #{preview.id}" if preview.id!=expected_id
      register(@user,slot)
      other_commands
      @battle.pbRegisterZMove(@user.index)
      before=snapshot
      advance
      result=report(before,preview)
      raise "Z-Move #{preview.name} was never announced" if !result[:messages].include?("#{preview.name}!")
      if expected_id==PBMoves::THEOLIAILLUSION
        raise "Theolia Illusion did not create a Substitute" if @user.effects[PBEffects::Substitute]<=0
      elsif expected_id==PBMoves::THEOLIASHIELD
        raise "Theolia Shield did not protect the user" if !result[:messages].any? { |msg| msg.include?("protected itself") }
      elsif expected_id==PBMoves::EXTREMEEVOBOOST
        raises=[PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
        raise "Extreme Evoboost did not raise all five combat stats by 2" unless @user.stages.values_at(*raises)==[2]*5
      elsif expected_id==PBMoves::GUARDIANOFALOLA
        damage=before[1][0]-result[:after][1][0]
        raise "Guardian of Alola dealt #{damage} instead of three quarters of target HP" if damage!=before[1][0]*3/4
      elsif preview.basedamage>0 && crystal!=:KOMMONIUMZ2
        raise "#{preview.name} did no damage" unless result[:after][1][0]<before[1][0]
      end
      result[:z_targets]=@targets.filter_map { |id,target| target if id==expected_id }
      result[:detail]+=" crystal=#{crystal} z_name=#{preview.name} oldmove=#{original.name}"
      result
    ensure
      $game_variables[646]=0
    end
  end

  def self.probe(audit,name,route,format=:triple)
    outcome=audit.check(:move,name,"#{route}-execution") do
      AzureAbilityFixture.setup_new_game
      srand(110_000+PBMoves.const_get(name))
      scenario=Scenario.new(name,PBMoveData.get(name),format)
      consistent,detail=yield scenario
      [consistent,detail]
    end
    return if !outcome
    consistent,detail=outcome
    audit.record(:move,name,consistent ? :pass : :mismatch,route,detail)
  end

  def self.audit_standard(audit,name,id,data)
    route=if name==:STRUGGLE
      "automatic-no-pp"
    elsif data.type==PBTypes::SHADOW
      "shadow-turn"
    else
      "battle-turn"
    end
    result=nil
    audit.check(:move,name,route) do
      AzureAbilityFixture.setup_new_game
      srand(100_000+id)
      result=Scenario.new(name,data).execute
      result[:detail]
    end
    if result && !result[:failures].empty?
      audit.record(:move,name,:gap,"effect-unconfirmed",result[:failures].first)
    end
  end

  def self.audit_legacy_move(audit,old_id,name)
    audit.check(:move,"#{name}:#{old_id}","legacy-save-battle-turn") do
      canonical=PBMoveData.get(name)
      raise "Legacy compiled move row differs from its canonical row" if $pkmn_move[old_id]!=$pkmn_move[canonical.id]
      if PBMoves.getName(old_id)!=PBMoves.getName(canonical.id) ||
         pbGetMessage(MessageTypes::MoveDescriptions,old_id)!=pbGetMessage(MessageTypes::MoveDescriptions,canonical.id)
        raise "Legacy numeric labels differ from their canonical labels"
      end
      raise "Numeric move construction did not canonicalize" if PBMove.new(old_id).id!=canonical.id
      AzureAbilityFixture.setup_new_game
      srand(100_000+old_id)
      "old_id=#{old_id} #{Scenario.new(name,canonical).use_saved_move(old_id)}"
    end
  end

  def self.run(audit)
    entries=audit.catalog(:move,PBMoves)
    names_by_id=entries.group_by(&:last)
    source_entries=audit.source_entries(:move)
    pbs_names=source_entries.to_h
    z_names=PokeBattle_ZMoves::ZMOVENAMES
    z_ids=z_names.each_index.map { |index| 10001+index }
    rows=PBMoveData.each.select { |data| data.id>0 }
    aliases=PBMove::LEGACY_DUPLICATE_MOVES
    retired=rows.select { |data| PBMove.current_id(data.id)!=data.id && !aliases.key?(data.id) }
    canonical=rows.reject { |data| PBMove.current_id(data.id)!=data.id }
    audit.line("MOVE COVERAGE compiled_ids=#{rows.size} canonical_ids=#{canonical.size} legacy_aliases=#{aliases.size} retired_rows=#{retired.size} z_ids=#{z_ids.size} internal_pseudomoves=1")
    if PBMoves::DIMZAP==PBMoves::DIMPULSE
      data=PBMoveData.get(:DIMZAP)
      audit.record(:move,"DIMZAP/DIMPULSE",:mismatch,"alias-collapses-effect",
        "Rift Zap should be Electric/paralysis; Rift Pulse should be Water/confusion. " +
        "Both load id=#{data.id}, name=#{PBMoves.getName(data.id)}, type=#{PBTypes.getName(data.type)}, function=#{data.function}.")
    end
    retired.each do |data|
      canonical=PBMove.current_id(data.id)
      audit.record(:move,data.id,:skip,"retired-migration","resolves to current id #{canonical}")
    end
    aliases.each { |old_id,name| audit_legacy_move(audit,old_id,name) }
    audit.check(:move,:ORIGINPULSE,"legacy-numeric-entry-points") do
      AzureAbilityFixture.setup_new_game
      srand(100_661)
      Scenario.new(:ORIGINPULSE,PBMoveData.get(:ORIGINPULSE)).legacy_move_queries(661)
    end
    canonical.each_with_index do |data,index|
      Graphics.update if index%20==0
      names=names_by_id.fetch(data.id,[]).map(&:first)
      if names.empty?
        audit.record(:move,data.id,:mismatch,"missing-runtime-symbol","compiled function=#{data.function}")
        next
      end
      name=names.find { |symbol| pbs_names[symbol]==data.id } || names.first
      handler=sprintf("PokeBattle_Move_%03X",data.function)
      if !Object.const_defined?(handler,false)
        audit.record(:move,name,:mismatch,"missing-effect-handler",
          "id=#{data.id} function=#{data.function} falls back to PokeBattle_UnimplementedMove")
      end
      audit_standard(audit,name,data.id,data)
    end
    entries.each do |name,id|
      next if PBMoveData.exists?(id) || z_ids.include?(id) || PBMove.current_id(id)!=id
      audit.record(:move,name,:mismatch,"missing-compiled-row","id=#{id}")
    end
    audit.check(:move,"CONFUSION","internal-self-damage") do
      AzureAbilityFixture.setup_new_game
      srand(112_001)
      Scenario.new(:TACKLE,PBMoveData.get(:TACKLE)).confusion
    end
    %i[HAZE SHADOWHALF PERISHSONG FLOWERSHIELD ROTOTILLER COACHING].each do |name|
      probe(audit,name,"triple-active-coverage") { |scenario| scenario.lane_probe }
    end
    %i[THUNDERCLAP EXPANDINGFORCE POLTERGEIST AROMATICMIST ALLYSWITCH].each do |name|
      probe(audit,name,"field-item-interaction") { |scenario| scenario.field_probe }
    end
    probe(audit,:ALLYSWITCH,"double-queued-target",:double) { |scenario| scenario.field_probe }
    probe(audit,:HOTTEMPO,"hype-thresholds") { |scenario| scenario.hot_tempo_probe }
    probe(audit,:ELECTROSHOT,"dry-charge") { |scenario| scenario.charge_probe(0) }
    probe(audit,:ELECTROSHOT,"rain-immediate") { |scenario| scenario.charge_probe(PBWeather::RAINDANCE) }
    probe(audit,:ELECTROSHOT,"rain-utility-umbrella") do |scenario|
      scenario.charge_probe(PBWeather::RAINDANCE,PBItems::UTILITYUMBRELLA)
    end
    z_ids.each_with_index do |id,index|
      Graphics.update
      name=names_by_id.fetch(id,[[z_names[index],id]]).first.first
      crystal,base,species,form=Z_FIXTURES.fetch(index)
      audit.check(:move,name,"z-battle-turn") do
        AzureAbilityFixture.setup_new_game
        srand(100_000+id)
        slot=crystal==:INTERCEPTZ2 ? index-34 : 0
        format=crystal==:KOMMONIUMZ2 ? :double : :single
        scenario=Scenario.new(name,PBMoveData.get(base),format,species,base,form)
        outcome=scenario.execute_z(id,crystal,slot)
        if crystal==:KOMMONIUMZ2
          hit_indices=outcome[:before].zip(outcome[:after]).each_with_index.filter_map do |(before,after),index|
            index if index.odd? && before[0]>after[0]
          end
          if hit_indices!=[1,3] || outcome[:z_targets].sort!=[1,3]
            audit.record(:move,name,:mismatch,"z-double-spread",
              "expected one hit per foe 1,3; damage slots #{hit_indices.join(',')}; process calls #{outcome[:z_targets].join(',')}")
          end
        end
        outcome[:detail]
      end
    end
  end
end
