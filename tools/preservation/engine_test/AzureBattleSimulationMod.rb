if ENV["AZURE_BATTLE_SIMULATION_REPORT"]
  begin
    source=ENV.fetch("AZURE_BATTLE_SIMULATION_SOURCE")
    load File.join(source,"AzureAbilityFixture.rb")
    if ENV["AZURE_BATTLE_COMPILE_DATA"]=="1"
      load File.join(source,"AzureCompileBattleData.rb")
      AzureCompileBattleData.run
    elsif !ENV["AZURE_BATTLE_CATALOG_AUDIT"].to_s.empty?
      load File.join(source,"AzureCatalogAudit.rb")
      AzureCatalogAudit.run(source,ENV.fetch("AZURE_BATTLE_CATALOG_AUDIT"))
    elsif ENV["AZURE_BATTLE_AI_REGRESSIONS"]=="1"
      load File.join(source,"AzureMoveRegression.rb")
      load File.join(source,"AzureAIRegression.rb")
      AzureAIRegression.run(source)
    elsif ENV["AZURE_BATTLE_DOUBLE_DOSE"]=="1"
      load File.join(source,"AzureMoveRegression.rb")
      load File.join(source,"AzureDoubleDoseRegression.rb")
      AzureDoubleDoseRegression.run(source)
    elsif ENV["AZURE_BATTLE_CUSTOM_MOVES"]=="1"
      load File.join(source,"AzureMoveRegression.rb")
      load File.join(source,"AzureCustomMoveRegression.rb")
      AzureCustomMoveRegression.run(source)
    elsif ENV["AZURE_BATTLE_MOVE_REGRESSIONS"]=="1"
      load File.join(source,"AzureMoveRegression.rb")
      AzureMoveRegression.run(source)
    else
      load File.join(source,"AzureBattleSimulation.rb")
      AzureBattleSimulation.run
    end
  rescue StandardError, ScriptError => error
    File.open(ENV.fetch("AZURE_BATTLE_SIMULATION_REPORT"),"ab") do |report|
      error.full_message.each_line { |line| report.puts("ERROR #{line.rstrip}") }
      report.puts("result=FAIL")
    end
  end
  # The launcher shuts down this isolated process after reading the result.
  loop { Graphics.update }
end
