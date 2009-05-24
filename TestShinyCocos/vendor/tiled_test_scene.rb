require 'menu_scene'
require 'map_reader'

class TiledTest < MenuScene
  include Cocos2D
  
  def initialize
    @map = TiledMapReader.new("TestTiled.tmx")
    @map.layers.each { |layer|
      node = TiledMap.new(
        :tiles => "tiles.png",
        :tile_width => @map.properties[:tile_width],
        :tile_height => @map.properties[:tile_height],
        :map_width => @map.properties[:width],
        :map_height => @map.properties[:height],
        # note: the data should NOT be compressed!!
        # you have to uncheck that option in Tiled preferences
        :data => layer[:data])
      add_child node
    }
	super
  end
end
