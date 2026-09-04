# Typed, read-only view of Azure's existing compiled species arrays. Numeric
# PBSpecies IDs, $pkmn_dex, form handlers, Pokemon objects, events, and save
# serialization remain the legacy storage/API boundary.
class PBSpeciesData
  attr_reader :id,:color,:habitat,:type1,:type2,:base_stats,:catch_rate
  attr_reader :gender_rate,:happiness,:growth_rate,:hatch_steps,:evs
  attr_reader :abilities,:hidden_ability,:egg_groups,:height,:weight,:base_exp
  attr_reader :wild_items

  def initialize(speciesid)
    @id=speciesid
    row=PBSpeciesData.data[speciesid]
    @color=row[1]
    @habitat=row[2]
    @type1=row[3]
    @type2=row[4]
    @base_stats=(row[5] || []).clone.freeze
    @catch_rate=row[6]
    @gender_rate=row[7]
    @happiness=row[8]
    @growth_rate=row[9]
    @hatch_steps=row[10]
    @evs=(row[11] || []).clone.freeze
    @abilities=(row[12] || []).clone.freeze
    @egg_groups=(row[13] || []).clone.freeze
    @height=row[14]
    @weight=row[15]
    @base_exp=row[16]
    @hidden_ability=row[17] || 0
    @wild_items=[row[18] || 0,row[19] || 0,row[20] || 0].freeze
    @azure_source_row=row
  end

  # Rejuvenation-compatible field names over Azure's numeric values.
  def species; return @id; end
  def name; return PBSpecies.getName(@id); end
  def kind; return pbGetMessage(MessageTypes::Kinds,@id); end
  def dexentry; return pbGetMessage(MessageTypes::Entries,@id); end
  def form_names; return pbGetMessage(MessageTypes::FormNames,@id); end
  def hidden_abilities; return @hidden_ability>0 ? [@hidden_ability].freeze : [].freeze; end

  def moveset
    if !defined?(@moveset)
      source=PBSpeciesData.move_data[@id] || []
      @moveset=source.map {|entry| entry.clone.freeze }.freeze
    end
    return @moveset
  end

  def egg_moves
    if !defined?(@egg_moves)
      source=PBSpeciesData.egg_data[@id] || []
      @egg_moves=source.clone.freeze
    end
    return @egg_moves
  end

  def evolutions
    return AzureEvolutionDataCache.forward(@id)
  end

  def previous_species
    record=AzureEvolutionDataCache.previous_record(@id)
    return record ? record[2] : @id
  end

  def regional_number(region)
    return AzureRegionalDexCache.regional_number(region,@id)
  end

  def metrics
    if !defined?(@metrics)
      source=pbCachedData("Data/metrics.dat")
      @metrics=[source[0][@id] || 0,source[1][@id] || 0,source[2][@id] || 0].freeze
    end
    return @metrics
  end

  def battler_player_y; return metrics[0]; end
  def battler_enemy_y; return metrics[1]; end
  def battler_altitude; return metrics[2]; end

  def Type1; return @type1; end
  def Type2; return @type2; end
  def BaseStats; return @base_stats; end
  def EVs; return @evs; end
  def Abilities; return @abilities; end
  def HiddenAbility; return @hidden_ability; end
  def GrowthRate; return @growth_rate; end
  def GenderRatio; return @gender_rate; end
  def BaseEXP; return @base_exp; end
  def CatchRate; return @catch_rate; end
  def Happiness; return @happiness; end
  def EggSteps; return @hatch_steps; end
  def EggMoves; return egg_moves; end
  def Moveset; return moveset; end
  def Evolutions; return evolutions; end
  def Preevo; return previous_species; end
  def Color; return @color; end
  def EggGroups; return @egg_groups; end
  def Height; return @height; end
  def Weight; return @weight; end

  class << self
    alias azure_uncached_new new

    def data
      $pkmn_dex=pbCachedData("Data/dexdata.dat") if !defined?($pkmn_dex) || !$pkmn_dex
      return $pkmn_dex
    end

    def move_data
      $pkmn_moves=pbCachedData("Data/attacksRS.rxdata") if !defined?($pkmn_moves) || !$pkmn_moves
      return $pkmn_moves
    end

    def egg_data
      $pkmn_egg=pbCachedData("Data/eggEmerald.dat") if !defined?($pkmn_egg) || !$pkmn_egg
      return $pkmn_egg
    end

    def normalize_id(value)
      return value.to_i if value.is_a?(Numeric) && value.to_i==value
      begin
        return nil if !value.is_a?(Symbol) && !value.is_a?(String)
        key=value.to_sym
        return nil if !PBSpecies.const_defined?(key)
        id=PBSpecies.const_get(key)
        return id.to_i if id.is_a?(Numeric) && id.to_i==id
      rescue
      end
      return nil
    end

    def new(speciesid)
      id=normalize_id(speciesid)
      return azure_uncached_new(speciesid) if id.nil?
      source=data
      return wrapper_for(id,source)
    end

    def wrapper_for(id,source)
      if @azure_source_id!=source.object_id
        @azure_source_id=source.object_id
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

    def get(species)
      id=normalize_id(species)
      source=data
      raise ArgumentError.new("Unknown species #{species.inspect}") if id.nil? || !source[id]
      return wrapper_for(id,source)
    end

    def try_get(species)
      id=normalize_id(species)
      return nil if id.nil?
      source=data
      return nil if !source[id]
      return wrapper_for(id,source)
    end

    def exists?(species)
      return !try_get(species).nil?
    end

    def each
      return enum_for(:each) if !block_given?
      source=data
      for id in 1...source.length
        yield wrapper_for(id,source) if source[id]
      end
    end

    def clear_cache
      @azure_source_id=nil
      @azure_cache=[]
    end
  end
end
