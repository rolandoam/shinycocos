require 'menu_scene'
require 'map_reader'

class TiledTest < MenuScene
  include Cocos2D
  
  def initialize
    @map = TiledMapReader.new("TestTiled.tmx")
    @map.layers.each { |layer|
      node = TiledMap.new(@map.properties.merge(:tiles => "tiles.png", :data => layer[:data]))
      add_child node
    }
	super
  end
end
