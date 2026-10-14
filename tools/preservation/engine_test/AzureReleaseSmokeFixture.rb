module AzureReleaseSmokeFixture
  STATUS_PATH=File.join(Dir.pwd,"release_smoke_runtime.status.txt")
  ROUNDTRIP_PATH=File.join(AzureEngineTest::SAVE_ROOT,"release_smoke_roundtrip.rxdata")

  class MenuProbe
    attr_reader :commands
    def pbStartScene; end
    def pbRefresh; end
    def pbShowMenu; end
    def pbHideMenu; end
    def pbShowInfo(_text); end
    def pbShowCommands(commands)
      @commands=commands.clone
      return -1
    end
    def pbEndScene; end
  end

  class DeterministicBattleScene < PokeBattle_DebugSceneNoLogging
    def pbCommandMenu(_index); return 0; end
    def pbFightMenu(index)
      battler=@battle.battlers[index]
      for i in 0...battler.moves.length
        return i if battler.moves[i] && battler.moves[i].id!=0
      end
      return -1
    end
    def pbChooseTarget(index)
      for i in 0...@battle.battlers.length
        battler=@battle.battlers[i]
        next if !battler || battler.isFainted?
        return i if @battle.battlers[index].pbIsOpposing?(i)
      end
      return -1
    end
    def pbChooseTargetAcupressure(index); return index; end
    def pbBlitz(_keys); return 0; end
    def method_missing(name,*args)
      return nil if name.to_s[/^pb/]
      return super
    end
  end

  def self.write(rows)
    File.open(STATUS_PATH,"wb") {|file|
      for row in rows; file.write(row+"\r\n"); end
    }
  end

  def self.assert(value,message)
    raise message if !value
  end

  def self.read_marshaled(path)
    objects=[]
    File.open(path,"rb") {|file|
      until file.eof?
        objects.push(Marshal.load(file))
      end
    }
    return objects
  end

  def self.write_marshaled(path,objects)
    File.open(path,"wb") {|file|
      for object in objects
        Marshal.dump(object,file)
      end
    }
  end

  def self.restore_loaded_save(objects)
    $Trainer=objects[0]
    Graphics.frame_count=objects[1]
    $game_system=objects[2]
    $PokemonSystem=objects[3]
    $game_switches=objects[5]
    $game_variables=objects[6]
    $game_self_switches=objects[7]
    $game_screen=objects[8]
    $MapFactory=objects[9]
    $game_map=$MapFactory.map
    $game_player=objects[10]
    $PokemonGlobal=objects[11]
    $PokemonMap=objects[12]
    $PokemonBag=objects[13]
    $PokemonStorage=objects[14]
    $achievements=objects[15]
    $PokemonTemp=PokemonTemp.new
    $game_temp=Game_Temp.new
    $PokemonEncounters=PokemonEncounters.new
    return objects[4]
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
    $Trainer=PokeBattle_Trainer.new("Release Smoke",0)
    $MapFactory=PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x,$data_system.start_y)
    $game_player.refresh
    $game_map.update
    $game_variables[542]=0
    return [$game_map.map_id,$game_player.x,$game_player.y]
  end

  def self.make_pokemon(trainer,level)
    species=getID(PBSpecies,:RATTATA)
    species=1 if !species || species<=0
    move=getID(PBMoves,:TACKLE)
    pokemon=PokeBattle_Pokemon.new(species,level,trainer,false)
    pokemon.moves=[PBMove.new(move),PBMove.new(0),PBMove.new(0),PBMove.new(0)]
    pokemon.calcStats
    pokemon.hp=pokemon.totalhp
    return pokemon
  end

  def self.run_battle(size)
    player=PokeBattle_Trainer.new("Release Smoke",0)
    player.party=[]
    enemy=[]
    size.times do
      player.party.push(make_pokemon(player,25))
      enemy.push(make_pokemon(nil,20))
    end
    previous_trainer=$Trainer
    $Trainer=player
    scene=DeterministicBattleScene.new
    battle=PokeBattle_Battle.new(scene,player.party,enemy,player,nil)
    battle.internalbattle=false
    battle.doublebattle=true if size==2
    srand(1400+size)
    decision=battle.pbStartBattle(true)
    $Trainer=previous_trainer
    expected_indices=(size==2) ? [0,1,2,3] : [0,1]
    initialized=expected_indices.all? {|index|
      battler=battle.battlers[index]
      battler && battler.pokemon
    }
    assert(initialized,"#{size}v#{size} battle did not initialize every active slot")
    assert([1,2,5].include?(decision),"#{size}v#{size} battle did not finish")
    return [decision,battle.turncount]
  ensure
    $Trainer=previous_trainer if previous_trainer
  end

  def self.run_debug_menu
    original=Input.method(:trigger?)
    Input.define_singleton_method(:trigger?) {|key| key==Input::B }
    pbDebugMenu
    return true
  ensure
    Input.define_singleton_method(:trigger?) {|key| original.call(key) } if original
  end

  def self.run
    write(["result=RUNNING","phase=5_step_3_release_interaction_smoke"])
    timings={}
    started=Process.clock_gettime(Process::CLOCK_MONOTONIC)
    $data_system=pbLoadRxData("Data/System")
    $mapinfos=pbCachedRxData("Data/MapInfos")
    $game_system=Game_System.new
    pbLoadAzureRuntimeData
    timings[:runtime_load]=Process.clock_gettime(Process::CLOCK_MONOTONIC)-started

    fixture=File.join(Dir.pwd,"save_fixture","Game.rxdata")
    assert(File.file?(fixture),"old-save fixture is missing")
    header=PokemonLoad.new(nil).pbTryLoadFile(fixture)
    assert(header.length==5,"old-save header has the wrong object count")
    objects=read_marshaled(fixture)
    assert(objects.length==16,"old-save fixture does not contain 16 objects")
    loaded_map_id=restore_loaded_save(objects)
    assert($Trainer.is_a?(PokeBattle_Trainer),"old-save trainer did not hydrate")
    assert($game_map && $game_map.map_id==loaded_map_id,"old-save map did not hydrate")
    AzureEngineTest.ensure_directory(AzureEngineTest::SAVE_ROOT)
    write_marshaled(ROUNDTRIP_PATH,objects)
    roundtrip=read_marshaled(ROUNDTRIP_PATH)
    assert(roundtrip.length==objects.length,"save round-trip object count changed")
    assert(roundtrip.map {|item| item.class }==objects.map {|item| item.class },
           "save round-trip class sequence changed")
    assert(roundtrip[0].name==objects[0].name,"save round-trip trainer changed")
    assert(roundtrip[4]==objects[4],"save round-trip map ID changed")

    load_panel=PokemonLoadPanel.new(0,"Continue",true,header[0],header[1],header[4])
    load_panel.refresh
    load_panel.dispose

    new_game=setup_new_game
    assert(new_game==[$data_system.start_map_id,$data_system.start_x,$data_system.start_y],
           "new-game start position changed")

    menu_probe=MenuProbe.new
    PokemonMenu.new(menu_probe).pbStartPokemonMenu
    assert(menu_probe.commands && menu_probe.commands.include?("Bag"),"pause menu omitted Bag")
    assert(menu_probe.commands.include?("Achievements"),"pause menu omitted Achievements")
    assert(menu_probe.commands.include?("Release Smoke"),"pause menu omitted trainer card")
    assert(menu_probe.commands.include?("Save"),"pause menu omitted Save")
    assert(menu_probe.commands.include?("Options"),"pause menu omitted Options")
    assert(menu_probe.commands.include?("Quit Game"),"pause menu omitted Quit Game")

    target_id=$mapinfos.keys.sort.find {|id|
      id!=$game_map.map_id && pbRgssExists?(sprintf("Data/Map%03d.rxdata",id))
    }
    assert(target_id,"no map-transfer target is available")
    transfer_started=Process.clock_gettime(Process::CLOCK_MONOTONIC)
    preloaded=AzureMapTransferHandoff.preload(target_id)
    $MapFactory.setup(target_id)
    timings[:map_transfer]=Process.clock_gettime(Process::CLOCK_MONOTONIC)-transfer_started
    installed=$game_map.instance_variable_get(:@map)
    assert(installed.equal?(preloaded),"map transfer did not consume the preloaded object")
    assert($game_map.map_id==target_id,"map transfer installed the wrong map")
    assert(!AzureMapTransferHandoff.instance_variable_get(:@map),"map handoff retained its object")

    tracked=pbAzurePBSTrackedFiles("PBS")
    assert(tracked.length>=19,"compiler/editor source inventory is incomplete")
    command_list=CommandList.new
    command_list.add("one","One")
    command_list.add("two","Two")
    assert(command_list.getCommand(0)=="one" && command_list.getCommand(1)=="two",
           "debug command registry lost keyed identity")
    debug_rendered=run_debug_menu

    single_started=Process.clock_gettime(Process::CLOCK_MONOTONIC)
    single=run_battle(1)
    timings[:single_battle]=Process.clock_gettime(Process::CLOCK_MONOTONIC)-single_started
    double_started=Process.clock_gettime(Process::CLOCK_MONOTONIC)
    double=run_battle(2)
    timings[:double_battle]=Process.clock_gettime(Process::CLOCK_MONOTONIC)-double_started

    cache_started=Process.clock_gettime(Process::CLOCK_MONOTONIC)
    1000.times { pbCachedData("Data/moves.dat") }
    timings[:cache_hits]=Process.clock_gettime(Process::CLOCK_MONOTONIC)-cache_started

    result=(objects.length==16 && roundtrip.length==16 &&
            $game_map.map_id==target_id && menu_probe.commands.length>=6 &&
            debug_rendered && single[0]!=0 && double[0]!=0)
    rows=[
      "result=#{result ? 'PASS' : 'FAIL'}",
      "phase=5_step_3_release_interaction_smoke",
      "old_save_fixture=true",
      "old_save_header=true",
      "old_save_objects=#{objects.length}",
      "old_save_map_id=#{loaded_map_id}",
      "save_roundtrip=true",
      "save_roundtrip_objects=#{roundtrip.length}",
      "save_write_scope=isolated_package_only",
      "new_game_setup=true",
      "new_game_map_id=#{new_game[0]}",
      "new_game_position=#{new_game[1]},#{new_game[2]}",
      "load_panel_render=true",
      "pause_menu=true",
      "pause_menu_commands=#{menu_probe.commands.length}",
      "debug_menu_render=true",
      "debug_registry_identity=true",
      "editor_sources=#{tracked.length}",
      "map_transfer=true",
      "map_transfer_target=#{target_id}",
      "map_transfer_same_object=true",
      "map_transfer_handoff_cleared=true",
      "single_battle=true",
      "single_battle_decision=#{single[0]}",
      "single_battle_turns=#{single[1]}",
      "double_battle=true",
      "double_battle_decision=#{double[0]}",
      "double_battle_turns=#{double[1]}",
      "runtime_load_seconds=#{timings[:runtime_load]}",
      "map_transfer_seconds=#{timings[:map_transfer]}",
      "single_battle_seconds=#{timings[:single_battle]}",
      "double_battle_seconds=#{timings[:double_battle]}",
      "cached_move_reads=1000",
      "cached_move_read_seconds=#{timings[:cache_hits]}",
      "probe_errors=none"
    ]
    write(rows)
    raise "Release smoke fixture failed" if !result
    return true
  rescue Exception
    detail="#{$!.class}: #{$!.message}"
    detail+=" | #{$!.backtrace[0,8].join(' <- ')}" if $!.backtrace
    write(["result=FAIL","phase=5_step_3_release_interaction_smoke","error=#{detail}"])
    raise
  end
end

AzureReleaseSmokeFixture.run
