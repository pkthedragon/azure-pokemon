module AzureDoubleDoseRegression
  class Suite
    attr_reader :cases

    def initialize
      @cases={}
    end

    def test(item,&block)
      raise "Duplicate Double Dose check #{item}" if @cases.key?(item)
      @cases[item]=block
    end
  end

  def self.run(source)
    $data_system=pbLoadRxData("Data/System")
    $mapinfos=pbCachedRxData("Data/MapInfos")
    $game_system=Game_System.new
    pbLoadAzureRuntimeData
    PBDebug.define_singleton_method(:logonerr) { |&block| block.call }
    $INTERNAL=false
    suite=Suite.new
    %w[AzureDoubleDoseSurvival AzureDoubleDoseDamageItems AzureDoubleDoseHitItems AzureDoubleDoseTurnItems].each do |name|
      load File.join(source,name+".rb")
      Object.const_get(name).register(suite)
    end
    File.open(ENV.fetch("AZURE_BATTLE_SIMULATION_REPORT"),"wb") do |report|
      report.sync=true
      failures=suite.cases.sum do |name,check|
        AzureMoveRegression.run_case(report,name) { AzureAbilityFixture::Scenario.new.instance_exec(&check) }
      end
      result=failures==0 ? "PASS" : "FAIL"
      report.puts("result=#{result} cases=#{suite.cases.length} passed=#{suite.cases.length-failures} failed=#{failures}")
    end
  end
end
