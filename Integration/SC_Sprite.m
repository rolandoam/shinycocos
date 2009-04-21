//
//  SC_Sprite.m
//  ShinyCocos
//
//  Created by Rolando Abarca on 4/13/09.
//  Copyright 2009 Games For Food SpA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ruby.h"
#import "SC_common.h"
#import "SC_CocosNode.h"
#import "SC_TextureNode.h"
#import "SC_Sprite.h"

VALUE rb_cSprite;

VALUE rb_cSprite_s_sprite_with_file(VALUE klass, VALUE filepath) {
	Check_Type(filepath, T_STRING);
	Sprite *obj = [Sprite spriteWithFile:[NSString stringWithCString:STR2CSTR(filepath) encoding:NSUTF8StringEncoding]];
	cocos_holder *ptr = malloc(sizeof(cocos_holder));
	ptr->_obj = obj;
	VALUE rb_obj = common_init(klass, ptr, NO);
	rb_hash_aset(rb_object_hash, INT2FIX((long)obj), rb_obj);

	return rb_obj;
}

void init_rb_cSprite() {
	rb_cSprite = rb_define_class_under(rb_mCocos2D, "Sprite", rb_cTextureNode);
	rb_define_singleton_method(rb_cSprite, "sprite_with_file", rb_cSprite_s_sprite_with_file, 1);
}
