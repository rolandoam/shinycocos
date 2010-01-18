/*
 *   ShinyCocos - ruby bindings for the cocos2d-iphone game framework
 *   Copyright (C) 2009, Rolando Abarca M.
 *
 *   This library is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU Lesser General Public
 *   License as published by the Free Software Foundation; either
 *   version 2.1 of the License.
 *
 *   This library is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *   Lesser General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public
 *   License along with this library; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#import "SC_common.h"
#import "SC_CocosNode.h"
#import "SC_AtlasSpriteManager.h"
#import "SC_AtlasSprite.h"
#import "SC_TMXTiledMap.h"

VALUE rb_cTMXTiledMap;
VALUE rb_cTMXLayer;

/*
 * call-seq:
 *   map = TMXTiledMap.new("my_map.tmx")   #=> a new TMXTiledMap
 *
 * creates a new TMXTiledMap from a tmx file (Tiled)
 */
VALUE rb_cTMXTiledMap_s_new(int argc, VALUE *argv, VALUE klass) {
	if (argc != 1) {
		rb_raise(rb_eArgError, "Invalid number of arguments");
	}
	Check_Type(argv[0], T_STRING);
	TMXTiledMap *map = [[TMXTiledMap alloc] initWithTMXFile:[NSString stringWithCString:RSTRING_PTR(argv[0]) encoding:NSUTF8StringEncoding]];
	VALUE ret = sc_init(klass, nil, map, argc-1, argv+1, YES);
	map.userData = (void *)ret;
	
	return ret;
}


/*
 * call-seq:
 *   map["layer_name"]   #=> a TMXLayer or nil
 *
 * returns the TMXLayer with the given name (or nil if there's no layer with that name)
 */
VALUE rb_cTMXTiledMap_get_layer(VALUE object, VALUE layer_name) {
	Check_Type(layer_name, T_STRING);
	TMXLayer *layer = [CC_TMXTILEDMAP(object) layerNamed:[NSString stringWithCString:RSTRING_PTR(layer_name) encoding:NSUTF8StringEncoding]];
	if (layer) {
		if (!layer.userData) {
			// create a new rb_cTMXLayer and attach it to this layer
			VALUE l = sc_init(rb_cTMXLayer, nil, layer, 0, 0, YES);
			layer.userData = (void *)l;
		}
		return (VALUE)layer.userData;
	}
	return Qnil;
}

void init_rb_cTMXTiledMap() {
	rb_cTMXTiledMap = rb_define_class_under(rb_mCocos2D, "TMXTiledMap", rb_cCocosNode);
	rb_define_singleton_method(rb_cTMXTiledMap, "new", rb_cTMXTiledMap_s_new, -1);
	rb_define_method(rb_cTMXTiledMap, "[]", rb_cTMXTiledMap_get_layer, 1);
}


/*
 * call-seq:
 *   layer.name   #=> string
 *
 * Returns the layer's name, as defined in Tiled
 */
VALUE rb_cTMXLayer_name(VALUE obj) {
	return rb_str_new2([CC_TMXLAYER(obj).layerName cStringUsingEncoding:NSUTF8StringEncoding]);
}


/*
 * call-seq:
 *   layer.add_tile(gid, coord)   #=> AtlasSprite
 *
 * Adds a new tile for the given gid on the specified position (as a 2d array).
 * Returns a new AtlasSprite.
VALUE rb_cTMXLayer_insert_tile(VALUE obj, VALUE gid, VALUE coord) {
	Check_Type(gid, T_FIXNUM);
	Check_Type(coord, T_ARRAY);
	
	CGPoint pos = CGPointMake(FIX2INT(RARRAY_PTR(coord)[0]), FIX2INT(RARRAY_PTR(coord)[1]));
	AtlasSprite *sprite = [CC_TMXLAYER(obj) insertTileForGID:FIX2INT(gid) at:pos];
	if (!sprite.userData) {
		VALUE ret = sc_init(rb_cAtlasSprite, nil, sprite, 0, 0, YES);
		sprite.userData = (void *)ret;
	}
	return (VALUE)sprite.userData;
}
*/


/*
 * call-seq:
 *   layer.tile(coord)   #=> AtlasSprite
 *
 * Returns the tile (as an AtlasSprite) for the given coordinate (as a 2d array)
 */
VALUE rb_cTMXLayer_tile(VALUE obj, VALUE coord) {
	Check_Type(coord, T_ARRAY);
	CGPoint pos = CGPointMake(FIX2INT(RARRAY_PTR(coord)[0]), FIX2INT(RARRAY_PTR(coord)[1]));
	AtlasSprite *sprite = [CC_TMXLAYER(obj) tileAt:pos];
	if (!sprite.userData) {
		VALUE ret = sc_init(rb_cAtlasSprite, nil, sprite, 0, 0, YES);
		sprite.userData = (void *)ret;
	}
	return (VALUE)sprite.userData;
}


/*
 * call-seq:
 *   layer.tile_gid(coord)   #=> int
 *
 * Same as layer.tile, but returns the gid of the tile instead of an AtlasSprite
 */
VALUE rb_cTMXLayer_tile_gid(VALUE obj, VALUE coord) {
	Check_Type(coord, T_ARRAY);
	CGPoint pos = CGPointMake(FIX2INT(RARRAY_PTR(coord)[0]), FIX2INT(RARRAY_PTR(coord)[1]));
	unsigned int gid = [CC_TMXLAYER(obj) tileGIDAt:pos];
	return INT2FIX(gid);
}


/*
 * call-seq:
 *   layer.set_tile_gid(gid, coord)   #=> gid
 *
 * Sets the given tile (based on the gid) for the specified position (as a 2d array)
 */
VALUE rb_cTMXLayer_set_tile_gid(VALUE obj, VALUE gid, VALUE coord) {
	Check_Type(coord, T_ARRAY);
	CGPoint pos = CGPointMake(FIX2INT(RARRAY_PTR(coord)[0]), FIX2INT(RARRAY_PTR(coord)[1]));
	[CC_TMXLAYER(obj) setTileGID:FIX2INT(gid) at:pos];
	return gid;
}


/*
 * call-seq:
 *   layer.remove_tile(coord)   #=> nil
 *
 * Removes the tile at the specified coordinate (as a 2d array)
 */
VALUE rb_cTMXLayer_remove_tile(VALUE obj, VALUE coord) {
	Check_Type(coord, T_ARRAY);
	CGPoint pos = CGPointMake(FIX2INT(RARRAY_PTR(coord)[0]), FIX2INT(RARRAY_PTR(coord)[1]));
	[CC_TMXLAYER(obj) removeTileAt:pos];
	return Qnil;
}


/*
 * call-seq:
 *   layer.px_position(coord)   #=> [x,y]
 *
 * Returns the position in pixels of a given tile coordinate
 */
VALUE rb_cTMXLayer_px_position(VALUE obj, VALUE coord) {
	Check_Type(coord, T_ARRAY);
	CGPoint pos = CGPointMake(FIX2INT(RARRAY_PTR(coord)[0]), FIX2INT(RARRAY_PTR(coord)[1]));
	CGPoint pxpos = [CC_TMXLAYER(obj) positionAt:pos];
	return rb_ary_new3(2, rb_float_new(pxpos.x), rb_float_new(pxpos.y));
}


void init_rb_cTMXLayer() {
	rb_cTMXLayer = rb_define_class_under(rb_mCocos2D, "TMXLayer", rb_cAtlasSpriteManager);
	// properties
	rb_define_method(rb_cTMXLayer, "name", rb_cTMXLayer_name, 0);
	// methods
//	rb_define_method(rb_cTMXLayer, "append_tile", rb_cTMXLayer_append_tile, 2);
	rb_define_method(rb_cTMXLayer, "tile", rb_cTMXLayer_tile, 1);
	rb_define_method(rb_cTMXLayer, "tile_gid", rb_cTMXLayer_tile_gid, 1);
	rb_define_method(rb_cTMXLayer, "set_tile_gid", rb_cTMXLayer_set_tile_gid, 2);
	rb_define_method(rb_cTMXLayer, "remove_tile", rb_cTMXLayer_remove_tile, 1);
	rb_define_method(rb_cTMXLayer, "px_position", rb_cTMXLayer_px_position, 1);
}
