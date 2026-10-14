# Lightweight runtime cache for immutable compiled data.
#
# Rejuvenation keeps its compiled registries in a Cache_Game object. Azure's
# data formats and public APIs remain unchanged here; callers opt in through
# pbCachedData for read-only access. The file signature invalidates entries
# automatically after a compiler/editor writes a new .dat file.
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
    # Packaged/release data is immutable for the lifetime of the process. Avoid
    # File.mtime/File.size system calls on every hot cached lookup there. Debug
    # builds retain signature checks so compiler/editor writes reload at once.
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

  # Signature-aware cache for immutable non-Marshal formats. The caller owns
  # parsing, while this module retains the same release/debug invalidation and
  # statistics behavior as load_data-backed entries.
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

# A transfer used to deserialize its destination once for audio fade decisions
# and again immediately in Game_Map#setup. Keep that exact object only until
# setup consumes it; this is a one-shot ownership handoff, not a map cache.
module AzureMapTransferHandoff
  def self.preload(map_id)
    clear
    @map_id=map_id
    @map=pbLoadRxData(sprintf("Data/Map%03d",map_id))
    return @map
  end

  def self.take(map_id)
    if @map && @map_id==map_id
      map=@map
      clear
      return map
    end
    clear
    return pbLoadRxData(sprintf("Data/Map%03d",map_id))
  end

  def self.clear
    @map_id=nil
    @map=nil
  end
end

# Parses Azure's fixed-width evolution file once while retaining its on-disk
# layout for the compiler, editors, and packaged-data compatibility.
module AzureEvolutionDataCache
  EVOTYPEMASK=0x3F
  EVODATAMASK=0xC0
  EVONEXTFORM=0x00
  EVOPREVFORM=0x40

  def self.data
    return AzureDataCache.fetch("Data/evolutions.dat") {|path| parse(path) }
  end

  def self.parse(path)
    records=[]
    pbRgssOpen(path,"rb") {|file|
      for species in 1..PBSpecies.maxValue
        file.pos=(species-1)*8
        offset=file.fgetdw
        length=file.fgetdw
        entries=[]
        if length>0
          file.pos=offset
          consumed=0
          while consumed<length
            evo=file.fgetb
            entries.push([evo&EVOTYPEMASK,file.fgetw,file.fgetw,evo&EVODATAMASK].freeze)
            consumed+=5
          end
        end
        records[species]=entries.freeze
      end
    }
    return records.freeze
  end

  def self.records(species)
    return [].freeze if !species || species<=0
    return data[species] || [].freeze
  end

  def self.forward(species)
    ret=[]
    for record in records(species)
      ret.push([record[0],record[1],record[2]].freeze) if record[3]==EVONEXTFORM
    end
    return ret.freeze
  end

  def self.previous_record(species)
    for record in records(species)
      return record if record[3]==EVOPREVFORM
    end
    return nil
  end

  def self.clear; AzureDataCache.clear("Data/evolutions.dat"); end
end

# Cached read-only representation of regionals.dat. Forward and reverse maps
# preserve the binary scan's original first-national-species-wins behavior.
module AzureRegionalDexCache
  def self.data
    return AzureDataCache.fetch("Data/regionals.dat") {|path| parse(path) }
  end

  def self.parse(path)
    result={:num_regions=>0,:num_species=>0,:regional=>[],:national=>[]}
    pbRgssOpen(path,"rb") {|file|
      result[:num_regions]=file.fgetw
      result[:num_species]=file.fgetw
      for region in 0...result[:num_regions]
        forward=[]
        reverse=[0]
        for species in 0...result[:num_species]
          number=file.fgetw
          forward[species]=number
          reverse[number]=species if number!=0 && reverse[number].nil?
        end
        for index in 0...reverse.length
          reverse[index]=0 if reverse[index].nil?
        end
        result[:regional][region]=forward.freeze
        result[:national][region]=reverse.freeze
      end
    }
    result[:regional].freeze
    result[:national].freeze
    return result.freeze
  end

  def self.num_regions; return data[:num_regions]; end
  def self.regional_number(region,national_species)
    table=data[:regional][region] if region && region>=0
    return table ? (table[national_species] || 0) : 0
  end
  def self.national_number(region,regional_species)
    table=data[:national][region] if region && region>=0
    return table ? (table[regional_species] || 0) : 0
  end
  def self.all_species(region)
    table=data[:national][region] if region && region>=0
    return table || [0].freeze
  end
  def self.clear; AzureDataCache.clear("Data/regionals.dat"); end
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

# Load the gameplay databases only after the player chooses an action that
# needs the runtime. RPG Maker's CommonEvents collection stays under its
# mutable engine global; the compiled Pokemon tables are read-only at runtime
# and share AzureDataCache entries with their typed registry adapters.
def pbLoadAzureRuntimeData
  $data_common_events=pbLoadRxData("Data/CommonEvents") if !$data_common_events
  $pkmn_dex=pbCachedData("Data/dexdata.dat") if !$pkmn_dex
  $pkmn_move=pbCachedData("Data/moves.dat") if !$pkmn_move
  $pkmn_egg=pbCachedData("Data/eggEmerald.dat") if !$pkmn_egg
  $ItemData=pbCachedData("Data/pokmanitems.rxdata") if !$ItemData
  $bosscache=pbCachedData("Data/bossdata.dat") if !$bosscache
  return true
end

# Tilesets are intentionally kept outside AzureDataCache. The tileset editor
# replaces this mutable collection at runtime, so retain the legacy global as
# the single source of truth while deferring its initial load until a map needs
# it.
def pbLoadTilesetData
  $data_tilesets=pbLoadRxData("Data/Tilesets") if !$data_tilesets
  return $data_tilesets
end

def pbReloadTilesetData
  $data_tilesets=pbLoadRxData("Data/Tilesets")
  return $data_tilesets
end

# RPG Maker animations are distinct from PkmnAnimations and are only required
# when a map/event visual effect is actually requested.
def pbLoadRPGAnimations
  $data_animations=pbLoadRxData("Data/Animations") if !$data_animations
  return $data_animations
end
