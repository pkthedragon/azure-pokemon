module AzureMoveRegression
  GROUPS=%w[AzureMoveEarlyCases AzureMoveMiddleCases AzureMoveTailCases AzureMoveDefenseCases].freeze
  MATRICES=%w[AzureMoveEarlyMatrix AzureMoveMiddleMatrix AzureMoveTailMatrix AzureMoveDefenseMatrix].freeze
  EXPECTED_MOVE_COUNT=150

  class Matrix
    attr_reader :cases

    def initialize
      @cases={}
    end

    def test(move,&test)
      raise "Duplicate move case #{move}" if @cases.key?(move)
      PBMoveData.get(move)
      @cases[move]=test
    end
  end

  def self.run_case(file,label)
    Graphics.update
    AzureAbilityFixture.setup_new_game
    srand(134)
    yield
    file.puts("PASS #{label}")
    return 0
  rescue StandardError, ScriptError => error
    file.puts("FAIL #{label} #{error.class}: #{error.message}")
    file.puts(error.backtrace.first(8))
    return 1
  end

  def self.run(source)
    $data_system=pbLoadRxData("Data/System")
    $mapinfos=pbCachedRxData("Data/MapInfos")
    $game_system=Game_System.new
    pbLoadAzureRuntimeData
    PBDebug.define_singleton_method(:logonerr) { |&block| block.call }
    $INTERNAL=false
    File.open(ENV.fetch("AZURE_BATTLE_SIMULATION_REPORT"),"wb") do |file|
      file.sync=true
      group_failures=0
      GROUPS.each do |group|
        group_failures+=run_case(file,group) do
          load File.join(source,group+".rb")
          Object.const_get(group).run
        end
      end
      matrix=Matrix.new
      MATRICES.each do |name|
        load File.join(source,name+".rb")
        Object.const_get(name).register(matrix)
      end
      raise "Expected #{EXPECTED_MOVE_COUNT} move cases, found #{matrix.cases.length}" if matrix.cases.length!=EXPECTED_MOVE_COUNT

      move_failures=matrix.cases.sum do |move,test|
        run_case(file,move) { AzureAbilityFixture::Scenario.new.instance_exec(&test) }
      end
      result=move_failures+group_failures==0 ? "PASS" : "FAIL"
      file.puts("result=#{result} moves=#{matrix.cases.length} passed=#{matrix.cases.length-move_failures} failed=#{move_failures} groups=#{GROUPS.length} group_failures=#{group_failures}")
    end
  end
end
