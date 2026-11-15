module AzureBattleSimulation
  FORMATS={"single"=>1,"double"=>2,"triple"=>3}.freeze
  STATS=%w[ATK DEF SPE SPA SPD ACC EVA].freeze
  OUTCOMES={1=>"player_win",2=>"opponent_win",5=>"draw"}.freeze

  # The launcher validates JSON and writes typed records because Game.exe's
  # embedded Ruby does not bundle the JSON library.
  def self.read_value(file)
    tag,value=file.readline.chomp.split(" ",2)
    case tag
    when "h" then Array.new(Integer(value,10)) { [read_value(file),read_value(file)] }.to_h
    when "a" then Array.new(Integer(value,10)) { read_value(file) }
    when "s" then [value.to_s].pack("H*").force_encoding(Encoding::UTF_8)
    when "i" then Integer(value,10)
    when "t" then true
    when "f" then false
    when "n" then nil
    else raise ArgumentError,"Invalid scenario record #{tag.inspect}"
    end
  end

  def self.object(value,label,keys)
    raise ArgumentError,"#{label} must be an object" unless value.is_a?(Hash)
    extra=value.keys-keys
    raise ArgumentError,"Unknown #{label} key(s) #{extra.join(', ')}" unless extra.empty?
    value
  end

  def self.integer(value,label,range)
    unless value.is_a?(Integer) && range.include?(value)
      maximum=range.exclude_end? ? range.end-1 : range.end
      raise ArgumentError,"#{label} must be an integer from #{range.begin} to #{maximum}"
    end
    value
  end

  def self.id(namespace,name,label)
    if name.is_a?(String) && name.match?(/\A[A-Z][A-Z0-9_]*\z/) && namespace.const_defined?(name,false)
      value=namespace.const_get(name,false)
      return value if value.is_a?(Integer)
    end
    raise ArgumentError,"Unknown #{label} #{name.inspect}"
  end

  def self.trainer(spec,label,active)
    object(spec,label,%w[name trainer_type ai_skill party])
    name=spec.fetch("name",label)
    raise ArgumentError,"#{label} name must be a nonempty string" unless name.is_a?(String) && !name.strip.empty?
    trainer=PokeBattle_Trainer.new(name,id(PBTrainers,spec.fetch("trainer_type","CONDUIT"),"trainer type"))
    if spec.key?("ai_skill")
      skill=integer(spec["ai_skill"],"#{label} AI skill",0..255)
      trainer.define_singleton_method(:skill) { skill }
    end
    party=spec.fetch("party")
    unless party.is_a?(Array) && (active..6).include?(party.length)
      raise ArgumentError,"#{label} needs #{active} to 6 Pokémon"
    end
    trainer.party=party.map.with_index do |set,index|
      context="#{label}.party[#{index}]"
      object(set,context,%w[species level moves ability item form hp])
      species=id(PBSpecies,set.fetch("species"),"species")
      level=integer(set.fetch("level",50),"#{context} level",1..100)
      pokemon=PokeBattle_Pokemon.new(species,level,trainer,false)
      pokemon.form=integer(set["form"],"#{context} form",0..255) if set.key?("form")
      pokemon.abilityoverride=id(PBAbilities,set["ability"],"ability") if set.key?("ability")
      pokemon.setItem(id(PBItems,set["item"],"held item")) if set.key?("item")
      moves=set.fetch("moves")
      unless moves.is_a?(Array) && (1..4).include?(moves.length)
        raise ArgumentError,"#{context} needs 1 to 4 moves"
      end
      pokemon.moves=moves.map { |move| PBMove.new(id(PBMoves,move,"move")) }
      pokemon.moves.push(PBMove.new(0)) while pokemon.moves.length<4
      pokemon.calcStats
      pokemon.hp=integer(set.fetch("hp",pokemon.totalhp),"#{context} HP",1..pokemon.totalhp)
      pokemon
    end
    trainer
  end

  class Report
    def initialize(file,expected,forbidden)
      @file=file
      @expected=expected.dup
      @forbidden=forbidden
    end

    def line(message)
      text=message.to_s.dup.force_encoding(Encoding::UTF_8).scrub.gsub(/[[:space:]]+/," ").strip
      return if text.empty?
      @expected.shift if !@expected.empty? && text.include?(@expected.first)
      @unexpected ||= @forbidden.find { |fragment| text.include?(fragment) }
      @file.puts(text.start_with?("result=") ? "MESSAGE #{text}" : text)
    end

    def verify
      raise "Expected log entry not found in order: #{@expected.first.inspect}" unless @expected.empty?
      raise "Forbidden log entry found: #{@unexpected.inspect}" if @unexpected
    end
  end

  class Scene < PokeBattle_DebugSceneNoLogging
    def initialize(report,actions)
      super()
      @report=report
      @actions=actions
    end

    def label(index)
      battler=@battle.battlers[index]
      "[#{index}] #{battler.name}"
    end

    def pbDisplayMessage(message,_brief=false)
      @report.line(message)
    end
    alias pbDisplayPausedMessage pbDisplayMessage
    alias pbDisplay pbDisplayMessage

    def pbBeginCommandPhase
      @report.line("TURN #{@battle.turncount+1}")
      snapshot
    end

    def pbEndBattle(_decision)
      @report.line("FINAL")
      snapshot
    end

    def pbChooseEnemyCommand(index)
      action=@actions.delete([@battle.turncount+1,index])
      if action
        apply_action(index,action)
      else
        super
      end
      log_choice(index,action ? "script" : "AI")
    end

    def apply_action(index,action)
      battler=@battle.battlers[index]
      if action.key?("move")
        move_id=AzureBattleSimulation.id(PBMoves,action["move"],"move")
        slot=battler.moves.index { |move| move.id==move_id }
        registered=slot && @battle.pbRegisterMove(index,slot,false)
        if registered && action.key?("target")
          target=@battle.battlers[action["target"]]
          unless targets_include?(battler,battler.moves[slot],target)
            raise "Turn #{@battle.turncount+1} #{label(index)} cannot target #{label(target.index)} with #{action['move']}"
          end
          @battle.pbRegisterTarget(index,target.index)
        end
      elsif action.key?("shift")
        registered=@battle.pbRegisterShift(index,action["shift"])
      else
        registered=@battle.pbRegisterSwitch(index,action["switch"])
      end
      raise "Turn #{@battle.turncount+1} #{label(index)} cannot use #{action.inspect}" unless registered
    end

    def targets_include?(battler,move,target)
      return false if target.isFainted? || !@battle.pbMoveCanTargetInTriple?(battler,target,move)
      same_lane=battler.index==target.index
      opposing=battler.pbIsOpposing?(target.index)
      return same_lane || opposing if move.id==PBMoves::MINIMIZE
      case battler.pbTarget(move)
      when PBTargets::User then same_lane
      when PBTargets::UserOrPartner then !opposing
      when PBTargets::Partner then !same_lane && !opposing
      when PBTargets::SingleNonUser then !same_lane
      when PBTargets::SingleOpposing,PBTargets::OppositeOpposing then opposing
      else false
      end
    end

    def log_choice(index,source)
      kind,slot,move,target=@battle.choices[index]
      description=case kind
      when 1
        target=target.index if target.is_a?(PokeBattle_Battler)
        selected=target.is_a?(Integer) && target>=0 ? target : "auto"
        "#{PBMoves.getName(move.id)} selected_target=#{selected}"
      when 2
        move==:shift ? "shift with #{label(target)}" : "switch to party[#{slot}] #{@battle.pbParty(index)[slot].name}"
      when 3
        "item=#{PBItems.getName(slot)}"
      else
        "no command (code #{kind})"
      end
      @report.line("CHOOSE #{source} #{label(index)} #{description}")
    end

    def pbTrainerSendOut(index,pokemon,battler)
      @report.line("SEND [#{index}] #{pokemon.name} party[#{battler.pokemonIndex}]")
    end

    def pbHPChanged(battler,old_hp,_animate=false)
      delta=battler.hp-old_hp
      @report.line("HP #{label(battler.index)} #{old_hp} -> #{battler.hp}/#{battler.totalhp} (#{format('%+d',delta)})")
    end

    def pbFainted(battler)
      @report.line("FAINT #{label(battler.index)}")
    end

    def pbShiftBattlers(first,second)
      @report.line("SHIFT #{label(first)} <-> #{label(second)}")
    end

    def record_target(move,user,target)
      @report.line("TARGET #{label(user.index)} #{PBMoves.getName(move.id)} -> #{label(target.index)}")
    end

    def record_ai_score(index,slot,move,score,target,legal)
      recipient=target.is_a?(Integer) && target>=0 ? target : "auto"
      @report.line("AI SCORE #{label(index)} slot=#{slot} move=#{move.name} score=#{score} target=#{recipient} legal=#{legal}")
    end

    def record_ai_candidate(move,user,target,roughdamage,score)
      @report.line("AI CANDIDATE #{label(user.index)} move=#{move.name} evaluated_target=#{label(target.index)} rough=#{roughdamage} score=#{score}")
    end

    def pbVanishSprite(battler)
      battler.vanished=true
    end

    def pbUnVanishSprite(battler,_fade=true)
      battler.vanished=false
    end

    def pbChangePokemon(_battler,_pokemon); end
    def pbApplyBGSprite(_sprite,_filename); end
    def pbResetMoveIndex(_index); end
    def pbSubstituteSprite(_battler,_back); end
    def pbUnSubstituteSprite(_battler,_back); end
    def partyBetweenKO1(_opposing=true); end
    alias partyBetweenKO2 partyBetweenKO1

    def snapshot
      field=$fefieldeffect==0 ? "No field effect" : pbGetFieldEffectName($fefieldeffect)
      @report.line("FIELD #{$fefieldeffect} #{field} | weather=#{@battle.pbWeather}")
      @battle.eachActiveBattlerIndex do |index|
        battler=@battle.battlers[index]
        next unless battler.pokemon
        ability=PBAbilities.getName(battler.ability)
        item=battler.item>0 ? PBItems.getName(battler.item) : "-"
        ability+=" (inactive)" if !battler.abilityWorks?
        item+=" (inactive)" if battler.item>0 && !battler.itemWorks?
        stages=STATS.each_with_index.map { |stat,i| "#{stat}=#{battler.stages[i+1]}" }
        effects=battler.effects
        extra=[]
        if effects[PBEffects::MultiTurn]>0
          extra.push("trap=#{PBMoves.getName(effects[PBEffects::MultiTurnAttack])} turns=#{effects[PBEffects::MultiTurn]} source=#{effects[PBEffects::MultiTurnUser]} binding_band=#{!!effects[PBEffects::MultiTurnBindingBand]}")
        end
        pair=effects[PBEffects::Commander] || effects[PBEffects::Commandee]
        extra.push("commander_pair=#{pair.index}") if pair
        @report.line("STATE #{label(index)} HP=#{battler.hp}/#{battler.totalhp} status=#{battler.status} ability=#{ability} item=#{item} #{stages.join(' ')} #{extra.join(' ')}")
      end
    end
  end

  module TargetTrace
    def pbProcessMoveAgainstTarget(move,user,target,*args)
      @battle.scene.record_target(move,user,target)
      super
    end
  end

  class Battle < PokeBattle_Battle
    attr_accessor :turn_limit, :trace_ai
    attr_reader :limit_reached

    def pbCommandPhase
      if turncount>=turn_limit
        @limit_reached=true
        self.decision=5
        return
      end
      Graphics.update
      super
    end

    def pbSwitchPlayer(index,_lax,_cancancel)
      scene.pbChooseNewEnemy(index,pbParty(index))
    end

    def pbBuildMoveScores(index,doublestargetting=false,shutup=false)
      return super if !trace_ai || !@trace_ai_command || !@trace_ai_index.nil? || doublestargetting
      @trace_ai_index=index
      begin
        result=super
        battlers[index].moves.each_with_index do |move,slot|
          next if move.id<=0
          scene.record_ai_score(index,slot,move,scores[slot],targets && targets[slot],myChoices.include?(slot))
        end
        result
      ensure
        @trace_ai_index=nil
      end
    end

    def pbGetMoveScore(move,attacker,opponent,skill=100,roughdamage=10,*args)
      score=super
      if @trace_ai_index==attacker.index && opponent
        scene.record_ai_candidate(move,attacker,opponent,roughdamage,score)
      end
      return score
    end

    def pbDefaultChooseEnemyCommand(index)
      @trace_ai_command=trace_ai
      super
    ensure
      @trace_ai_command=false
    end
  end

  def self.prepare_actions(spec,active,limit)
    raise ArgumentError,"actions must be an array" unless spec.is_a?(Array)
    result={}
    spec.each do |action|
      object(action,"action",%w[turn slot move target switch shift])
      turn=integer(action.fetch("turn"),"action turn",1..limit)
      slot=integer(action.fetch("slot"),"action slot",0...(2*active))
      kinds=action.keys & %w[move switch shift]
      unless kinds.length==1 && (!action.key?("target") || kinds.first=="move")
        raise ArgumentError,"Each action needs exactly one move, switch or shift, with target only for moves"
      end
      integer(action["target"],"target slot",0...(2*active)) if action.key?("target")
      integer(action["shift"],"shift slot",0...(2*active)) if action.key?("shift")
      integer(action["switch"],"switch party index",0..5) if action.key?("switch")
      raise ArgumentError,"Duplicate command for turn #{turn}, slot #{slot}" if result.key?([turn,slot])
      result[[turn,slot]]=action
    end
    result
  end

  def self.fragments(spec,key)
    entries=spec.fetch(key,[])
    unless entries.is_a?(Array) && entries.all? { |value| value.is_a?(String) && !value.empty? }
      raise ArgumentError,"#{key} must be an array of nonempty text fragments"
    end
    entries
  end

  def self.run
    spec=File.open(ENV.fetch("AZURE_BATTLE_SIMULATION_SCENARIO"),"rb") do |file|
      value=read_value(file)
      raise ArgumentError,"Unexpected data after scenario" unless file.eof?
      value
    end
    object(spec,"scenario",%w[title format player opponent seed max_turns field weather trace_ai actions expect reject])
    trace_ai=spec.fetch("trace_ai",false)
    raise ArgumentError,"trace_ai must be true or false" unless [true,false].include?(trace_ai)
    format=spec.fetch("format","single")
    active=FORMATS.fetch(format) { raise ArgumentError,"format must be single, double or triple" }
    seed_override=ENV["AZURE_BATTLE_SIMULATION_SEED"]
    seed=integer(seed_override && !seed_override.empty? ? Integer(seed_override,10) : spec.fetch("seed",1),
      "seed",-2147483648..2147483647)
    limit=integer(spec.fetch("max_turns",50),"max_turns",1..200)
    actions=prepare_actions(spec.fetch("actions",[]),active,limit)
    expected=fragments(spec,"expect")
    forbidden=fragments(spec,"reject")

    $data_system=pbLoadRxData("Data/System")
    $mapinfos=pbCachedRxData("Data/MapInfos")
    $game_system=Game_System.new
    pbLoadAzureRuntimeData
    srand(seed)
    AzureAbilityFixture.setup_new_game
    # Let the launcher report any runtime error instead of showing the game's dialog.
    PBDebug.define_singleton_method(:logonerr) { |&block| block.call }
    PokeBattle_Battler.prepend(TargetTrace)
    $INTERNAL=false
    $fefieldeffect=integer(spec.fetch("field",0),"field",0..255)
    raise ArgumentError,"Unknown field #{$fefieldeffect}" unless $fefieldeffect==0 || pbGetFieldEffectData($fefieldeffect)
    $febackup=$fefieldeffect
    $fecounter=0
    $fetempfield=0
    $game_variables[699]=0
    $game_variables[704]=0

    player=trainer(spec.fetch("player"),"Player",active)
    opponent=trainer(spec.fetch("opponent"),"Opponent",active)
    $Trainer=player
    File.open(ENV.fetch("AZURE_BATTLE_SIMULATION_REPORT"),"wb") do |file|
      file.sync=true
      report=Report.new(file,expected,forbidden)
      title=spec.fetch("title","Azure battle simulation")
      raise ArgumentError,"title must be a string" unless title.is_a?(String)
      report.line("SCENARIO #{title}")
      report.line("CONFIG format=#{format} seed=#{seed} max_turns=#{limit} ruby=#{RUBY_VERSION}")
      [player,opponent].each do |owner|
        owner.party.each_with_index do |pokemon,index|
          moves=pokemon.moves.reject { |move| move.id==0 }.map { |move| PBMoves.getName(move.id) }
          item=pokemon.item>0 ? PBItems.getName(pokemon.item) : "-"
          report.line("TEAM #{owner.name} [#{index}] #{pokemon.name} L#{pokemon.level} ability=#{PBAbilities.getName(pokemon.ability)} item=#{item} moves=#{moves.join(', ')}")
        end
      end
      scene=Scene.new(report,actions)
      battle=Battle.new(scene,player.party,opponent.party,player,opponent)
      battle.setBattleMode(format)
      battle.controlPlayer=true
      battle.internalbattle=false
      battle.battlescene=false
      battle.turn_limit=limit
      battle.trace_ai=trace_ai
      weather=spec.fetch("weather","NONE")
      battle.weather=weather=="NONE" ? 0 : id(PBWeather,weather,"weather")
      battle.weatherduration=-1 if battle.weather>0
      decision=battle.pbStartBattle(true)
      outcome=battle.limit_reached ? "turn_limit" : OUTCOMES.fetch(decision) { raise "Unexpected battle decision #{decision}" }
      report.line("OUTCOME #{outcome}")
      raise "Unused scripted command for turn #{actions.keys.first[0]}, slot #{actions.keys.first[1]}" unless actions.empty?
      report.verify
      file.puts("result=PASS outcome=#{outcome}")
    end
  end
end
