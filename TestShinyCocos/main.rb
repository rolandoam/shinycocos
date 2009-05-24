#  main.rb
#  TestShinyCocos
#
#  Created by Rolando Abarca on 4/7/09.
#  Copyright (c) 2009 Games For Food SpA. All rights reserved.

require 'test_scene'
require 'tiled_test_scene'
require 'test_layer'

Cocos2D::Director.landscape true
Cocos2D::Director.animation_interval = 1/320.0
Cocos2D::Director.display_fps true

$scenes = [
  TestScene,
  TiledTest,
  TestLayer
]
$curr_scene = 0
$running = $scenes[$curr_scene].new
Cocos2D::Director.run_scene $running
