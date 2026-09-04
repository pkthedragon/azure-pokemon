class PBTypes
  @@TypeData=nil # internal

  def PBTypes.loadTypeData # internal
    if !@@TypeData
      @@TypeData=load_data("Data/types.dat")
      @@TypeData[0].freeze
      @@TypeData[1].freeze
      @@TypeData[2].freeze
      @@TypeData.freeze
    end
    return @@TypeData
  end

  def PBTypes.isPseudoType?(type)
    return PBTypes.loadTypeData()[0].include?(type)
  end

  def PBTypes.isSpecialType?(type)
    return PBTypes.loadTypeData()[1].include?(type)
  end

  def PBTypes.getEffectiveness(attackType,opponentType)
    return PBTypes.loadTypeData()[2][attackType*(PBTypes.maxValue+1)+opponentType]
  end

  def PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2=nil)
    if opponentType2==nil
      return PBTypes.getEffectiveness(attackType,opponentType1)*2
    else
      mod1=PBTypes.getEffectiveness(attackType,opponentType1)
      mod2=(opponentType1==opponentType2) ? 2 : PBTypes.getEffectiveness(attackType,opponentType2)
      return (mod1*mod2)
    end
  end

  def PBTypes.isNotVeryEffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e>0 && e<4
  end

  def PBTypes.isNormalEffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e==4
  end

  def PBTypes.isIneffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e==0
  end

  def PBTypes.isSuperEffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e>4
  end
end

# Typed, immutable view over Azure's existing types.dat layout. The legacy
# PBTypes IDs and flattened effectiveness chart stay authoritative for battle
# code, while new tools can use symbolic registry lookups and named fields.
class PBTypeData
  attr_reader :id,:weak,:resist,:immune,:specialtype

  def initialize(typeid)
    @id=typeid
    source=PBTypes.loadTypeData
    chart=source[2]
    count=PBTypes.maxValue+1
    @weak=[]
    @resist=[]
    @immune=[]
    for attack_type in 0...count
      effectiveness=chart[attack_type*count+@id]
      @weak.push(attack_type) if effectiveness==4
      @resist.push(attack_type) if effectiveness==1
      @immune.push(attack_type) if effectiveness==0
    end
    @weak.freeze
    @resist.freeze
    @immune.freeze
    @specialtype=source[1].include?(@id)
    @pseudotype=source[0].include?(@id)
    @azure_source=source
  end

  def type; return @id; end
  def name; return PBTypes.getName(@id); end
  def pseudo?; return @pseudotype; end

  def weak?(type)
    id=PBTypeData.normalize_id(type)
    return !id.nil? && @weak.include?(id)
  end

  def resists?(type)
    id=PBTypeData.normalize_id(type)
    return !id.nil? && @resist.include?(id)
  end

  def immune?(type)
    id=PBTypeData.normalize_id(type)
    return !id.nil? && @immune.include?(id)
  end

  def specialtype?(type=nil); return @specialtype; end

  class << self
    alias azure_uncached_new new

    def normalize_id(value)
      return value.to_i if value.is_a?(Numeric) && value.to_i==value
      begin
        return nil if !value.is_a?(Symbol) && !value.is_a?(String)
        key=value.to_sym
        return nil if !PBTypes.const_defined?(key)
        id=PBTypes.const_get(key)
        return id.to_i if id.is_a?(Numeric) && id.to_i==id
      rescue
      end
      return nil
    end

    def valid_id?(id)
      return false if !id.is_a?(Numeric) || id.to_i!=id
      id=id.to_i
      return false if id<0 || id>PBTypes.maxValue
      value=PBTypes.getName(id)
      return value && value!=""
    end

    def new(typeid)
      id=normalize_id(typeid)
      return azure_uncached_new(typeid) if id.nil?
      source=PBTypes.loadTypeData
      return wrapper_for(id,source)
    end

    def wrapper_for(id,source)
      if @azure_source_id!=source.object_id
        @azure_source_id=source.object_id
        @azure_cache=[]
      end
      cached=@azure_cache[id] if @azure_cache && id>=0
      if cached && cached.instance_variable_get(:@azure_source).equal?(source)
        return cached
      end
      wrapper=azure_uncached_new(id)
      @azure_cache[id]=wrapper if id>=0
      return wrapper
    end

    def get(type)
      id=normalize_id(type)
      raise ArgumentError.new("Unknown type #{type.inspect}") if id.nil? || !valid_id?(id)
      source=PBTypes.loadTypeData
      return wrapper_for(id,source)
    end

    def try_get(type)
      id=normalize_id(type)
      return nil if id.nil? || !valid_id?(id)
      source=PBTypes.loadTypeData
      return wrapper_for(id,source)
    end

    def exists?(type)
      return !try_get(type).nil?
    end

    def each
      return enum_for(:each) if !block_given?
      source=PBTypes.loadTypeData
      for id in 0..PBTypes.maxValue
        yield wrapper_for(id,source) if valid_id?(id)
      end
    end

    def clear_cache
      @azure_source_id=nil
      @azure_cache=[]
    end
  end
end
