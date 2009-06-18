require 'menu_scene'

module TouchDelegate
  def touch_began(touch)
    pos = self.position
    tpos = @scene.world_to_node_space(touch[:location])
    if (tpos[1] - pos[0]).abs < 16 && (tpos[0] - pos[1]).abs < 18
      # apply force to the black box
      @shape.body.apply_impulse(CP::Vec2.new(1000, 0), CP::Vec2.new(0,0))
      # claim touch
      return false
    end
    true
  end
  
  def scene=(scene)
    @scene = scene
  end
  
  def shape=(shape)
    @shape = shape
  end
end

class TestCoordinates < MenuScene
  def initialize
    add_child Sprite.new("tube.png").tap { |sp|
      sp.position = [240,160]
    } # too lazy to implement a ColorLayer :-P
    add_child Sprite.new("black_box.png"), :tag => 0
    add_child Sprite.new("brown_box.png"), :tag => 1
    add_child Sprite.new("wheel.png"),     :tag => 2
    add_child Sprite.new("wheel.png"),     :tag => 3
    # set the position of each sub-sprite
    @st_x = 45.0 # initial position: center of the screen (landscape)
    @st_y = 200.0
    positions = [
      [  0.0,   0.0],
      [  0.0, -21.5],
      [-25.0, -21.5],
      [ 25.0, -21.5]
    ]
    (0..3).each { |i|
      child_with_tag(i).tap do |c|
        c.position = [@st_x + positions[i][0], @st_y + positions[i][1]]
        if i == 0 # only add black box as a touch delegate
          c.extend(TouchDelegate)
          c.scene = self
          Director.add_touch_handler(c)
        end
      end
    }
    init_physics
    add_physics
    # call super to add the menus on the bottom
    super
  end
  
  # just the simple formula for an oval
  def oval(x, a, b, h, k)
    k + -b * Math.sqrt(1 - ((x-h)/a) ** 2)
  end
  
  def init_physics
    $space = CP::Space.new
    $space.resize_static_hash(400, 40)
    $space.resize_active_hash(100, 600)
    $space.gravity = CP::Vec2.new(0.0, -98)
    $space.iterations = 40
    $space.elastic_iterations = $space.iterations
    # add the floor, we want to simulate the "tube" in tube.png
    # to do that, we will add lots of small segments
    verts = [CP::Vec2.new(0, 5000)]
    (0..480).each do |x|
      verts << CP::Vec2.new(x, oval(x, 240.0, 160.0, 240.0, 160.0))
    end
    verts << CP::Vec2.new(480, 5000)

    sbody = CP::Body.new(+1.0/0, +1.0/0) # big static body
    first = verts.first
    (1...verts.size).each do |i|
      shape = CP::Shape::Segment.new(sbody, first, verts[i], 0.0)
      shape.u = 1.0
      $space.add_static_shape(shape)
      first = verts[i]
    end
    # install default stepper
    become_chipmunk_stepper
    # or, we could use our own stepper
    # schedule :tick
  end
  
  # the same version of the objc default stepper
  def tick(delta)
    steps = 2
    dt = delta/steps
    (0...steps).each { |i| $space.step(dt) }
    (0..2).each { |i|
      child_with_tag(i).tap do |c|
        b = c.shape.body
        c.position = [b.p.x, b.p.y]
        c.rotation = b.a
        b.reset_forces
      end
    }
  end
  
  def add_physics
    cpvzero = CP::Vec2.new(0.0,0.0)
    # the black box
    verts = [[-16,18],[16,18],[16,-18],[-16,-18]].map{|p| CP::Vec2.new(p[0],p[1])}
    body1 = CP::Body.new(10, CP.moment_for_poly(10, verts, cpvzero))
    shape1 = CP::Shape::Poly.new(body1, verts, cpvzero)
    # the brown box
    verts = [[-26,3.5],[26,3.5],[26,-3,5],[-26,-3.5]].map{|p| CP::Vec2.new(p[0],p[1])}
    body2 = CP::Body.new(10, CP.moment_for_poly(10, verts, cpvzero))
    shape2 = CP::Shape::Poly.new(body2, verts, cpvzero)
    # the wheels
    body_wheel1 = CP::Body.new(3, CP.moment_for_circle(3, 7, 0, cpvzero))
    shape_wheel1 = CP::Shape::Circle.new(body_wheel1, 7, cpvzero)
    body_wheel2 = CP::Body.new(3, CP.moment_for_circle(3, 7, 0, cpvzero))
    shape_wheel2 = CP::Shape::Circle.new(body_wheel2, 7, cpvzero)
    shape_wheel1.u = shape_wheel2.u = 0.5
    # brown box and wheels in the same collision group
    shape_wheel2.group = shape_wheel1.group = shape2.group = 1
    # position each body
    body1.p = CP::Vec2.new(@st_x - 0.0, @st_y - 0.0)
    body2.p = CP::Vec2.new(@st_x - 0.0, @st_y - 21.5)
    body_wheel1.p = CP::Vec2.new(@st_x - 25.0, @st_y - 21.5)
    body_wheel2.p = CP::Vec2.new(@st_x + 25.0, @st_y - 21.5)
    # create the joints
    j1 = CP::Joint::Pin.new(body1, body2, cpvzero, cpvzero)
    j2 = CP::Joint::Groove.new(body_wheel1, body2, CP::Vec2.new(0.0,0.1), CP::Vec2.new(0.0,0.0), CP::Vec2.new(-25.0, 0))
    j3 = CP::Joint::Groove.new(body_wheel2, body2, CP::Vec2.new(0.0,0.1), CP::Vec2.new(0.0,0.0), CP::Vec2.new( 25.0, 0))
    # add all bodies/shapes/joints to the space
    [body1, body2, body_wheel1, body_wheel2].each { |b| $space.add_body(b) }
    (shapes = [shape1, shape2, shape_wheel1, shape_wheel2]).each { |s| $space.add_shape(s) }
    [j1, j2, j3].each { |j| $space.add_joint(j) }
    # attach each body to the corresponding sprite
    (0..3).each do |i|
      child_with_tag(i).tap do |c|
        c.attach_chipmunk_shape(shapes[i])
        c.shape = shapes[i] if i == 0
      end
    end
  end
end
