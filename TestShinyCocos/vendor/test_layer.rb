#  test_layer.rb
#  TestShinyCocos
#
#  Created by Rolando Abarca on 5/15/09.
#  Copyright (c) 2009 Games For Food SpA. All rights reserved.

require 'menu_scene'

class TestLayer < MenuScene
  include Cocos2D
  
  def initialize
    enable_touch(true)
    super
  end
  
  def touches_began(touches)
    p touches
  end
  
  def touches_ended(touches)
    p touches
  end
end
