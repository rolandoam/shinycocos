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
#import "SC_common.h"
#import "SC_CocosNode.h"
#import "SC_TiledMap.h"

@interface SC_TiledMap : AtlasNode {
	int width_;
	int height_;
	int itemsToRender;
	NSData *data_;
}
- (void)calculateItemsToRender:(NSData *)data;
- (void)updateAtlasValueAt:(ccGridSize)pos withValue:(NSUInteger)value withIndex:(int)idx;
- (void)updateAtlasValues;
@end

@implementation SC_TiledMap
- (id)initWithFile:(NSString *)tiles tileWidth:(int)tileWidth tileHeight:(int)tileHeight mapWidth:(int)width mapHeight:(int)height data:(NSData *)data {
	[self calculateItemsToRender:data];
	if (self = [super initWithTileFile:tiles tileWidth:tileWidth tileHeight:tileHeight itemsToRender:itemsToRender]) {
		width_ = width;
		height_ = height;
		data_ = [data retain];
		[self updateAtlasValues];
	}
	return self;
}

- (void)calculateItemsToRender:(NSData *)data {
	unsigned char* ptr = (unsigned char *)[data bytes];
	NSUInteger total = [data length];
	int i;
	itemsToRender = 0;
	for (i=0; i < total; i += 4) {
		NSUInteger value = ptr[i] | ptr[i+1] << 8 | ptr[i+2] << 16 | ptr[i+3] << 24;
		if (value)
			itemsToRender++;
	}
}

/*
 * just like the method with the same signature on TileMapAtlas.m, but works with data
 */
- (void)updateAtlasValueAt:(ccGridSize)pos withValue:(NSUInteger)value withIndex:(int)idx {
	ccQuad2 texCoord;
	ccQuad3 vertex;
	int x = pos.x;
	int y = pos.y;
	float row = (value % itemsPerRow) * texStepX;
	float col = (value / itemsPerRow) * texStepY;
	
	texCoord.bl_x = row;							// A - x
	texCoord.bl_y = col;							// A - y
	texCoord.br_x = row + texStepX;					// B - x
	texCoord.br_y = col;							// B - y
	texCoord.tl_x = row;							// C - x
	texCoord.tl_y = col + texStepY;					// C - y
	texCoord.tr_x = row + texStepX;					// D - x
	texCoord.tr_y = col + texStepY;					// D - y
	
	vertex.bl_x = (int) (x * itemWidth);				// A - x
	vertex.bl_y = (int) (y * itemHeight);				// A - y
	vertex.bl_z = 0.0f;									// A - z
	vertex.br_x = (int)(x * itemWidth + itemWidth);		// B - x
	vertex.br_y = (int)(y * itemHeight);				// B - y
	vertex.br_z = 0.0f;									// B - z
	vertex.tl_x = (int)(x * itemWidth);					// C - x
	vertex.tl_y = (int)(y * itemHeight + itemHeight);	// C - y
	vertex.tl_z = 0.0f;									// C - z
	vertex.tr_x = (int)(x * itemWidth + itemWidth);		// D - x
	vertex.tr_y = (int)(y * itemHeight + itemHeight);	// D - y
	vertex.tr_z = 0.0f;									// D - z
	
	[textureAtlas updateQuadWithTexture:&texCoord vertexQuad:&vertex atIndex:idx];
}

- (void)updateAtlasValues {
	int total = 0, x, y;

	unsigned char* ptr = (unsigned char *)[data_ bytes];
	for(y = 0; y < height_; y++ ) {
		for(x = 0; x < width_; x++ ) {
			if (total < itemsToRender) {
				NSUInteger st = y*4*width_ + x*4;
				NSUInteger value = ptr[st] | ptr[st+1] << 8 | ptr[st+2] << 16 | ptr[st+3] << 24;
				if(value != 0) {
					[self updateAtlasValueAt:ccg(x, (height_ - 1) - y) withValue:value-1 withIndex:total];
					total++;
				}
			}
		} // x
	} // y
}

- (void)dealloc {
	[super dealloc];
	[data_ release];
}
@end

#pragma mark RUBY

VALUE rb_cTiledMap;

/*
 * call-seq:
 *   tm = TiledMap.new(opts)   #=> new TiledMap
 *
 * Required options:
 *
 * * <tt>:tiles</tt> String, tiles file (png or pvr)
 * * <tt>:tile_width</tt> Integer, the given tile width
 * * <tt>:tile_height</tt> Integer, the given tile height
 * * <tt>:map_width</tt> Integer, the map width
 * * <tt>:map_height</tt> Integer, the map height
 * * <tt>:data</tt> String, the decoded data (not the Base64 string)
 */ 
VALUE rb_cTiledMap_s_new(VALUE klass, VALUE opts) {
	Check_Type(opts, T_HASH);
	NSUInteger tileWidth, tileHeight, mapWidth, mapHeight;
	NSString *tileFile;
	NSData *data;
	
	VALUE tmp = rb_hash_aref(opts, ID2SYM(id_sc_tile_width));
	VALUE obj = Qnil;
	
	if (tmp != Qnil)
		tileWidth = FIX2INT(tmp);
	if (tmp != Qnil && (tmp = rb_hash_aref(opts, ID2SYM(id_sc_tile_height))) != Qnil)
		tileHeight = FIX2INT(tmp);
	if (tmp != Qnil && (tmp = rb_hash_aref(opts, ID2SYM(id_sc_map_width))) != Qnil)
		mapWidth = FIX2INT(tmp);
	if (tmp != Qnil && (tmp = rb_hash_aref(opts, ID2SYM(id_sc_map_height))) != Qnil)
		mapHeight = FIX2INT(tmp);
	if (tmp != Qnil && (tmp = rb_hash_aref(opts, ID2SYM(id_sc_tiles))) != Qnil)
		tileFile = [NSString stringWithUTF8String:StringValueCStr(tmp)];
	if (tmp != Qnil && (tmp = rb_hash_aref(opts, ID2SYM(id_sc_data))) != Qnil) {
		data = [[NSData alloc] initWithBytes:RSTRING_PTR(tmp) length:RSTRING_LEN(tmp)];
		// init the objc counterpart
		SC_TiledMap *tm = [[SC_TiledMap alloc] initWithFile:tileFile tileWidth:tileWidth tileHeight:tileHeight mapWidth:mapWidth mapHeight:mapHeight data:data];
		[data release];
		obj = sc_init(rb_cTiledMap, nil, tm, 0, 0, YES);
	}
	
	if (tmp == Qnil)
		rb_raise(rb_eArgError, "Invalid Options");
	return obj;
}

void init_rb_cTiledMap() {
	// FIXME:
	// TileMap should be a subclass of AtlasNode, which is not implemented yet
	rb_cTiledMap = rb_define_class_under(rb_mCocos2D, "TiledMap", rb_cCocosNode);
	rb_define_singleton_method(rb_cTiledMap, "new", rb_cTiledMap_s_new, 1);
}
