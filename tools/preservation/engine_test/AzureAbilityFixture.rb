module AzureAbilityFixture
  @cases={}

  def self.test(ability,&block)
    raise "Duplicate test for #{ability}" if @cases.key?(ability)
    @cases[ability]=block
  end

  class Scene < PokeBattle_DebugSceneNoLogging
    attr_reader :messages

    def initialize
      super
      @messages=[]
    end

    def pbDisplayMessage(message,brief=false)
      @messages.push(message)
    end

    def pbDisplayPausedMessage(message)
      @messages.push(message)
    end

    def pbTrainerSendOut(_index,_pokemon,_battler)
    end

    def method_missing(name,*args)
      return nil if name.to_s.start_with?("pb")
      super
    end
  end

  class Scenario
    include AzureAbilityFixture

    def assert(value,message)
      raise message unless value
    end

    def equal(expected,actual)
      assert(expected==actual,"Expected #{expected.inspect}, got #{actual.inspect}")
    end

    def turn(user_move,foe_move)
      [[@user,user_move,@foe],[@foe,foe_move,@user]].each do |battler,ability_test_move,target|
        battler.turncount=0 if @battle.turncount==0
        move_id=PBMoves.const_get(ability_test_move)
        slot=battler.moves.index { |known| known && known.id==move_id }
        assert(slot,"#{battler.name} does not know #{ability_test_move}")
        assert(@battle.pbRegisterMove(battler.index,slot,false),"Could not select #{ability_test_move}")
        @battle.pbRegisterTarget(battler.index,target.index)
      end
      @battle.pbAttackPhase
      @battle.pbEndOfRoundWithStall if @battle.decision==0
      @battle.instance_variable_set(:@turncount,@battle.turncount+1)
    end

    def pokemon(ability,owner,moves,species=:RATTATA)
      mon=PokeBattle_Pokemon.new(PBSpecies.const_get(species),50,owner,false)
      mon.abilityoverride=PBAbilities.const_get(ability==:NONE ? :BALLFETCH : ability)
      mon.moves=(moves+[nil]*4).first(4).map { |symbol| PBMove.new(symbol ? PBMoves.const_get(symbol) : 0) }
      mon.hp=mon.totalhp
      return mon
    end

    def battle(user_ability,foe_ability=:NONE,user_moves: [:TACKLE],foe_moves: [:TACKLE],
               ally: nil,foe_ally: nil,user_species: :RATTATA,foe_species: :RATTATA,
               wild: false, outer_ally: nil, outer_foe: nil)
      $fefieldeffect=0
      $fecounter=0
      $febackup=0
      $fetempfield=0
      $game_variables[699]=0
      $game_variables[704]=0
      player=PokeBattle_Trainer.new("Ability Test",0)
      opponent=PokeBattle_Trainer.new("Ability Test Foe",0) unless wild
      player.party=[pokemon(user_ability,player,user_moves,user_species)]
      enemies=[pokemon(foe_ability,opponent,foe_moves,foe_species)]
      if ally || foe_ally || outer_ally || outer_foe
        player.party.push(pokemon(ally || :NONE,player,[:TACKLE]))
        enemies.push(pokemon(foe_ally || :NONE,opponent,[:TACKLE]))
      end
      if outer_ally || outer_foe
        player.party.push(pokemon(outer_ally || :NONE,player,[:TACKLE]))
        enemies.push(pokemon(outer_foe || :NONE,opponent,[:TACKLE]))
      end
      opponent.party=enemies if opponent
      @scene=Scene.new
      $Trainer=player
      @battle=PokeBattle_Battle.new(@scene,player.party,enemies,player,opponent)
      @battle.internalbattle=false
      @battle.setBattleMode("triple") if enemies.length==3
      @battle.doublebattle=true if enemies.length==2
      @battle.eachActiveBattlerIndex do |index|
        party=index.even? ? player.party : enemies
        @battle.battlers[index].pbInitialize(party[index/2],index/2,false)
        @battle.battlers[index].turncount=1
      end
      @user,@foe,@ally,@foe_ally,@outer_ally,@outer_foe=@battle.battlers
      @scene.pbStartBattle(@battle)
      return @battle
    end

    def move(symbol,user=@user)
      PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(PBMoves.const_get(symbol)),user)
    end

    def entry(battler=@user)
      battler.pbAbilitiesOnSwitchIn(true)
    end

    def hit(symbol,user=@user,target=@foe)
      attack=move(symbol,user)
      @battle.lastMoveUsed=attack.id
      @battle.lastMoveUser=user.index
      target.damagestate.reset
      user.grazed=false
      target.moldbroken=false
      turneffects=[]
      turneffects[PBEffects::TotalDamage]=0
      user.pbProcessMoveAgainstTarget(attack,user,target,1,turneffects,false,[target.index],false)
      return target.damagestate.hplost
    end

    def round
      @battle.pbEndOfRoundPhase
    end
  end

  def self.setup_new_game
    $PokemonTemp=PokemonTemp.new
    $game_temp=Game_Temp.new
    $game_system=Game_System.new
    $PokemonSystem=PokemonSystem.new
    $game_switches=Game_Switches.new
    $game_variables=Game_Variables.new
    $game_self_switches=Game_SelfSwitches.new
    $game_screen=Game_Screen.new
    $game_player=Game_Player.new
    $PokemonMap=PokemonMapMetadata.new
    $PokemonGlobal=PokemonGlobalMetadata.new
    $PokemonStorage=PokemonStorage.new
    $PokemonEncounters=PokemonEncounters.new
    $PokemonBag=PokemonBag.new
    Achievements.resetAchievements
    $strengthUsed=false
    $Trainer=PokeBattle_Trainer.new("Ability Test",0)
    $MapFactory=PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x,$data_system.start_y)
    $game_player.refresh
    $game_map.update
    $game_variables[542]=0
  end

  def self.run
    report=ENV.fetch("AZURE_ABILITY_TEST_REPORT")
    pattern=ENV["AZURE_ABILITY_TEST_FILTER"].to_s
    filter=Regexp.new(pattern) unless pattern.empty?
    $data_system=pbLoadRxData("Data/System")
    $mapinfos=pbCachedRxData("Data/MapInfos")
    $game_system=Game_System.new
    pbLoadAzureRuntimeData
    File.open(report,"w") do |file|
      file.sync=true
      file.puts "Ruby #{RUBY_VERSION}"
      passed=0
      failed=0
      @cases.each do |ability,pr|
        next if filter && !filter.match?(ability.to_s)
        begin
          Graphics.update
          setup_new_game
          srand(134)
          Scenario.new.instance_exec(&pr)
          file.puts "PASS #{ability}"
          passed+=1
        rescue StandardError => error
          message=error.message.lines.first.to_s.strip
          file.puts "FAIL #{ability} #{error.class}: #{message[0,400]}"
          file.puts error.backtrace.first(6)
          failed+=1
        end
      end
      file.puts "result=#{failed==0 && (filter ? passed>0 : passed==134) ? 'PASS' : 'FAIL'} passed=#{passed} failed=#{failed} registered=#{@cases.length}"
    end
  end
end
