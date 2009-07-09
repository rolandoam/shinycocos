#  main.rb
#  TestShinyCocos
#
#  Created by Rolando Abarca on 4/7/09.
#  Copyright (c) 2009 Games For Food SpA. All rights reserved.

%w(test_scene tiled_test_scene test_physics_layer test_twitter test_coordinates).each { |f|
  require f
}

Cocos2D::Director.set_orientation Cocos2D::Director::ORIENTATION_LANDSCAPE_LEFT
Cocos2D::Director.set_animation_interval 1/70.0
Cocos2D::Director.display_fps true

$scenes = [
  TestScene,
  TiledTest,
  TestCoordinates,
  TestPhysicsLayer,
  TestTwitter
]
$curr_scene = 0
Cocos2D::Director.run_scene $scenes[$curr_scene].new
