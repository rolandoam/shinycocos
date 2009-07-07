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
#import "SC_ids.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "SC_AVAudioPlayer.h"

typedef struct {
	id _obj;
} cocos_holder;

#define SC_GETTER_TEMPLATE(funcname, type) \
static inline type *funcname(VALUE obj) { \
	cocos_holder *ptr; \
	Data_Get_Struct(obj, cocos_holder, ptr);\
	return (type *)(ptr->_obj);\
}
static inline id sc_get_objc(VALUE obj) {
	cocos_holder *ptr;
	Data_Get_Struct(obj, cocos_holder, ptr);
	return (ptr->_obj);
}
SC_GETTER_TEMPLATE(CC_NODE, CocosNode)
SC_GETTER_TEMPLATE(CC_PXNODE, ParallaxNode)
SC_GETTER_TEMPLATE(CC_LAYER, Layer)
SC_GETTER_TEMPLATE(CC_MENU, Menu)
SC_GETTER_TEMPLATE(CC_SPRITE, Sprite)
SC_GETTER_TEMPLATE(CC_SCENE, Scene)
SC_GETTER_TEMPLATE(CC_ACTION, Action)
SC_GETTER_TEMPLATE(CC_ATLAS_ANIMATION, AtlasAnimation)
SC_GETTER_TEMPLATE(CC_ATLAS_SPRITE, AtlasSprite)
SC_GETTER_TEMPLATE(CC_ATLAS_SPRITE_MNG, AtlasSpriteManager)
SC_GETTER_TEMPLATE(CC_LABEL, Label)
SC_GETTER_TEMPLATE(CC_TRANS, TransitionScene)
SC_GETTER_TEMPLATE(UI_TFIELD, UITextField)
SC_GETTER_TEMPLATE(UI_SLIDER, UISlider)
SC_GETTER_TEMPLATE(AV_PLAYER, RBAudioPlayer)
SC_GETTER_TEMPLATE(CC_BMFONT, BitmapFontAtlas)

#define INSPECT(obj) sc_protect_funcall(obj, id_sc_inspect, 0, 0)
#define RBCALL(obj, func) sc_protect_funcall(obj, rb_intern(func), 0, 0)

extern VALUE rb_mCocos2D;
extern VALUE sc_acc_delegate;
extern NSMutableDictionary *sc_object_hash;
extern NSMutableDictionary *sc_schedule_methods;
extern NSMutableDictionary *sc_handler_hash;
extern id accDelegate;

VALUE sc_init(VALUE klass, cocos_holder **ret_ptr, id object, int argc, VALUE *argv, BOOL release_on_free);
VALUE rb_hash_with_touch(UITouch *touch);
VALUE rb_ary_with_set(NSSet *touches);
VALUE sc_protect_funcall(VALUE recv, ID mid, int n, ...);
void  sc_error(int state);
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
static inline void sc_remove_tracking_for(NSMutableDictionary *hash, CocosNode *obj1) {
	[hash removeObjectForKey:[NSValue valueWithPointer:obj1]];
}

/*
 * get a ruby object associated to the ObjC-Object
 */
static inline VALUE sc_ruby_instance_for(NSMutableDictionary *hash, id obj1) {
	NSValue *v = [hash objectForKey:[NSValue valueWithPointer:obj1]];
	if (v == nil) {
		return Qnil;
	}
	VALUE rv = (VALUE)[v pointerValue];
	if (TYPE(rv) != T_NONE) {
		return rv;
	}
	// should never reach this
	NSLog(@"probably trying to call a hook on a dead ruby object: %@ (%d,%d,%d)",
		obj1,
		hash == sc_object_hash,
		hash == sc_handler_hash,
		hash == sc_schedule_methods);
	return Qnil;
}
