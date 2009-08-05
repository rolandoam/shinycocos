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

#import <Foundation/Foundation.h>
#import "ruby.h"
#import "Chipmunk.h"
#import "SC_common.h"
#import "SC_CocosNode.h"
#import "SC_SolidShapeMap.h"
#import "chipmunk.h"
#import "rb_chipmunk.h"

VALUE rb_cSolidShapeMap;

#define NEW_FLOOR_DBG(body, seg, st, ed, rad) do { \
NSLog(@"adding floor (%d) from (%f,%f) to (%f,%f)", gid, st.x, st.y, ed.x, ed.y); \
seg = cpSegmentShapeNew(body, st, ed, rad); \
} while(0)

#define NEW_FLOOR(body, seg, st, ed, rad) (seg = cpSegmentShapeNew(body, st, ed, rad))

/*
 *  1: horizontal floor, centered [ - ]
 *  2: vertical floor, centered   [ | ]
 *  3: horizontal floor, top
 *  4: horizontal floor, bottom
 *  5: vertical floor, left
 *  6: vertical floor, right
 *  7: corner, bottom right       [__|]
 *  8: corner, bottom left        [|__]
 *  9: corner, upper left
 * 10: corner, upper right
 * 11: top box (open on the bottom)
 */
void add_floor_to_space(cpSpace *space, int width, int height, int tw, int th, int off, const unsigned char* ptr, int len) {
	int x, y, last_gid;
	cpBody *floorBody = cpBodyNew(INFINITY, INFINITY);
	cpShape *segment;
	CGPoint stp = cpvzero, edp = cpvzero;
	
	// add floorBody as a global variable
	VALUE rb_floorBody = Data_Wrap_Struct(c_cpBody, NULL, cpBodyFree, floorBody);
	rb_gv_set("floor_body", rb_floorBody);
	
	for (y=0; y < height; y++) {
		for (x=0; x < width; x++) {
			NSUInteger st = y*4*width + x*4;
			int value = (ptr[st] | ptr[st+1] << 8 | ptr[st+2] << 16 | ptr[st+3] << 24);
			int gid = value - off + 1;
			int y_ = height - y - 1;
			if (last_gid == 3 && last_gid != gid) {
				NEW_FLOOR(floorBody, segment, stp, edp, 0.0f);
				cpSpaceAddStaticShape(space, segment);
			}
			switch (gid) {
				case 1: // horizontal floor, centered
					NEW_FLOOR(floorBody, segment, cpv(x*tw, y_*th+th/2), cpv((x+1)*tw, y_*th+th/2), 0.0f);
					break;
				case 2: // vertical floor, centered
					NEW_FLOOR(floorBody, segment, cpv(x*tw+tw/2, y_*th), cpv(x*tw+tw/2, (y_+1)*th), 0.0f);
					break;
				case 3: // horizontal floor, top
					if (last_gid != 3)
						stp.x = x*tw; stp.y = (y_+1)*th;
					edp.x = (x+1)*tw; edp.y = (y_+1)*th;
					segment = nil;
					//NEW_FLOOR(floorBody, segment, cpv(x*tw, (y_+1)*th), cpv((x+1)*tw, (y_+1)*th), 0.0f);
					break;
				case 4: // horizontal floor, bottom
					NEW_FLOOR(floorBody, segment, cpv(x*tw, y_*th), cpv((x+1)*tw, y_*th), 0.0f);
					break;
				case 5: // vertical floor, left
					NEW_FLOOR(floorBody, segment, cpv(x*tw, y_*th), cpv(x*tw, (y_+1)*th), 0.0f);
					break;
				case 6: // vertical floor, right
					NEW_FLOOR(floorBody, segment, cpv((x+1)*tw, y_*th), cpv((x+1)*tw, (y_+1)*th), 0.0f);
					break;
				case 7: // corner, bottom right
					NEW_FLOOR(floorBody, segment, cpv(x*tw, y_*th), cpv((x+1)*tw, y_*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					NEW_FLOOR(floorBody, segment, cpv((x+1)*tw, y_*th), cpv((x+1)*tw, (y_+1)*th), 0.0f);
					break;
				case 8: // corner, bottom left
					NEW_FLOOR(floorBody, segment, cpv(x*tw, y_*th), cpv((x+1)*tw, y_*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					NEW_FLOOR(floorBody, segment, cpv(x*tw, y_*th), cpv(x*tw, (y_+1)*th), 0.0f);
					break;
				case 9: // corner, top right
					NEW_FLOOR(floorBody, segment, cpv(x*tw, y_*th), cpv(x*tw, (y_+1)*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					NEW_FLOOR(floorBody, segment, cpv(x*tw, (y_+1)*th), cpv((x+1)*tw, (y_+1)*th), 0.0f);
					break;
				case 10: // corner, top left
					NEW_FLOOR(floorBody, segment, cpv(x*tw, y_*th), cpv(x*tw, (y_+1)*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					NEW_FLOOR(floorBody, segment, cpv(x*tw, (y_+1)*th), cpv((x+1)*tw, (y_+1)*th), 0.0f);
					break;
				case 11: // top box (open on the bottom)
					NEW_FLOOR(floorBody, segment, cpv(x*tw, y_*th), cpv(x*tw, (y_+1)*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					NEW_FLOOR(floorBody, segment, cpv(x*tw, (y_+1)*th), cpv((x+1)*tw, (y_+1)*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					NEW_FLOOR(floorBody, segment, cpv((x+1)*tw, y_*th), cpv((x+1)*tw, (y_+1)*th), 0.0f);
					break;
				default:
					segment = nil;
					break;
			}
			last_gid = gid;
			if (segment != nil)
				cpSpaceAddStaticShape(space, segment);
		} // x
	} // y
}

/*
 * call-seq:
 *   SolidShapeMap.create(chipmunk_space, options)   #=> chipmunk_space
 *
 * Creates the floor, defined using the tileset physics_layer.png and the
 * TiledMap data <tt>data</tt>.
 *
 * Required options:
 *
 * <tt>:data</tt>:: the TiledMap data (raw data)
 * <tt>:starting_gid</tt>:: the starting gid (global tile id)
 * <tt>:tile_width</tt>:: the tile width
 * <tt>:tile_height</tt>:: the tile height
 * <tt>:map_width</tt>:: the map width
 * <tt>:map_height</tt>:: the map height
 *
 * The physics_layer defines several "floor" tiles, based on which the floor for the map
 * is constructed. Internally, several segment shapes are added to the given space.
 */
VALUE rb_cSolidShapeMap_s_create(VALUE klass, VALUE rb_space, VALUE options) {
	Check_Type(options, T_HASH);
	cpSpace *space;
	Data_Get_Struct(rb_space, cpSpace, space);
	int map_width, map_height, tile_width, tile_height, starting_gid;

	VALUE tmp;
	if ((tmp = rb_hash_aref(options, sym_sc_map_width)) != Qnil) {
		map_width = FIX2INT(tmp);
	}
	if (tmp != Qnil && (tmp = rb_hash_aref(options, sym_sc_map_height)) != Qnil) {
		map_height = FIX2INT(tmp);
	}
	if (tmp != Qnil && (tmp = rb_hash_aref(options, sym_sc_tile_width)) != Qnil) {
		tile_width = FIX2INT(tmp);
	}
	if (tmp != Qnil && (tmp = rb_hash_aref(options, sym_sc_tile_height)) != Qnil) {
		tile_height = FIX2INT(tmp);
	}
	if (tmp != Qnil && (tmp = rb_hash_aref(options, sym_sc_starting_gid)) != Qnil) {
		starting_gid = FIX2INT(tmp);
	}
	if (tmp != Qnil && (tmp = rb_hash_aref(options, sym_sc_data)) != Qnil) {
		Check_Type(tmp, T_STRING);
		unsigned char *data = (unsigned char *)RSTRING_PTR(tmp);
		add_floor_to_space(space, map_width, map_height, tile_width, tile_height, starting_gid, data, RSTRING_LEN(tmp));
	}
	if (tmp == Qnil) {
		NSLog(@"will raise");
		rb_raise(rb_eArgError, "Missing required key in options");
	}
	return rb_space;
}

void init_rb_cSolidShapeMap() {
	rb_cSolidShapeMap = rb_define_class_under(rb_mCocos2D, "SolidShapeMap", rb_cObject);
	rb_define_singleton_method(rb_cSolidShapeMap, "create", rb_cSolidShapeMap_s_create, 2);
}
