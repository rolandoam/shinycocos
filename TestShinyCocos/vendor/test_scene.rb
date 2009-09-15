require 'menu_scene'

class TestScene < MenuScene
  include Cocos2D
  
  def initialize
    # create animations
    @animations = {}
    @animations[:walk] = AtlasAnimation.new(:name => "walk", :delay => 0.5) { |anim|
      0.upto(14) do |i|
        x = i % 5
        y = i / 5
        anim.add_frame [x*85, y*121, 85, 121]
      end
    }
    @manager = AtlasSpriteManager.new "grossini_dance_atlas.pvr", :capacity => 50
    add_child @manager, :z => 0
    @sprite = AtlasSprite.new(:rect => [0, 0, 85, 121], :manager => @manager)
    @sprite.position = [240, 160]
    action = Actions::RepeatForever.new(Actions::Animate.new(@animations[:walk]))
    @sprite.run_action(action)
    @manager.add_child @sprite, :z => 0
    @sprite_test = Sprite.new("ball.png")
    @sprite_test.position = [100, 100]
    add_child @sprite_test

    become_accelerometer_delegate
    
    # install standard touch handler
    Director.add_touch_handler(self)
    # continue with the menu scene initialization
    super
  end
  
  def touches_began(touches)
    @sprite_test.run_action(Actions::MoveBy.new(1.0, [35.0, 0.0]))
  end
  
  # acceleration is an array of floats
  # acceleration[0..2] = x,y,z
  # acceleration[3] = absolute acceleration
  def did_accelerate(acceleration)
    # ns_log("acceleration abs:%0.2f" % acceleration[3])
    # now move the sprite
    old_pos = @sprite.position
    @sprite.position = [old_pos[0] + (acceleration[1] * -2), old_pos[1] + (acceleration[0] * 2)]
  end
end
