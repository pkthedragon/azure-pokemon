#===============================================================================
# ** Game_Switches
#-------------------------------------------------------------------------------
#  This class handles switches. It's a wrapper for the built-in class "Array."
#  Refer to "$game_switches" for the instance of this class.
#===============================================================================

class Game_Switches
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------------------
  def initialize
    @data = []
  end
  #-----------------------------------------------------------------------------
  # * Get Switch
  #     switch_id : switch ID
  #-----------------------------------------------------------------------------
  def [](switch_id)
    switch_id = Switches[switch_id] if switch_id.is_a?(Symbol)
    return false if switch_id.nil?
    if switch_id <= 5000 && @data[switch_id] != nil
      return @data[switch_id]
    else
      return false
    end
  end
  #-----------------------------------------------------------------------------
  # * Set Switch
  #     switch_id : switch ID
  #     value     : ON (true) / OFF (false)
  #-----------------------------------------------------------------------------
  def []=(switch_id, value)
    switch_id = Switches[switch_id] if switch_id.is_a?(Symbol)
    return if switch_id.nil?
    if switch_id <= 5000
      @data[switch_id] = value
    end
  end
end

#===============================================================================
# * Hashes for Variable names, in ascending order
#===============================================================================

Switches = {
    No_Catch:       290,
    Boss_Battle:    1998
}