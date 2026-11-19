module MakerStudioTileOverlays
  EMPTY_METADATA = {}.freeze

  def self.original_metadata(map_id)
    @original_metadata ||= load_data("Data/TileOverlayMetadata.rxdata")
    return @original_metadata.fetch(map_id, EMPTY_METADATA)
  end

  # Azure's bundled RGSS runtime does not include Ruby's JSON library.
  class JsonReader
    TOKEN = /\G[ \t\r\n]*("(?:[^"\\\x00-\x1f]|\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4}))*"|-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?|true|false|null|[{}\[\],:])/
    ESCAPE = /\\u([dD][89a-bA-B][0-9a-fA-F]{2})\\u([dD][c-fC-F][0-9a-fA-F]{2})|\\u([0-9a-fA-F]{4})|\\(["\\\/bfnrt])/
    ESCAPES = { '"' => '"', '\\' => '\\', '/' => '/', 'b' => "\b", 'f' => "\f", 'n' => "\n", 'r' => "\r", 't' => "\t" }.freeze

    def initialize(source)
      @source = source.dup.force_encoding(Encoding::UTF_8)
      @offset = 0
      advance
    end

    def read
      value = read_value
      raise ArgumentError, "Extra data after MakerStudio JSON" if @token
      return value
    end

    private

    def advance
      match = TOKEN.match(@source, @offset)
      if match
        @offset = match.end(0)
        @token = match[1]
      elsif @source.match?(/\G[ \t\r\n]*\z/, @offset)
        @token = nil
      else
        raise ArgumentError, "Invalid MakerStudio JSON at character #{@offset}"
      end
    end

    def take(expected = nil)
      token = @token
      raise ArgumentError, "Expected #{expected || 'a JSON value'} at character #{@offset}" if !token || (expected && token != expected)
      advance
      return token
    end

    def read_value
      case @token
      when "{"
        read_object
      when "["
        read_array
      when "true"
        take
        true
      when "false"
        take
        false
      when "null"
        take
        nil
      else
        token = take
        return read_string(token) if token.start_with?('"')
        return Float(token) if token.match?(/[.eE]/)
        return Integer(token, 10)
      end
    end

    def read_object
      take("{")
      result = {}
      if @token != "}"
        loop do
          key = read_string(take)
          take(":")
          result[key] = read_value
          break if @token != ","
          take
        end
      end
      take("}")
      return result
    end

    def read_array
      take("[")
      result = []
      if @token != "]"
        loop do
          result << read_value
          break if @token != ","
          take
        end
      end
      take("]")
      return result
    end

    def read_string(token)
      raise ArgumentError, "Expected a MakerStudio JSON string" unless token.start_with?('"')
      return token[1...-1].gsub(ESCAPE) do
        match = Regexp.last_match
        if match[1]
          code = 0x10000 + ((match[1].to_i(16) - 0xD800) << 10) + match[2].to_i(16) - 0xDC00
          code.chr(Encoding::UTF_8)
        elsif match[3]
          match[3].to_i(16).chr(Encoding::UTF_8)
        else
          ESCAPES.fetch(match[4])
        end
      end
    end
  end

  # Layer tiles keep their original event z value and sprite creation order.
  class Sprite < ::Sprite
    def initialize(viewport, map, tile)
      super(viewport)
      @map = map
      @tile_id = tile.fetch("tile_id")
      @real_x = tile.fetch("x") * Game_Map.realResX
      @real_y = tile.fetch("y") * Game_Map.realResY
      @on_top = tile["azure_event_on_top"]
      self.bitmap = pbGetTileBitmap(map.tileset_name, @tile_id, tile.fetch("hue", 0))
      self.ox = Game_Map::TILEWIDTH / 2
      self.oy = Game_Map::TILEHEIGHT
      self.opacity = tile.fetch("opacity", 255)
      update
    end

    def update
      super
      draw_x = (@real_x - @map.display_x + 3) / 4 + ox
      draw_y = (@real_y - @map.display_y + 3) / 4 + oy
      draw_z = if @on_top
                 999
               else
                 (@real_y - $game_map.display_y + 3) / 4 + 32 + $game_map.priorities[@tile_id].to_i * 32
               end
      self.x = draw_x if draw_x != @draw_x
      self.y = draw_y if draw_y != @draw_y
      self.z = draw_z if draw_z != @draw_z
      @draw_x, @draw_y, @draw_z = draw_x, draw_y, draw_z

      tint = $PokemonSystem.tilemap == 0 ? PBDayNight::NEUTRAL_TINT : PBDayNight.map_tint
      if tint && tint != @draw_tint
        tone.set(*tint)
        @draw_tint = tint
      end
    end

    def dispose
      bitmap.dispose if bitmap
      super
    end
  end
end

class Game_Map
  def azure_overlays_by_event_id
    azure_refresh_overlay_index
    return @azure_overlays_by_event_id
  end

  def azure_overlay_at(x, y)
    azure_refresh_overlay_index
    return nil if @azure_overlay_cells.empty? || !valid?(x, y)
    return @azure_overlay_cells[y * width + x]
  end

  private

  def azure_refresh_overlay_index
    raw = @map && @map.instance_variable_get(:@extended_layers)
    return if @azure_overlay_cells && @azure_overlay_source.equal?(raw)
    @azure_overlay_source = raw
    @azure_overlay_cells = {}
    @azure_overlays_by_event_id = {}
    return if !raw || raw.empty?
    data = MakerStudioTileOverlays::JsonReader.new(raw).read
    original_metadata = nil
    (data["layers"] || []).each do |layer|
      next unless layer["visible"]
      (layer["tiles"] || {}).each do |coordinate, cell|
        next unless cell && cell["tile_id"].to_i >= 384
        unless cell["azure_event_id"]
          next unless layer["id"] == 0
          # Keep the original settings if a map save normalizes the tile fields.
          original_metadata ||= MakerStudioTileOverlays.original_metadata(@map_id)
          original = original_metadata[coordinate]
          next unless original && original["tile_id"] == cell["tile_id"]
          cell = original.merge(cell)
        end
        x, y = coordinate.split(",", 2).map(&:to_i)
        next unless y && valid?(x, y)
        tile = cell.merge("x" => x, "y" => y)
        tile["opacity"] = cell.fetch("opacity", 255) * layer.fetch("opacity", 255) / 255
        @azure_overlay_cells[y * width + x] = tile
        @azure_overlays_by_event_id[tile["azure_event_id"]] = tile
      end
    end
  end
end
