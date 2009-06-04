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
    #Texture2D.aliased do
      @manager = AtlasSpriteManager.new "grossini_dance_atlas.pvr", :capacity => 50
      add_child @manager, :z => 0
    #end
    @sprite = AtlasSprite.new(:rect => [0, 0, 85, 121], :manager => @manager)
    @sprite.position = [240, 160]
    @sprite.run_action(:repeat_forever, {}, :animate, @animations[:walk])
    @manager.add_child @sprite, :z => 0
	enable_accelerometer(true)
    super
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
