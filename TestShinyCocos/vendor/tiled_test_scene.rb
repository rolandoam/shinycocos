require 'map_reader'

class TiledTest < Cocos2D::Scene
  include Cocos2D
  
  def initialize
    @map = ::TiledMapReader.new("TestTiled.tmx")
    @map.layers.each { |layer|
      node = TiledMap.new(
        :tiles => "tiles.png",
        :tile_width => @map.properties[:tile_width],
        :tile_height => @map.properties[:tile_height],
        :map_width => @map.properties[:width],
        :map_height => @map.properties[:height],
        :data => layer[:data])
      add_child node
    }
  end
end
