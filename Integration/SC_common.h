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
#define CC_NODE(ptr) ((CocosNode *)ptr->_obj)

extern VALUE rb_mCocos2D;
extern VALUE sc_acc_delegate;
extern NSMutableDictionary *sc_object_hash;
extern NSMutableDictionary *sc_schedule_methods;
extern NSMutableDictionary *sc_handler_hash;
extern id accDelegate;

VALUE sc_init(VALUE klass, cocos_holder **ret_ptr, id object, int argc, VALUE *argv, BOOL release_on_free);
void  sc_method_swap(Class cls, SEL orig, SEL repl);

static inline CGRect sc_make_rect(VALUE rb_rect) {
	Check_Type(rb_rect, T_ARRAY);
	if (RARRAY_LEN(rb_rect) < 4) {
		rb_raise(rb_eArgError, "rect must be of at least 4 elements");
	}
	return CGRectMake(
		NUM2DBL(RARRAY_PTR(rb_rect)[0]),
		NUM2DBL(RARRAY_PTR(rb_rect)[1]),
		NUM2DBL(RARRAY_PTR(rb_rect)[2]),
		NUM2DBL(RARRAY_PTR(rb_rect)[3])
	);
}

/*
 * link an ruby object with an objective C one, throught a hash table
 */
static inline void sc_add_tracking(NSMutableDictionary *hash, id obj1, VALUE obj2) {
	[hash setObject:[NSValue valueWithPointer:(void *)obj2] forKey:[NSValue valueWithPointer:obj1]];
}


/*
 * remove tracking for a given object
 */
static inline void sc_remove_tracking_for(NSMutableDictionary *hash, id obj1) {
	[hash removeObjectForKey:[NSValue valueWithPointer:obj1]];
}

/*
 * get a ruby object associated to the ObjC-Object
 */
static inline VALUE sc_ruby_instance_for(NSMutableDictionary *hash, id obj1) {
	NSValue *v = [hash objectForKey:[NSValue valueWithPointer:obj1]];
	if (v == nil)
		return Qnil;
	return (VALUE)[v pointerValue];
}

#define INSPECT(obj) rb_funcall(obj, rb_intern("inspect"), 0, 0)
#define RBCALL(obj, func) rb_funcall(obj, rb_intern(func), 0, 0)
