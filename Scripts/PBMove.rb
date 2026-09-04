class PBMoveData
  attr_reader :id
  attr_reader :function,:basedamage,:type,:accuracy
  attr_reader :totalpp,:addlEffect,:target,:priority
  attr_reader :flags
  attr_reader :contestType,:category

  def initialize(moveid)
    @id          = moveid
    @function    = $pkmn_move[moveid][0]
    @basedamage  = $pkmn_move[moveid][1]
    @type        = $pkmn_move[moveid][2]
    @category    = $pkmn_move[moveid][3]
    @accuracy    = $pkmn_move[moveid][4]
    @totalpp     = $pkmn_move[moveid][5]
    @addlEffect  = $pkmn_move[moveid][6]
    @target      = $pkmn_move[moveid][7]
    @priority    = $pkmn_move[moveid][8]
    @flags       = $pkmn_move[moveid][9]
  end
  def isSoundBased?
    return (@flags&0x400)!=0 # Sound Flag ("k") needed checkable for substitute
  end

  class << self
    alias azure_uncached_new new

    # Accept the numeric IDs used by saves/events and the symbolic identifiers
    # used by sectioned PBS files. Numeric behavior remains the default.
    def normalize_id(value)
      return value if value.is_a?(Numeric)
      begin
        return nil if !value.is_a?(Symbol) && !value.is_a?(String)
        key=value.to_sym
        return nil if !PBMoves.const_defined?(key)
        return PBMoves.const_get(key)
      rescue
        return nil
      end
    end

    # PBMoveData is immutable through its public API. Reuse one typed view per
    # compiled move row instead of allocating it repeatedly in battle and AI
    # loops. A replaced row or reloaded moves.dat invalidates itself safely.
    def new(moveid)
      id=normalize_id(moveid)
      return azure_uncached_new(moveid) if id.nil?
      source=$pkmn_move
      source_id=source ? source.object_id : nil
      if @azure_source_id!=source_id
        @azure_source_id=source_id
        @azure_cache=[]
      end
      row=source ? source[id] : nil
      cached=@azure_cache[id] if @azure_cache && id>=0
      if cached && cached.instance_variable_get(:@azure_source_row).equal?(row)
        return cached
      end
      data=azure_uncached_new(id)
      data.instance_variable_set(:@azure_source_row,row)
      @azure_cache[id]=data if id>=0
      return data
    end

    def get(move)
      id=normalize_id(move)
      raise ArgumentError.new("Unknown move #{move.inspect}") if id.nil? ||
        !$pkmn_move || !$pkmn_move[id]
      return new(id)
    end

    def try_get(move)
      id=normalize_id(move)
      return nil if id.nil? || !$pkmn_move || !$pkmn_move[id]
      return new(id)
    end

    def exists?(move)
      return !try_get(move).nil?
    end

    def each
      return enum_for(:each) if !block_given?
      return if !$pkmn_move
      for id in 0...$pkmn_move.length
        yield new(id) if $pkmn_move[id]
      end
    end

    def clear_cache
      @azure_source_id=nil
      @azure_cache=[]
    end
  end
end

class PBMove
  attr_reader(:id)       # Gets this move's ID.
  attr_accessor(:pp)     # Gets the number of PP remaining for this move.
  attr_accessor(:ppup)   # Gets the number of PP Ups used for this move.
  attr_accessor(:totalpp)# Gets the total number of PP this move can have.

# Gets this move's type.
  def type
    return $pkmn_move[@id][2]
  end

# Gets the maximum PP for this move.
  def totalpp
    return @totalpp if defined?(@totalpp)
    return 0 if @id==0 || !$pkmn_move[@id]
    tpp=$pkmn_move[@id][5]
    return 0 if !tpp
    return tpp+(tpp*@ppup/5).floor
  end

# Gets basedamage for this move
  def basedamage
    return $pkmn_move[@id][1]
  end
  
# Initializes this object to the specified move ID.
  def initialize(moveid)
    @id=moveid
    @ppup=0
    @pp=totalpp
  end
end
