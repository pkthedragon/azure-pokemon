# Native mkxp customScript regression fixture. Run in an isolated game package
# with AZURE_BITMAP_SOURCE set to the repository and optional AZURE_BITMAP_REPORT.
# The working directory must be outside the repository; generated images stay there.
require "zlib"

module AzureBitmapLoadingFixture
  SOURCE=ENV.fetch("AZURE_BITMAP_SOURCE")
  REPORT=ENV["AZURE_BITMAP_REPORT"] || "bitmap_loading_runtime.status.txt"
  ROOT="BitmapFixtures"
  DATA={
    "PNG"=>"eJzrDPBz5+WS4mJgYOD19HAJAtLaQCzLwQQk98gwqQMpJ08Xx5CKOW8vOPIyKDAcPmDE/sJZzs3T4UjFFraymzOyg3XvVrJuv6CXy8AV0MBkX9FalskMZIj8OKi9xVu6gclOQMafkdGTv2oFH9A0Bk9XP5d1TglNAEcBIYI=",
    "GIF"=>"eJxz93SzME/UZpBlaGRgEIxezAADOiACJO7AYc3AyCHjsWHBwWYOYa2YExsWHm4XUPaa47Fx0dFuCeOsOyc2Lj7er+DcJeO5acnJyRrBq2JOblp6erpBchQPB4M1AJXaHsU=",
    "JPG"=>"eJz7f+P/AwYBLzdPNwZGRgYGRiBk+H+bwZmBg42NnY2Vg52dnZOTg4tHhJeHm5tHUkiYX0RWSl5OVkpGRkFFT11BSUdZRkbDXFPHwNDExERe3dLWwshGz9jECGQIIycnJw83jwQvr4SRooyiEcng/wEGQQ4GWQZtZkYlBiZBRmZBxv9HGOSB7mRlBAMGKGBkYmZhZWPn4OTiBirYKsDAxMjMzMTCzMrKwgKUrQXKM7AIsgopGjqyCQcmsisVihg1TlzIoey08aBo0MUPKsZJRU2cXGLiEpJSqmrqGppaJqZm5haWVs4urm7uHp5ewSGhYeERkVHJKalp6RmZWcUlpWXlFZVVzS2tbe0dnV2TJk+ZOm36jJmzFi1esnTZ8hUrV23avGXrtu07du46dPjI0WPHT5w8denylavXrt+4eevho8dPnj57/uLlq4+fPn/5+u37j5+/QP5iZGBmhAGs/hIE+ouJhYWZhR3kL0amcpACQRZWRUM2IcdA9sRCYSWjRg4Rp4kLNx7kVDYO+iCaVHSRS0zF5KHqR5DXwD4jzmNNZPkM7jGEv24x8DAzAiOPWZDBnuGxxqKuX5ufOXVpLGBCw/z/bwIAf+LXDA==",
    "BMP"=>"eJxz8tXiZwADMyDWAGJtIJYFYkYGCbD4Fz4GhiNQDAOLowUHFo26YdQNo24YdcOoG0bdMOqGUTeMumHUDaNuGHXDqBtG3UAjNwAA3WUsig==",
    "Tiny.PNG"=>"eJzrDPBz5+WS4mJgYOD19HAJAtIKIMzBBCT/SLxdDKTMPF0cQyrmvD1ryMhgwHHkwHK+Ves/GURxJiae5vR4te/css1R/c2M7CcYixpkFGCUonyKEqO/6vuVIIMYPF39XNY5JTQBAG0SIFc=",
    "Tiny.GIF"=>"eJxz93SzME9UYFBgaGRgEIxezAADOiACJO7AYcrAyCHjsWHBwWYOYa2YExsWHm4XUPaa47Fx0dFuCeOsOyc2Lj7er+DcJeO5acnJyRrBq2JOBqU4MFgDANM6G+s="
  }.freeze

  def self.assert(value,message)
    raise message unless value
  end

  def self.image_data(format)
    format="JPG" if format=="JPEG"
    return Zlib.inflate(DATA.fetch(format).unpack1("m0"))
  end

  def self.write_image(path,format="PNG")
    File.binwrite(path,image_data(format))
  end

  def self.valid_image(bitmap,width=43,height=29)
    assert(bitmap.width==width && bitmap.height==height,"Wrong image size #{bitmap.width}x#{bitmap.height}")
    color=bitmap.get_pixel(width/2,height/2)
    assert(color.alpha==255 && (color.red-17).abs<=1 && (color.green-91).abs<=1 &&
      (color.blue-163).abs<=1,"Image content is blank or wrong: #{[color.red,color.green,color.blue,color.alpha].inspect}")
  end

  def self.test(name)
    yield
    @report.puts "PASS #{name}"
  end

  def self.load_runtime
    load File.join(SOURCE,"Scripts/BitmapCache.rb")
    load File.join(SOURCE,"Scripts/SpriteWindow.rb")
    # Compiler.rb installs this normalization during a full game boot. The
    # customScript fixture loads only graphics code and uses the same behavior.
    Object.send(:define_method,:canonicalize) { |path| path }
  end

  def self.run
    working_directory=File.expand_path(Dir.pwd).tr("\\","/").downcase
    source_directory=File.expand_path(SOURCE).tr("\\","/").downcase
    assert(working_directory!=source_directory && !working_directory.start_with?(source_directory+"/"),
      "Run this fixture from an isolated game package, not the repository")
    Dir.mkdir(ROOT) unless Dir.exist?(ROOT)
    ["PNG","GIF","JPG","JPEG","BMP"].each do |format|
      folder=File.join(ROOT,format)
      Dir.mkdir(folder) unless Dir.exist?(folder)
      write_image(File.join(folder,"ColorImage.#{format}"),format)
    end
    write_image(File.join(ROOT,"Tiny.PNG"),"Tiny.PNG")
    write_image(File.join(ROOT,"Tiny.GIF"),"Tiny.GIF")
    write_image(File.join(ROOT,"585-sm.png"))
    write_image(File.join(ROOT,"585.png"))
    write_image(File.join(ROOT,"battlebgDream - Copy.png"))
    write_image(File.join(ROOT,"battlebgDream.png"))
    load_runtime

    test("five native formats, filename case, directory case, extensionless and explicit paths") do
      ["PNG","GIF","JPG","JPEG","BMP"].each do |format|
        ["ColorImage.#{format}","ColorImage.#{format.downcase}","colorimage.#{format}","colorimage"].each do |name|
          path=File.join(ROOT.downcase,format.downcase,name)
          resolved=pbResolveBitmap(path)
          assert(resolved && File.basename(resolved)=="ColorImage.#{format}","Failed to resolve #{path}")
          [Bitmap,BitmapWrapper].each do |klass|
            bitmap=klass.new(path)
            valid_image(bitmap)
            assert(bitmap.refcount==1,"Bad wrapper ownership") if klass==BitmapWrapper
            bitmap.dispose
          end
        end
      end
    end

    test("Deerling and Dream prefix collisions") do
      ["585","battlebgDream"].each do |name|
        bitmap=Bitmap.new(File.join(ROOT,name))
        valid_image(bitmap)
        bitmap.dispose
      end
    end

    test("valid 32x32 PNG and GIF are never treated as fallback images") do
      ["Tiny.PNG","Tiny.GIF"].each do |name|
        animated=AnimatedBitmap.new(File.join(ROOT,name.downcase))
        valid_image(animated.bitmap,32,32)
        animated.dispose
      end
    end

    test("raw canvas, native clone, wrapper copy and independent mutation") do
      canvas=Bitmap.new(7,9)
      canvas.fill_rect(0,0,7,9,Color.new(11,22,33,255))
      copy=canvas.clone
      canvas.dispose
      assert(copy.width==7 && copy.height==9 && copy.get_pixel(3,4).red==11,"Native clone was changed or disposed")
      copy.dispose
      original=BitmapWrapper.new(File.join(ROOT,"PNG/colorimage.png"))
      copied=original.copy
      assert(copied.refcount==1 && original.refcount==1,"Wrapper copy did not get independent ownership")
      copied.clear
      valid_image(original)
      original.dispose
      assert(!copied.disposed?,"Disposing original disposed its copy")
      copied.dispose
    end

    test("cache reference counts and AnimatedBitmap copy") do
      path=File.join(ROOT,"PNG/colorimage.png")
      first=BitmapCache.load_bitmap(path)
      second=BitmapCache.load_bitmap(path)
      assert(first.equal?(second) && first.refcount==2,"Cache did not reuse source with one reference per caller")
      first.dispose
      valid_image(second)
      assert(second.refcount==1,"Caller disposal released another caller's reference")
      second.dispose
      animated=AnimatedBitmap.new(path)
      copied=animated.copy
      animated.dispose
      valid_image(copied.bitmap)
      copied.dispose
    end

    test("IconSprite and AnimatedPlane load, update and release source") do
      path=File.join(ROOT,"PNG/colorimage.png")
      icon=IconSprite.new(0,0)
      icon.setBitmap(path)
      icon.update
      valid_image(icon.bitmap)
      icon_source=icon.bitmap
      plane=AnimatedPlane.new(nil)
      plane.setBitmap(path)
      plane.update
      valid_image(plane.bitmap)
      assert(plane.bitmap.equal?(icon_source),"UI wrappers bypassed shared source ownership")
      icon.dispose
      valid_image(plane.bitmap)
      plane.dispose
      assert(icon_source.disposed?,"UI owners leaked the bitmap")
    end

    test("missing image fallback is uncached and a newly added image becomes visible") do
      path=File.join(ROOT,"AddedLater")
      File.delete(path+".PNG") if File.exist?(path+".PNG")
      missing=AnimatedBitmap.new(path)
      assert(missing.width==32 && missing.bitmap.get_pixel(16,16).alpha==0,"Missing optional image has no transparent fallback")
      assert(BitmapCache.fromCache(-path).nil?,"Missing fallback was cached as a real source")
      missing.dispose
      assert(pbResolveBitmap(path).nil?,"Missing image unexpectedly resolved")
      write_image(path+".PNG")
      added=AnimatedBitmap.new(path)
      valid_image(added.bitmap)
      added.dispose
    end

    test("existing corrupt image raises instead of silently becoming transparent") do
      path=File.join(ROOT,"Corrupt.png")
      File.binwrite(path,"invalid image content")
      raised=false
      begin
        AnimatedBitmap.new(path)
      rescue Exception
        raised=true
      end
      assert(raised,"An existing corrupt image became a blank fallback")
    end

    test("missing raw constructor keeps native failure behavior") do
      raised=false
      begin
        Bitmap.new(File.join(ROOT,"MissingNative.PNG"))
      rescue Errno::ENOENT
        raised=true
      end
      assert(raised,"Missing raw Bitmap did not preserve native ENOENT")
    end

    test("archive probing still resolves files outside loose directory listings") do
      archive="Game.rgssad"
      assert(!File.exist?(archive),"Isolated fixture unexpectedly contains an archive")
      original=Object.instance_method(:pbTryString)
      begin
        File.binwrite(archive,"")
        Object.send(:define_method,:pbTryString) { |path| path=="Archived/Only.PNG" ? path : nil }
        assert(AzureBitmapFiles.resolve("Archived/Only")=="Archived/Only.PNG","Archive uppercase extension fallback was lost")
      ensure
        Object.send(:define_method,:pbTryString,original)
        File.delete(archive) if File.exist?(archive)
      end
    end

    test("native transition masks resolve actual filenames and coded transitions keep their names") do
      load File.join(SOURCE,"Scripts/Transitions.rb")
      native_transition=Graphics.method(:transition_KGC_SpecialTransition)
      breaking_glass=BreakingGlass.method(:new)
      calls=[]
      selected=[]
      completed=Object.new
      completed.define_singleton_method(:disposed?) { true }
      begin
        Graphics.define_singleton_method(:transition_KGC_SpecialTransition) { |*args| calls << args }
        BreakingGlass.define_singleton_method(:new) { |duration| selected << duration; completed }
        Graphics.transition(4,File.join(ROOT,"PNG/colorimage.png"),19)
        assert(calls.last==[4,File.join(ROOT,"PNG/ColorImage.PNG"),19],"Native mask filename was not resolved: #{calls.last.inspect}")
        Graphics.transition(7,"BreakingGlass",23)
        assert(selected==[7] && calls.last==[0,"",23],"Coded transition selection changed")
      ensure
        Graphics.define_singleton_method(:transition_KGC_SpecialTransition,native_transition)
        BreakingGlass.define_singleton_method(:new,breaking_glass)
        Graphics.class_variable_set(:@@transition,nil)
      end
    end

    test("cache clear preserves active callers and refreshes the filename index") do
      path=File.join(ROOT,"PNG/colorimage.png")
      active=BitmapCache.load_bitmap(path)
      BitmapCache.clear
      valid_image(active)
      reloaded=BitmapCache.load_bitmap(path)
      assert(!active.equal?(reloaded),"Cache clear retained an old lookup")
      valid_image(reloaded)
      active.dispose
      reloaded.dispose
    end

    test("script reload does not duplicate the constructor prepend") do
      BitmapCache.clear
      previous_verbose=$VERBOSE
      begin
        $VERBOSE=nil
        2.times { load File.join(SOURCE,"Scripts/BitmapCache.rb") }
      ensure
        $VERBOSE=previous_verbose
      end
      Object.send(:define_method,:canonicalize) { |path| path }
      count=Bitmap.singleton_class.ancestors.count { |entry| entry==AzureBitmapFileConstructor }
      assert(count==1,"Constructor wrapper was installed #{count} times")
      bitmap=BitmapWrapper.new(File.join(ROOT,"PNG/colorimage.png"))
      valid_image(bitmap)
      assert(bitmap.refcount==1,"Reload changed wrapper reference count")
      bitmap.dispose
    end
    @report.puts "result=PASS"
  end

  def self.main
    File.open(REPORT,"wb") do |report|
      @report=report
      report.sync=true
      begin
        run
      rescue Exception=>error
        report.puts "FAIL #{error.class}: #{error.message}"
        report.puts error.backtrace.first(12)
        report.puts "result=FAIL"
      end
    end
  end
end

AzureBitmapLoadingFixture.main
exit
