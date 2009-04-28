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
extern VALUE rb_acc_delegate;
extern id accDelegate;

void common_free(void *ptr);
void common_free_no_release(void *ptr);
VALUE common_init(VALUE klass, cocos_holder **ret_ptr, id object, BOOL release_on_free);
VALUE common_rb_ns_log(int argc, VALUE *argv, VALUE module);
VALUE common_rb_set_acceleration_delegate(VALUE module, VALUE obj);
void common_method_swap(Class cls, SEL orig, SEL repl);

static inline CGRect common_sc_make_rect(VALUE rb_rect) {
	Check_Type(rb_rect, T_ARRAY);
	if (RARRAY(rb_rect)->len < 4) {
		rb_raise(rb_eArgError, "rect must be of at least 4 elements");
	}
	return CGRectMake(
		NUM2DBL(RARRAY(rb_rect)->ptr[0]),
		NUM2DBL(RARRAY(rb_rect)->ptr[1]),
		NUM2DBL(RARRAY(rb_rect)->ptr[2]),
		NUM2DBL(RARRAY(rb_rect)->ptr[3])
	);
}
#define INSPECT(obj) rb_funcall(obj, rb_intern("inspect"), 0)
#define RBCALL(obj, func) rb_funcall(obj, rb_intern(func), 0)
