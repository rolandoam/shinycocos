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
VALUE common_rb_set_acceleration_delegate(VALUE module, VALUE obj);
void common_method_swap(Class cls, SEL orig, SEL repl, const char *signature);

static inline CGRect common_sc_make_rect(VALUE rb_rect) {
	Check_Type(rb_rect, T_ARRAY);
	if (FIX2INT(rb_funcall(rb_rect, rb_intern("length"), 0)) < 4) {
		rb_raise(rb_eArgError, "rect must be of at least 4 elements");
	}
	return CGRectMake(
		NUM2DBL(rb_ary_entry(rb_rect, 0)),
		NUM2DBL(rb_ary_entry(rb_rect, 1)),
		NUM2DBL(rb_ary_entry(rb_rect, 2)),
		NUM2DBL(rb_ary_entry(rb_rect, 3))
	);
}