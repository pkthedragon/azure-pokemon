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

  # Bitmap#raw_data is RGBA. Check only the alpha byte of each source pixel.
  VISIBLE_PIXEL = /\A(?:.{3}\x00)*.{3}[^\x00]/mn

  # Only bitmaps used for shadow checks need to track changes to their alpha.
  module FrameAlphaChanges
    [:add_frame, :blt, :blur, :clear, :clear_rect, :draw_text, :fill_rect,
     :gradient_fill_rect, :hires=, :hue_change, :radial_blur, :raw_data=,
     :remove_frame, :set_pixel, :snap_to_bitmap, :stretch_blt].each do |operation|
      define_method(operation) do |*args|
        @overworld_shadow_frames = nil
        @overworld_shadow_revision = @overworld_shadow_revision.to_i + 1
        super(*args)
      end
    end
  end
  private_constant :FrameAlphaChanges

  def self.visible_pixels?(pixels, stride, x, y, width, height)
    bytes = width * 4
    offset = y * stride + x * 4
    height.times do
      return true if pixels.byteslice(offset, bytes).match?(VISIBLE_PIXEL)
      offset += stride
    end
    return false
  end
  private_class_method :visible_pixels?

  def self.frame_visible?(bitmap, x, y, width, height, charset = false)
    unless bitmap.is_a?(FrameAlphaChanges)
      bitmap.extend(FrameAlphaChanges)
      bitmap.instance_variable_set(:@overworld_shadow_frames, nil)
    end
    frames = unless bitmap.animated?
      bitmap.instance_variable_get(:@overworld_shadow_frames) ||
        bitmap.instance_variable_set(:@overworld_shadow_frames, {})
    end
    bitmap_width = bitmap.width
    bitmap_height = bitmap.height
    stride = bitmap_width * 4

    # Read back a standard charset once and retain only the visibility of each cell.
    if frames && charset && width > 0 && height > 0 &&
       width == bitmap_width / 4 && height == bitmap_height / 4 &&
       x >= 0 && x < width * 4 && x % width == 0 &&
       y >= 0 && y < height * 4 && y % height == 0
      cells = frames[:charset] ||= begin
        pixels = bitmap.raw_data
        Array.new(16) do |index|
          visible_pixels?(pixels, stride, (index % 4) * width, (index / 4) * height, width, height)
        end
      end
      return cells[y / height * 4 + x / width]
    end

    # Tiles and custom regions use the actual clipped source rectangle.
    key = [x, y, width, height] if frames
    return frames[key] if frames && frames.key?(key)
    left = [x, 0].max
    top = [y, 0].max
    right = [x + width, bitmap_width].min
    bottom = [y + height, bitmap_height].min
    visible = left < right && top < bottom &&
              visible_pixels?(bitmap.raw_data, stride, left, top, right - left, bottom - top)
    frames[key] = visible if frames
    return visible
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
    # The initial update already handles event shadows.
    make_shadow if character.is_a?(Game_Player)
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
    @shadow.visible = self.visible && @shadow_drawable
    # Positioning the shadow
    position_shadow
  end

  def dispose_shadow
    return unless @shadow
    bitmap = @shadow.bitmap
    @shadow.dispose
    @shadow = nil
    bitmap.dispose if bitmap
  end

  def position_shadow
    return unless @shadow
    if !@charbitmap || @charbitmap.disposed? ||
       (@character.is_a?(Game_Event) && @character.instance_variable_get(:@erased))
      dispose_shadow
      return
    end
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
    x = @character.screen_x
    y = @character.screen_y - 6
    z = self.z - 1
    @shadow.x = x if @shadow.x != x
    @shadow.y = y if @shadow.y != y
    @shadow.z = z if @shadow.z != z
  end

  unless method_defined?(:ow_shadow_visible)
    alias ow_shadow_visible visible=
  end
  def visible=(value)
    ow_shadow_visible(value)
    @shadow.visible = value && @shadow_drawable if @shadow
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
  def shadow_frame_visible?
    graphic = self.bitmap
    return false if !graphic || graphic.disposed?
    revision = graphic.instance_variable_get(:@overworld_shadow_revision)
    graphic_changed = !@shadow_graphic.equal?(graphic) || revision != @shadow_graphic_revision
    @shadow_graphic_animated = graphic.animated? if graphic_changed
    animation_frame = graphic.current_frame if @shadow_graphic_animated
    frame = self.src_rect
    x, y, width, height = frame.x, frame.y, frame.width, frame.height
    if graphic_changed || animation_frame != @shadow_animation_frame ||
       x != @shadow_frame_x || y != @shadow_frame_y ||
       width != @shadow_frame_width || height != @shadow_frame_height
      @shadow_graphic = graphic
      @shadow_graphic_revision = revision
      @shadow_animation_frame = animation_frame
      @shadow_frame_x, @shadow_frame_y = x, y
      @shadow_frame_width, @shadow_frame_height = width, height
      @shadow_frame_visible = OverworldShadows.frame_visible?(graphic, x, y, width, height, @charbitmapAnimated)
    end
    return @shadow_frame_visible
  end

  def update
    ow_shadow_update
    position_shadow
    visible = self.visible
    opacity = self.opacity
    @shadow_drawable = @oldbushdepth == 0 && opacity > 0

    if @character.is_a?(Game_Event)
      page = OverworldShadows.active_event_page(@character)
      if @old_page != page
        dispose_shadow
        @shadow_allowed = OverworldShadows.should_get_shadow?(@character)
        @old_page = page
      end
      if !@shadow_allowed || @character_name.to_s.empty?
        dispose_shadow
        return
      end
      @shadow_drawable &&= visible && shadow_frame_visible?
      make_shadow if !@shadow && @shadow_drawable
    elsif @character == $game_player && $PokemonGlobal
      @shadow_drawable &&= !($PokemonGlobal.surfing || $PokemonGlobal.diving || $PokemonGlobal.lavasurfing)
    end

    if @shadow
      @shadow.opacity = opacity if @shadow.opacity != opacity
      shadow_visible = visible && @shadow_drawable
      @shadow.visible = shadow_visible if @shadow.visible != shadow_visible
    end
  end
end
