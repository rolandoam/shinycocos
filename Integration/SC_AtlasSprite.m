//
//  SC_CocosNode.h
//  ShinyCocos
//
//  Created by Rolando Abarca on 4/11/09.
//  Copyright 2009 Games For Food SpA. All rights reserved.
//

#import "SC_common.h"
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
	rb_cAtlasSprite = rb_define_class_under(rb_mCocos2D, "AtlasSprite", rb_cCocosNode);
	rb_define_singleton_method(rb_cAtlasSprite, "sprite", rb_cAtlasSprite_s_sprite, 1);
}
