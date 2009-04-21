//
//  SC_TextureNode.m
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

VALUE rb_cTextureNode;

VALUE rb_cTextureNode_s_new(VALUE klass) {
	TextureNode *node = [[TextureNode alloc] init];
	cocos_holder *ptr = malloc(sizeof(cocos_holder));
	ptr->_obj = node;
	VALUE rb_obj = common_init(klass, ptr, YES);
	rb_hash_aset(rb_object_hash, INT2FIX((long)node), rb_obj);

	return rb_obj;
}

void init_rb_cTextureNode() {
	rb_cTextureNode = rb_define_class_under(rb_mCocos2D, "TextureNode", rb_cCocosNode);
	rb_define_singleton_method(rb_cTextureNode, "new", rb_cTextureNode_s_new, 0);
}
