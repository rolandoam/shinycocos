#  main.rb
#  TestShinyCocos
#
#  Created by Rolando Abarca on 4/7/09.
#  Copyright (c) 2009 Games For Food SpA. All rights reserved.

#require 'test_scene'
require 'tiled_test_scene'

Cocos2D::Director.landscape = true
Cocos2D::Director.animation_interval = 1/60.0
Cocos2D::Director.display_fps(true)

test = TiledTest.new
#set_acceleration_delegate test
Cocos2D::Director.run_scene test
