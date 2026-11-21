class Hangup < Exception; end



def strsplit(str,re)
  ret=[]
  tstr=str
  while re=~tstr
    ret[ret.length]=$~.pre_match
    tstr=$~.post_match
  end
  ret[ret.length]=tstr if ret.length
  return ret
end

def canonicalize(c)
  return System.normalize(c)
end


# Cache from RPG Maker VX library
module Cache
  def self.system(x,hue=0)
    BitmapCache.load_bitmap("Graphics/System/"+x,hue, true)
  end

  def self.character(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Characters/"+x,hue, true)
  end

  def self.picture(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Pictures/"+x,hue, true)
  end

  def self.animation(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Animations/"+x,hue, true)
  end

  def self.battler(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Battlers/"+x,hue, true)
  end

  def self.face(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Faces/"+x,hue, true)
  end

  def self.parallax(x,hue=0)
    BitmapCache.load_bitmap("Graphics/Parallaxes/"+x,hue, true)
  end

  def self.clear
    BitmapCache.clear()
  end

  def self.load_bitmap(dir,name,hue=0)
    BitmapCache.load_bitmap(dir+name,hue, true)
  end
end

# RPG::Cache from RPG Maker XP library
module RPG
  module Cache
    def self.load_bitmap(folder_name, filename, hue = 0)
      BitmapCache.load_bitmap(folder_name+filename.to_s,hue, true)
    end

    def self.animation(filename, hue)
      self.load_bitmap("Graphics/Animations/", filename, hue)
    end

    def self.autotile(filename)
      self.load_bitmap("Graphics/Autotiles/", filename)
    end

    def self.battleback(filename)
      self.load_bitmap("Graphics/Battlebacks/", filename)
    end

    def self.battler(filename, hue)
      self.load_bitmap("Graphics/Battlers/", filename, hue)
    end

    def self.character(filename, hue)
      self.load_bitmap("Graphics/Characters/", filename, hue)
    end

    def self.fog(filename, hue)
      self.load_bitmap("Graphics/Fogs/", filename, hue)
    end

    def self.gameover(filename)
      self.load_bitmap("Graphics/Gameovers/", filename)
    end

    def self.icon(filename)
      self.load_bitmap("Graphics/Icons/", filename)
    end

    def self.panorama(filename, hue)
      self.load_bitmap("Graphics/Panoramas/", filename, hue)
    end

    def self.picture(filename)
      self.load_bitmap("Graphics/Pictures/", filename)
    end

    def self.tileset(filename)
      self.load_bitmap("Graphics/Tilesets/", filename)
    end

    def self.title(filename)
      self.load_bitmap("Graphics/Titles/", filename)
    end

    def self.windowskin(filename)
      self.load_bitmap("Graphics/Windowskins/", filename)
    end

    def self.tile(filename, tile_id, hue)
      BitmapCache.tile(filename,tile_id,hue)
    end

    def self.clear
      BitmapCache.clear()
    end
  end
end

#pk code
# Resolve exact filenames before native prefix matching.
module AzureBitmapFiles
  EXTENSIONS=[".png",".gif",".jpg",".jpeg",".bmp"].freeze
  IMAGE_EXTENSION=/\.(?:png|gif|jpe?g|bmp)\z/i

  def self.clear
    @directories={}
  end

  def self.directory_names(directory)
    key=File.expand_path(directory)
    stamp=File.mtime(directory)
    @directories ||= {}
    entry=@directories[key]
    if !entry || entry[0]!=stamp
      names={}
      Dir.children(directory).each { |name| names[name.downcase] ||= name }
      entry=[stamp,names]
      @directories[key]=entry
    end
    return entry[1]
  rescue SystemCallError, IOError
    return {}
  end

  def self.resolve(filename, directory_snapshot=nil)
    return nil unless filename.is_a?(String) && !filename.empty?
    return nil if filename.end_with?("/","\\")
    filename=filename.tr("\\","/")
    paths=[]
    if defined?(RTP)
      RTP.eachPathFor(filename) { |path| paths << path }
    else
      paths << filename
    end
    paths.each do |path|
      directory=File.dirname(path)
      basename=File.basename(path)
      candidates=[basename]
      candidates.concat(EXTENSIONS.map { |ext| basename+ext }) unless IMAGE_EXTENSION.match?(basename)
      names=directory_snapshot ? (directory_snapshot[directory] ||= directory_names(directory)) : directory_names(directory)
      candidates.each do |candidate|
        actual=names[candidate.downcase]
        next unless actual
        resolved=File.join(directory,actual)
        return resolved if File.file?(resolved)
      end
      # Use the RGSS probe for encrypted archives.
      if respond_to?(:pbTryString,true) &&
         (File.file?("Game.rgssad") || File.file?("Game.rgss2a"))
        candidates.each do |candidate|
          resolved=File.join(directory,candidate)
          return resolved if pbTryString(resolved)
          if IMAGE_EXTENSION.match?(candidate)
            uppercase=resolved.sub(IMAGE_EXTENSION) { |ext| ext.upcase }
            return uppercase if uppercase!=resolved && pbTryString(uppercase)
          end
        end
      end
    end
    return nil
  end
end

module AzureBitmapFileConstructor
  def new(*args,&block)
    if args.length==1 && args[0].is_a?(String)
      resolved=AzureBitmapFiles.resolve(args[0])
      args[0]=resolved if resolved
    end
    return super(*args,&block)
  end
end
Bitmap.singleton_class.prepend(AzureBitmapFileConstructor) unless
  Bitmap.singleton_class.ancestors.include?(AzureBitmapFileConstructor)

class BitmapWrapper < Bitmap
  attr_reader :refcount
  attr_accessor :cache_key

  def dispose
    return if self.disposed?
    @refcount-=1
    if @refcount<=0
      @cache_key=nil
      super
    end
  end

  def initialize(*arg)
    super
    @refcount=1
  end

  def resetRef # internal
    @refcount=1
  end

  def copy
    bm=self.clone
    bm.resetRef
    return bm
  end

  def addRef
    @refcount+=1
  end
end



module BitmapCache
  @cache = ObjectSpace::WeakMap.new
  #pk code
  BATTLE_BITMAP_LIMIT = 16 * 1024 * 1024
  FIELD_STEP_SHEET = "Graphics/Animations/DustandGrass".freeze

  def self.with_battle_bitmaps
    previous_depth = @battle_bitmap_depth.to_i
    @battle_bitmap_depth = previous_depth + 1
    yield
  ensure
    @battle_bitmap_depth = previous_depth
  end

  def self.retain_battle_bitmap(path, bitmap)
    return if @battle_bitmap_depth.to_i == 0 || $INEDITOR
    return unless path.start_with?("Graphics/Pictures/Battle/", "Graphics/Battlebacks/",
      "Graphics/Battlers/", "Graphics/Windowskins/", "Graphics/Characters/trainer",
      "Graphics/Characters/trback", "Graphics/Characters/trfront") ||
      path == "Graphics/Pictures/types" || path.start_with?("Graphics/Pictures/types.")
    return unless bitmap.is_a?(BitmapWrapper) && bitmap.cache_key &&
                  fromCache(bitmap.cache_key).equal?(bitmap)

    @battle_bitmaps ||= {}
    @battle_bitmap_bytes ||= 0
    entry = @battle_bitmaps.delete(path)
    if entry && entry[0].equal?(bitmap)
      @battle_bitmaps[path] = entry
      return
    end
    if entry
      @battle_bitmap_bytes -= entry[1]
      entry[0].dispose
    end
    size = bitmap.width * bitmap.height * 4
    return if size > BATTLE_BITMAP_LIMIT
    while @battle_bitmap_bytes + size > BATTLE_BITMAP_LIMIT
      _old_path, old_entry = @battle_bitmaps.shift
      @battle_bitmap_bytes -= old_entry[1]
      old_entry[0].dispose
    end
    bitmap.addRef
    @battle_bitmaps[path] = [bitmap, size]
    @battle_bitmap_bytes += size
  end
  private_class_method :retain_battle_bitmap

  def self.with_retained_map_bitmaps
    retained=[]
    @cache.each_pair do |path,bitmap|
      next unless path.is_a?(String) && path.start_with?("Graphics/Characters/",
        "Graphics/Tilesets/","Graphics/Autotiles/","Graphics/Panoramas/","Graphics/Fogs/")
      next if !bitmap || bitmap.disposed?
      bitmap.addRef
      retained.push(bitmap)
    end
    yield
  ensure
    retained.each {|bitmap| bitmap.dispose}
  end

  def self.retain_hidden_move_bitmap(bitmap)
    return if $INEDITOR || @hidden_move_bitmap.equal?(bitmap)
    @hidden_move_bitmap.dispose if @hidden_move_bitmap
    @hidden_move_bitmap=nil
    return unless bitmap.is_a?(BitmapWrapper) && bitmap.cache_key &&
                  fromCache(bitmap.cache_key).equal?(bitmap)
    bitmap.addRef
    @hidden_move_bitmap=bitmap
  end

  def self.fromCache(i)
    return nil if !@cache.include?(i)
    obj=@cache[i]
    return nil if obj && obj.disposed?
    return obj
  end

  def self.setKey(key,obj)
    if key.is_a?(String) && obj.is_a?(BitmapWrapper)
      key=-key
      # Keep the WeakMap key alive with the bitmap.
      obj.cache_key=key
    end
    @cache[key]=obj
  end

  def self.debug
    File.open("bitmapcache2.txt","wb"){|f|
       for i in @cache.keys
         k=fromCache(i)
         if !k
           f.write("#{i} (nil)\r\n")
         elsif k.disposed?
           f.write("#{i} (disposed)\r\n")
         else
           f.write("#{i} (#{k.refcount}, #{k.width}x#{k.height})\r\n")
         end
       end
    }
  end

  def self.load_bitmap(path, hue = 0, failsafe = false)
    cached = true
    path = -canonicalize(path)  # This creates a frozen string from the path, to ensure identical paths are treated as identical.
    ret = fromCache(path)
    if !ret
      begin
        ret = BitmapWrapper.new(path)
      rescue Hangup
        begin
          ret = BitmapWrapper.new(path)
        rescue
          raise _INTL("Failed to load the bitmap located at: {1}",path) if !failsafe
          ret = BitmapWrapper.new(32,32)
        end
      rescue
        raise _INTL("Failed to load the bitmap located at: {1}",path) if !failsafe
        ret = BitmapWrapper.new(32,32)
      end
      setKey(path,ret)
      cached = false
    end
    #pk code
    retain_battle_bitmap(path,ret)
    if path == FIELD_STEP_SHEET && !ret.equal?(@field_step_bitmap) && !$INEDITOR
      @field_step_bitmap.dispose if @field_step_bitmap
      ret.addRef
      @field_step_bitmap = ret
    end
    if hue == 0
      ret.addRef if cached
      return ret
    end
    key = [path, hue]
    ret2 = fromCache(key)
    if ret2
      ret2.addRef
    else
      ret2 = ret.copy
      ret2.hue_change(hue)
      @cache[key] = ret2
    end
    return ret2
  end

  def self.animation(filename, hue)
    self.load_bitmap("Graphics/Animations/"+filename, hue)
  end

  def self.autotile(filename)
    self.load_bitmap("Graphics/Autotiles/"+ filename)
  end

  def self.battleback(filename)
    self.load_bitmap("Graphics/Battlebacks/"+ filename)
  end

  def self.battler(filename, hue)
    self.load_bitmap("Graphics/Battlers/"+ filename, hue)
  end

  def self.character(filename, hue)
    self.load_bitmap("Graphics/Characters/"+ filename, hue)
  end

  def self.fog(filename, hue)
    self.load_bitmap("Graphics/Fogs/"+ filename, hue)
  end

  def self.gameover(filename)
    self.load_bitmap("Graphics/Gameovers/"+ filename)
  end

  def self.icon(filename)
    self.load_bitmap("Graphics/Icons/"+ filename)
  end

  def self.panorama(filename, hue)
    self.load_bitmap("Graphics/Panoramas/"+ filename, hue)
  end

  def self.picture(filename)
    self.load_bitmap("Graphics/Pictures/"+ filename)
  end

  def self.tileset(filename)
    self.load_bitmap("Graphics/Tilesets/"+ filename)
  end

  def self.title(filename)
    self.load_bitmap("Graphics/Titles/"+ filename)
  end

  def self.windowskin(filename)
    self.load_bitmap("Graphics/Windowskins/"+ filename)
  end

  def self.tileEx(filename, tile_id, hue)
    key = [filename, tile_id, hue]
    objKey=fromCache(key)
    if !objKey
      bitmap=BitmapWrapper.new(32, 32)
      x = (tile_id - 384) % 8 * 32
      y = (tile_id - 384) / 8 * 32
      rect = Rect.new(x, y, 32, 32)
      tileset = yield(filename)
      bitmap.blt(0, 0, tileset, rect)
      tileset.dispose
      bitmap.hue_change(hue) if hue!=0
      objKey=bitmap
      @cache[key]=objKey
    else
      objKey.addRef
    end
    objKey
  end

  def self.tile(filename, tile_id, hue)
    return self.tileEx(filename, tile_id,hue) {|f| self.tileset(f) }
  end

  def self.clear
    @hidden_move_bitmap.dispose if @hidden_move_bitmap
    @hidden_move_bitmap=nil
    @field_step_bitmap.dispose if @field_step_bitmap
    @field_step_bitmap = nil
    @battle_bitmaps.each_value { |entry| entry[0].dispose } if @battle_bitmaps
    @battle_bitmaps = {}
    @battle_bitmap_bytes = 0
    @cache = ObjectSpace::WeakMap.new
    AzureBitmapFiles.clear
    GC.start
  end
end
