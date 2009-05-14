require 'base64'
require 'rexml/document'

class TiledMapReader
  class InvalidMap < StandardError; end
  class CellOutOfRange < StandardError; end
  
  attr_reader :layers
  attr_reader :properties

  def initialize(map)
    @doc = REXML::Document.new(File.read_from_resources(map))
    root = @doc.root
    if root.name != "map"
      raise InvalidMap.new
    end
    @properties = {}
    @properties[:width] = root.attributes['width'].to_i
    @properties[:height] = root.attributes['height'].to_i
    @properties[:tile_width] = root.attributes['tilewidth'].to_i
    @properties[:tile_height] = root.attributes['tileheight'].to_i
    # parse layers
    @layers = []
    root.each_element("layer") { |layer|
      l = {}
      l[:name] = layer.attributes['name']
      l[:width] = layer.attributes['width'].to_i
      l[:height] = layer.attributes['height'].to_i
      data = REXML::XPath.first(layer, "data")
      l[:data] = Base64.decode64(data.text.strip)
      @layers << l
    }
  end

  def show_map
    @layers.each do |layer|
      puts "Layer: #{layer[:name]}"
      (0 ... layer[:height]).each { |y|
        (0 ... layer[:width]).each { |x|
          print "%03d " % [get_tile_id(x, y, layer[:data])]
        }
        print "\n"
      }
      print "\n"
    end
  end

  def get_tile_id(x, y, data)
    raise CellOutOfRange.new if x >= @properties[:width] || y >= @properties[:height]
    st = y*4*@properties[:width] + x*4
    data[st] | data[st + 1] << 8 | data[st + 2] << 16 | data[st + 3] << 24
  end
end
