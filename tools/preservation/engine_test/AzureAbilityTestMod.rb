if ENV["AZURE_ABILITY_TEST_SOURCE"] && ENV["AZURE_ABILITY_TEST_REPORT"]
  begin
    fixture_root=ENV.fetch("AZURE_ABILITY_TEST_SOURCE")
    load File.join(fixture_root,"AzureAbilityFixture.rb")
    %w[AzureAbilityCustomCases AzureAbilityMiddleCases AzureAbilityTailCases].each do |name|
      load File.join(fixture_root,name+".rb")
    end
    AzureAbilityFixture.run
  rescue StandardError, ScriptError => error
    File.open(ENV.fetch("AZURE_ABILITY_TEST_REPORT"),"a") do |file|
      file.puts(error.full_message)
      file.puts("result=ERROR")
    end
  end
  # The launcher terminates this private Game.exe once the report is complete.
  # Calling RGSS exit here would run the game's exception logger.
  loop { Graphics.update }
end
