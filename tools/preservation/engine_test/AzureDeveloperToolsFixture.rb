module AzureDeveloperToolsFixture
  STATUS_PATH=File.join(Dir.pwd,"developer_tools_runtime.status.txt")

  def self.write(rows)
    File.open(STATUS_PATH,"wb") {|file|
      for row in rows; file.write(row+"\r\n"); end
    }
  end

  def self.run
    profiler_preloaded=!!defined?(CP_Profiler)
    validator_preloaded=!!defined?(AzurePBSValidator)
    order=File.open("Scripts/!script_order.csv","rb") {|file| file.read }
    profiler_ordered=!!(order =~ /(?:^|\r?\n)Profiler(?:\r?\n|$)/)
    validator_ordered=!!(order =~ /(?:^|\r?\n)AzurePBSValidator(?:\r?\n|$)/)
    profiler_present=AzureDeveloperTools.present?("Profiler.rb")
    validator_present=AzureDeveloperTools.present?("AzurePBSValidator.rb")
    profiler_loaded=AzureDeveloperTools.load("Profiler.rb",:CP_Profiler)
    validator_loaded=AzureDeveloperTools.load("AzurePBSValidator.rb",:AzurePBSValidator)
    profiler_output=(CP_Profiler::OUTPUT_PATH rescue "")
    output_outside_data=(profiler_output=="tools/preservation/profiler_latest.txt")
    result=(!profiler_preloaded && !validator_preloaded && !profiler_ordered &&
            !validator_ordered && profiler_present && validator_present &&
            profiler_loaded && validator_loaded && output_outside_data)
    write([
      "result=#{result ? 'PASS' : 'FAIL'}",
      "profiler_preloaded=#{profiler_preloaded}",
      "validator_preloaded=#{validator_preloaded}",
      "profiler_ordered=#{profiler_ordered}",
      "validator_ordered=#{validator_ordered}",
      "profiler_present=#{profiler_present}",
      "validator_present=#{validator_present}",
      "profiler_loaded=#{profiler_loaded}",
      "validator_loaded=#{validator_loaded}",
      "profiler_output=#{profiler_output}",
      "profiler_output_outside_data=#{output_outside_data}",
      "probe_errors=none"
    ])
    raise "Developer tools fixture failed" if !result
    return true
  rescue Exception
    write(["result=FAIL","error=#{$!.class}: #{$!.message}"])
    raise
  end
end

AzureDeveloperToolsFixture.run
