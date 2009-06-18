require 'base64'
require 'rexml/document'
if ENV['NONDEVICE']
  require 'zlib'
  require 'stringio'
end

class String
  def parse_value
    case self[-1,1]
    when "f"
      to_f
    when "i"
      to_i
    else
      self
    end
  end
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
      ts[:image] = tset.first('image').attributes['source']
      # tile properties
      ts[:tiles] = {}
      tset.each_element("tile") { |tile|
        ts[:tiles][tile.attributes['id'].to_i] = tile_hsh = {}
        tile.each_element("properties/property") { |prop|
          if prop.attributes['name'] == "physics"
            # turn the string into an array of CP::Vec2
            tile_hsh[:physics] = prop.attributes['value'].split(';').map { |p|
              arr = p.split(',').map { |i| i.to_f }
              CP::Vec2.new(arr[0], arr[1])
            }
          else
            tile_hsh[prop.attributes['name'].to_sym] = prop.attributes['value'].parse_value
          end
        }
      }
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
      # add properties
      layer.each_element("properties/property") { |prop|
        puts "layer #{l[:name]}: #{prop.inspect}"
        value = prop.attributes['name'] == 'parallax_ratio' ?
          prop.attributes['value'].split(';').map { |i| i.to_f } :
          prop.attributes['value']
        l[prop.attributes['name'].to_sym] = value
      }
      @layers << l
    }
  end

  def physics_first_gid
    # cache
    @physics_first_gid ||= @tilesets.select { |ts| ts[:name] == 'physics' }.first[:first_gid]
  end

  # get a tileset for a given gid
  def tileset_for_gid(gid)
    @tilesets.each_with_index { |ts,i|
      return ts if ts[:first_gid] <= gid && (@tilesets[i+1].nil? || @tilesets[i+1][:first_gid] > gid)
    }
  end

  def tileset_with_name(name)
    @tilesets.select { |ts| ts[:name] == name }.first
  end

  def init_physics
    return if $space
    # create chipmunk space
    $space = CP::Space.new
    $space.resize_static_hash(400, 40)
    $space.resize_active_hash(100, 600)
    $space.gravity = CP::Vec2.new(0.0, -98)
    $space.iterations = 40
    $space.elastic_iterations = $space.iterations
  end

  # fixed for sprites 32x32 sheet 1024x1024
  def add_sprite(gid, tileset, x, y)
    rect_x = ((gid - 1) % 32) * 32
    rect_y = (gid / 32) * 32
    rect = [rect_x, rect_y, 32, 32]
    sp = AtlasSprite.new(:rect => rect, :manager => @sp_manager)
    @sp_manager.add_child sp
    # the position of the anchor (the center)
    pos = [x*32+16, (propertes[:map_height]-1-y)*32+16]
    sp.position = pos
    # add physics if it has any
    if tileset[:tiles][gid] && tileset[:tiles][gid][:physics]
      tile = tileset[:tiles][gid]
      body = CP::Body.new(tile[:mass], CP.moment_for_poly(tile[:mass], tile[:physics], CP::Vec2.new(0,0)))
      body.p = CP::Vec2.new(pos[0], pos[1])
      shape = CP::Shape::Poly.new(body, tile[:physics], CP::Vec2.new(0, 0))
      shape.e = tile[:e]
      shape.u = tile[:u]
      $space.add_body(body)
      $space.add_shape(shape)
      sp.attach_chipmunk_shape(shape)
    end
  end

  # create the layers/nodes/physics
  # after creation, the layers will be attached to +node+
  def process_and_attach(node)
    # create a sprite manager with the 'sprite' tilesheet
    if ts_sp = tileset_with_name('sprites')
      @sp_manager = AtlasSpriteManager.new(ts_sp[:image], :capacity => 200)
    end
    @layers.each do |layer|
      if layer[:name] == 'physics'
        init_physics
        SolidShapeMap.create($space, @properties.merge(:data => layer[:data],
                                                       :starting_gid => physics_first_gid))
      elsif layer[:name] == 'sprites'
        data = l[:data].bytes.to_a
        (0 ... l[:height]).each { |y|
          (0 ... l[:width]).each { |x|
            gid = get_tile_id(x, y, data)
            add_sprite(gid, ts_sp, x, y) if gid > 0
          }
        }
        node.add_child @sp_manager
      else
        node.add_child TiledMap.new(@properties.merge(:data => layer[:data], :tiles => ts_sp[:image])),
                       :parallax_ratio => layer[:parallax_ratio]
      end
    end
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
