require 'menu_scene'

class TestTwitter < MenuScene
  include Cocos2D
  
  def initialize
    enable_touch(true)
    super
  end
  
  def touches_began(touches)
    if err = twitt("user", "pass", "I should read the source code, it makes me a good programmer")
      puts "twitt err: #{err.inspect}"
    else
      puts "twitt: #{err.inspect}"
    end
    p touches
  end
  
  def touches_ended(touches)
    p touches
  end
end
