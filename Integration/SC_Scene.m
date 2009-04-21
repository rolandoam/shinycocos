//
//  SC_Scene.m
//  ShinyCocos
//
//  Created by Rolando Abarca on 4/11/09.
//  Copyright 2009 Games For Food SpA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ruby.h"
#import "SC_common.h"
#import "SC_CocosNode.h"
#import "SC_Scene.h"

VALUE rb_cScene;

VALUE rb_cScene_s_new(VALUE klass) {
	Scene *obj = [[Scene alloc] init];
	cocos_holder *ptr = malloc(sizeof(cocos_holder));
	ptr->_obj = obj;
	VALUE rb_obj = common_init(klass, ptr, YES);
	rb_hash_aset(rb_object_hash, INT2FIX((long)obj), rb_obj);

	return rb_obj;
}

void init_rb_cScene() {
	rb_cScene = rb_define_class_under(rb_mCocos2D, "Scene", rb_cCocosNode);
	rb_define_singleton_method(rb_cScene, "new", rb_cScene_s_new, 0);
}
