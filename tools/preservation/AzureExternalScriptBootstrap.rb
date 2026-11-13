# Azure's tracked external-script bootstrap.
#
# Data/Scripts.rxdata contains this file as its only embedded script. Keep the
# source here and rebuild the archive with Build-ScriptBootstrap.ps1.

IMPORT_EXPORT_MODE = 3
FOLDER_NAME = "Scripts"
FOLDER_INDICATOR = '@'
BLANK_SCRIPT_TAG = '~blank'
MAKE_EXPORT_COPIES = false
CREATE_SCRIPTS_COPY = true
TABS_TO_SPACES = true

def pbPrintException(e)
  emessage=e.message
  btrace=""
  if e.backtrace
    maxlength=$INTERNAL ? 25 : 10
    e.backtrace[0,maxlength].each {|line| btrace+="#{line}\n" }
  end
  btrace.gsub!(/Section(\d+)/) {$RGSS_SCRIPTS[$1.to_i][1] }
  message="Exception: #{e.class}\nMessage: #{emessage}\n#{btrace}"
  errorlog="errorlog.txt"
  errorlog=RTP.getSaveFileName("errorlog.txt") if Object.const_defined?(:RTP) rescue errorlog
  errorlogline=errorlog.sub(Dir.pwd+"\\","").sub(Dir.pwd+"/","")
  errorlogline="\n"+errorlogline if errorlogline.length>20
  File.open(errorlog,"ab") {|file| file.write(message) }
  if !e.is_a?(Hangup)
    print("#{message}\nThis exception was logged in #{errorlogline}.\n"+
          "Press Ctrl+C to copy this message to the clipboard.")
  end
end

module AzureExternalScriptLoader
  CACHE_VERSION=1
  CACHE_PATH="Data/AzureExternalScripts.cache"
  CACHE_BYPASS_ENV="AZURE_SCRIPT_CACHE_BYPASS"
  CACHE_NO_WRITE_ENV="AZURE_SCRIPT_CACHE_NO_WRITE"
  INVALID_CHAR_REPLACE={
    '\\'=>'&','/'=>'&',':'=>';','*'=>'�','?'=>'!','<'=>'�','>'=>'�',
    '|'=>'�','"'=>"'"
  }

  def self.heartbeat(index,stride=12)
    Graphics.update if index%stride==0
  end

  def self.trace(stage)
    token=ENV["AZURE_STARTUP_PROBE_TOKEN"]
    return if !token || token !~ /\A[0-9a-f]{32}\z/i
    temp=ENV["TEMP"] || ENV["TMP"] || "."
    path=File.join(temp,"PokemonAzureLoader-#{token}.status")
    File.open(path,"wb") {|file| file.write(stage.to_s+"\r\n") }
  rescue StandardError
  end

  def self.read(path)
    File.open(path,"rb") {|file| file.read }
  end

  def self.manifest
    read(File.join(FOLDER_NAME,"!script_order.csv"))
  end

  def self.script_name(filename)
    filename.sub(/~@\d+\z/,"")
  end

  def self.descriptors(manifest_text)
    folder_tree=[FOLDER_NAME]
    result=[]
    manifest_text.split(/\r?\n/).each_with_index do |filename,index|
      heartbeat(index,24)
      code_name=script_name(filename)
      level_and_folder=code_name.scan(/^(#{Regexp.escape(FOLDER_INDICATOR)}+)(.*)/).flatten
      level=level_and_folder[0]
      subfolder=level_and_folder[1]
      if level
        level=level.size
        case level <=> (folder_tree.size-1)
        when -1
          (folder_tree.size-1-level).times { folder_tree.pop }
          if subfolder.empty?
            folder_tree.pop
          else
            folder_tree[-1]=subfolder
          end
        when 0
          if subfolder.empty?
            folder_tree.pop
          else
            folder_tree[-1]=subfolder
          end
        when 1
          if level-(folder_tree.size-1)!=1
            raise "Invalid sublevel for folder!\n"+
                  "Expected: #{FOLDER_INDICATOR*folder_tree.size}#{subfolder}\n"+
                  "Received: #{code_name}"
          end
          raise "Branching subfolder needs a name!" if subfolder.empty?
          folder_tree << subfolder
        end
        next
      end
      if code_name.empty? || code_name[/#{Regexp.escape(BLANK_SCRIPT_TAG)}$/]
        result << [code_name.chomp(BLANK_SCRIPT_TAG),nil]
      else
        result << [code_name,File.join(*(folder_tree+[filename+".rb"]))]
      end
    end
    return result
  end

  def self.signature(manifest_text,descriptors)
    files=[]
    descriptors.each_with_index do |descriptor,index|
      heartbeat(index,24)
      path=descriptor[1]
      next if !path
      stat=File.stat(path)
      files << [path,stat.size,stat.mtime.to_f]
    end
    return [CACHE_VERSION,RUBY_VERSION,manifest_text,files]
  end

  def self.load_cache(signature)
    return nil if ENV[CACHE_BYPASS_ENV]=="1"
    encoded=read(CACHE_PATH)
    payload=Marshal.load(Zlib::Inflate.inflate(encoded))
    return nil if !payload.is_a?(Array) || payload.length!=2
    return nil if payload[0]!=signature
    entries=payload[1]
    return nil if !entries.is_a?(Array)
    return entries
  rescue StandardError
    return nil
  end

  def self.write_cache(signature,entries)
    temporary="#{CACHE_PATH}.#{Process.pid}.tmp"
    encoded=Zlib::Deflate.deflate(Marshal.dump([signature,entries]),1)
    File.open(temporary,"wb") {|file| file.write(encoded) }
    File.delete(CACHE_PATH) if File.exist?(CACHE_PATH)
    File.rename(temporary,CACHE_PATH)
    return true
  rescue StandardError
    File.delete(temporary) if temporary && File.exist?(temporary) rescue nil
    return false
  end

  def self.load_entries
    trace("reading_manifest")
    manifest_text=manifest
    trace("parsing_manifest")
    script_descriptors=descriptors(manifest_text)
    trace("fingerprinting_sources")
    cache_signature=signature(manifest_text,script_descriptors)
    trace("reading_cache")
    entries=load_cache(cache_signature)
    if entries
      $AZURE_SCRIPT_CACHE_STATE=:hit
      trace("cache_hit entries=#{entries.length}")
      return entries
    end
    $AZURE_SCRIPT_CACHE_STATE=:miss
    trace("cache_miss")
    entries=[]
    script_descriptors.each_with_index do |descriptor,index|
      heartbeat(index,8)
      name,path=descriptor
      code=path ? read(path) : ""
      code.gsub!(/\t/) { "  " } if TABS_TO_SPACES
      entries << [name,code]
    end
    trace("writing_cache entries=#{entries.length}")
    write_cache(cache_signature,entries) if ENV[CACHE_NO_WRITE_ENV]!="1"
    trace("sources_ready entries=#{entries.length}")
    return entries
  end

  def self.install(entries,compressed=false)
    counter=1
    entries.each do |entry|
      name,code=entry
      data=code
      if compressed
        stream=Zlib::Deflate.new(6)
        data=stream.deflate(code,Zlib::FINISH)
        stream.close
      end
      $RGSS_SCRIPTS[counter]=[counter,name,nil,data]
      counter+=1
    end
    $RGSS_SCRIPTS.pop while $RGSS_SCRIPTS.length>counter
    return counter
  end

  def self.run_playtest
    trace("playtest_start")
    entries=load_entries
    trace("installing entries=#{entries.length}")
    install(entries,false)
    trace("evaluating entries=#{entries.length}")
    $RGSS_SCRIPTS.each_with_index do |script,index|
      next if index==0
      heartbeat(index,8)
      trace("eval index=#{index} name=#{script[1]}")
      begin
        # This method is defined inside AzureExternalScriptLoader, but external
        # RPG Maker scripts must retain the original top-level lexical scope.
        eval(script[3],TOPLEVEL_BINDING,script[1])
      rescue ScriptError
        pbPrintException($!)
      rescue Exception
        pbPrintException($!)
      end
    end
    exit
  end

  def self.run_import
    source=load_entries
    scripts_file=File.open("Data/Scripts.rxdata","rb")
    import_obj=Marshal.load(scripts_file)
    scripts_file.close
    if CREATE_SCRIPTS_COPY
      File.open("Data/Copy - Scripts.rxdata","wb") {|file| Marshal.dump(import_obj,file) }
    end
    original=$RGSS_SCRIPTS
    begin
      $RGSS_SCRIPTS=import_obj
      count=install(source,true)
      File.open("Data/Scripts.rxdata","wb") {|file| Marshal.dump($RGSS_SCRIPTS[0,count],file) }
    ensure
      $RGSS_SCRIPTS=original
    end
    p "#{source.length} files successfully imported. Please close RPG Maker now without saving it."
    exit
  end

  def self.mkdir_p(parts)
    path=""
    parts.each do |part|
      path=path.empty? ? part : File.join(path,part)
      Dir.mkdir(path) if !File.exist?(path)
    end
  end

  def self.run_export
    folder_name=FOLDER_NAME
    if File.exist?(folder_name)
      if MAKE_EXPORT_COPIES
        suffix=1
        suffix+=1 while File.exist?("#{FOLDER_NAME}_#{suffix}")
        folder_name="#{FOLDER_NAME}_#{suffix}"
        Dir.mkdir(folder_name)
      else
        Dir[File.join(folder_name,"*")].each {|path| File.delete(path) if File.file?(path) }
      end
    else
      Dir.mkdir(folder_name)
    end
    scripts=load_data("Data/Scripts.rxdata")
    order=File.open(File.join(folder_name,"!script_order.csv"),"wb")
    names={}
    folders=[folder_name]
    current_level=0
    exported=0
    scripts.each_with_index do |script,index|
      next if index==0 || !script || script[0].nil?
      id,name,code=script
      match=name.scan(/^(#{Regexp.escape(FOLDER_INDICATOR)}+)(.*)/).flatten
      if match[0]
        level=match[0].size
        folder=match[1].split(//).map {|char| INVALID_CHAR_REPLACE[char] || char }.join
        while current_level>level
          folders.pop
          current_level-=1
        end
        if level==current_level
          if folder.empty?
            folders.pop
            current_level-=1
          else
            folders[-1]=folder
          end
        elsif level==current_level+1
          raise "Branching subfolder needs a name!" if folder.empty?
          folders << folder
          current_level+=1
        else
          raise "Invalid sublevel for folder: #{name}"
        end
        mkdir_p(folders)
        order.write(name+"\r\n")
        next
      end
      filename=name.split(//).map {|char| INVALID_CHAR_REPLACE[char] || char }.join
      source=Zlib::Inflate.inflate(code)
      source.gsub!(/\t/) { "  " } if TABS_TO_SPACES
      if source.empty?
        filename+=BLANK_SCRIPT_TAG if !filename.empty?
        order.write(filename+"\r\n")
        next
      end
      filename="no_script_name" if filename.empty?
      if names.key?(filename)
        names[filename]+=1
        filename="#{filename}~@#{names[filename]}"
      else
        names[filename]=0
      end
      order.write(filename+"\r\n")
      File.open(File.join(*(folders+[filename+".rb"])),"wb") {|file| file.write(source) }
      exported+=1
    end
    order.close
    p "#{exported} files successfully exported to folder '#{folder_name}'"
    exit
  end
end

if IMPORT_EXPORT_MODE!=0
  unless FOLDER_INDICATOR.is_a?(String) && FOLDER_INDICATOR.size==1
    raise "FOLDER_INDICATOR needs to be 1 character long!"
  end
  if RUBY_VERSION=="1.9.2"
    def p(*args); msgbox_p(*args); end
  end
  case IMPORT_EXPORT_MODE
  when 1 then AzureExternalScriptLoader.run_export
  when 2 then AzureExternalScriptLoader.run_import
  else AzureExternalScriptLoader.run_playtest
  end
end
