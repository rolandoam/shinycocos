class TestItem < Cocos2D::MenuItemImage  
  include Cocos2D
  
  # iterate through all the scenes
  def item_action
    pos = self.position
    if pos[0] == 0.0
      $curr_scene = 0
    elsif pos[0] > 0
      $curr_scene = ($curr_scene + 1) % $scenes.size
    elsif pos[0] < 0
      $curr_scene = ($curr_scene - 1) % $scenes.size
    end
    Director.replace_scene $scenes[$curr_scene].new
  end
end

class MenuScene < Cocos2D::Layer
  include Cocos2D
  
  def initialize
    @menu = Cocos2D::Menu.new do |items|
      items << TestItem.new(:normal => "b1.png", :selected => "b2.png")
      items << TestItem.new(:normal => "r1.png", :selected => "r2.png")
      items << TestItem.new(:normal => "f1.png", :selected => "f2.png")
    end
    @menu.position = [240, 30]
    @menu.align(:horizontally, 20.0)
    add_child @menu
  end
end
