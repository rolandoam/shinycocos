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

static ID id_action_animate;
static ID id_action_repeat_forever;
static ID id_action_move_to;
static ID id_action_move_by;
static ID id_cb_on_enter;
static ID id_cb_on_exit;

VALUE rb_cCocosNode;

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
// actions
- (void)rb_on_enter;
- (void)rb_on_exit;
- (void)rb_draw;
// TODO
// add ccTouches*

// chipmunk support
- (void)chipmunk_step:(ccTime)delta;
// ruby schedule support
- (void)rbScheduler;
@end

@implementation CocosNode (SC_Extension)
- (void)rb_on_enter {
	[self rb_on_enter];
	// call the ruby version
	VALUE rbObject = sc_ruby_instance_for(sc_object_hash, self);
	if (rbObject != Qnil) {
		rb_funcall(rbObject, id_cb_on_enter, 0, 0);
	}
}

- (void)rb_on_exit {
	[self rb_on_exit];
	// call the ruby version
	VALUE rbObject = sc_ruby_instance_for(sc_object_hash, self);
	if (rbObject != Qnil) {
		rb_funcall(rbObject, id_cb_on_exit, 0, 0);
	}
}

- (void)rb_draw {
	[self rb_draw];
}

- (void)chipmunk_step:(ccTime)delta {
	int steps = 2, i;
	cpSpace *space = SPACE(rb_gv_get("space"));
	cpFloat dt = delta/(cpFloat)steps;
	for (i=0; i < steps; i++)
		cpSpaceStep(space, dt);
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	//cpSpaceHashEach(space->staticShapes, &eachShape, nil);
}

- (void)rbScheduler {
	VALUE methods = sc_ruby_instance_for(sc_schedule_methods, self);
	if (methods != Qnil && TYPE(methods) == T_ARRAY) {
		int i;
		VALUE target = RARRAY_PTR(methods)[0];
		for (i=1; target != Qnil && i < RARRAY_LEN(methods); i++) {
			// check that the target responds to the action
			ID m = rb_to_id(RARRAY_PTR(methods)[i]);
			rb_funcall(target, m, 0, 0);
		}
	}
}
@end

# pragma mark Action Extension

@interface Action (SC_Extension)
- (void)rb_stop;
@end

@implementation Action (SC_Extension)
- (void)rb_stop {
	[self rb_stop];
	VALUE handler = sc_ruby_instance_for(sc_handler_hash, (CocosNode *)self);
	// handler should be an array with two items: the handler and the
	// method to be called. This will be good if the handler could also
	// be a block/proc. It shouldn't be hard to implement, just check
	// the type
	if (handler && TYPE(handler) == T_ARRAY && RARRAY_LEN(handler) == 2) {
		rb_funcall(RARRAY_PTR(handler)[0], rb_to_id(RARRAY_PTR(handler)[1]), 0, 0);
	}
	// unregister the handler
	// NOTE
	// this might break things for actions that will be executed more than once.
	sc_remove_tracking_for(sc_handler_hash, (CocosNode *)self);
	rb_gc_unregister_address(&handler);
}
@end

# pragma mark Properties

/* 
 * call-seq:
 *   node.z_order   => Integer
 * 
 * Returns the z_order of the node
 */
VALUE rb_cCocosNode_z_order(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return INT2FIX(CC_NODE(ptr).zOrder);
}

/* 
 *  call-seq:
 *     node.rotation   => Float
 * 
 * Returns the rotation of the sprite
 */
VALUE rb_cCocosNode_rotation(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(CC_NODE(ptr).rotation);
}

/* 
 * call-seq:
 *   node.rotation = 15.0
 *
 * Sets the rotation of the sprite
 */
VALUE rb_cCocosNode_set_rotation(VALUE object, VALUE rotation) {
	cocos_holder *ptr;
	Check_Type(rotation, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	CC_NODE(ptr).rotation = NUM2DBL(rotation);
	return rotation;
}

/* 
 *   node.scale #=> float
 */
VALUE rb_cCocosNode_scale(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(CC_NODE(ptr).scale);
}

/* 
 *   node.scale = 0.5
 */
VALUE rb_cCocosNode_set_scale(VALUE object, VALUE scale) {
	cocos_holder *ptr;
	Check_Type(scale, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	CC_NODE(ptr).scale = NUM2DBL(scale);
	return scale;
}

/* 
 *   node.scale_x #=> float
 */
VALUE rb_cCocosNode_scale_x(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(CC_NODE(ptr).scaleX);
}

/* 
 *   node.scale_x = 1.1
 */
VALUE rb_cCocosNode_set_scale_x(VALUE object, VALUE scale_x) {
	cocos_holder *ptr;
	Check_Type(scale_x, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	CC_NODE(ptr).scaleY = NUM2DBL(scale_x);
	return scale_x;
}

/* 
 *   node.scale_y #=> float
 */
VALUE rb_cCocosNode_scale_y(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return rb_float_new(CC_NODE(ptr).scaleY);
}

/* 
 *   node.scale_y = 0.3
 */
VALUE rb_cCocosNode_set_scale_y(VALUE object, VALUE scale_y) {
	cocos_holder *ptr;
	Check_Type(scale_y, T_FLOAT);
	Data_Get_Struct(object, cocos_holder, ptr);
	CC_NODE(ptr).scaleY = NUM2DBL(scale_y);
	return scale_y;
}

/* 
 *   node.position #=> [x,y]
 */
VALUE rb_cCocosNode_position(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	cpVect v = CC_NODE(ptr).position;
	return rb_ary_new3(2, rb_float_new(v.x), rb_float_new(v.y));
}

/* 
 *   node.position = [x,y] #=> [x,y]
 */
VALUE rb_cCocosNode_set_position(VALUE object, VALUE position) {
	cocos_holder *ptr;
	Check_Type(position, T_ARRAY);
	if (RARRAY_LEN(position) == 2) {
		Data_Get_Struct(object, cocos_holder, ptr);
		CC_NODE(ptr).position = cpv(NUM2DBL(RARRAY_PTR(position)[0]), NUM2DBL(RARRAY_PTR(position)[1]));
		return position;
	} else {
		NSLog(@"Invalid array size for position");
		return Qnil;
	}
}

/* 
 *   node.visible? #=> true or false
 */
VALUE rb_cCocosNode_visible(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return CC_NODE(ptr).visible ? Qtrue : Qfalse;
}

/* 
 * Sets the node's visibility
 * 
 *   node.visible = true
 */
VALUE rb_cCocosNode_set_visible(VALUE object, VALUE visible) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	CC_NODE(ptr).visible = (visible == Qfalse) ? NO : YES;
	return (visible == Qfalse) ? Qfalse : Qtrue;
}

/* 
 *   node.tag #=> Integer
 */
VALUE rb_cCocosNode_tag(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	return INT2FIX(CC_NODE(ptr).tag);
}

/* 
 * Sets the node's tag, it should be an integer.
 * 
 *   node.tag = MY_TAG
 */
VALUE rb_cCocosNode_set_tag(VALUE object, VALUE tag) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	CC_NODE(ptr).tag = FIX2INT(tag);
	return tag;
}

#pragma mark Methods

/* 
 * call-seq:
 *     node = CocosNode.node   #=> CocosNode
 * 
 * Creates a new node. Use the other version when subclassing
 * CocosNode.
 * 
 * This one creates an autoreleaseable version (although this doesn't
 * matter on the ruby side).
 */
VALUE rb_cCocosNode_s_node(VALUE klass) {
	CocosNode *node = [CocosNode node];
	VALUE obj = sc_init(klass, nil, node, 0, 0, NO);
	// add the pointer to the object hash
	sc_add_tracking(sc_object_hash, node, obj);
	return obj;
}

/* 
 * call-seq:
 *     node = CocosNode.new    #=> CocosNode
 *     node = CocosNodeSubclass.new(a,b)   #=> CocosNode
 * 
 * Same as CocosNode.node, althought the Obj-C object is not
 * autoreleaseable. It will be safely released by ruby's GC.
 * 
 * Use this when subclassing CocosNode and your initializer uses
 * arguments.
 */
VALUE rb_cCocosNode_s_new(int argc, VALUE *argv, VALUE klass) {
	CocosNode *node = [[CocosNode alloc] init];
	VALUE obj = sc_init(klass, nil, node, argc, argv, YES);
	// add the pointer to the object hash
	sc_add_tracking(sc_object_hash, node, obj);
	return obj;
}

/*
 * Adds a child. The child should be a subclass of CocosNode.
 * 
 *   add_child(obj) #=> obj
 *   add_child(obj, :z => z, :tag => tag, :parallaxRatio => ratio)
 */
VALUE rb_cCocosNode_add_child(int argc, VALUE *args, VALUE object) {
	if (argc < 1 || argc > 2) {
		rb_raise(rb_eArgError, "invalid number of arguments");
	}
	// set default values
	cocos_holder *ptr_child;
	Data_Get_Struct(args[0], cocos_holder, ptr_child);
	int z_order = CC_NODE(ptr_child).zOrder;
	int tag     = CC_NODE(ptr_child).tag;
	VALUE parallaxRatio = Qnil;
	if (argc == 2) {
		Check_Type(args[1], T_HASH);
		VALUE _tmp = Qnil;
		if ((_tmp = rb_hash_aref(args[1], ID2SYM(rb_intern("z")))) != Qnil)
			z_order = FIX2INT(_tmp);
		if ((_tmp = rb_hash_aref(args[1], ID2SYM(rb_intern("tag")))) != Qnil)
			tag = FIX2INT(_tmp);
		if ((_tmp = rb_hash_aref(args[1], ID2SYM(rb_intern("parallax_ratio")))) != Qnil) {
			parallaxRatio = _tmp;
		}
	}
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	if (parallaxRatio != Qnil) {
		Check_Type(parallaxRatio, T_ARRAY);
		cpVect v = cpv(NUM2DBL(RARRAY_PTR(parallaxRatio)[0]), NUM2DBL(RARRAY_PTR(parallaxRatio)[1]));
		[CC_NODE(ptr) addChild:GET_OBJC(ptr_child) z:z_order parallaxRatio:v];
	} else {
		[CC_NODE(ptr) addChild:GET_OBJC(ptr_child) z:z_order tag:tag];
	}
	return args[0];
}

id create_action(ID name, int argc, VALUE *argv) {
	cocos_holder *ptr;
	id action = nil;
	
	if (name == id_action_repeat_forever) {
		// argv[0] should be an action name, different from repeat_forever
		id nested_action = nil;
		if (argc > 0 && argv[0] != id_action_repeat_forever && TYPE(argv[0]) == T_SYMBOL) {
			nested_action = create_action(SYM2ID(argv[0]), argc-1, argv+1);
		}
		if (nested_action == nil) {
			rb_raise(rb_eArgError, "Invalid Nested Action");
			return nil;
		}
		action = [RepeatForever actionWithAction:nested_action];
	} else if (name == 	id_action_animate && argc == 1) {
		Data_Get_Struct(argv[0], cocos_holder, ptr);
		action = [Animate actionWithAnimation:GET_OBJC(ptr)];
	} else if ((name == id_action_move_to || name == id_action_move_by) && argc == 2) {
		Check_Type(argv[0], T_FLOAT);
		Check_Type(argv[1], T_ARRAY);
		cpVect pos = cpv(NUM2DBL(RARRAY_PTR(argv[0])[0]), NUM2DBL(RARRAY_PTR(argv[0])[1]));
		if (name == id_action_move_to)
			action = [MoveTo actionWithDuration:NUM2DBL(argv[1]) position:pos];
		else
			action = [MoveBy actionWithDuration:NUM2DBL(argv[1]) position:pos];
	} else {
		rb_raise(rb_eArgError, "Invalid Action");
	}
	return action;
}

/*
 *    node.run_action(action, options, *args) do |action|
 *    end
 *
 * +action+ it's a symbol representing an action. Valid symbols are all
 * Cocos2D-iphone (0.7.2) actions, camel cased. e.g.: RepeatForever =>
 * repeat_forever; RotateBy => rotate_by.
 * 
 * Valid options:
 * 
 * <tt>:on_stop</tt>:: Will be called when the generated action
 *                     stops.
 *  
 * The rest of arguments are the valid arguments for the new action:
 *  
 *   node.run_action(:rotate_by, {}, duration, angle)
 * 
 * THE FOLLOWING IS HOW THIS WILL WORK IN A FUTURE RELEASE :-)
 * 
 * The optional block passes the newly created action. You can there
 * further configure the action. Each action has it's own properties. In
 * order to simplify the configuration, each action is a struct, where the
 * +name+ property specifies the corresponding Objective-C class.
 * 
 * The way to specify nested actions is with an array. This is commonly
 * used in the repeat actions:
 * 
 *   animation = AtlasAnimation.animation(:name => "walk", :delay => 1/30.0) do |walk|
 *     (0..37).each { |i|
 *       x = i % 10
 *       y = i / 10
 *       walk.add_frame [x*100, y*160, 100, 160]
 *     }
 *   end
 * 
 *   node.run_action(:repeat_forever) do |action|
 *     action.action = [:animate, animation]
 *   end
 * 
 * Returns the object that will run the action.
 */
VALUE rb_cCocosNode_run_action(int argc, VALUE *argv, VALUE object) {
	if (argc < 2) {
		rb_raise(rb_eArgError, "Invalid number of arguments (need to pass the action and its options)");
	}
	Check_Type(argv[0], T_SYMBOL);
	Check_Type(argv[1], T_HASH);
	
	VALUE action_struct = Qnil; // the Struct to be passed to the block (if any)
	ID rb_action = SYM2ID(argv[0]);
	id action = create_action(rb_action, argc-2, argv+2);
	
	/* not yet working */
	if (rb_block_given_p()) {
		rb_yield(action_struct);
	}
	// add an on_stop handler if needed
	VALUE on_stop_handler = rb_hash_aref(argv[1], ID2SYM(rb_intern("on_stop")));
	if (on_stop_handler && TYPE(on_stop_handler) == T_SYMBOL) {
		VALUE handler_ary = rb_ary_new3(2, object, on_stop_handler);
		// protect variable, we should remove it later
		rb_global_variable(&handler_ary);
		sc_add_tracking(sc_handler_hash, action, handler_ary);
	}
	
	// here we should do something with the modified struct (when the yield works)
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	[CC_NODE(ptr) runAction:action];
	
	return object;
}

/*
 * Will set the node as the stepper for chipmunk (will run the
 * <tt>step:</tt> selector).
 */
VALUE rb_cCocosNode_become_chipmunk_stepper(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	[CC_NODE(ptr) schedule:@selector(chipmunk_step:)];
	
	return object;
}

/*
 * Will bind a Chipmunk Shape to a CocosNode.
 */
VALUE rb_cCocosNode_attach_chipmunk_shape(VALUE object, VALUE rb_shape) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	cpShape *shape = SHAPE(rb_shape);
	shape->data = ptr->_obj;
	
	return object;
}

/*
 * Will schedule a method to be called every frame
 * 
 *   node.schedule(:every_frame)
 * 
 * <tt>:every_frame</tt> on <tt>node</tt> will be called every frame.
 */
VALUE rb_cCocosNode_schedule(VALUE object, VALUE method) {	
	Check_Type(method, T_SYMBOL);
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	VALUE methods = sc_ruby_instance_for(sc_schedule_methods, CC_NODE(ptr));
	if (methods == Qnil) {
		methods = rb_ary_new3(2, object, method);
		sc_add_tracking(sc_schedule_methods, CC_NODE(ptr), methods);
		[CC_NODE(ptr) schedule:@selector(rbScheduler)];
	} else {
		rb_ary_push(methods, method);
	}
	
	return object;
}

/*
 * will remove a scheduled method
 */
VALUE rb_cCocosNode_unschedule(VALUE object, VALUE method) {
	Check_Type(method, T_SYMBOL);
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	VALUE methods = sc_ruby_instance_for(sc_schedule_methods, CC_NODE(ptr));
	if (methods != Qnil) {
		rb_funcall(methods, rb_intern("delete"), 1, method);
		if (RARRAY_LEN(methods) == 0) {
			// empty array, unschedule the ruby scheduler
			[CC_NODE(ptr) unschedule:@selector(rbScheduler)];
			// remove the array from the hash
			sc_remove_tracking_for(sc_schedule_methods, CC_NODE(ptr));
		}
	}
	return methods;
}

/*
 * call-seq:
 *   node.camera_eye   => [x,y,z]
 * 
 * returns the camera eye as an array of 3 floats
 */
VALUE rb_cCocosNode_camera_eye(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	float x, y, z;
	[CC_NODE(ptr).camera eyeX:&x eyeY:&y eyeZ:&z];
	
	return rb_ary_new3(3, rb_float_new(x), rb_float_new(y), rb_float_new(z));
}

/*
 * call-seq:
 *   node.camera_eye = [x,y,z]   => [x,y,z]
 * 
 * Sets the new camera eye.
 */
VALUE rb_cCocosNode_set_camera_eye(VALUE object, VALUE position) {
	Check_Type(position, T_ARRAY);
	if (RARRAY_LEN(position) < 3) {
		rb_raise(rb_eArgError, "Invalid position array");
	}
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	VALUE x = RARRAY_PTR(position)[0];
	VALUE y = RARRAY_PTR(position)[1];
	VALUE z = RARRAY_PTR(position)[2];
	[CC_NODE(ptr).camera setEyeX:NUM2DBL(x) eyeY:NUM2DBL(y) eyeZ:NUM2DBL(z)];
	
	return position;
}

/*
 * call-seq:
 *   node.camera_center   => [x,y,z]
 * 
 * returns the camera center as an array of 3 floats
 */
VALUE rb_cCocosNode_camera_center(VALUE object) {
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	float x, y, z;
	[CC_NODE(ptr).camera centerX:&x centerY:&y centerZ:&z];
	
	return rb_ary_new3(3, rb_float_new(x), rb_float_new(y), rb_float_new(z));
}

/*
 * call-seq:
 *   node.camera_center = [x,y,z]   => [x,y,z]
 * 
 * Sets the new camera center.
 */
VALUE rb_cCocosNode_set_camera_center(VALUE object, VALUE position) {
	Check_Type(position, T_ARRAY);
	if (RARRAY_LEN(position) < 3) {
		rb_raise(rb_eArgError, "Invalid position array");
	}
	cocos_holder *ptr;
	Data_Get_Struct(object, cocos_holder, ptr);
	VALUE x = RARRAY_PTR(position)[0];
	VALUE y = RARRAY_PTR(position)[1];
	VALUE z = RARRAY_PTR(position)[2];
	[CC_NODE(ptr).camera setCenterX:NUM2DBL(x) centerY:NUM2DBL(y) centerZ:NUM2DBL(z)];
	
	return position;
}

#pragma mark Override Points

/* 
 * Will be called when the node enters the 'stage'
 */
VALUE rb_cCocosNode_on_enter(VALUE object) {
	return Qnil;
}

/* 
 * Will be called when the node exits the 'stage'
 */
VALUE rb_cCocosNode_on_exit(VALUE object) {
	return Qnil;
}

/* 
 * override this method to draw your own node (not sure this is
 * working)
 */
VALUE rb_cCocosNode_draw(VALUE object) {
	return Qnil;
}

/*
 * The ruby equivalent of the CocosNode class - not yet complete
 */
void init_rb_cCocosNode() {
	rb_cCocosNode = rb_define_class_under(rb_mCocos2D, "CocosNode", rb_cObject);
	rb_define_singleton_method(rb_cCocosNode, "node", rb_cCocosNode_s_node, 0);
	rb_define_singleton_method(rb_cCocosNode, "new", rb_cCocosNode_s_new, -1);
	
	// getters
	rb_define_method(rb_cCocosNode, "z_order", rb_cCocosNode_z_order, 0);
	rb_define_method(rb_cCocosNode, "rotation", rb_cCocosNode_rotation, 0);
	rb_define_method(rb_cCocosNode, "scale", rb_cCocosNode_scale, 0);
	rb_define_method(rb_cCocosNode, "scale_x", rb_cCocosNode_scale_x, 0);
	rb_define_method(rb_cCocosNode, "scale_y", rb_cCocosNode_scale_y, 0);
	rb_define_method(rb_cCocosNode, "position", rb_cCocosNode_position, 0);
	rb_define_method(rb_cCocosNode, "visible?", rb_cCocosNode_visible, 0);
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
	rb_define_method(rb_cCocosNode, "become_chipmunk_stepper", rb_cCocosNode_become_chipmunk_stepper, 0);
	rb_define_method(rb_cCocosNode, "attach_chipmunk_shape", rb_cCocosNode_attach_chipmunk_shape, 1);
	rb_define_method(rb_cCocosNode, "schedule", rb_cCocosNode_schedule, 1);
	rb_define_method(rb_cCocosNode, "unschedule", rb_cCocosNode_unschedule, 1);
	
	// camera
	rb_define_method(rb_cCocosNode, "camera_eye", rb_cCocosNode_camera_eye, 0);
	rb_define_method(rb_cCocosNode, "camera_eye=", rb_cCocosNode_set_camera_eye, 1);
	rb_define_method(rb_cCocosNode, "camera_center", rb_cCocosNode_camera_center, 0);
	rb_define_method(rb_cCocosNode, "camera_center=", rb_cCocosNode_set_camera_center, 1);
	
	// actions
	rb_define_method(rb_cCocosNode, "on_enter", rb_cCocosNode_on_enter, 0);
	rb_define_method(rb_cCocosNode, "on_exit", rb_cCocosNode_on_exit, 0);
	rb_define_method(rb_cCocosNode, "draw", rb_cCocosNode_on_exit, 0);
	
	// replace the common actions on the CocosNode class
	sc_method_swap([CocosNode class], @selector(onEnter), @selector(rb_on_enter));
	sc_method_swap([CocosNode class], @selector(onExit), @selector(rb_on_exit));
	// replace the stop method on Action (to be able to call the stop handler in ruby)
	sc_method_swap([Action class], @selector(stop), @selector(rb_stop));
		
	// setup the valid_actions array
	id_action_animate = rb_intern("animate");
	id_action_repeat_forever = rb_intern("repeat_forever");
	id_action_move_to = rb_intern("move_to");
	id_action_move_by = rb_intern("move_by");
	id_cb_on_enter = rb_intern("on_enter");
	id_cb_on_exit = rb_intern("on_exit");
}
