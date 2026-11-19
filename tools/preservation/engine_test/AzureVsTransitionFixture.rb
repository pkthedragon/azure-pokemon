# Native mkxp regression; never add this fixture to the production script order.
# Copy the game runtime, Data and Scripts into an isolated temporary package,
# copy this file to its Data/Mods, and use a temporary USERPROFILE/save directory.
# Set AZURE_VS_REPORT to an absolute report filename and AZURE_VS_OUTPUT to an
# existing output directory, then launch that package's Game.exe. Only frame 80
# is saved for each case. The process exits after reporting PASS or FAIL.
# Old code can produce correct snapshots while native frames remain frozen;
# native Graphics.frame_count advancement is therefore a required assertion.
module AzureVsTransitionFixture
  EXPECTED_FRAMES=168
  STOP=:azure_vs_fixture_intro_complete
  class << self
    attr_accessor :active,:frames,:label,:report,:output,:captured
  end

  def self.assert(value,message)
    raise message unless value
  end

  def self.capture
    shot=Graphics.snap_to_bitmap
    path=File.join(output,"#{label}-frame080.png")
    shot.to_file(path)
    self.captured=File.file?(path)
    report.puts("FRAME80 #{label} #{path}")
  ensure
    shot.dispose if shot && !shot.disposed?
  end

  module IntroProbe
    def pbTrainerVsAnimation(*args)
      fixture=AzureVsTransitionFixture
      fixture.active=true
      fixture.frames=0
      fixture.captured=false
      start=Graphics.frame_count
      handled=super
      native_frames=Graphics.frame_count-start
      # Return evidence through throw, not an exception caught by the event UI.
      # The helper's ensure has run; no input-driven battle scene was entered.
      throw fixture::STOP,{:handled=>handled,:logical_frames=>fixture.frames,
        :native_frames=>native_frames,:captured=>fixture.captured}
    ensure
      AzureVsTransitionFixture.active=false
    end

    def pbWait(numframes)
      result=super
      fixture=AzureVsTransitionFixture
      if fixture.active
        fixture.frames+=numframes
        fixture.capture if fixture.frames==80
      end
      result
    end
  end

  def self.setup_map
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
    $PokemonBag=PokemonBag.new
    $PokemonEncounters=PokemonEncounters.new
    $Trainer=PokeBattle_Trainer.new("Key",PBTrainers::POKEMONTRAINER_Key)
    $Trainer.party=[PokeBattle_Pokemon.new(PBSpecies::FUECOCO,15,$Trainer)]
    $MapFactory=PokemonMapFactory.new(6)
    $game_player.moveto(5,5)
    pbChangePlayer(6)
    Kernel.pbUpdateVehicle
    $PokemonEncounters.setup(6)
    $fefieldeffect=0; $feoverride=0; $fetempfield=0
    $febackgroundstore=0; $febackup=0; $fecounter=0
    $scene=Scene_Map.new
    $scene.createSpritesets
    Graphics.transition(0)
    Graphics.update
  end

  def self.run_case(mode,command)
    setup_map
    self.label="kara-event6-23-#{mode}"
    Graphics.freeze if mode==:inherited_freeze
    interpreter=$game_system.map_interpreter
    interpreter.setup([command,RPG::EventCommand.new(0,0,[])],23,6)
    report.puts("EVENT #{label} Map006 event23 page2 command58")
    result=catch(STOP) { interpreter.update; nil }
    # Assert outside Interpreter.update so a regression cannot open an error dialog.
    assert(result.is_a?(Hash),"Actual event did not reach the VS helper")
    report.puts("INTRO #{label} #{result.inspect}")
    assert(result[:handled],"VS helper fell back instead of showing the portraits")
    assert(result[:logical_frames]==EXPECTED_FRAMES,"Wrong VS animation length")
    assert(result[:captured],"Frame 80 was not captured")
    assert(result[:native_frames]>=result[:logical_frames],
      "Native presentation stayed frozen despite valid snapshots")
    assert(!active,"VS helper did not finish")
    assert(!$game_temp.in_battle,"Battle intro did not restore in_battle")
  ensure
    self.active=false
    interpreter.clear if interpreter
    # Do not call pbEndBattle: the actual battle scene was never entered.
    $scene.disposeSpritesets if $scene && $scene.is_a?(Scene_Map)
    Graphics.transition(0)
    Graphics.update
  end

  def self.run
    assert(!File.file?("tools/preservation/engine_test/AzureVsTransitionFixture.rb"),
      "Run from an isolated temporary package, not the repository")
    self.output=ENV.fetch("AZURE_VS_OUTPUT")
    assert(Dir.exist?(output),"AZURE_VS_OUTPUT must be an existing directory")
    File.open(ENV.fetch("AZURE_VS_REPORT"),"w") do |file|
      self.report=file
      file.sync=true
      begin
        Object.prepend(IntroProbe)
        $data_system=pbLoadRxData("Data/System")
        $mapinfos=pbCachedRxData("Data/MapInfos")
        pbLoadAzureRuntimeData
        command=load_data("Data/Map006.rxdata").events.fetch(23).pages[1].list[58]
        assert(command.code==111 && command.parameters[1].include?("pbTrainerBattle"),
          "Map006 event23 page2 command58 is no longer the Kara battle")
        Graphics.transition(0)
        start=Graphics.frame_count
        Graphics.freeze
        3.times { Graphics.update }
        assert(Graphics.frame_count==start,"Frozen negative control advanced native frames")
        file.puts("PASS frozen negative control native_frames=0")
        Graphics.transition(0)
        [:ordinary,:inherited_freeze].each { |mode| run_case(mode,command) }
        file.puts("result=PASS")
      rescue Exception => error
        self.active=false
        file.puts("ERROR #{error.class}: #{error.message}")
        file.puts(error.backtrace.first(8))
        file.puts("result=FAIL")
      end
    end
  end
end

if ENV["AZURE_VS_REPORT"] && ENV["AZURE_VS_OUTPUT"]
  AzureVsTransitionFixture.run
  exit
end
