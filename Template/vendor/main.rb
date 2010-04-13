# ___PROJECTNAME___
#
# just a simple test

class DemoScene < Cocos2D::Scene
  include Cocos2D

  def initialize
    @sprite = Sprite.new("grossini.png")
	@sprite.position = [160,120]
    add_child @sprite
    Director.add_touch_handler(self)
  end
  
  def touches_ended(touches)
    # move the sprite to the touched part, with a "Move To"
    @sprite.run_action Actions::MoveTo.new(1.0, Director.convert_to_gl(touches.first[:location]))
  end
end

if $0 == "ShinyCocos"
  Cocos2D::Director.set_orientation Cocos2D::Director::ORIENTATION_LANDSCAPE_RIGHT
  Cocos2D::Director.run_scene DemoScene.new
else
  $stderr.puts "This script should be run only from a ShinyCocos environment"
end
