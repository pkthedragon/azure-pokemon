module FileInputMixin
  def fgetb
    x=0
    ret=0
    each_byte do |i|
      if i.is_a? Integer
        ret=i || 0
      else
        ret=i.ord || 0
      end
      break
    end
    return ret
  end

  def fgetw
    x=0
    ret=0
    each_byte do |i|
      break if !i
      if i.is_a? Integer
        ret|=(i<<x)
      else
        ret|=(i.ord<<x)
      end
      x+=8
      break if x==16
    end
    return ret
  end

  def fgetdw
    x=0
    ret=0
    each_byte do |i|
      break if !i
      if i.is_a? Integer
        ret|=(i<<x)
      else
        ret|=(i.ord<<x)
      end
      x+=8
      break if x==32
    end
    return ret
  end

  def fgetsb
    ret=fgetb
    if (ret&0x80)!=0
      return ret-256
    else
      return ret
    end
  end

  def xfgetb(offset)
    self.pos=offset
    return fgetb
  end

  def xfgetw(offset)
    self.pos=offset
    return fgetw
  end

  def xfgetdw(offset)
    self.pos=offset
    return fgetdw
  end

  def getOffset(index)
    self.binmode
    self.pos=0
    offset=fgetdw>>3
    return 0 if index>=offset
    self.pos=index*8
    return fgetdw
  end

  def getLength(index)
    self.binmode
    self.pos=0
    offset=fgetdw>>3
    return 0 if index>=offset
    self.pos=index*8+4
    return fgetdw
  end

  def readName(index)
    self.binmode
    self.pos=0
    offset=fgetdw>>3
    return "" if index>=offset
    self.pos=index<<3
    offset=fgetdw
    length=fgetdw
    return "" if length==0
    self.pos=offset
    return read(length)
  end
end



module FileOutputMixin
  def fputb(b)
    b=b&0xFF
    write(b.chr)
  end

  def fputw(w)
    2.times do
      b=w&0xFF
      write(b.chr)
      w>>=8
    end
  end

  def fputdw(w)
    4.times do
      b=w&0xFF
      write(b.chr)
      w>>=8
    end
  end
end



class File < IO
=begin
  unless defined?(debugopen)
    class << self
      alias debugopen open
    end
  end

  def open(f,m="r")
    debugopen("debug.txt","ab"){|file| file.write([f,m,Time.now.to_f].inspect+"\r\n") }
    if block_given?
      debugopen(f,m) {|file| yield file }
    else
      return debugopen(f,m)
    end
  end
=end
  include FileInputMixin
  include FileOutputMixin
end



class StringInput
  include FileInputMixin

  def pos=(value)
    seek(value)
  end

  def each_byte
    while !eof?
      yield getc
    end
  end

  def binmode
  end
end



class StringOutput
  include FileOutputMixin
end


#pk code
module AzureDataCache
  def self.file_key(path)
    return path.to_s.gsub("\\","/").downcase
  end

  def self.file_signature(path)
    return [File.mtime(path).to_f,File.size(path)]
  rescue
    return nil
  end

  def self.load(path)
    @entries={} if !@entries
    key=file_key(path)
    entry=@entries[key]
    if entry && (!defined?($DEBUG) || !$DEBUG)
      return entry[1]
    end
    signature=file_signature(path)
    if entry && entry[0]==signature
      record_stat(key,:hits)
      return entry[1]
    end
    record_stat(key,:loads)
    record_stat(key,:reloads) if entry
    data=load_data(path)
    @entries[key]=[signature,data]
    return data
  end

  def self.fetch(path)
    @entries={} if !@entries
    key=file_key(path)
    entry=@entries[key]
    if entry && (!defined?($DEBUG) || !$DEBUG)
      return entry[1]
    end
    signature=file_signature(path)
    if entry && entry[0]==signature
      record_stat(key,:hits)
      return entry[1]
    end
    record_stat(key,:loads)
    record_stat(key,:reloads) if entry
    data=yield(path)
    @entries[key]=[signature,data]
    return data
  end

  def self.clear(path=nil)
    @entries={} if !@entries || !path
    @entries.delete(file_key(path)) if path && @entries
  end

  def self.record_stat(key,kind)
    return if !defined?($DEBUG) || !$DEBUG
    @stats={} if !@stats
    @stats[key]={:hits=>0,:loads=>0,:reloads=>0} if !@stats[key]
    @stats[key][kind]+=1
  end

  def self.stats
    ret=[]
    return ret if !@stats
    for key in @stats.keys.sort
      row=@stats[key]
      ret.push([key,row[:hits],row[:loads],row[:reloads]])
    end
    return ret
  end

  def self.reset_stats
    @stats={}
  end
end

def pbCachedData(path)
  return AzureDataCache.load(path)
end

def pbLoadTownMapData
  return pbCachedData("Data/townmap.dat")
end

def pbLoadConnectionData
  return pbCachedData("Data/connections.dat")
end

def pbLoadPhoneDataFile
  return pbCachedData("Data/phone.dat")
end

def pbCachedRxData(path)
  extension=$RPGVX ? ".rvdata" : ".rxdata"
  return pbCachedData(path+extension)
end

def pbLoadAzureRuntimeData
  $data_common_events=pbLoadRxData("Data/CommonEvents") if !$data_common_events
  $pkmn_dex=pbCachedData("Data/dexdata.dat") if !$pkmn_dex
  $pkmn_move=pbCachedData("Data/moves.dat") if !$pkmn_move
  $pkmn_egg=pbCachedData("Data/eggEmerald.dat") if !$pkmn_egg
  $ItemData=pbCachedData("Data/pokmanitems.rxdata") if !$ItemData
  $bosscache=pbCachedData("Data/bossdata.dat") if !$bosscache
  return true
end

def pbLoadTilesetData
  $data_tilesets=pbLoadRxData("Data/Tilesets") if !$data_tilesets
  return $data_tilesets
end

def pbReloadTilesetData
  $data_tilesets=pbLoadRxData("Data/Tilesets")
  return $data_tilesets
end

def pbLoadRPGAnimations
  $data_animations=pbLoadRxData("Data/Animations") if !$data_animations
  return $data_animations
end
