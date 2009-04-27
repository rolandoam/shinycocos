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

#include "SC_common.h"
#import "SC_AtlasSprite.h"
#import "SC_CocosNode.h"

VALUE rb_cAtlasSprite;

VALUE rb_cAtlasSprite_s_sprite(VALUE klass, VALUE opts) {
	Check_Type(opts, T_HASH);
	VALUE rb_manager = rb_hash_aref(opts, ID2SYM(rb_intern("manager")));
	VALUE rb_rect = rb_hash_aref(opts, ID2SYM(rb_intern("rect")));
	CGRect rect = common_sc_make_rect(rb_rect);
	
	cocos_holder *ptr, *ptr2;
	Data_Get_Struct(rb_manager, cocos_holder, ptr);
	AtlasSprite *sprite = [AtlasSprite spriteWithRect:rect spriteManager:ptr->_obj];
	ptr2 = ALLOC(cocos_holder);
	ptr2->_obj = sprite;
	VALUE ret = common_init(rb_cAtlasSprite, ptr2, NO);
	rb_hash_aset(rb_object_hash, INT2FIX((long)sprite), ret);
	return ret;
}

void init_rb_cAtlasSprite() {
#if 0
	rb_mCocos2D = rb_define_module("Cocos2D");
#endif
	rb_cAtlasSprite = rb_define_class_under(rb_mCocos2D, "AtlasSprite", rb_cCocosNode);
	rb_define_singleton_method(rb_cAtlasSprite, "sprite", rb_cAtlasSprite_s_sprite, 1);
}

#pragma mark AtlasAnimation

VALUE rb_cAtlasAnimation_s_animation(VALUE klass, VALUE opts) {
	Check_Type(opts, T_HASH);
	VALUE rb_name   = rb_hash_aref(opts, ID2SYM(rb_intern("name")));
	VALUE rb_delay  = rb_hash_aref(opts, ID2SYM(rb_intern("delay")));
	VALUE rb_frames = rb_hash_aref(opts, ID2SYM(rb_intern("frames")));
	AtlasAnimation *anim;
	if (rb_frames == Qnil) {
	} else {
	}
	return Qnil;
}
/*
animation.add(frame, rect)
*/
VALUE rb_cAtlasAnimation_add(VALUE obj, VALUE frame, VALUE rect);
void init_rb_cAtlasAnimation();
