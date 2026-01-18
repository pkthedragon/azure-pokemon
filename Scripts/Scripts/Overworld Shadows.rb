#==============================================================================#
#                             Overworld Shadows                                #
#                                  by Marin                                    #
#==============================================================================#
#                                    Info                                      #
#                                                                              #
#   You'll have likely heard of KleinStudios' Overworld Shadows script; many   #
#    fangames use it, after all. It was not compatible with Essentials v17+    #
#    though, so after getting the suggestion I thought it would be cool if I   #
#   could make something of my own that would work with v16, as well as v17.   #
#==============================================================================#
#                                  Features:                                   #
#                - Blacklisting events from receiving shadows                  #
#                - Whitelisting events to always receive shadows               #
#                - A scaling animation when an event jumps                     #
#==============================================================================#
#                                    Usage                                     #
#                                                                              #
#     Shadow_Path is the path to the shadow graphic. You can change this       #
#   sprite, though you may need to fiddle with positioning of the sprite in    #
#  relation to the event after, though. That's done in "def position_shadow".  #
#                                                                              #
#  As the name literally says, if an event's name includes any of the strings  #
#  in "No_Shadow_If_Event_Name_Has", it won't get a shadow, UNLESS the event's #
#                 name also includes any of the strings in                     #
#   "Always_Give_Shadow_If_Event_Name_Has". This is essentially "overriding".  #
#                                                                              #
#    Case_Sensitive is either true or false. It's used when determing if an    #
# event's name includes a string in the "No_Shadow" and "Always_Give" arrays.  #
#      If true, it must match all strings with capitals exactly as well.       #
#                If false, capitals don't need to match up.                    #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#

module OverworldShadows
  SHADOW_PATH = "Graphics/Characters/shadow"

  # Whether or not the event names below need to match in capitals as well.
  CASE_SENSITIVE = false

  NO_SHADOW_IF_EVENT_NAME_HAS = [
    # I like to use "extensions" like these. Up to you though.
    "Shrine",
	"Hollow",
  ].freeze

  # Events that have this in their event name will always receive a shadow.
  # Does take "CASE_SENSITIVE" into account.
  ALWAYS_GIVE_SHADOW_IF_EVENT_NAME_HAS = [
    "Trainer"
  ].freeze

  def self.active_event_page(event)
    return nil unless event
    return event.instance_variable_get(:@page) if event.is_a?(Game_Event)
    return nil unless event.respond_to?(:pages)
    map_id = event.respond_to?(:map) ? event.map.map_id : $game_map.map_id
    event.pages.reverse_each do |page|
      c = page.condition
      ss = !(c.self_switch_valid && !$game_self_switches[[map_id, event.id, c.self_switch_ch]])
      sw1 = !(c.switch1_valid && !$game_switches[c.switch1_id])
      sw2 = !(c.switch2_valid && !$game_switches[c.switch2_id])
      var = true
      if c.variable_valid
        var = $game_variables[c.variable_id].is_a?(Numeric) &&
              $game_variables[c.variable_id] >= c.variable_value
      end
      return page if ss && sw1 && sw2 && var
    end
    nil
  end

  def self.event_comments(page)
    return [] unless page
    page.list.select { |e| e.code == 108 || e.code == 408 }.map { |e| e.parameters.join }
  end

  def self.match_name?(name, token)
    return name.include?(token) if CASE_SENSITIVE
    name.downcase.include?(token.downcase)
  end

  def self.match_comment?(comments, token)
    if CASE_SENSITIVE
      comments.any? { |comment| comment.include?(token) }
    else
      token_down = token.downcase
      comments.any? { |comment| comment.downcase.include?(token_down) }
    end
  end

  # Determines whether or not an event should be given a shadow.
  def self.should_get_shadow?(event)
    return true if event.is_a?(Game_Player) # The player will always have a shadow
    page = active_event_page(event)
    return false unless page
    comments = event_comments(page)
    name = event.respond_to?(:name) ? event.name.to_s : ""
    ALWAYS_GIVE_SHADOW_IF_EVENT_NAME_HAS.each do |token|
      return true if match_name?(name, token) || match_comment?(comments, token)
    end
    NO_SHADOW_IF_EVENT_NAME_HAS.each do |token|
      return false if match_name?(name, token) || match_comment?(comments, token)
    end
    true
  end
end

# Extending so we can access some private instance variables.
class Game_Character
  attr_reader :jump_count
end

class Sprite_Character
  attr_accessor :shadow

  unless method_defined?(:ow_shadow_init)
    alias ow_shadow_init initialize
  end
  def initialize(viewport, character = nil)
    @shadow_viewport = viewport
    ow_shadow_init(viewport, character)
    return unless OverworldShadows.should_get_shadow?(character)
    return if character.is_a?(Game_Event) && character.character_name.to_s.empty?
    make_shadow
  end

  def make_shadow
    dispose_shadow
    @shadow = Sprite.new(@shadow_viewport || self.viewport)
    @shadow.bitmap = BitmapCache.load_bitmap(OverworldShadows::SHADOW_PATH)
    # Center the shadow by halving the origin points
    @shadow.ox = @shadow.bitmap.width / 2.0
    @shadow.oy = @shadow.bitmap.height / 2.0
    @shadow.zoom_x = 1.0
    @shadow.zoom_y = 1.0
    # Positioning the shadow
    position_shadow
  end

  def dispose_shadow
    return unless @shadow
    @shadow.dispose
    @shadow = nil
  end

  def position_shadow
    return unless @shadow
    x = @character.screen_x
    y = @character.screen_y
    if @character.jumping?
      @total_jump = @character.jump_count if !@total_jump
      case @character.jump_count
      when 1..(@total_jump / 3)
        @shadow.zoom_x += 0.1
        @shadow.zoom_y += 0.1
      when (@total_jump / 3 + 1)..(@total_jump / 3 + 2)
        @shadow.zoom_x += 0.05
        @shadow.zoom_y += 0.05
      when (@total_jump / 3 * 2 - 1)..(@total_jump / 3 * 2)
        @shadow.zoom_x -= 0.05
        @shadow.zoom_y -= 0.05
      when (@total_jump / 3 * 2 + 1)..(@total_jump)
        @shadow.zoom_x -= 0.1
        @shadow.zoom_y -= 0.1
      end
      if @character.jump_count == 1
        @shadow.zoom_x = 1.0
        @shadow.zoom_y = 1.0
        @total_jump = nil
      end
    end
    @shadow.x = x
    @shadow.y = y - 6
    @shadow.z = self.z - 1
    if @shadow
      if !@charbitmap || @charbitmap.disposed? ||
         (@character.is_a?(Game_Event) && @character.instance_eval { @erased })
        dispose_shadow
      end
    end
  end

  unless method_defined?(:ow_shadow_visible)
    alias ow_shadow_visible visible=
  end
  def visible=(value)
    ow_shadow_visible(value)
    @shadow.visible = value if @shadow
  end

  unless method_defined?(:ow_shadow_dispose)
    alias ow_shadow_dispose dispose
  end
  def dispose
    ow_shadow_dispose
    dispose_shadow
  end

  unless method_defined?(:ow_shadow_update)
    alias ow_shadow_update update
  end
  def update
    ow_shadow_update
    position_shadow

    if @character.is_a?(Game_Event)
      page = OverworldShadows.active_event_page(@character)
      graphic_empty = @character.character_name.to_s.empty?

      # Dispose shadow if graphic becomes empty (e.g., during move command)
      if @shadow && graphic_empty
        dispose_shadow
      # Check for page changes
      elsif @old_page != page
        dispose_shadow
        if page && !graphic_empty &&
           OverworldShadows.should_get_shadow?(@character)
          make_shadow
        end
      # Recreate shadow if graphic was restored
      elsif !@shadow && !graphic_empty && page &&
            OverworldShadows.should_get_shadow?(@character)
        make_shadow
      end
      @old_page = page
    end

    bushdepth = @character.bush_depth
    if @shadow
      @shadow.opacity = self.opacity
      @shadow.visible = (bushdepth == 0)
      if !self.visible || ((@character == $game_player) &&
         ($PokemonGlobal.surfing || $PokemonGlobal.diving || $PokemonGlobal.lavasurfing))
        @shadow.visible = false
      end
    end
  end
end
