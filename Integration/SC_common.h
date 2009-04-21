/*
 *  common.h
 *  ShinyCocos
 *
 *  Created by Rolando Abarca on 4/7/09.
 *  Copyright 2009 Games For Food SpA. All rights reserved.
 *
 */

#import <objc/runtime.h>
#import "ruby.h"
#import "cocos2d.h"
#import "chipmunk.h"

typedef struct {
	id _obj;
} cocos_holder;
#define GET_OBJC(ptr) ((cocos_holder *)ptr)->_obj

extern VALUE rb_mCocos2D;
extern VALUE rb_object_hash;

void common_free(void *ptr);
void common_free_no_release(void *ptr);
VALUE common_init(VALUE klass, cocos_holder *ptr, BOOL release_on_free);
VALUE common_rb_ns_log(int argc, VALUE *argv, VALUE module);
VALUE common_rb_set_accelerator_delegate(VALUE module);
void common_method_swap(Class cls, SEL orig, SEL repl, const char *signature);
