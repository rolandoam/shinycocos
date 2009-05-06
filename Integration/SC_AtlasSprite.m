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
#import "SC_AtlasSprite.h"
#import "SC_CocosNode.h"

VALUE rb_cAtlasSprite;
VALUE rb_cAtlasAnimation;

/*
 *   sprite = AtlasSprite.sprite_with_options(:rect => [top, left, width, height], :manager => manager)
 */
VALUE rb_cAtlasSprite_s_sprite(VALUE klass, VALUE opts) {
	Check_Type(opts, T_HASH);
	VALUE rb_manager = rb_hash_aref(opts, ID2SYM(rb_intern("manager")));
	VALUE rb_rect = rb_hash_aref(opts, ID2SYM(rb_intern("rect")));
	CGRect rect = common_sc_make_rect(rb_rect);
	
	cocos_holder *ptr;
	Data_Get_Struct(rb_manager, cocos_holder, ptr);
	AtlasSprite *sprite = [AtlasSprite spriteWithRect:rect spriteManager:ptr->_obj];
	VALUE ret = common_init(klass, nil, sprite, 0, 0, NO);
	rb_hash_aset(rb_object_hash, INT2FIX((long)sprite), ret);
	return ret;
}

void init_rb_cAtlasSprite() {
	rb_cAtlasSprite = rb_define_class_under(rb_mCocos2D, "AtlasSprite", rb_cCocosNode);
	rb_define_singleton_method(rb_cAtlasSprite, "sprite", rb_cAtlasSprite_s_sprite, 1);
}

#pragma mark AtlasAnimation

/*
 * frames is optional
 * 
 *   animation = AltasAnimation.animation(:name => "name", :delay => 1/60.0, :frames => [frame1, frame2])
 */
VALUE rb_cAtlasAnimation_s_animation(VALUE klass, VALUE opts) {
	Check_Type(opts, T_HASH);
	VALUE rb_name   = rb_hash_aref(opts, ID2SYM(rb_intern("name")));
	VALUE rb_delay  = rb_hash_aref(opts, ID2SYM(rb_intern("delay")));
	VALUE rb_frames = rb_hash_aref(opts, ID2SYM(rb_intern("frames")));
	AtlasAnimation *anim;
	if (rb_frames == Qnil) {
		anim = [[AtlasAnimation alloc] initWithName:[NSString stringWithCString:StringValueCStr(rb_name) encoding:NSUTF8StringEncoding] delay:NUM2DBL(rb_delay)];
	} else {
	}
	VALUE ret = common_init(klass, nil, anim, 0, 0, YES);
	if (rb_block_given_p()) {
		rb_yield(ret);
	}
	return ret;
}

/*
 *   animation.add_frame(rect) #=> rect
 * 
 * rect is an array that will be converted to a CGRect
 */
VALUE rb_cAtlasAnimation_add_frame(VALUE obj, VALUE rect) {
	cocos_holder *ptr;
	Data_Get_Struct(obj, cocos_holder, ptr);
	[GET_OBJC(ptr) addFrameWithRect:common_sc_make_rect(rect)];

	return rect;
}

void init_rb_cAtlasAnimation() {
	rb_cAtlasAnimation = rb_define_class_under(rb_mCocos2D, "AtlasAnimation", rb_cObject);
	rb_define_singleton_method(rb_cAtlasAnimation, "animation", rb_cAtlasAnimation_s_animation, 1);
	rb_define_method(rb_cAtlasAnimation, "add_frame", rb_cAtlasAnimation_add_frame, 1);
}
