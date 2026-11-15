module AzureAIRegression
  class Suite
    attr_reader :cases

    def initialize
      @cases={}
    end

    def test(name,&check)
      raise "Duplicate AI case #{name}" if @cases.key?(name)
      @cases[name]=check
    end
  end

  module Checks
    def ai_prepare
      @battle.eachActiveBattlerIndex do |index|
        owner=@battle.pbGetOwner(index)
        owner.define_singleton_method(:skill) { 100 } if owner
      end
    end

    def ai_score(name,user=@user,target=@foe,skill=100)
      move_id=PBMoves.const_get(name)
      candidate=user.moves.find { |known| known.id==move_id } || move(name,user)
      base=@battle.pbAIRoughDamagePercentForTarget(candidate,user,target,skill)
      @battle.pbGetMoveScore(candidate,user,target,skill,base,[base],0,true)
    end

    def ai_choices(user=@user)
      ai_prepare
      @battle.pbBuildMoveScores(user.index,false,true)
      user.moves.each_with_index.each_with_object({}) do |(candidate,slot),scores|
        next if candidate.id<=0
        symbol=PBMoves.constants(false).find { |name| PBMoves.const_get(name)==candidate.id }
        scores[symbol]=[@battle.scores[slot],(@battle.targets || [])[slot]]
      end
    end

    def ai_command(user=@user)
      ai_prepare
      @battle.pbDefaultChooseEnemyCommand(user.index)
      @battle.choices[user.index]
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
    filter=ENV["AZURE_BATTLE_AI_FILTER"]
    filter=filter && !filter.empty? ? Regexp.new(filter) : nil
    %w[AzureAICustomMoveCases AzureAIReworkedMoveCases AzureAITargetCases AzureAISharedCases].each do |name|
      next if filter && !File.file?(File.join(source,name+".rb"))
      load File.join(source,name+".rb")
      Object.const_get(name).register(suite)
    end
    File.open(ENV.fetch("AZURE_BATTLE_SIMULATION_REPORT"),"wb") do |report|
      report.sync=true
      cases=suite.cases.select { |name,_| !filter || filter.match?(name.to_s) }
      failures=cases.sum do |name,check|
        AzureMoveRegression.run_case(report,name) do
          fixture=AzureAbilityFixture::Scenario.new
          fixture.extend(Checks)
          fixture.instance_exec(&check)
        end
      end
      catalog_count,catalog_failures=run_catalog(report) if !filter || filter.match?("CATALOG")
      count=cases.length+catalog_count.to_i
      failures+=catalog_failures.to_i
      status=count>0 && failures.zero? ? "PASS" : "FAIL"
      report.puts("result=#{status} cases=#{cases.length} catalog=#{catalog_count.to_i} passed=#{count-failures} failed=#{failures}")
    end
  end

  def self.run_catalog(report)
    AzureAbilityFixture.setup_new_game
    srand(134)
    failures=0
    count=0
    PBMoveData.each do |data|
      next if data.id<=0 || PBMove.current_id(data.id)!=data.id
      count+=1
      fixture=AzureAbilityFixture::Scenario.new
      fixture.extend(Checks)
      battle=fixture.battle(:NONE,:NONE,foe_species: :LAPRAS)
      user,target=battle.battlers
      move=PokeBattle_Move.pbFromPBMove(battle,PBMove.new(data.id),user)
      begin
        fixture.ai_prepare
        if data.id==PBMoves::STRUGGLE
          score=battle.pbAIRoughDamagePercentForTarget(move,user,target,100)
        else
          user.moves[0]=move
          battle.pbBuildMoveScores(user.index,false,true)
          score=battle.scores[0]
        end
        raise "invalid score #{score.inspect}" unless score.is_a?(Numeric) && score.finite?
        report.puts("PASS CATALOG #{data.id} #{move.name} score=#{score}")
      rescue StandardError, ScriptError => error
        failures+=1
        report.puts("FAIL CATALOG #{data.id} #{move.name} #{error.class}: #{error.message.lines.first&.strip}")
        report.puts(error.backtrace.first(4))
      end
      Graphics.update if count%30==0
    end
    return count,failures
  end
end
