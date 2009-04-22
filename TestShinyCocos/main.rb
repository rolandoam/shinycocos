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
    sprite = Sprite.sprite_with_file "logogff.png"
    sprite.position = [240, 160]
    add_child sprites
  end
  
  def on_enter
    ns_log "entering the scene..."
  end
  
  # acceleration is an array of floats
  # acceleration[0..2] = x,y,z
  # acceleration[3] = absolute acceleration
  def got_acceleration(acceleration)
    ns_log("acceleration x:%f" % [acceleration[0]])
  end
end

Director.landscape = true
Director.animation_interval = 1/60.0
test = TestScene.node
set_acceleration_delegate test
Director.run_scene test
