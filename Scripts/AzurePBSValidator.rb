# Read-only bridge from the in-game debug menu to Azure's preservation audit.
# It validates source schemas, references, contracts, and compiled-data freshness
# without compiling or changing PBS/compiled data.
module AzurePBSValidator
  AUDIT_PATH="tools/preservation/Audit-Azure.ps1"
  LOG_PATH="tools/preservation/pbs_validation.log"

  def self.windows?
    return !!(RUBY_PLATFORM[/mswin|mingw|cygwin/i])
  end

  def self.quoted_path(path)
    text=path.to_s
    raise "Paths containing double quotes are not supported." if text.include?('"')
    return '"'+text+'"'
  end

  def self.powershell
    if windows? && ENV["SystemRoot"]
      bundled=File.join(ENV["SystemRoot"],"System32","WindowsPowerShell","v1.0","powershell.exe")
      return bundled if File.exist?(bundled)
    end
    return windows? ? "powershell.exe" : "pwsh"
  end

  def self.run(root=Dir.pwd)
    root=File.expand_path(root)
    audit=File.expand_path(AUDIT_PATH,root)
    log=File.expand_path(LOG_PATH,root)
    if !File.exist?(audit)
      return {
        :ok=>false,
        :exit_code=>-1,
        :summary=>"Validation tool is missing: #{audit}",
        :log=>log,
        :output=>""
      }
    end

    command="#{quoted_path(powershell)} -NoLogo -NoProfile -NonInteractive "
    command+="-ExecutionPolicy Bypass "
    command+="-WindowStyle Hidden " if windows?
    command+="-File #{quoted_path(audit)} -Root #{quoted_path(root)} 2>&1"
    output=""
    exitCode=-1
    begin
      IO.popen(command,"rb"){|pipe| output=pipe.read.to_s }
      processStatus=$?
      exitCode=processStatus.exitstatus if processStatus && processStatus.respond_to?(:exitstatus)
    rescue Exception
      output="#{($!.class rescue Exception)}: #{($!.message rescue '')}\r\n"
      output+=$!.backtrace.join("\r\n") if $! && $!.backtrace
    end

    summary=output[/Summary:\s*\d+ checks,\s*\d+ warnings,\s*\d+ failures\./]
    summary="Validation process exited with code #{exitCode}." if !summary
    begin
      File.open(log,"wb"){|file|
        file.write("Azure PBS validation #{Time.new}\r\n")
        file.write("Command: #{command}\r\n\r\n")
        file.write(output)
      }
    rescue Exception
      return {
        :ok=>false,
        :exit_code=>exitCode,
        :summary=>"Validation finished, but its log could not be written: #{($!.message rescue '')}",
        :log=>log,
        :output=>output
      }
    end
    return {
      :ok=>(exitCode==0),
      :exit_code=>exitCode,
      :summary=>summary,
      :log=>log,
      :output=>output
    }
  end
end

def pbValidateAzureProject(root=Dir.pwd)
  return AzurePBSValidator.run(root)
end
