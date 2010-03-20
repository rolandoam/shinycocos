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
 * call-seq:
 *   sprite = AtlasSprite.new(:rect => [left, top, width, height], :manager => manager) #=>   AtlasSprite
 *
 * creates a new AtlasSprite
 */
VALUE rb_cAtlasSprite_s_new(int argc, VALUE *argv, VALUE klass) {
	if (argc < 1) {
		rb_raise(rb_eArgError, "Invalid number of arguments");
	}
	Check_Type(argv[0], T_HASH);
	VALUE rb_manager = rb_hash_aref(argv[0], sym_sc_manager);
	VALUE rb_rect = rb_hash_aref(argv[0], sym_sc_rect);
	CGRect rect = sc_make_rect(rb_rect);
	
	cocos_holder *ptr;
	Data_Get_Struct(rb_manager, cocos_holder, ptr);
	AtlasSprite *sprite = [[AtlasSprite alloc] initWithRect:rect spriteManager:ptr->_obj];
	VALUE ret = sc_init(klass, nil, sprite, argc-1, argv+1, YES);
	sprite.userData = (void *)ret;
	return ret;
}


/*
 * call_seq:
 *   atlas_sprite.texture_rect = [left, top, width, height]  #=> rect
 *
 * Sets the new texture rect
 */
VALUE rb_cAtlasSprite_set_texture_rect(VALUE obj, VALUE rect) {
	Check_Type(rect, T_ARRAY);
	CC_ATLAS_SPRITE(obj).textureRect = sc_make_rect(rect);
	return rect;
}


/*
 * call-seq:
 *   atlas_sprite.flip_x   #=> true/false
 *
 * returns whether or not the sprite is flipped on X axis
 */
VALUE rb_cCocosNode_flip_x(VALUE obj) {
	return CC_ATLAS_SPRITE(obj).flipX ? Qtrue : Qfalse;
}


/*
 * call-seq:
 *   atlas_sprite.flip_y   #=> true/false
 *
 * returns whether or not the sprite is flipped on Y axis
 */
VALUE rb_cCocosNode_flip_y(VALUE obj) {
	return CC_ATLAS_SPRITE(obj).flipY ? Qtrue : Qfalse;
}


/*
 * call-seq:
 *   atlas_sprite.flip_x = true   #=> true/false
 *
 * sets the flip_x property on the sprite
 */
VALUE rb_cCocosNode_set_flip_x(VALUE obj, VALUE flip) {
	CC_ATLAS_SPRITE(obj).flipX = (flip != Qfalse ? YES : NO);
	return flip;
}


/*
 * call-seq:
 *   atlas_sprite.flip_y = true   #=> true/false
 *
 * sets the flip_y property on the sprite
 */
VALUE rb_cCocosNode_set_flip_y(VALUE obj, VALUE flip) {
	CC_ATLAS_SPRITE(obj).flipY = (flip != Qfalse ? YES : NO);
	return flip;
}

void init_rb_cAtlasSprite() {
	rb_cAtlasSprite = rb_define_class_under(rb_mCocos2D, "AtlasSprite", rb_cCocosNode);
	rb_define_singleton_method(rb_cAtlasSprite, "new", rb_cAtlasSprite_s_new, -1);
	rb_define_method(rb_cAtlasSprite, "texture_rect=", rb_cAtlasSprite_set_texture_rect, 1);
	rb_define_method(rb_cCocosNode, "flip_x", rb_cCocosNode_flip_x, 0);
	rb_define_method(rb_cCocosNode, "flip_y", rb_cCocosNode_flip_y, 0);
	rb_define_method(rb_cCocosNode, "flip_x=", rb_cCocosNode_set_flip_x, 1);
	rb_define_method(rb_cCocosNode, "flip_y=", rb_cCocosNode_set_flip_y, 1);
}

#pragma mark AtlasAnimation

/*
 * call-seq:
 *   animation = AltasAnimation.new(:name => "name", :delay => 1/60.0, :frames => [frame1, frame2])
 *
 * Frames is optional
 */
VALUE rb_cAtlasAnimation_s_new(VALUE klass, VALUE opts) {
	Check_Type(opts, T_HASH);
	VALUE rb_name   = rb_hash_aref(opts, sym_sc_name);
	VALUE rb_delay  = rb_hash_aref(opts, sym_sc_delay);
	VALUE rb_frames = rb_hash_aref(opts, sym_sc_frames);
	AtlasAnimation *anim;
	if (rb_frames == Qnil) {
		anim = [[AtlasAnimation alloc] initWithName:[NSString stringWithCString:StringValueCStr(rb_name) encoding:NSUTF8StringEncoding] delay:NUM2DBL(rb_delay)];
	} else {
	}
	VALUE ret = sc_init(klass, nil, anim, 0, 0, YES);
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
	[CC_ATLAS_ANIMATION(obj) addFrameWithRect:sc_make_rect(rect)];
	return rect;
}

void init_rb_cAtlasAnimation() {
	rb_cAtlasAnimation = rb_define_class_under(rb_mCocos2D, "AtlasAnimation", rb_cObject);
	rb_define_singleton_method(rb_cAtlasAnimation, "new", rb_cAtlasAnimation_s_new, 1);
	rb_define_method(rb_cAtlasAnimation, "add_frame", rb_cAtlasAnimation_add_frame, 1);
}
