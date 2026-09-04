# Typed, read-only view of Azure's existing trainer-type rows. The compiled
# array, PBTrainers numeric constants, events, trainer objects, and saves remain
# the storage/API boundary for legacy code.
class PBTrainerTypeData
  attr_reader :id,:internal_name,:raw_name,:base_money
  attr_reader :battle_bgm,:victory_bgm,:intro_bgm,:gender,:skill_level

  def initialize(trainertype)
    @id=trainertype
    row=PBTrainerTypeData.data[trainertype]
    @internal_name=row[1]
    @raw_name=row[2]
    @base_money=row[3]
    @battle_bgm=row[4]
    @victory_bgm=row[5]
    @intro_bgm=row[6]
    @gender=row[7]
    @skill_level=row[8]
    @azure_source_row=row
  end

  def name; return PBTrainers.getName(@id); end
  def money; return @base_money; end
  def skill; return @skill_level; end

  class << self
    alias azure_uncached_new new

    def data
      return pbCachedData("Data/trainertypes.dat")
    end

    def normalize_id(value)
      return value if value.is_a?(Numeric)
      begin
        return nil if !value.is_a?(Symbol) && !value.is_a?(String)
        key=value.to_sym
        return nil if !PBTrainers.const_defined?(key)
        return PBTrainers.const_get(key)
      rescue
        return nil
      end
    end

    def new(trainertype)
      id=normalize_id(trainertype)
      return azure_uncached_new(trainertype) if id.nil?
      source=data
      return wrapper_for(id,source)
    end

    def wrapper_for(id,source)
      source_id=source.object_id
      if @azure_source_id!=source_id
        @azure_source_id=source_id
        @azure_cache=[]
      end
      row=source[id]
      cached=@azure_cache[id] if @azure_cache && id>=0
      if cached && cached.instance_variable_get(:@azure_source_row).equal?(row)
        return cached
      end
      wrapper=azure_uncached_new(id)
      @azure_cache[id]=wrapper if id>=0
      return wrapper
    end

    def get(trainertype)
      id=normalize_id(trainertype)
      source=data
      raise ArgumentError.new("Unknown trainer type #{trainertype.inspect}") if id.nil? || !source[id]
      return wrapper_for(id,source)
    end

    def try_get(trainertype)
      id=normalize_id(trainertype)
      return nil if id.nil?
      source=data
      return nil if !source[id]
      return wrapper_for(id,source)
    end

    def exists?(trainertype)
      return !try_get(trainertype).nil?
    end

    def each
      return enum_for(:each) if !block_given?
      source=data
      for id in 0...source.length
        yield wrapper_for(id,source) if source[id]
      end
    end

    def clear_cache
      @azure_source_id=nil
      @azure_cache=[]
    end
  end
end

class PokeBattle_Trainer
  attr_accessor(:name)
  attr_accessor(:id)
  attr_accessor(:metaID)
  attr_accessor(:trainertype)
  attr_accessor(:outfit)
  attr_accessor(:badges)
  attr_accessor(:money)
  attr_accessor(:seen)
  attr_accessor(:owned)
  attr_accessor(:formseen)
  attr_accessor(:formlastseen)
  attr_accessor(:shadowcaught)
  attr_accessor(:party)
  attr_accessor(:pokedex)    # Whether the Pokédex was obtained
  attr_accessor(:pokegear)   # Whether the Pokégear was obtained
  attr_accessor(:language)
  attr_accessor(:lastSave)
  attr_accessor(:saveNumber)
  attr_accessor(:noOnlineBattle)
  attr_accessor(:storedOnlineParty)  
  attr_accessor(:onlineMusic) 
  attr_accessor(:trainercardbackup)
  attr_accessor(:initialquestion)
  attr_accessor(:tutorlist)


  def trainerTypeName   # Name of this trainer type (localized)
    return PBTrainers.getName(@trainertype) rescue _INTL("PkMn Trainer")
  end

  def fullname
    return _INTL("{1} {2}",self.trainerTypeName,@name)
  end

  def publicID(id=nil)   # Portion of the ID which is visible on the Trainer Card
    return id ? id&0xFFFF : @id&0xFFFF
  end

  def secretID(id=nil)   # Other portion of the ID
    return id ? id>>16 : @id>>16
  end

  def getForeignID   # Random ID other than this Trainer's ID
    fid=0
    loop do
      fid=rand(256)
      fid|=rand(256)<<8
      fid|=rand(256)<<16
      fid|=rand(256)<<24
      break if fid!=@id
    end
    return fid 
  end

  def setForeignID(other)
    @id=other.getForeignID
  end

  def metaID
    @metaID=$PokemonGlobal.trainerID if !@metaID && $PokemonGlobal
    @metaID=0 if !@metaID
    return @metaID
  end

  def outfit
    @outfit=0 if !@outfit
    return @outfit
  end

  def language
    @language=pbGetLanguage() if !@language
    return @language
  end

  def money=(value)
    @money=[[value,MAXMONEY].min,0].max
  end

  def moneyEarned   # Money won when trainer is defeated
    data=PBTrainerTypeData.try_get(@trainertype)
    return data ? data.base_money : 30
  end

  def skill   # Skill level (for AI)
    data=PBTrainerTypeData.try_get(@trainertype)
    return data ? data.skill_level : 30
  end

  def numbadges   # Number of badges
    ret=0
    for i in 0...@badges.length
      ret+=1 if @badges[i]
    end
    return ret
  end

  def gender
    data=PBTrainerTypeData.try_get(trainertype)
    return (data && data.gender) ? data.gender : 2
  end

  def isMale?; return self.gender==0; end
  def isFemale?; return self.gender==1; end

  def pokemonParty
    return @party.find_all {|item| item && !item.isEgg? }
  end

  def ablePokemonParty
    return @party.find_all {|item| item && !item.isEgg? && item.hp>0 }
  end

  def partyCount
    return @party.length
  end

  def pokemonCount
    ret=0
    for i in 0...@party.length
      ret+=1 if @party[i] && !@party[i].isEgg?
    end
    return ret
  end

  def ablePokemonCount
    ret=0
    for i in 0...@party.length
      ret+=1 if @party[i] && !@party[i].isEgg? && @party[i].hp>0
    end
    return ret
  end

  def lastParty
    return nil if @party.length==0
    return @party[@party.length-1]
  end

  def lastPokemon
    i=self.pokemonParty
    return nil if i.length==0
    return i[i.length-1]
  end

  def lastAblePokemon
    i=self.ablePokemonParty
    return nil if i.length==0
    return i[i.length-1]
  end

  def pokedexSeen(region=-1)   # Number of Pokémon seen
    ret=0
    if region==-1
      for i in 1..PBSpecies.maxValue
        ret+=1 if @seen[i]
      end
    else
      regionlist=pbAllRegionalSpecies(region)
      for i in regionlist
        next if !i || i==0  # Skip empty entries
        ret+=1 if @seen[i]
      end
    end
    return ret
  end

  def pokedexOwned(region=-1)   # Number of Pokémon owned
    ret=0
    if region==-1
      for i in 1..PBSpecies.maxValue
        ret+=1 if @owned[i]
      end
    else
      regionlist=pbAllRegionalSpecies(region)
      for i in regionlist
        next if !i || i==0  # Skip empty entries
        ret+=1 if @owned[i]
      end
    end
    return ret
  end

  def numFormsSeen(species)
    ret=0
    array=@formseen[species]
    for i in 0...[array[0].length,array[1].length].max
      ret+=1 if array[0][i] || array[1][i]
    end
    return ret
  end

  def hasSeen?(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    return species>0 ? @seen[species] : false
  end

  def hasOwned?(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    return species>0 ? @owned[species] : false
  end

  def setSeen(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    @seen[species]=true if species>0
  end

  def setOwned(species)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    @owned[species]=true if species>0
  end

  def clearPokedex
    @seen=[]
    @owned=[]
    @formseen=[]
    @formlastseen=[]
    for i in 1..PBSpecies.maxValue
      @seen[i]=false
      @owned[i]=false
      @formlastseen[i]=[]
      @formseen[i]=[[],[]]
    end
  end

  def initialize(name,trainertype)
    @name=name
    @language=pbGetLanguage()
    @trainertype=trainertype
    @id=rand(256)
    @id|=rand(256)<<8
    @id|=rand(256)<<16
    @id|=rand(256)<<24
    @metaID=0
    @outfit=0
    @pokegear=false
    @pokedex=false
    clearPokedex
    @shadowcaught=[]
    for i in 1..PBSpecies.maxValue
      @shadowcaught[i]=false
    end
    @badges=[]
    for i in 0...8
      @badges[i]=false
    end
    @money=INITIALMONEY
    @party=[]
    @lastSave=""
    @tutorlist=[]
    @saveNumber = 0
    @noOnlineBattle = false
    @storedOnlineParty=[]   
    @onlineMusic="Battle- Trainer.mp3"
  end
end
