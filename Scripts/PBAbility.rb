# Typed, read-only ability view inspired by Rejuvenation's AbilityData. Azure's
# PBAbilities numeric constants and localized MessageTypes remain authoritative,
# so events, Pokemon objects, battles, translations, and saves are unchanged.
class PBAbilityData
  attr_reader :id

  def initialize(abilityid)
    @id=abilityid
  end

  # Keep text dynamic so changing the active language immediately affects
  # already cached wrappers.
  def ability; return @id; end
  def name; return pbGetMessage(MessageTypes::Abilities,@id); end
  def desc; return pbGetMessage(MessageTypes::AbilityDescs,@id); end
  def description; return desc; end
  def fullName; return name; end
  def fullDesc; return desc; end

  class << self
    alias azure_uncached_new new

    def normalize_id(value)
      return value.to_i if value.is_a?(Numeric) && value.to_i==value
      begin
        return nil if !value.is_a?(Symbol) && !value.is_a?(String)
        key=value.to_sym
        return nil if !PBAbilities.const_defined?(key)
        id=PBAbilities.const_get(key)
        return id.to_i if id.is_a?(Numeric) && id.to_i==id
      rescue
      end
      return nil
    end

    def max_value
      return PBAbilities.maxValue if PBAbilities.respond_to?(:maxValue)
      return pbGetMessageCount(MessageTypes::Abilities)-1
    end

    def valid_id?(id)
      return false if !id.is_a?(Numeric) || id.to_i!=id
      id=id.to_i
      return false if id<=0 || id>max_value
      value=pbGetMessage(MessageTypes::Abilities,id)
      return value && value!=""
    end

    def new(abilityid)
      id=normalize_id(abilityid)
      return azure_uncached_new(abilityid) if id.nil?
      @azure_cache=[] if !@azure_cache
      return @azure_cache[id] if @azure_cache[id]
      @azure_cache[id]=azure_uncached_new(id)
      return @azure_cache[id]
    end

    def get(ability)
      id=normalize_id(ability)
      raise ArgumentError.new("Unknown ability #{ability.inspect}") if id.nil? || !valid_id?(id)
      return new(id)
    end

    def try_get(ability)
      id=normalize_id(ability)
      return nil if id.nil? || !valid_id?(id)
      return new(id)
    end

    def exists?(ability)
      return !try_get(ability).nil?
    end

    def each
      return enum_for(:each) if !block_given?
      for id in 1..max_value
        yield new(id) if valid_id?(id)
      end
    end

    def clear_cache
      @azure_cache=[]
    end
  end
end
