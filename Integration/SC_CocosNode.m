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
#import "ruby.h"
// this one is for thread critical
#import "rubysig.h"

#import "SC_CocosNode.h"
#import "SC_Action.h"
#import "rb_chipmunk.h"

VALUE rb_cCocosNode;
ccHashSet *scheduledMethods;

typedef struct hashMethod_ {
	VALUE object;
	VALUE methods;
} hashMethod;

static int scheduledMethodsEql(void *ptr, void *elt)
{
	hashMethod *first = (hashMethod *)ptr;
	hashMethod *second = (hashMethod *)elt;
	return (first->object == second->object);
}

#pragma mark CocosNode extension

static void eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*)ptr;
	cpBody *body = shape->body;
	VALUE rb_shape = (VALUE)shape->data;
	if (rb_shape) {
		// get node from shape (if any)
		VALUE node = rb_ivar_get(rb_shape, id_sc_ivar_cc_node);
		if (node != Qnil) {
			CC_NODE(node).position = body->p;
			CC_NODE(node).rotation = (float)CC_RADIANS_TO_DEGREES(-body->a);
		}
	}
	cpBodyResetForces(shape->body);
}

typedef struct tSCProtectWrapper_ {
	VALUE obj;
	ID method;
	VALUE delta;
} tSCProtectWrapper;

static VALUE sc_protect_wrapper(VALUE arg) {
	tSCProtectWrapper *w = (tSCProtectWrapper *)arg;
	return sc_protect_funcall(w->obj, w->method, 1, w->delta);
}

static VALUE sc_set_critical(VALUE value)
{
    rb_thread_critical = (int)value;
    return Qundef;
}


@interface CocosNode (SC_Extension)
// actions
- (void)rb_on_enter;
- (void)rb_on_enter_transition_did_finish;
- (void)rb_on_exit;
- (void)rb_dealloc;
- (void)rb_draw;

// chipmunk support
- (void)chipmunk_step:(ccTime)delta;
// ruby schedule support
- (void)rbScheduler:(ccTime)delta;
// standard event handler
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
// targeted event handler
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;
// accelerometer delegate
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
// UI Control target
- (void)action:(id)sender;
// text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
// simplified alert view delegate protocol
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)alertViewCancel:(UIAlertView *)alertView;
@end

@implementation CocosNode (SC_Extension)
- (void)rb_on_enter {
	[self rb_on_enter];
	// call the ruby version
	if (userData) {
		sc_protect_funcall((VALUE)userData, id_sc_on_enter, 0, 0);
	}
}

- (void)rb_on_enter_transition_did_finish {
	[self rb_on_enter_transition_did_finish];
	// call the ruby version
	if (userData) {
		sc_protect_funcall((VALUE)userData, sc_id_on_enter_transition_did_finish, 0, 0);
	}
}

- (void)rb_on_exit {
	[self rb_on_exit];
	// call the ruby version
	if (userData) {
		sc_protect_funcall((VALUE)userData, id_sc_on_exit, 0, 0);
	}
}

- (void)rb_dealloc {
	[self rb_dealloc];
	if (userData) {
		// get rid of scheduledMethods if any
		hashMethod tmpMethod;
		tmpMethod.object = (VALUE)userData;
		hashMethod *methods = ccHashSetFind(scheduledMethods, CC_HASH_INT(userData), &tmpMethod);
		if (methods) {
			VALUE rb_methods = methods->methods;
			rb_gc_unregister_address(&rb_methods);
		}
	}
}

- (void)rb_draw {
	[self rb_draw];
	if (userData) {
		sc_protect_funcall((VALUE)userData, id_sc_draw, 0, 0);
	}
}

- (void)chipmunk_step:(ccTime)delta {
	if (!userData)
		return;
	VALUE rb_space = rb_ivar_get((VALUE)userData, id_sc_ivar_space);
	if (rb_space == Qnil)
		return;
	cpSpace *space = SPACE(rb_space);
	int steps = 1, i;
	cpFloat dt = ([Director sharedDirector].animationInterval)/(cpFloat)steps;
	
	for(i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
	
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
}

- (void)rbScheduler:(ccTime)delta {
	if (!userData)
		return;
	hashMethod tmpMethod;
	tmpMethod.object = (VALUE)userData;
	hashMethod *methods = ccHashSetFind(scheduledMethods, CC_HASH_INT(userData), &tmpMethod);
	if (methods) {
		int i;
		VALUE rb_delta = rb_float_new(delta);
		VALUE rb_methods = methods->methods;
		for (i=0; i < RARRAY_LEN(rb_methods); i++) {
			ID m_id = rb_to_id(RARRAY_PTR(rb_methods)[i]);
			sc_protect_funcall((VALUE)userData, m_id, 1, rb_delta);
		}
	} else {
		CCLOG(@"running scheduled method for %d, but no ary set?", userData);
	}
}

- (void)action:(id)sender {
	if (userData) {
		VALUE rbSender = sc_ruby_instance_for(sc_object_hash, sender);
		sc_protect_funcall((VALUE)userData, id_sc_ui_action, 1, rbSender);
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (userData) {
		VALUE rbTextField = sc_ruby_instance_for(sc_object_hash, textField);
		if (sc_protect_funcall((VALUE)userData, id_sc_text_field_action, 1, rbTextField) != Qnil) {
			return YES;
		}
	}
	return NO;
}

/* standard event handler */
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (userData) {
		if (RTEST(sc_protect_funcall((VALUE)userData, id_sc_touches_began, 1, rb_ary_with_set(touches)))) {
			return kEventHandled;
		}
	}
	return kEventIgnored;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (userData) {
		if (RTEST(sc_protect_funcall((VALUE)userData, id_sc_touches_moved, 1, rb_ary_with_set(touches)))) {
			return kEventHandled;
		}
	}
	return kEventIgnored;
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (userData) {
		if (RTEST(sc_protect_funcall((VALUE)userData, id_sc_touches_ended, 1, rb_ary_with_set(touches)))) {
			return kEventHandled;
		}
	}
	return kEventIgnored;
}

- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (userData) {
		if (RTEST(sc_protect_funcall((VALUE)userData, id_sc_touches_cancelled, 1, rb_ary_with_set(touches)))) {
			return kEventHandled;
		}
	}
	return kEventIgnored;
}



/* targeted event handler */
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (userData) {
		if (sc_protect_funcall((VALUE)userData, id_sc_touch_began, 1, rb_hash_with_touch(touch)) != Qfalse) {
			return kEventHandled;
		}
	}
	return kEventIgnored;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	if (userData) {
		sc_protect_funcall((VALUE)userData, id_sc_touch_moved, 1, rb_hash_with_touch(touch));
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	if (userData) {
		sc_protect_funcall((VALUE)userData, id_sc_touch_ended, 1, rb_hash_with_touch(touch));
	}
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
	if (userData) {
		sc_protect_funcall((VALUE)userData, id_sc_touch_cancelled, 1, rb_hash_with_touch(touch));
	}
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	if (userData) {
		VALUE rb_arr = rb_ary_new3(3,
								   rb_float_new(acceleration.x),
								   rb_float_new(acceleration.y),
								   rb_float_new(acceleration.z));
		sc_protect_funcall((VALUE)userData, id_sc_did_accelerate, 1, rb_arr);
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (userData) {
		sc_protect_funcall((VALUE)userData, id_sc_alert_view_clicked_button, 1, INT2FIX(buttonIndex));
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (userData) {
		sc_protect_funcall((VALUE)userData, id_sc_alert_view_did_dismiss, 1, INT2FIX(buttonIndex));
	}
}

- (void)alertViewCancel:(UIAlertView *)alertView {
	if (userData) {
		sc_protect_funcall((VALUE)userData, id_sc_alert_view_cancel, 0, 0);
	}
}
@end

# pragma mark Properties


/* 
 * call-seq:
 *   node.parent   => CocosNode
 * 
 * Returns the parent of the node
 */
VALUE rb_cCocosNode_parent(VALUE object) {
	return (VALUE)(((CocosNode *)CC_NODE(object).parent).userData);
}

/* 
 * call-seq:
 *   node.parent = another_node
 *
 * Sets the parent of the node
 */
VALUE rb_cCocosNode_set_parent(VALUE object, VALUE p) {
	CHECK_SUBCLASS(p, rb_cCocosNode);
	[CC_NODE(object) setParent: CC_NODE(p)];
	return p;
}


/* 
 * call-seq:
 *   node.opacity = 0.3
 *
 * Sets the opacity of the sprite
 */
VALUE rb_cCocosNode_set_opacity(VALUE object, VALUE o) {
	[(<CocosNodeRGBA>)CC_NODE(object) setOpacity: NUM2DBL(o)];
	return object;
}


/* 
 * call-seq:
 *   node.z_order   => Integer
 * 
 * Returns the z_order of the node
 */
VALUE rb_cCocosNode_z_order(VALUE object) {
	return INT2FIX(CC_NODE(object).zOrder);
}

/* 
 * call-seq:
 *   node.z_order = 4
 *
 * Sets the z order of the sprite
 */
VALUE rb_cCocosNode_set_z_order(VALUE object, VALUE z) {
	[CC_NODE(object).parent reorderChild: CC_NODE(object) z: FIX2INT(z)];
	return z;
}


/*
 * call-seq:
 *   node.color   #=> [r,g,b]
 *
 * gets the color as a 3 element array
 */
VALUE rb_cCocosNode_color(VALUE object) {
	ccColor3B color = ((<CocosNodeRGBA>)CC_NODE(object)).color;
	return rb_ary_new3(3, INT2FIX(color.r), INT2FIX(color.g), INT2FIX(color.g));
}


/*
 * call-seq:
 *   node.color = [r,g,b]   #=> [r,g,b]
 *
 * sets the color of the node as a 3 element array
 */
VALUE rb_cCocosNode_set_color(VALUE object, VALUE array) {
	Check_Type(array, T_ARRAY);
	if (RARRAY_LEN(array) < 3) {
		rb_raise(rb_eArgError, "invalid color array length");
		return Qnil;
	}
	ccColor3B color;
	color.r = FIX2INT(RARRAY_PTR(array)[0]);
	color.g = FIX2INT(RARRAY_PTR(array)[1]);
	color.b = FIX2INT(RARRAY_PTR(array)[2]);
	((<CocosNodeRGBA>)CC_NODE(object)).color = color;
	return array;
}



/* 
 *  call-seq:
 *     node.rotation   => Float
 * 
 * Returns the rotation of the sprite
 */
VALUE rb_cCocosNode_rotation(VALUE object) {
	return rb_float_new(CC_NODE(object).rotation);
}

/* 
 * call-seq:
 *   node.rotation = 15.0
 *
 * Sets the rotation of the sprite
 */
VALUE rb_cCocosNode_set_rotation(VALUE object, VALUE rotation) {
	CC_NODE(object).rotation = NUM2DBL(rotation);
	return rotation;
}

/* 
 *   node.scale #=> float
 */
VALUE rb_cCocosNode_scale(VALUE object) {
	return rb_float_new(CC_NODE(object).scale);
}

/* 
 *   node.scale = 0.5
 */
VALUE rb_cCocosNode_set_scale(VALUE object, VALUE scale) {
	Check_Type(scale, T_FLOAT);
	CC_NODE(object).scale = NUM2DBL(scale);
	return scale;
}

/* 
 *   node.scale_x #=> float
 */
VALUE rb_cCocosNode_scale_x(VALUE object) {
	return rb_float_new(CC_NODE(object).scaleX);
}

/* 
 *   node.scale_x = 1.1
 */
VALUE rb_cCocosNode_set_scale_x(VALUE object, VALUE scale_x) {
	Check_Type(scale_x, T_FLOAT);
	CC_NODE(object).scaleY = NUM2DBL(scale_x);
	return scale_x;
}

/* 
 *   node.scale_y #=> float
 */
VALUE rb_cCocosNode_scale_y(VALUE object) {
	return rb_float_new(CC_NODE(object).scaleY);
}

/* 
 *   node.scale_y = 0.3
 */
VALUE rb_cCocosNode_set_scale_y(VALUE object, VALUE scale_y) {
	Check_Type(scale_y, T_FLOAT);
	CC_NODE(object).scaleY = NUM2DBL(scale_y);
	return scale_y;
}

/* 
 *   node.position #=> [x,y]
 */
VALUE rb_cCocosNode_position(VALUE object) {
	cpVect v = CC_NODE(object).position;
	return rb_ary_new3(2, rb_float_new(v.x), rb_float_new(v.y));
}

/* 
 *   node.position = [x,y] #=> [x,y]
 */
VALUE rb_cCocosNode_set_position(VALUE object, VALUE position) {
	Check_Type(position, T_ARRAY);
	if (RARRAY_LEN(position) == 2) {
		CC_NODE(object).position = cpv(NUM2DBL(RARRAY_PTR(position)[0]), NUM2DBL(RARRAY_PTR(position)[1]));
		return position;
	} else {
		CCLOG(@"Invalid array size for position");
		return Qnil;
	}
}

/* 
 *   node.visible? #=> true or false
 */
VALUE rb_cCocosNode_visible(VALUE object) {
	return CC_NODE(object).visible ? Qtrue : Qfalse;
}

/* 
 * Sets the node's visibility
 * 
 *   node.visible = true
 */
VALUE rb_cCocosNode_set_visible(VALUE object, VALUE visible) {
	CC_NODE(object).visible = (visible == Qfalse) ? NO : YES;
	return (visible == Qfalse) ? Qfalse : Qtrue;
}

/* 
 *   node.tag #=> Integer
 */
VALUE rb_cCocosNode_tag(VALUE object) {
	return INT2FIX(CC_NODE(object).tag);
}

/* 
 * Sets the node's tag, it should be an integer.
 * 
 *   node.tag = MY_TAG
 */
VALUE rb_cCocosNode_set_tag(VALUE object, VALUE tag) {
	CC_NODE(object).tag = FIX2INT(tag);
	return tag;
}

/*
 * Returns the node's anchor point as an array of floats
 */
VALUE rb_cCocosNode_anchor_point(VALUE object) {
	cpVect anchor = CC_NODE(object).anchorPoint;
	return rb_ary_new3(2, rb_float_new(anchor.x), rb_float_new(anchor.y));
}


/*
 * call-seq:
 *  node.anchor_point = [x,y]   #=> [x,y]
 *
 * Sets the anchor point for the node. By deafult is its center.
 */
VALUE rb_cCocosNode_set_anchor_point(VALUE object, VALUE rb_anchor) {
	Check_Type(rb_anchor, T_ARRAY);
	if (RARRAY_LEN(rb_anchor) < 2)
		rb_raise(rb_eArgError, "Invalid array size");
	cpVect anchor;
	anchor.x = NUM2DBL(RARRAY_PTR(rb_anchor)[0]);
	anchor.y = NUM2DBL(RARRAY_PTR(rb_anchor)[1]);
	CC_NODE(object).anchorPoint = anchor;
	return rb_anchor;
}


/*
 * call-seq:
 *   node.content_size   #=> [width, height]
 *
 * returns the content size of a node
 */
VALUE rb_cCocosNode_content_size(VALUE object) {
	CGSize cs = CC_NODE(object).contentSize;
	return rb_ary_new3(2, rb_float_new(cs.width), rb_float_new(cs.height));
}

#pragma mark Methods

/* 
 * call-seq:
 *     node = CocosNode.new    #=> CocosNode
 *     node = CocosNodeSubclass.new(a,b)   #=> CocosNode
 * 
 * Use this when subclassing CocosNode and your initializer uses
 * arguments.
 */
VALUE rb_cCocosNode_s_new(int argc, VALUE *argv, VALUE klass) {
	id node;
	if (argc > 0 && argv[0] == ID2SYM(rb_intern("parallax"))) {
		node = [[ParallaxNode alloc] init];
		argc -= 1;
		argv += 1;
	} else {
		node = [[CocosNode alloc] init];
	}
	VALUE obj = sc_init(klass, nil, node, argc, argv, YES);
	// set the userData field in CocosNode to point to the ruby object
	((CocosNode *)node).userData = (void *)obj;
	
	return obj;
}


/*
 * call-seq:
 *   node = CocosNode.new    #=> a new CocosNode
 */
VALUE rb_cCocosNode_init(int argc, VALUE *argv, VALUE object) {
	return object;
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
	// get the children array
	VALUE children_ary = rb_ivar_get(object, id_sc_ivar_children);
	if (children_ary == Qnil) {
		children_ary = rb_ivar_set(object, id_sc_ivar_children, rb_ary_new());
	}
	// set default values
	int z_order = CC_NODE(args[0]).zOrder;
	int tag     = CC_NODE(args[0]).tag;
	VALUE parallaxRatio = Qnil;
	if (argc == 2) {
		Check_Type(args[1], T_HASH);
		VALUE _tmp = Qnil;
		if ((_tmp = rb_hash_aref(args[1], sym_sc_z)) != Qnil)
			z_order = FIX2INT(_tmp);
		if ((_tmp = rb_hash_aref(args[1], sym_sc_tag)) != Qnil)
			tag = FIX2INT(_tmp);
		if ((_tmp = rb_hash_aref(args[1], sym_sc_parallax_ratio)) != Qnil) {
			parallaxRatio = _tmp;
		}
	}
	if (parallaxRatio != Qnil) {
		Check_Type(parallaxRatio, T_ARRAY);
		cpVect v = cpv(NUM2DBL(RARRAY_PTR(parallaxRatio)[0]), NUM2DBL(RARRAY_PTR(parallaxRatio)[1]));
		[CC_PXNODE(object) addChild:CC_NODE(args[0]) z:z_order parallaxRatio:v positionOffset:cpvzero];
	} else {
		[CC_NODE(object) addChild:CC_NODE(args[0]) z:z_order tag:tag];
	}
	// now add the child to the children ary
	rb_ary_push(children_ary, args[0]);
	return args[0];
}


/*
 * call-seq:
 *   node.remove_child(some_child)   #=> node
 *
 * removes a child from the children's list.
 */
VALUE rb_cCocosNode_remove_child(VALUE object, VALUE child) {
	[CC_NODE(object) removeChild:CC_NODE(child) cleanup:YES];
	// remove the child from the children array
	VALUE children_ary = rb_ivar_get(object, id_sc_ivar_children);
	rb_ary_delete(children_ary, object);
	return object;
}


/*
 * call-seq:
 *   node.child_with_tag(tag)   #=> CocosNode
 *
 * returns the child with the specified tag. Nil if there's no child with that tag.
 */
VALUE rb_cCocosNode_child_with_tag(VALUE object, VALUE tag) {
	id child = [CC_NODE(object) getChildByTag:FIX2INT(tag)];
	if (child)
		return (VALUE)(((CocosNode *)child).userData);
	return Qnil;
}


/*
 * call-seq:
 *   node.children   #=> array of children (empty if no children has been added)
 */
VALUE rb_cCocosNode_children(VALUE object) {
	return rb_ivar_get(object, id_sc_ivar_children);
}


/*
 * call-seq:
 *    node.run_action(action)   #=> nil
 *
 * +action+ must be a subclass of Cocos2D::Actions::Action.
 */
VALUE rb_cCocosNode_run_action(VALUE object, VALUE action) {
	CHECK_SUBCLASS(action, rb_cAction);
	[CC_NODE(object) runAction:CC_ACTION(action)];
	
	return object;
}

/*
 * call-seq:
 *    node.stop_action(action)   #=> nil
 *
 * will stop a specific action
 */
VALUE rb_cCocosNode_stop_action(VALUE object, VALUE action) {
	CHECK_SUBCLASS(action, rb_cAction);
	[CC_NODE(object) stopAction:CC_ACTION(action)];
	
	return object;
}

/*
 * call-seq:
 *    node.stop_actions()   #=> nil
 *
 * will stop all actions
 */
VALUE rb_cCocosNode_stop_actions(VALUE object) {
	[CC_NODE(object) stopAllActions];
	
	return object;
}

/*
 * Will set the node as the stepper for chipmunk (will run the
 * <tt>chipmunk_step:</tt> selector).
 *
 * The default stepper iterates only over the active shapes, not the static
 * ones. Also, when becoming the stepper, it must have an instance variable
 * named +@space+.
 *
 * Currently, the code for the stepper is:
 *
 *   int steps = 1, i;
 *   cpFloat dt = 1.0f/60.0f/(cpFloat)steps;
 *   
 *   for(i=0; i<steps; i++){
 *       cpSpaceStep(space, dt);
 *   }
 *   cpSpaceHashEach(space->activeShapes, &eachShape, nil);
 *
 * You can read a small discussion about this stepper here:
 *
 * http://www.cocos2d-iphone.org/forum/topic/596
 */
VALUE rb_cCocosNode_become_chipmunk_stepper(VALUE object) {
	[CC_NODE(object) schedule:@selector(chipmunk_step:)];
	
	return object;
}

/*
 * Will bind a Chipmunk Shape to a CocosNode (will create an ivar named
 * cc_node in the shape and set it to the node)
 */
VALUE rb_cCocosNode_attach_chipmunk_shape(VALUE object, VALUE rb_shape) {
	rb_ivar_set(rb_shape, id_sc_ivar_cc_node, object);
	rb_ivar_set(object, id_sc_ivar_shape, rb_shape);
	
	return rb_shape;
}

/*
 * Will schedule a method to be called every frame
 * 
 *   node.schedule(:every_frame)   #=> node
 * 
 * <tt>:every_frame</tt> on <tt>node</tt> will be called every frame.
 */
VALUE rb_cCocosNode_schedule(VALUE object, VALUE method) {	
	Check_Type(method, T_SYMBOL);
	hashMethod tmpMethod;
	tmpMethod.object = (VALUE)object;
	hashMethod *methods = (hashMethod *)ccHashSetFind(scheduledMethods, CC_HASH_INT(object), &tmpMethod);
	if (!methods) {
		CCLOG(@"**** inserting new scheduled method for object %d", object);
		methods = (hashMethod *)malloc(sizeof(hashMethod));
		methods->object = object;
		VALUE rb_methods = rb_ary_new3(1, method);
		methods->methods = rb_methods;
		rb_gc_register_address(&rb_methods);
		ccHashSetInsert(scheduledMethods, CC_HASH_INT(object), methods, nil);
		[CC_NODE(object) schedule:@selector(rbScheduler:)];
	} else {
		rb_ary_push(methods->methods, method);
	}
	
	return object;
}

/*
 * will remove a scheduled method
 */
VALUE rb_cCocosNode_unschedule(VALUE object, VALUE method) {
	Check_Type(method, T_SYMBOL);
	hashMethod tmpMethod;
	tmpMethod.object = (VALUE)object;
	hashMethod *methods = (hashMethod *)ccHashSetFind(scheduledMethods, CC_HASH_INT(object), &tmpMethod);
	if (methods) {
		sc_protect_funcall(methods->methods, id_sc_delete, 1, method);
		if (RARRAY_LEN(methods) == 0) {
			// empty array, unschedule the ruby scheduler
			[CC_NODE(object) unschedule:@selector(rbScheduler)];
			// and remove the object from the hash
			VALUE rb_methods = methods->methods;
			rb_gc_unregister_address(&rb_methods);
			ccHashSetRemove(scheduledMethods, CC_HASH_INT(object), methods);
			free(methods);
		}
		return methods->methods;
	}
	return Qnil;
}

/*
 * call-seq:
 *   node.become_accelerometer_delegate   #=> node
 *
 * Will become the shared accelerometer's delegate. The node must implement
 * +did_accelerate(accel)+, where +accel+ is an array of three floats (acceleration
 * in axis x, y and z respectively.
 */
VALUE rb_cCocosNode_become_accelerometer_delegate(VALUE object) {
	[UIAccelerometer sharedAccelerometer].delegate = (id)CC_NODE(object);
	return object;
}

/*
 * call-seq:
 *   node.world_to_node_space([a,b])   #=> new array in node space
 */
VALUE rb_cCocosNode_world_to_node_space(VALUE object, VALUE point) {
	Check_Type(point, T_ARRAY);
	if (RARRAY_LEN(point) < 2) {
		rb_raise(rb_eArgError, "Invalid argument");
	}
	CGPoint wp = CGPointMake(NUM2DBL(RARRAY_PTR(point)[0]), NUM2DBL(RARRAY_PTR(point)[1]));
	CGPoint np = [CC_NODE(object) convertToWorldSpace:wp];
	return rb_ary_new3(2, rb_float_new(np.x), rb_float_new(np.y));
}

/*
 * call-seq:
 *   node.camera_eye   => [x,y,z]
 * 
 * returns the camera eye as an array of 3 floats
 */
VALUE rb_cCocosNode_camera_eye(VALUE object) {
	float x, y, z;
	[CC_NODE(object).camera eyeX:&x eyeY:&y eyeZ:&z];
	
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
	VALUE x = RARRAY_PTR(position)[0];
	VALUE y = RARRAY_PTR(position)[1];
	VALUE z = RARRAY_PTR(position)[2];
	[CC_NODE(object).camera setEyeX:NUM2DBL(x) eyeY:NUM2DBL(y) eyeZ:NUM2DBL(z)];
	
	return position;
}

/*
 * call-seq:
 *   node.camera_center   => [x,y,z]
 * 
 * returns the camera center as an array of 3 floats
 */
VALUE rb_cCocosNode_camera_center(VALUE object) {
	float x, y, z;
	[CC_NODE(object).camera centerX:&x centerY:&y centerZ:&z];
	
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
	VALUE x = RARRAY_PTR(position)[0];
	VALUE y = RARRAY_PTR(position)[1];
	VALUE z = RARRAY_PTR(position)[2];
	[CC_NODE(object).camera setCenterX:NUM2DBL(x) centerY:NUM2DBL(y) centerZ:NUM2DBL(z)];
	
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
 * returns info about the object
 */
VALUE rb_cCocosNode_inspect(VALUE object) {
	CocosNode *tmp = CC_NODE(object);
	NSString *str = [NSString stringWithFormat:@"<#%s position:%f,%f (desc: %@)>",
					 rb_obj_classname(object), tmp.position.x, tmp.position.y, [tmp description]];
	return rb_str_new2([str cStringUsingEncoding:NSUTF8StringEncoding]);
}

/*
 * The ruby equivalent of the CocosNode class - not yet complete
 */
void init_rb_cCocosNode() {
	rb_cCocosNode = rb_define_class_under(rb_mCocos2D, "CocosNode", rb_cObject);
	rb_define_singleton_method(rb_cCocosNode, "new", rb_cCocosNode_s_new, -1);
	rb_define_method(rb_cCocosNode, "initializer", rb_cCocosNode_init, -1);
	
	// getters
	rb_define_method(rb_cCocosNode, "parent", rb_cCocosNode_parent, 0);
	rb_define_method(rb_cCocosNode, "z_order", rb_cCocosNode_z_order, 0);
	rb_define_method(rb_cCocosNode, "color", rb_cCocosNode_color, 0);
	rb_define_method(rb_cCocosNode, "rotation", rb_cCocosNode_rotation, 0);
	rb_define_method(rb_cCocosNode, "scale", rb_cCocosNode_scale, 0);
	rb_define_method(rb_cCocosNode, "scale_x", rb_cCocosNode_scale_x, 0);
	rb_define_method(rb_cCocosNode, "scale_y", rb_cCocosNode_scale_y, 0);
	rb_define_method(rb_cCocosNode, "position", rb_cCocosNode_position, 0);
	rb_define_method(rb_cCocosNode, "visible?", rb_cCocosNode_visible, 0);
	rb_define_method(rb_cCocosNode, "tag", rb_cCocosNode_tag, 0);
	rb_define_method(rb_cCocosNode, "anchor_point", rb_cCocosNode_anchor_point, 0);
	rb_define_method(rb_cCocosNode, "content_size", rb_cCocosNode_content_size, 0);

	// setters
	rb_define_method(rb_cCocosNode, "parent=", rb_cCocosNode_set_parent, 1);
	rb_define_method(rb_cCocosNode, "z_order=", rb_cCocosNode_set_z_order, 1);
	rb_define_method(rb_cCocosNode, "opacity=", rb_cCocosNode_set_opacity, 1);	
	rb_define_method(rb_cCocosNode, "color=", rb_cCocosNode_set_color, 1);
	rb_define_method(rb_cCocosNode, "rotation=", rb_cCocosNode_set_rotation, 1);
	rb_define_method(rb_cCocosNode, "scale=", rb_cCocosNode_set_scale, 1);
	rb_define_method(rb_cCocosNode, "scale_x=", rb_cCocosNode_set_scale_x, 1);
	rb_define_method(rb_cCocosNode, "scale_y=", rb_cCocosNode_set_scale_y, 1);
	rb_define_method(rb_cCocosNode, "position=", rb_cCocosNode_set_position, 1);
	rb_define_method(rb_cCocosNode, "visible=", rb_cCocosNode_set_visible, 1);
	rb_define_method(rb_cCocosNode, "tag=", rb_cCocosNode_set_tag, 1);
	rb_define_method(rb_cCocosNode, "anchor_point=", rb_cCocosNode_set_anchor_point, 1);
	
	// misc
	rb_define_method(rb_cCocosNode, "add_child", rb_cCocosNode_add_child, -1);
	rb_define_method(rb_cCocosNode, "remove_child", rb_cCocosNode_remove_child, 1);
	rb_define_method(rb_cCocosNode, "child_with_tag", rb_cCocosNode_child_with_tag, 1);
	rb_define_method(rb_cCocosNode, "children", rb_cCocosNode_children, 0);
	rb_define_method(rb_cCocosNode, "run_action", rb_cCocosNode_run_action, 1);
	rb_define_method(rb_cCocosNode, "stop_action", rb_cCocosNode_stop_action, 1);
	rb_define_method(rb_cCocosNode, "stop_actions", rb_cCocosNode_stop_actions, 0);
	rb_define_method(rb_cCocosNode, "become_chipmunk_stepper", rb_cCocosNode_become_chipmunk_stepper, 0);
	rb_define_method(rb_cCocosNode, "attach_chipmunk_shape", rb_cCocosNode_attach_chipmunk_shape, 1);
	rb_define_method(rb_cCocosNode, "schedule", rb_cCocosNode_schedule, 1);
	rb_define_method(rb_cCocosNode, "unschedule", rb_cCocosNode_unschedule, 1);
	rb_define_method(rb_cCocosNode, "become_accelerometer_delegate", rb_cCocosNode_become_accelerometer_delegate, 0);
	
	// point conversion
	rb_define_method(rb_cCocosNode, "world_to_node_space", rb_cCocosNode_world_to_node_space, 1);
	
	// camera
	rb_define_method(rb_cCocosNode, "camera_eye", rb_cCocosNode_camera_eye, 0);
	rb_define_method(rb_cCocosNode, "camera_eye=", rb_cCocosNode_set_camera_eye, 1);
	rb_define_method(rb_cCocosNode, "camera_center", rb_cCocosNode_camera_center, 0);
	rb_define_method(rb_cCocosNode, "camera_center=", rb_cCocosNode_set_camera_center, 1);
	
	// actions
	rb_define_method(rb_cCocosNode, "on_enter", rb_cCocosNode_on_enter, 0);
	rb_define_method(rb_cCocosNode, "on_exit", rb_cCocosNode_on_exit, 0);
	rb_define_method(rb_cCocosNode, "draw", rb_cCocosNode_draw, 0);
	
	// inspect
	rb_define_method(rb_cCocosNode, "inspect", rb_cCocosNode_inspect, 0);
	
	// replace the common actions on the CocosNode class
	sc_method_swap([CocosNode class], @selector(onEnter), @selector(rb_on_enter));
	sc_method_swap([CocosNode class], @selector(onEnterTransitionDidFinish), @selector(rb_on_enter_transition_did_finish));
	sc_method_swap([CocosNode class], @selector(onExit), @selector(rb_on_exit));
	sc_method_swap([CocosNode class], @selector(dealloc), @selector(rb_dealloc));
	
	// hash for scheduled methods
	scheduledMethods = ccHashSetNew(20, scheduledMethodsEql);
}
