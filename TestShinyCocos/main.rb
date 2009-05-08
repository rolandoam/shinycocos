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
    bg = Sprite.sprite_with_file "logogff.png"
    bg.position = [240, 160]
    # @sprite = Sprite.sprite_with_file "dante.png"
    add_child bg, :z => -1
    # add_child @sprite, :z => 1
  end
  
  def on_enter
    ns_log "entering the scene..."
  end
  
  # acceleration is an array of floats
  # acceleration[0..2] = x,y,z
  # acceleration[3] = absolute acceleration
  def got_acceleration(acceleration)
    ns_log("acceleration abs:%0.2f" % acceleration[3])
    # now move the sprite
    # old_pos = @sprite.position
    # @sprite.position = [old_pos[0] + acceleration[0], old_pos[1] + acceleration[1]]
  end
end

Director.landscape = true
Director.animation_interval = 1/60.0
test = TestScene.new
set_acceleration_delegate test
Director.run_scene test
