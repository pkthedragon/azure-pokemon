class PBMoveData
  attr_reader :function,:basedamage,:type,:accuracy
  attr_reader :totalpp,:addlEffect,:target,:priority
  attr_reader :flags
  attr_reader :contestType,:category

  def initialize(moveid)
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
    tpp=$pkmn_move[@id][5]
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