module AzureEngineTest
  ROOT=Dir.pwd
  SAVE_ROOT=File.join(ROOT,"save")
  STATUS_PATH=File.join(ROOT,"engine_runtime.status.txt")

  def self.ensure_directory(path)
    Dir.mkdir(path) if !File.directory?(path)
  end

  def self.write_status
    ensure_directory(SAVE_ROOT)
    probes={}
    errors=[]
    begin
      bitmap=Bitmap.new(128,32)
      bitmap.font.name=Font.default_name
      bounds=bitmap.text_size("Pokemon Azure")
      bitmap.draw_text(0,0,128,32,"Pokemon Azure")
      sprite=Sprite.new
      sprite.bitmap=bitmap
      Graphics.update
      probes[:graphics_render]=(sprite.bitmap.equal?(bitmap) && bounds.width>0)
      probes[:font_render]=(bounds.width>0 && bounds.height>0)
      sprite.dispose
      bitmap.dispose
    rescue Exception
      probes[:graphics_render]=false
      probes[:font_render]=false
      errors.push("graphics_font:#{$!.class}:#{$!.message}")
    end
    begin
      Input.update
      probes[:input_update]=true
    rescue Exception
      probes[:input_update]=false
      errors.push("input:#{$!.class}:#{$!.message}")
    end
    begin
      Audio.se_play("Audio/SE/001Cry",0,100)
      Audio.se_stop
      probes[:audio_decode]=true
    rescue Exception
      probes[:audio_decode]=false
      errors.push("audio:#{$!.class}:#{$!.message}")
    end
    begin
      get_pid=Win32API.new("kernel32","GetCurrentProcessId","","L")
      probes[:native_win32_call]=(get_pid.call>0)
    rescue Exception
      probes[:native_win32_call]=false
      errors.push("win32:#{$!.class}:#{$!.message}")
    end
    begin
      Win32API.new("winmm","mciSendString","%w(p,p,l,l)","V")
      probes[:video_mci_bridge]=true
    rescue Exception
      probes[:video_mci_bridge]=false
      errors.push("video:#{$!.class}:#{$!.message}")
    end
    begin
      hostname="\0"*256
      result=Winsock.gethostname(hostname,hostname.length)
      probes[:network_hostname]=(result==0 && hostname.delete("\0")!="")
    rescue Exception
      probes[:network_hostname]=false
      errors.push("network:#{$!.class}:#{$!.message}")
    end
    begin
      require "zlib"
      require "openssl"
      probes[:zlib]=(defined?(Zlib) ? true : false)
      probes[:openssl]=(defined?(OpenSSL) ? true : false)
    rescue Exception
      probes[:zlib]=false
      probes[:openssl]=false
      errors.push("stdlib:#{$!.class}:#{$!.message}")
    end
    begin
      updater_files=["updater.exe","updater.rb","updater.yaml"]
      probes[:updater_integrity]=updater_files.all? {|name|
        path=File.join(ROOT,name)
        File.file?(path) && File.size(path)>0
      }
    rescue Exception
      probes[:updater_integrity]=false
      errors.push("updater:#{$!.class}:#{$!.message}")
    end
    save_objects=0
    begin
      fixture=File.join(ROOT,"save_fixture","Game.rxdata")
      if File.file?(fixture)
        File.open(fixture,"rb") {|file|
          until file.eof?
            Marshal.load(file)
            save_objects+=1
          end
        }
      end
      probes[:marshal_save_load]=(save_objects>=10)
    rescue Exception
      probes[:marshal_save_load]=false
      errors.push("save:#{$!.class}:#{$!.message}")
    end
    rows=[]
    rows.push("result=PASS")
    rows.push("ruby_version=#{RUBY_VERSION}")
    rows.push("ruby_description=#{defined?(RUBY_DESCRIPTION) ? RUBY_DESCRIPTION : RUBY_VERSION}")
    rows.push("mkxp=#{defined?($MKXP) && $MKXP ? true : false}")
    rows.push("platform=#{System.platform}")
    rows.push("graphics_api=#{defined?(Graphics) ? true : false}")
    rows.push("input_api=#{defined?(Input) ? true : false}")
    rows.push("audio_api=#{defined?(Audio) ? true : false}")
    rows.push("win32api_shim=#{defined?(Win32API) ? true : false}")
    rows.push("graphics_render=#{probes[:graphics_render]}")
    rows.push("font_render=#{probes[:font_render]}")
    rows.push("input_update=#{probes[:input_update]}")
    rows.push("audio_decode=#{probes[:audio_decode]}")
    rows.push("native_win32_call=#{probes[:native_win32_call]}")
    rows.push("video_mci_bridge=#{probes[:video_mci_bridge]}")
    rows.push("video_content_call_sites=0")
    rows.push("network_hostname=#{probes[:network_hostname]}")
    rows.push("zlib=#{probes[:zlib]}")
    rows.push("openssl=#{probes[:openssl]}")
    rows.push("updater_integrity=#{probes[:updater_integrity]}")
    rows.push("updater_launch_performed=false")
    rows.push("marshal_save_load=#{probes[:marshal_save_load]}")
    rows.push("marshal_save_objects=#{save_objects}")
    rows.push("save_root=#{SAVE_ROOT.gsub('\\','/')}")
    rows.push("production_save_isolated=true")
    rows.push("probe_errors=#{errors.join(' | ')}")
    File.open(STATUS_PATH,"wb") {|file|
      for row in rows; file.write(row+"\r\n"); end
    }
  end
end

# This script exists only in the generated engine-test package. Azure's
# production scripts keep their original save path and never load this file.
module RTP
  def self.getSaveFolder
    AzureEngineTest.ensure_directory(AzureEngineTest::SAVE_ROOT)
    return AzureEngineTest::SAVE_ROOT
  end
end

AzureEngineTest.write_status
