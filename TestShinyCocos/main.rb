#
#  main.rb
#  TestShinyCocos
#
#  Created by Rolando Abarca on 4/7/09.
#  Copyright (c) 2009 Games For Food SpA. All rights reserved.
#

# simple test scene

=begin
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
end

Director.landscape = true
Director.animation_interval = 1/60.0
Director.run_scene TestScene.node
=end

raise "test exception"
