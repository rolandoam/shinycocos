#  main.rb
#  TestShinyCocos
#
#  Created by Rolando Abarca on 4/7/09.
#  Copyright (c) 2009 Games For Food SpA. All rights reserved.

#require 'test_scene'
#require 'tiled_test_scene'
require 'test_layer'

Cocos2D::Director.landscape true
Cocos2D::Director.animation_interval = 1/60.0
Cocos2D::Director.display_fps false

class TestItem < Cocos2D::MenuItemImage  
  include Cocos2D
  def item_action
    ns_log "touched item #{self}"
  end
end

#menu = Cocos2D::Menu.new(
#  TestItem.new(:normal => "b1.png", :selected => "b2.png"),
#  TestItem.new(:normal => "b1.png", :selected => "b2.png"),
#  TestItem.new(:normal => "b1.png", :selected => "b2.png")
#  )
menu = Cocos2D::Menu.new do |items|
  items << TestItem.new(:normal => "b1.png", :selected => "b2.png")
  items << TestItem.new(:normal => "b1.png", :selected => "b2.png")
  items << TestItem.new(:normal => "b1.png", :selected => "b2.png")
end
menu.align(:horizontally, 20.0)

Cocos2D::Director.run_scene menu
