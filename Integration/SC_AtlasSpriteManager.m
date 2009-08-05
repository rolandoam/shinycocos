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
#import "SC_AtlasSpriteManager.h"
#import "SC_AtlasSprite.h"
#import "SC_CocosNode.h"

VALUE rb_cAtlasSpriteManager;

/* 
 * Must complete doc
 */
VALUE rb_cAtlasSpriteManager_s_new(int argc, VALUE *argv, VALUE klass) {
	AtlasSpriteManager *manager;
	if (argc < 1)
		rb_raise(rb_eArgError, "invalid number of arguments");
	
	Check_Type(argv[0], T_STRING);
	NSString *file = [NSString stringWithCString:StringValueCStr(argv[0]) encoding:NSUTF8StringEncoding];
	if (argc == 1) {
		manager = [[AtlasSpriteManager alloc] initWithFile:file capacity:29];
	} else {
		Check_Type(argv[1], T_HASH);
		VALUE cap = rb_hash_aref(argv[1], sym_sc_capacity);
		if (cap == Qnil)
			rb_raise(rb_eArgError, "no :capacity key in hash");
		manager = [[AtlasSpriteManager alloc] initWithFile:file capacity:FIX2INT(cap)];
	}
	VALUE obj = sc_init(klass, nil, manager, 0, 0, YES);
	manager.userData = (void *)obj;
	return obj;
}

/* 
 * Must complete doc
 */
VALUE rb_cAtlasSpriteManager_create_sprite(VALUE obj, VALUE rb_rect) {
	CGRect rect = sc_make_rect(rb_rect);
	// create the sprite
	AtlasSprite* sprite = [CC_ATLAS_SPRITE_MNG(obj) createSpriteWithRect:rect];
	// return the sprite as a ruby object
	VALUE ret = sc_init(rb_cAtlasSprite, nil, sprite, 0, 0, NO);
	sprite.userData = (void *)ret;
	return ret;
}


/*
 * call-seq:
 *   manager.antialias(true)   #=> true/false
 *
 * turn on/off the antialias texParams of the texture
 */
VALUE rb_cAtlasSpriteManager_antialias(VALUE obj, VALUE alias) {
	if (alias != Qfalse)
		[CC_ATLAS_SPRITE_MNG(obj).textureAtlas.texture setAntiAliasTexParameters];
	else
		[CC_ATLAS_SPRITE_MNG(obj).textureAtlas.texture setAliasTexParameters];
	return (alias != Qfalse);
}


void init_rb_cAtlasSpriteManager() {
	rb_cAtlasSpriteManager = rb_define_class_under(rb_mCocos2D, "AtlasSpriteManager", rb_cCocosNode);
	rb_define_singleton_method(rb_cAtlasSpriteManager, "new", rb_cAtlasSpriteManager_s_new, -1);
	rb_define_method(rb_cAtlasSpriteManager, "create_sprite", rb_cAtlasSpriteManager_create_sprite, 1);
	rb_define_method(rb_cAtlasSpriteManager, "antialias", rb_cAtlasSpriteManager_antialias, 1);
}
