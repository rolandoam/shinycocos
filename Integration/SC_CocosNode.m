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
#import "SC_common.h"
#import "SC_CocosNode.h"
#import "rb_chipmunk.h"

static ID id_animate;
static ID id_repeat_forever;
VALUE rb_cCocosNode;
VALUE rb_handler_hash;

#pragma mark CocosNode extension

static void eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	CocosNode *sprite = shape->data;
	if (sprite) {
		cpBody *body = shape->body;
		
		sprite.position = body->p;
		sprite.rotation = (float)CC_RADIANS_TO_DEGREES(-body->a);
		// reset forces (we could add a check against a iv to see if we
		// need to reset forces)
		cpBodyResetForces(shape->body);
	}
}

@interface CocosNode (SC_Extension)
- (id)rb_init;
- (void)rb_dealloc;
// actions
- (void)rb_on_enter;
- (void)rb_on_exit;
- (void)rb_draw;
- (void)rb_transform;
// chipmunk support
- (void)step:(ccTime)delta;
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

- (void)step:(ccTime)delta {
	int steps = 2, i;
	cpSpace *space = SPACE(rb_gv_get("space"));
	cpFloat dt = delta/(cpFloat)steps;
	for (i=0; i < steps; i++)
		cpSpaceStep(space, dt);
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	//cpSpaceHashEach(space->staticShapes, &eachShape, nil);
}
@end

# pragma mark Action Extension

@interface Action (SC_Extension)
- (void)rb_stop;
@end

@implementation Action (SC_Extension)
- (void)rb_stop {
	[self rb_stop];
	VALUE handler = rb_hash_aref(rb_handler_hash, INT2FIX((long)self));
	// handler should be an array with two items: the handler and the
	// method to be called. This will be good if the handler could also
	// be a block/proc. It shouldn't be hard to implement, just check
	// the type
	if (handler && TYPE(handler) == T_ARRAY && RARRAY(handler)->len == 2) {
		rb_funcall(RARRAY(handler)->ptr[0], rb_to_id(RARRAY(handler)->ptr[1]), 0);
	}
}
@end

# pragma mark Properties

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_z_order(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return INT2FIX(((CocosNode *)GET_OBJC(ptr)).zOrder);
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_rotation(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(((CocosNode *)GET_OBJC(ptr)).rotation);
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_set_rotation(VALUE object, VALUE rotation) {
	cocos_holder *ptr;
	Check_Type(rotation, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).rotation = NUM2DBL(rotation);
	return rotation;
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_scale(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(((CocosNode *)GET_OBJC(ptr)).scale);
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_set_scale(VALUE object, VALUE scale) {
	cocos_holder *ptr;
	Check_Type(scale, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).scale = NUM2DBL(scale);
	return scale;
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_scale_x(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(((CocosNode *)GET_OBJC(ptr)).scaleX);
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_set_scale_x(VALUE object, VALUE scale_x) {
	cocos_holder *ptr;
	Check_Type(scale_x, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).scaleY = NUM2DBL(scale_x);
	return scale_x;
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_scale_y(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(((CocosNode *)GET_OBJC(ptr)).scaleY);
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_set_scale_y(VALUE object, VALUE scale_y) {
	cocos_holder *ptr;
	Check_Type(scale_y, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).scaleY = NUM2DBL(scale_y);
	return scale_y;
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_position(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	cpVect v = ((CocosNode *)GET_OBJC(ptr)).position;
	return rb_ary_new3(2, v.x, v.y);
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_set_position(VALUE object, VALUE position) {
	cocos_holder *ptr;
	Check_Type(position, T_ARRAY);
	if (RARRAY(position)->len == 2) {
		Data_Get_Struct(object, cocos_holder, ptr);
		((CocosNode *)GET_OBJC(ptr)).position = cpv(FIX2INT(RARRAY(position)->ptr[0]), FIX2INT(RARRAY(position)->ptr[1]));
		return position;
	} else {
		NSLog(@"Invalid array size for position");
		return Qnil;
	}
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_visible(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return ((CocosNode *)GET_OBJC(ptr)).visible ? Qtrue : Qfalse;
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_set_visible(VALUE object, VALUE visible) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).visible = (visible == Qfalse) ? NO : YES;
	return (visible == Qfalse) ? Qfalse : Qtrue;
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_tag(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return INT2FIX(((CocosNode *)GET_OBJC(ptr)).tag);
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_set_tag(VALUE object, VALUE tag) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	((CocosNode *)GET_OBJC(ptr)).tag = FIX2INT(tag);
	return tag;
}

#pragma mark Methods

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_s_node(VALUE klass) {
	CocosNode *node = [CocosNode node];
	VALUE obj = common_init(klass, nil, node, NO);
	// add the pointer to the object hash
	rb_hash_aset(rb_object_hash, INT2FIX((long)node), obj);
	return obj;
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_s_new(VALUE klass) {
	CocosNode *node = [[CocosNode alloc] init];
	VALUE obj = common_init(klass, nil, node, YES);
	// add the pointer to the object hash
	rb_hash_aset(rb_object_hash, INT2FIX((long)node), obj);
	return obj;
}

/*
 *   add_child(obj)
 *   add_child(obj, :z => z, :tag => tag, :parallaxRatio => ratio)
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
		cpVect v = cpv(NUM2DBL(RARRAY(parallaxRatio)->ptr[0]), NUM2DBL(RARRAY(parallaxRatio)->ptr[1]));
		[((CocosNode *)GET_OBJC(ptr)) addChild:GET_OBJC(ptr_child) z:z_order parallaxRatio:v];
	} else {
		[((CocosNode *)GET_OBJC(ptr)) addChild:GET_OBJC(ptr_child) z:z_order tag:tag];
	}
	return args[0];
}

/*
 *    node.run_action(action, options, *args) do |action|
 *    end
 *
 *  +action+ it's a symbol representing an action. Valid symbols are all
 *  Cocos2D-iphone (0.7.2) actions, camel cased. e.g.: RepeatForever =>
 *  repeat_forever; RotateBy => rotate_by.
 * 
 *  Valid options:
 * 
 *  * <tt>:on_stop</tt>:: Will be called when the generated action.
 *  stops.
 *  
 *  The rest of arguments are the valid arguments for the new action:
 *  
 *    node.run_action(:rotate_by, duration, angle)
 *  
 *  The optional block passes the newly created action. You can there
 *  further configure the action. Each action has it's own properties. In
 *  order to simplify the configuration, each action is a struct, where the
 *  +name+ property specifies the corresponding Objective-C class.
 *  
 *  The way to specify nested actions is with an array. This is commonly
 *  used in the repeat actions:
 *  
 *    animation = AtlasAnimation.animation(:name => "walk", :delay => 1/30.0) do |walk|
 *      (0..37).each { |i|
 *        x = i % 10
 *        y = i / 10
 *        walk.add_frame [x*100, y*160, 100, 160]
 *      }
 *    end
 *  
 *    node.run_action(:repeat_forever) do |action|
 *      action.action = [:animate, animation]
 *    end
 */
VALUE rb_cCocosNode_run_action(int argc, VALUE *args, VALUE object) {
	if (argc < 2) {
		rb_raise(rb_eArgError, "Invalid number of arguments (need to pass the action and its options)");
	}
	Check_Type(args[0], T_SYMBOL);
	Check_Type(args[1], T_HASH);
	
	VALUE action_struct = Qnil; // the Struct to be passed to the block (if any)
	id action;                  // the Obj-C action
	ID rb_action = SYM2ID(args[0]);
	cocos_holder *ptr;
	if (rb_action == id_animate && argc == 3) {
		Data_Get_Struct(args[2], cocos_holder, ptr);
		action = [Animate actionWithAnimation:GET_OBJC(ptr)];
	} else {
		rb_raise(rb_eArgError, "Invalid Action");
	}
	if (rb_block_given_p()) {
		rb_yield(action_struct);
	}
	// add an on_stop handler here. This will require modification to Action.h
	VALUE on_stop_handler = rb_hash_aref(args[1], ID2SYM(rb_intern("on_stop")));
	if (on_stop_handler && TYPE(on_stop_handler) == T_SYMBOL) {
		VALUE handler_ary = rb_ary_new3(2, object, on_stop_handler);
		rb_hash_aset(rb_handler_hash, INT2FIX((long)action), handler_ary);
	}
	
	// here we should do something with the modified struct
	Data_Get_Struct(object, cocos_holder, ptr);
	[GET_OBJC(ptr) runAction:action];
	
	return object;
}

/*
 * will set the current CocosNode as the stepper for chipmunk (will run
 * the <tt>step:</tt> selector).
 */
VALUE rb_cCocosNode_set_chipmunk_stepper(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	[GET_OBJC(ptr) schedule:@selector(step:)];
	
	return object;
}

/*
 * will set the internal data attribute of the shape to the internal
 * objective-c object of the CocosNode.
 */
VALUE rb_cCocosNode_attach_chipmunk_shape(VALUE object, VALUE rb_shape) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	cpShape *shape = SHAPE(rb_shape);
	shape->data = ptr->_obj;
	
	return object;
}

#pragma mark Override Points

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_on_enter(VALUE object) {
	return Qnil;
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_on_exit(VALUE object) {
	return Qnil;
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_draw(VALUE object) {
	return Qnil;
}

/* 
 * Must complete doc
 */
VALUE rb_cCocosNode_transform(VALUE object) {
	return Qnil;
}

/*
 * The ruby equivalent of the CocosNode class - not yet complete
 */
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
	rb_define_method(rb_cCocosNode, "run_action", rb_cCocosNode_run_action, -1);
	rb_define_method(rb_cCocosNode, "set_chipmunk_stepper", rb_cCocosNode_set_chipmunk_stepper, 0);
	rb_define_method(rb_cCocosNode, "attach_chipmunk_shape", rb_cCocosNode_attach_chipmunk_shape, 1);
	
	// actions
	rb_define_method(rb_cCocosNode, "on_enter", rb_cCocosNode_on_enter, 0);
	rb_define_method(rb_cCocosNode, "on_exit", rb_cCocosNode_on_exit, 0);
	rb_define_method(rb_cCocosNode, "draw", rb_cCocosNode_on_exit, 0);
	rb_define_method(rb_cCocosNode, "transform", rb_cCocosNode_on_exit, 0);
	
	// replace the init and dealloc methods in the CocosNode class
	common_method_swap([CocosNode class], @selector(init), @selector(rb_init));
	common_method_swap([CocosNode class], @selector(dealloc), @selector(rb_dealloc));
	// replace the common actions on the CocosNode class
	common_method_swap([CocosNode class], @selector(onEnter), @selector(rb_on_enter));
	common_method_swap([CocosNode class], @selector(onExit), @selector(rb_on_exit));
	// replace the stop method on Action (to be able to call the stop handler in ruby)
	common_method_swap([Action class], @selector(stop), @selector(rb_stop));
	
	// init the handler hash
	rb_handler_hash = rb_hash_new();
	rb_gv_set("_sc_handler_hash", rb_handler_hash);
	
	// setup the valid_actions array
	id_animate = rb_intern("animate");
	id_repeat_forever = rb_intern("repeat_forever");
}
