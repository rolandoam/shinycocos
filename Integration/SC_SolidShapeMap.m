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

/*
 * for now just assume a 32px tile
 *
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
	int x, y;
	cpBody *floorBody = cpBodyNew(INFINITY, INFINITY);
	cpShape *segment;
	for (y=0; y < height; y++) {
		for (x=0; x < width; x++) {
			NSUInteger st = y*4*width + x*4;
			int gid = off - (ptr[st] | ptr[st+1] << 8 | ptr[st+2] << 16 | ptr[st+3] << 24);
			switch (gid) {
				case 1: // horizontal floor, centered
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, y*th+th/2), cpv((x+1)*tw, y*th+th/2), 0.0f);
					break;
				case 2: // vertical floor, centered
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw+tw/2, y*th), cpv(x*tw+tw/2, (y+1)*th), 0.0f);
					break;
				case 3: // horizontal floor, top
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, (y+1)*th), cpv((x+1)*tw, (y+1)*th), 0.0f);
					break;
				case 4: // horizontal floor, bottom
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, y*th), cpv((x+1)*tw, y*th), 0.0f);
					break;
				case 5: // vertical floor, left
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, y*th), cpv(x*tw, (y+1)*th), 0.0f);
					break;
				case 6: // vertical floor, right
					segment = cpSegmentShapeNew(floorBody, cpv((x+1)*tw, y*th), cpv((x+1)*tw, (y+1)*th), 0.0f);
					break;
				case 7: // corner, bottom right
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, y*th), cpv((x+1)*tw, y*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					segment = cpSegmentShapeNew(floorBody, cpv((x+1)*tw, y*th), cpv((x+1)*tw, (y+1)*th), 0.0f);
					break;
				case 8: // corner, bottom left
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, y*th), cpv((x+1)*tw, y*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, y*th), cpv(x*tw, (y+1)*th), 0.0f);
					break;
				case 9: // corner, top right
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, y*th), cpv(x*tw, (y+1)*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, (y+1)*th), cpv((x+1)*tw, (y+1)*th), 0.0f);
					break;
				case 10: // corner, top left
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, y*th), cpv(x*tw, (y+1)*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, (y+1)*th), cpv((x+1)*tw, (y+1)*th), 0.0f);
					break;
				case 11: // top box (open on the bottom)
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, y*th), cpv(x*tw, (y+1)*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					segment = cpSegmentShapeNew(floorBody, cpv(x*tw, (y+1)*th), cpv((x+1)*tw, (y+1)*th), 0.0f);
					cpSpaceAddStaticShape(space, segment);
					segment = cpSegmentShapeNew(floorBody, cpv((x+1)*tw, y*th), cpv((x+1)*tw, (y+1)*th), 0.0f);
					break;
				default:
					segment = nil;
					break;
			}
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
	if ((tmp = rb_hash_aref(options, id_sc_map_width)) != Qnil) {
		map_width = FIX2INT(tmp);
	}
	if (tmp != Qnil && (tmp = rb_hash_aref(options, id_sc_map_height)) != Qnil) {
		map_height = FIX2INT(tmp);
	}
	if (tmp != Qnil && (tmp = rb_hash_aref(options, id_sc_tile_width)) != Qnil) {
		tile_width = FIX2INT(tmp);
	}
	if (tmp != Qnil && (tmp = rb_hash_aref(options, id_sc_tile_height)) != Qnil) {
		tile_height = FIX2INT(tmp);
	}
	if (tmp != Qnil && (tmp = rb_hash_aref(options, id_sc_starting_gid)) != Qnil) {
		starting_gid = FIX2INT(tmp);
	}
	if (tmp != Qnil && (tmp = rb_hash_aref(options, id_sc_data)) != Qnil) {
		Check_Type(tmp, T_STRING);
		unsigned char *data = (unsigned char *)RSTRING_PTR(tmp);
		add_floor_to_space(space, map_width, map_height, tile_width, tile_height, starting_gid, data, RSTRING_LEN(tmp));
	}
	if (tmp == Qnil) {
		rb_raise(rb_eArgError, "Missing required key in options");
	}
	return rb_space;
}

void init_rb_cSolidShapeMap() {
	rb_cSolidShapeMap = rb_define_class_under(rb_mCocos2D, "SolidShapeMap", rb_cObject);
	rb_define_singleton_method(rb_cSolidShapeMap, "create", rb_cSolidShapeMap_s_create, 2);
}
