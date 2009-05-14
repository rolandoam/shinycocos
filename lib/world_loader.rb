require 'yaml'

class Float
  INFINITY = (1.0/0)
end

# this should be a Layer!!
class GFFWorld < Scene
  def initialize(world)
    raise "Invalid World" if world.nil?
    @layers = CocosNode.new
    @data = YAML.load(world)
    process_all
    # add the layers
    add_child @layers, :z => 0
    # schedule ourselves as the chipmunk stepper
    become_chipmunk_stepper
    schedule :check_world
  end
  
  def check_world
  end
  
  def create_chipmunk_space(gravity = nil)
    $space = CP::Space.new
    $space.resize_static_hash(400, 40)
    $space.resize_active_hash(100, 600)
    # default gravity
    $space.gravity = gravity ? CP::Vec2.new(gravity[0], gravity[1]) : CP::Vec2.new(0.0, -980)
    $space.elastic_iterations = $space.iterations
  end
  
  private
  def process_all
    @data["layers"].each { |layer| process(layer) }
  end
  
  def process(layer)
    # atlas sprite layer
    if layer["type"] == :atlas_sprite_manager
      manager = nil
      if layer["aliased"]
        Texture2D.aliased do
          manager = AtlasSpriteManager.manager_with_file layer["file"], :capacity => layer["capacity"]
          @layers.add_child manager, :z => layer["z"], :parallax_ratio => layer["parallax_ratio"]
        end
      else
        manager = AtlasSpriteManager.manager_with_file layer["file"], :capacity => layer["capacity"]
        @layers.add_child manager, :z => layer["z"], :parallax_ratio => layer["parallax_ratio"]
      end
      layer["sprites"].each { |sprite|
        klass = Kernel.const_get(sprite["class"].capitalize)
        raise "Invalid Sprite Class (#{klass}): should be a subclass of AtlasSprite" if !klass.ancestors.include?(AtlasSprite)
        sp = klass.sprite(:rect => sprite["rect"], :manager => manager)
        manager.add_child(sp)
        if sprite['main_character']
          @sprite = sp
        end
      }
    # physics layer
    elsif layer["type"] == :chipmunk
      # check if there's a space global variable
      create_chipmunk_space(layer["gravity"]) if $space.nil?
      layer["solid_shapes"].each { |shape|
        body = CP::Body.new(Float::INFINITY, Float::INFINITY)
        coords = shape["coords"].map { |c| CP::Vec2.new(c[0], c[1]) } << 0.0
        cp_shape = CP::Shape::Segment.new(body, *coords)
        cp_shape.e = shape["e"] if shape["e"]
        cp_shape.u = shape["u"] if shape["u"]
        $space.add_static_shape(cp_shape)
      }
    # regular layer
    elsif layer["type"].nil?
      tmp = CocosNode.new
      layer["sprites"].each { |sprite|
        sp = Sprite.sprite_with_file sprite["file"]
        sp.position = sprite["position"] if sprite["position"]
        tmp.add_child sp
        @sprite = sp if sprite['main_character']
      }
      @layers.add_child tmp, :z => layer["z"], :parallax_ratio => layer["parallax_ratio"]
    else
      raise "Invalid layer type: #{layer['type']}"
    end # if
  end
end
