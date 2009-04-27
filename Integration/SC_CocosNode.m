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

#import <Foundation/Foundation.h>
#import "ruby.h"
#import "SC_common.h"
#import "SC_CocosNode.h"

#pragma mark CocosNode extension

@interface CocosNode (SC_Extension)
- (id)rb_init;
- (void)rb_dealloc;
// actions
- (void)rb_on_enter;
- (void)rb_on_exit;
- (void)rb_draw;
- (void)rb_transform;
@end

@implementation CocosNode (SC_Extension)
- (id)rb_init {
	self = [self rb_init]; // will call the old init
	return self;
}

- (void)rb_dealloc {
	[self rb_dealloc]; // will call the old dealloc
	// remove the object from the object hash
	rb_funcall(rb_object_hash, rb_intern("delete"), 1, INT2FIX((long)self));
}

- (void)rb_on_enter {
	[self rb_on_enter];
	// call the ruby version
	VALUE rb_obj = rb_hash_aref(rb_object_hash, INT2FIX((long)self));
//	cocos_holder *ptr;
//	NSAssert(self == GET_OBJC(ptr), @"Invalid pointer from rb_object!");
	rb_funcall(rb_obj, rb_intern("on_enter"), 0, 0);
}

- (void)rb_on_exit {
	[self rb_on_exit];
	// call the ruby version
	VALUE rb_obj = rb_hash_aref(rb_object_hash, INT2FIX((long)self));
//	cocos_holder *ptr;
//	NSAssert(self == GET_OBJC(ptr), @"Invalid pointer from rb_object!");
	rb_funcall(rb_obj, rb_intern("on_exit"), 0, 0);
}

- (void)rb_draw {
	[self rb_draw];
}

- (void)rb_transform {
	[self rb_transform];
}
@end

VALUE rb_cCocosNode;

# pragma mark Properties

VALUE rb_cCocosNode_z_order(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return INT2FIX(((CocosNode *)GET_OBJC(ptr)).zOrder);
}

VALUE rb_cCocosNode_rotation(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(((CocosNode *)GET_OBJC(ptr)).rotation);
}

VALUE rb_cCocosNode_set_rotation(VALUE object, VALUE rotation) {
	cocos_holder *ptr;
	Check_Type(rotation, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).rotation = NUM2DBL(rotation);
	return rotation;
}

VALUE rb_cCocosNode_scale(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(((CocosNode *)GET_OBJC(ptr)).scale);
}

VALUE rb_cCocosNode_set_scale(VALUE object, VALUE scale) {
	cocos_holder *ptr;
	Check_Type(scale, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).scale = NUM2DBL(scale);
	return scale;
}

VALUE rb_cCocosNode_scale_x(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(((CocosNode *)GET_OBJC(ptr)).scaleX);
}

VALUE rb_cCocosNode_set_scale_x(VALUE object, VALUE scale_x) {
	cocos_holder *ptr;
	Check_Type(scale_x, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).scaleY = NUM2DBL(scale_x);
	return scale_x;
}

VALUE rb_cCocosNode_scale_y(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(((CocosNode *)GET_OBJC(ptr)).scaleY);
}

VALUE rb_cCocosNode_set_scale_y(VALUE object, VALUE scale_y) {
	cocos_holder *ptr;
	Check_Type(scale_y, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).scaleY = NUM2DBL(scale_y);
	return scale_y;
}

VALUE rb_cCocosNode_position(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	cpVect v = ((CocosNode *)GET_OBJC(ptr)).position;
	return rb_ary_new3(2, v.x, v.y);
}

VALUE rb_cCocosNode_set_position(VALUE object, VALUE position) {
	cocos_holder *ptr;
	Check_Type(position, T_ARRAY);
	if (FIX2INT(rb_funcall(position, rb_intern("size"), 0, 0)) == 2) {
		Data_Get_Struct(object, cocos_holder, ptr);
		((CocosNode *)GET_OBJC(ptr)).position = cpv(FIX2INT(rb_ary_entry(position, 0)), FIX2INT(rb_ary_entry(position, 1)));
		return position;
	} else {
		NSLog(@"Invalid array size for position");
		return Qnil;
	}
}

VALUE rb_cCocosNode_visible(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return ((CocosNode *)GET_OBJC(ptr)).visible ? Qtrue : Qfalse;
}

VALUE rb_cCocosNode_set_visible(VALUE object, VALUE visible) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).visible = (visible == Qfalse) ? NO : YES;
	return (visible == Qfalse) ? Qfalse : Qtrue;
}

VALUE rb_cCocosNode_tag(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return INT2FIX(((CocosNode *)GET_OBJC(ptr)).tag);
}

VALUE rb_cCocosNode_set_tag(VALUE object, VALUE tag) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).tag = FIX2INT(tag);
	return tag;
}

#pragma mark Methods

VALUE rb_cCocosNode_s_node(VALUE klass) {
	CocosNode *node = [CocosNode node];
	cocos_holder *ptr = ALLOC(cocos_holder);
	ptr->_obj = node;
	VALUE obj = common_init(klass, ptr, NO);
	// add the pointer to the object hash
	rb_hash_aset(rb_object_hash, INT2FIX((long)node), obj);
	return obj;
}

VALUE rb_cCocosNode_s_new(VALUE klass) {
	CocosNode *node = [[CocosNode alloc] init];
	cocos_holder *ptr = ALLOC(cocos_holder);
	ptr->_obj = node;
	VALUE obj = common_init(klass, ptr, YES);
	// add the pointer to the object hash
	rb_hash_aset(rb_object_hash, INT2FIX((long)node), obj);
	return obj;
}

/*
 add_child(obj)
 add_child(obj, :z => z, :tag => tag, :parallax_ratio => ratio)
 */
VALUE rb_cCocosNode_add_child(int argc, VALUE *args, VALUE object) {
	if (argc < 1 || argc > 2) {
		rb_raise(rb_eArgError, "invalid number of arguments");
	}
	// set default values
	cocos_holder *ptr_child;
	Data_Get_Struct(args[0], cocos_holder, ptr_child);
	int z_order = ((CocosNode *)GET_OBJC(ptr_child)).zOrder;
	int tag     = ((CocosNode *)GET_OBJC(ptr_child)).tag;
	VALUE parallaxRatio = Qnil;
	if (argc == 2) {
		Check_Type(args[1], T_HASH);
		VALUE _tmp = Qnil;
		if (_tmp = rb_hash_aref(args[1], ID2SYM(rb_intern("z"))) != Qnil)
			z_order = FIX2INT(_tmp);
		if (_tmp = rb_hash_aref(args[1], ID2SYM(rb_intern("tag"))) != Qnil)
			tag = FIX2INT(_tmp);
		if (_tmp = rb_hash_aref(args[1], ID2SYM(rb_intern("parallax_ratio"))) != Qnil)
			parallaxRatio = _tmp;
	}
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	if (parallaxRatio != Qnil) {
		Check_Type(parallaxRatio, T_ARRAY);
		cpVect v = cpv(NUM2DBL(rb_ary_entry(parallaxRatio, 0)), NUM2DBL(rb_ary_entry(parallaxRatio, 1)));
		[((CocosNode *)GET_OBJC(ptr)) addChild:GET_OBJC(ptr_child) z:z_order parallaxRatio:v];
	} else {
		[((CocosNode *)GET_OBJC(ptr)) addChild:GET_OBJC(ptr_child) z:z_order tag:tag];
	}
	return args[0];
}

#pragma mark Override Points

/* call node's onEnter */
VALUE rb_cCocosNode_on_enter(VALUE object) {
	return Qnil;
}

VALUE rb_cCocosNode_on_exit(VALUE object) {
	return Qnil;
}

VALUE rb_cCocosNode_draw(VALUE object) {
	return Qnil;
}

VALUE rb_cCocosNode_transform(VALUE object) {
	return Qnil;
}

void init_rb_cCocosNode() {
#if 0
	rb_mCocos2D = rb_define_module("Cocos2D");
#endif
	rb_cCocosNode = rb_define_class_under(rb_mCocos2D, "CocosNode", rb_cObject);
	rb_define_singleton_method(rb_cCocosNode, "node", rb_cCocosNode_s_node, 0);
	rb_define_singleton_method(rb_cCocosNode, "new", rb_cCocosNode_s_new, 0);
	
	// getters
	rb_define_method(rb_cCocosNode, "z_order", rb_cCocosNode_z_order, 0);
	rb_define_method(rb_cCocosNode, "rotation", rb_cCocosNode_rotation, 0);
	rb_define_method(rb_cCocosNode, "scale", rb_cCocosNode_scale, 0);
	rb_define_method(rb_cCocosNode, "scale_x", rb_cCocosNode_scale_x, 0);
	rb_define_method(rb_cCocosNode, "scale_y", rb_cCocosNode_scale_y, 0);
	rb_define_method(rb_cCocosNode, "position", rb_cCocosNode_position, 0);
	rb_define_method(rb_cCocosNode, "visible", rb_cCocosNode_visible, 0);
	rb_define_method(rb_cCocosNode, "tag", rb_cCocosNode_tag, 0);

	// setters
	rb_define_method(rb_cCocosNode, "rotation=", rb_cCocosNode_set_rotation, 1);
	rb_define_method(rb_cCocosNode, "scale=", rb_cCocosNode_set_scale, 1);
	rb_define_method(rb_cCocosNode, "scale_x=", rb_cCocosNode_set_scale_x, 1);
	rb_define_method(rb_cCocosNode, "scale_y=", rb_cCocosNode_set_scale_y, 1);
	rb_define_method(rb_cCocosNode, "position=", rb_cCocosNode_set_position, 1);
	rb_define_method(rb_cCocosNode, "visible=", rb_cCocosNode_set_visible, 1);
	rb_define_method(rb_cCocosNode, "tag=", rb_cCocosNode_set_tag, 1);
	
	// misc
	rb_define_method(rb_cCocosNode, "add_child", rb_cCocosNode_add_child, -1);
	
	// actions
	rb_define_method(rb_cCocosNode, "on_enter", rb_cCocosNode_on_enter, 0);
	rb_define_method(rb_cCocosNode, "on_exit", rb_cCocosNode_on_exit, 0);
	rb_define_method(rb_cCocosNode, "draw", rb_cCocosNode_on_exit, 0);
	rb_define_method(rb_cCocosNode, "transform", rb_cCocosNode_on_exit, 0);
	
	// replace the init and dealloc methods in the CocosNode class
	common_method_swap([CocosNode class], @selector(init), @selector(rb_init), "@@:");
	common_method_swap([CocosNode class], @selector(dealloc), @selector(rb_dealloc), "v@:");
	// replace the common actions on the CocosNode class
	common_method_swap([CocosNode class], @selector(onEnter), @selector(rb_on_enter), "v@:");
	common_method_swap([CocosNode class], @selector(onExit), @selector(rb_on_exit), "v@:");
}
