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
#import "SC_TMXTiledMap.h"

VALUE rb_cTMXTiledMap;
VALUE rb_cTMXLayer;

/*
 * call-seq:
 *   map = TMXTiledMap.new("my_map.tmx")   #=> a new TMXTiledMap
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
 *   map["layer_name"]   #=> a TMXLayer
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

void init_rb_cTMXLayer() {
	rb_cTMXLayer = rb_define_class_under(rb_mCocos2D, "TMXLayer", rb_cAtlasSpriteManager);
}
