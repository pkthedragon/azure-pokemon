module AzureReleaseCompileFixture
  STATUS_PATH=File.join(Dir.pwd,"release_compile_runtime.status.txt")
  OUTPUTS=[
    "Data/types.dat","Scripts/PBTypes.rb","Data/townmap.dat",
    "Data/connections.dat","Scripts/PBAbilities.rb","Data/moves.dat",
    "Scripts/PBMoves.rb","Data/pokmanitems.rxdata","Scripts/PBItems.rb",
    "Data/metrics.dat","Data/regionals.dat","Data/evolutions.dat",
    "Data/dexdata.dat","Data/eggEmerald.dat","Data/attacksRS.rxdata",
    "Scripts/PBSpecies.rb","Data/tm.dat","Data/trainertypes.dat",
    "Data/trainers.dat","Scripts/PBTrainers.rb","Data/trainerlists.dat",
    "Data/phone.dat","Data/metadata.dat","Data/encounters.dat",
    "Data/bossdata.dat","Data/shadowmoves.dat","Data/move2anim.dat",
    "Data/PkmnAnimations.rxdata","Data/messages.dat"
  ]

  def self.write(rows)
    File.open(STATUS_PATH,"wb") {|file|
      for row in rows; file.write(row+"\r\n"); end
    }
  end

  def self.read_files(paths)
    result={}
    for path in paths
      result[path]=File.open(path,"rb") {|file| file.read } if File.file?(path)
    end
    return result
  end

  def self.deep_equal?(left,right,seen={})
    return true if left.equal?(right)
    return false if left.class!=right.class
    case left
    when NilClass,TrueClass,FalseClass,Numeric,Symbol,String
      return left==right
    when Array
      return false if left.length!=right.length
      pair=[left.object_id,right.object_id]
      return true if seen[pair]
      seen[pair]=true
      for index in 0...left.length
        return false if !deep_equal?(left[index],right[index],seen)
      end
      return true
    when Hash
      return false if left.length!=right.length
      pair=[left.object_id,right.object_id]
      return true if seen[pair]
      seen[pair]=true
      leftPairs=left.to_a
      rightPairs=right.to_a
      for index in 0...leftPairs.length
        return false if !deep_equal?(leftPairs[index][0],rightPairs[index][0],seen)
        return false if !deep_equal?(leftPairs[index][1],rightPairs[index][1],seen)
      end
      return true
    end
    pair=[left.object_id,right.object_id]
    return true if seen[pair]
    seen[pair]=true
    leftVars=left.instance_variables.map {|name| name.to_s }.sort
    rightVars=right.instance_variables.map {|name| name.to_s }.sort
    return false if leftVars!=rightVars
    if leftVars.length>0
      for name in leftVars
        symbol=name.to_sym
        return false if !deep_equal?(left.instance_variable_get(symbol),
                                     right.instance_variable_get(symbol),seen)
      end
      return true
    end
    begin
      return Marshal.dump(left)==Marshal.dump(right)
    rescue
      return left==right
    end
  end

  def self.semantic_equal?(beforeBytes,afterBytes)
    beforeObject=Marshal.load(beforeBytes)
    afterObject=Marshal.load(afterBytes)
    return deep_equal?(beforeObject,afterObject)
  rescue
    return false
  end

  def self.run
    write(["result=RUNNING","phase=5_step_1_clean_isolated_compile"])
    tracked=pbAzurePBSTrackedFiles("PBS")
    sources=[]
    for filename in tracked
      path=filename[/^(?:PBS|Scripts|Data)[\\\/]/] ? filename : File.join("PBS",filename)
      sources.push(path) if File.file?(path) && !sources.include?(path)
    end
    for path in [%q{Scripts/BossInfo.rb},%q{Data/PkmnAnimations.rxdata}]
      sources.push(path) if File.file?(path) && !sources.include?(path)
    end
    beforeSources=read_files(sources)
    beforeOutputs=read_files(OUTPUTS)
    missingBefore=OUTPUTS.find_all {|path| !beforeOutputs.has_key?(path) }
    started=Process.clock_gettime(Process::CLOCK_MONOTONIC)
    pbCompileAllData(true,true) {|message| }
    MessageTypes.saveMessages
    elapsed=Process.clock_gettime(Process::CLOCK_MONOTONIC)-started
    afterSources=read_files(sources)
    afterOutputs=read_files(OUTPUTS)
    sourceChanges=[]
    for path in sources
      sourceChanges.push(path) if beforeSources[path]!=afterSources[path]
    end
    missingAfter=OUTPUTS.find_all {|path| !afterOutputs.has_key?(path) }
    byteIdentical=[]
    semanticIdentical=[]
    mismatched=[]
    for path in OUTPUTS
      next if !beforeOutputs.has_key?(path) || !afterOutputs.has_key?(path)
      if beforeOutputs[path]==afterOutputs[path]
        byteIdentical.push(path)
      elsif semantic_equal?(beforeOutputs[path],afterOutputs[path])
        semanticIdentical.push(path)
      else
        mismatched.push(path)
      end
    end
    result=(missingBefore.length==0 && missingAfter.length==0 &&
            sourceChanges.length==0 && mismatched.length==0 &&
            byteIdentical.length+semanticIdentical.length==OUTPUTS.length)
    rows=[
      "result=#{result ? 'PASS' : 'FAIL'}",
      "phase=5_step_1_clean_isolated_compile",
      "outputs=#{OUTPUTS.length}",
      "byte_identical=#{byteIdentical.length}",
      "semantic_identical=#{semanticIdentical.length}",
      "mismatched=#{mismatched.length}",
      "missing_before=#{missingBefore.length}",
      "missing_after=#{missingAfter.length}",
      "sources=#{sources.length}",
      "sources_unchanged=#{sourceChanges.length==0}",
      "compile_seconds=#{elapsed}",
      "messages_saved=true",
      "production_install=false",
      "probe_errors=none"
    ]
    rows.push("semantic_paths=#{semanticIdentical.join(',')}")
    rows.push("mismatched_paths=#{mismatched.join(',')}")
    rows.push("source_changes=#{sourceChanges.join(',')}")
    write(rows)
    raise "Release compile fixture failed: #{mismatched.join(',')}" if !result
    return true
  rescue Exception
    write(["result=FAIL","error=#{$!.class}: #{$!.message}"])
    raise
  end
end

AzureReleaseCompileFixture.run
