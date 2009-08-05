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
		int value = ptr[i] | ptr[i+1] << 8 | ptr[i+2] << 16 | ptr[i+3] << 24;
		if (value) {
			itemsToRender++;
		}
	}
}

/*
 * just like the method with the same signature on TileMapAtlas.m, but works with data
 */
- (void)updateAtlasValueAt:(ccGridSize)pos withValue:(NSUInteger)value withIndex:(int)idx {
	ccV3F_C4B_T2F_Quad quad;
	int x = pos.x;
	int y = pos.y;
	float row = (value % itemsPerRow) * texStepX;
	float col = (value / itemsPerRow) * texStepY;
	
	quad.tl.texCoords.u = row;
	quad.tl.texCoords.v = col;
	quad.tr.texCoords.u = row + texStepX;
	quad.tr.texCoords.v = col;
	quad.bl.texCoords.u = row;
	quad.bl.texCoords.v = col + texStepY;
	quad.br.texCoords.u = row + texStepX;
	quad.br.texCoords.v = col + texStepY;
	
	quad.bl.vertices.x = (int) (x * itemWidth);
	quad.bl.vertices.y = (int) (y * itemHeight);
	quad.bl.vertices.z = 0.0f;
	quad.br.vertices.x = (int)(x * itemWidth + itemWidth);
	quad.br.vertices.y = (int)(y * itemHeight);
	quad.br.vertices.z = 0.0f;
	quad.tl.vertices.x = (int)(x * itemWidth);
	quad.tl.vertices.y = (int)(y * itemHeight + itemHeight);
	quad.tl.vertices.z = 0.0f;
	quad.tr.vertices.x = (int)(x * itemWidth + itemWidth);
	quad.tr.vertices.y = (int)(y * itemHeight + itemHeight);
	quad.tr.vertices.z = 0.0f;
	
	[textureAtlas_ updateQuad:&quad atIndex:idx];
}

- (void)updateAtlasValues {
	int total = 0, x, y;

	unsigned char* ptr = (unsigned char *)[data_ bytes];
	for(y = 0; y < height_; y++ ) {
		for(x = 0; x < width_; x++ ) {
			if (total < itemsToRender) {
				NSUInteger st = y*4*width_ + x*4;
				int value = ptr[st] | ptr[st+1] << 8 | ptr[st+2] << 16 | ptr[st+3] << 24;
				if(value > 0) {
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
 * <tt>:tiles</tt>:: String, tiles file (png or pvr)
 * <tt>:tile_width</tt>:: Integer, the given tile width
 * <tt>:tile_height</tt>:: Integer, the given tile height
 * <tt>:map_width</tt>:: Integer, the map width
 * <tt>:map_height</tt>:: Integer, the map height
 * <tt>:data</tt>:: String, the decoded data (not the Base64 string)
 */ 
VALUE rb_cTiledMap_s_new(VALUE klass, VALUE opts) {
	Check_Type(opts, T_HASH);
	NSUInteger tileWidth, tileHeight, mapWidth, mapHeight;
	NSString *tileFile;
	NSData *data;
	
	VALUE tmp = rb_hash_aref(opts, sym_sc_tile_width);
	VALUE obj = Qnil;
	
	if (tmp != Qnil)
		tileWidth = FIX2INT(tmp);
	if (tmp != Qnil && (tmp = rb_hash_aref(opts, sym_sc_tile_height)) != Qnil)
		tileHeight = FIX2INT(tmp);
	if (tmp != Qnil && (tmp = rb_hash_aref(opts, sym_sc_map_width)) != Qnil)
		mapWidth = FIX2INT(tmp);
	if (tmp != Qnil && (tmp = rb_hash_aref(opts, sym_sc_map_height)) != Qnil)
		mapHeight = FIX2INT(tmp);
	if (tmp != Qnil && (tmp = rb_hash_aref(opts, sym_sc_tiles)) != Qnil)
		tileFile = [NSString stringWithUTF8String:StringValueCStr(tmp)];
	if (tmp != Qnil && (tmp = rb_hash_aref(opts, sym_sc_data)) != Qnil) {
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
