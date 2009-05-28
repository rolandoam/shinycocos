require 'map_reader'

class Player < Cocos2D::CocosNode
  def initialize
    @sp = Cocos2D::Sprite.new("ball.png") # 32x32
    body = CP::Body.new(10, CP.moment_for_circle(10, 0, 16, CP::Vec2.new(0,0)));
    body.p = CP::Vec2.new(100,200)
    @shape = CP::Shape::Circle.new(body, 16.0, CP::Vec2.new(0,0))
    $space.add_body(body)
    $space.add_shape(@shape)
    attach_chipmunk_shape(@shape)
    add_child @sp
  end

  def jump
    @shape.body.apply_impulse(CP::Vec2.new(0.0, 100.0), CP::Vec2.new(0.0, 0.0))
  end
end

class TestPhysicsLayer < MenuScene
  def initialize
    $space = CP::Space.new
    $space.resize_static_hash(400, 40)
    $space.resize_active_hash(100, 600)
    # default gravity
    $space.gravity = CP::Vec2.new(0.0, -98.0)
    $space.elastic_iterations = $space.iterations

    @map = TiledMapReader.new('simple_map.tmx')
    @map.layers.each { |layer|
      if layer[:name] == 'physics'
        pgid = @map.physics_first_gid
        SolidShapeMap.create($space, @map.properties.merge(:data => layer[:data], :starting_gid => pgid))
      else
        node = TiledMap.new(@map.properties.merge(:tiles => "tiles.png", :data => layer[:data]))
        add_child node
      end
    }
    # add the "ball"
    @ball = Player.new
    add_child @ball
    # call the menu initializer
    super
    # become the chipmunk stepper
    become_chipmunk_stepper
    # we want accelerometer!
    enable_accelerometer(true)
  end

  def did_accelerate(acceleration)
    $space.gravity = CP::Vec2.new(acceleration[1] * -30.0, -98.0)
    if acceleration[0] > 0.05
      @ball.jump
    end
  end
end
