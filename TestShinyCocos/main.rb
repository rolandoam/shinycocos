#
#  main.rb
#  TestShinyCocos
#
#  Created by Rolando Abarca on 4/7/09.
#  Copyright (c) 2009 Games For Food SpA. All rights reserved.
#

# simple test scene

include Cocos2D

class TestScene < Scene
  def initialize
    # create animations
    @animations = {}
    @animations[:walk] = AtlasAnimation.animation(:name => "walk", :delay => 0.5) { |anim|
      0.upto(14) do |i|
        x = i % 5
        y = i / 5
        anim.add_frame [x*85, y*121, 85, 121]
      end
    }
    Texture2D.aliased do
      @manager = AtlasSpriteManager.manager_with_file "grossini_dance_atlas.pvr", :capacity => 50
      add_child @manager, :z => 0
    end
    @sprite = AtlasSprite.sprite(:rect => [0, 0, 85, 121], :manager => @manager)
    @sprite.position = [240, 160]
    @sprite.run_action(:repeat_forever, {}, :animate, @animations[:walk])
    @manager.add_child @sprite, :z => 0
  end
  
  def on_enter
    ns_log "entering the scene..."
  end
  
  # acceleration is an array of floats
  # acceleration[0..2] = x,y,z
  # acceleration[3] = absolute acceleration
  def got_acceleration(acceleration)
    # ns_log("acceleration abs:%0.2f" % acceleration[3])
    # now move the sprite
    old_pos = @sprite.position
    @sprite.position = [old_pos[0] + (acceleration[1] * -2), old_pos[1] + (acceleration[0] * 2)]
  end
end

Director.landscape = true
Director.animation_interval = 1/60.0
Director.display_fps(true)

test = TestScene.new
set_acceleration_delegate test
Director.run_scene test
