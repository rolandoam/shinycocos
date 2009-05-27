require 'base64'
require 'rexml/document'
if ENV['NONDEVICE']
  require 'zlib'
  require 'stringio'
end

class TiledMapReader
  class InvalidMap < StandardError; end
  class CellOutOfRange < StandardError; end
  
  attr_reader :layers
  attr_reader :properties
  attr_reader :tilesets

  def initialize(map)
    if ENV['NONDEVICE']
      @doc = REXML::Document.new(File.read(map))
    else
      @doc = REXML::Document.new(File.read_from_resources(map))
    end
    root = @doc.root
    if root.name != "map"
      raise InvalidMap.new
    end
    @properties = {}
    @properties[:map_width] = root.attributes['width'].to_i
    @properties[:map_height] = root.attributes['height'].to_i
    @properties[:tile_width] = root.attributes['tilewidth'].to_i
    @properties[:tile_height] = root.attributes['tileheight'].to_i
    # parse tilesets
    @tilesets = []
    root.each_element("tileset") { |tset|
      ts = {}
      ts[:name] = tset.attributes['name']
      ts[:first_gid] = tset.attributes['firstgid'].to_i
      ts[:width] = tset.attributes['tilewidth'].to_i
      ts[:height] = tset.attributes['tileheight'].to_i
      @tilesets << ts
    }
    # parse layers
    @layers = []
    root.each_element("layer") { |layer|
      l = {}
      l[:name] = layer.attributes['name']
      l[:width] = layer.attributes['width'].to_i
      l[:height] = layer.attributes['height'].to_i
      data = REXML::XPath.first(layer, "data")
      if data.attributes['compression'] == "gzip"
        str = StringIO.new(Base64.decode64(data.text.strip))
        reader = Zlib::GzipReader.new(str)
        l[:data] = reader.read
        reader.close
      else
        l[:data] = Base64.decode64(data.text.strip)
      end
      @layers << l
    }
  end

  def physics_first_gid
    @tilesets.select { |ts| ts[:name] == 'physics' }.first[:first_gid]
  end

  # get a tileset for a given gid
  def tileset_for_gid(gid)
    @tilesets.each_with_index { |ts,i|
      return ts if ts[:first_gid] <= gid && (@tilesets[i+1].nil? || @tilesets[i+1][:first_gid] > gid)
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

if __FILE__ == $0
  tm = TiledMapReader.new(ARGV[0])
  tm.show_map
end
