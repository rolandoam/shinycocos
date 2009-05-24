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
#import <UIKit/UIKit.h>
#import "SC_common.h"
#import "SC_Layer.h"
#import "SC_CocosNode.h"

VALUE rb_cLayer;

@interface RBLayer : Layer
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
- (VALUE)rbArrayWithSet:(NSSet *)touches;
@end

@implementation RBLayer
- (VALUE)rbArrayWithSet:(NSSet *)touches {
	NSArray *arr = [touches allObjects];
	VALUE rb_arr = rb_ary_new2([arr count]);
	for (UITouch *touch in arr) {
		// touch should be a hash in the ruby world
		// with keys like :location, :tap_count, :timestamp
		CGPoint loc = [touch locationInView:[touch view]];
		NSUInteger taps = [touch tapCount];
		VALUE h = rb_hash_new();
		rb_hash_aset(h, ID2SYM(id_sc_location), rb_ary_new3(2, rb_float_new(loc.x), rb_float_new(loc.y)));
		rb_hash_aset(h, ID2SYM(id_sc_tap_count), INT2FIX(taps));
		rb_ary_push(rb_arr, h);
	}
	return rb_arr;
}

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	VALUE obj = sc_ruby_instance_for(sc_object_hash, self);
	if (obj != Qnil) {
		if (rb_respond_to(obj, id_sc_touches_began)) {
			rb_funcall(obj, id_sc_touches_began, 1, [self rbArrayWithSet:touches]);
			return YES;
		}
	}
	return NO;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	VALUE obj = sc_ruby_instance_for(sc_object_hash, self);
	if (obj != Qnil) {
		if (rb_respond_to(obj, id_sc_touches_moved)) {
			rb_funcall(obj, id_sc_touches_moved, 1, [self rbArrayWithSet:touches]);
			return YES;
		}
	}
	return NO;
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	VALUE obj = sc_ruby_instance_for(sc_object_hash, self);
	if (obj != Qnil) {
		if (rb_respond_to(obj, id_sc_touches_ended)) {
			rb_funcall(obj, id_sc_touches_ended, 1, [self rbArrayWithSet:touches]);
			return YES;
		}
	}
	return NO;
}

- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	VALUE obj = sc_ruby_instance_for(sc_object_hash, self);
	if (obj != Qnil) {
		if (rb_respond_to(obj, id_sc_touches_cancelled)) {
			rb_funcall(obj, id_sc_touches_cancelled, 1, [self rbArrayWithSet:touches]);
			return YES;
		}
	}
	return NO;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	VALUE obj = sc_ruby_instance_for(sc_object_hash, self);
	if (obj != Qnil) {
		if (rb_respond_to(obj, id_sc_did_accelerate)) {
			VALUE rb_arr = rb_ary_new3(3,
				rb_float_new(acceleration.x),
				rb_float_new(acceleration.y),
				rb_float_new(acceleration.z));
			rb_funcall(obj, id_sc_did_accelerate, 1, rb_arr);
		}
	}
}
@end


/*
 * call-seq:
 *   layer = Layer.new   #=> Layer
 *
 * Creates a new layer
 */
VALUE rb_cLayer_s_new(int argc, VALUE *argv, VALUE klass) {
	Layer *layer = [[RBLayer alloc] init];
	VALUE ret = sc_init(klass, nil, layer, argc, argv, YES);
	sc_add_tracking(sc_object_hash, layer, ret);
	
	return ret;
}

/*
 * call-seq:
 *   layer.enable_touch(true)  #=> true or false
 *
 * Enables/disables the touch capabilities of the layer. When enabling
 * the touch capabilities, the following method could be called:
 *
 * * <tt>touches_began</tt>
 * * <tt>touches_moved</tt>
 * * <tt>touches_ended</tt>
 *
 * All of these methods receive a <tt>touches</tt> argument, which is an
 * array of hashes, where the <tt>:location</tt> element is the position
 * of the touch (as an array of 2 floats), and the <tt>:tap_count</tt>
 * element is an integer.
 */
VALUE rb_cLayer_enable_touch(VALUE obj, VALUE enable) {
	cocos_holder *ptr;
	Data_Get_Struct(obj, cocos_holder, ptr);
	CC_LAYER(ptr).isTouchEnabled = !(enable == Qfalse);
	return !(enable == Qfalse);
}

/*
 * call-seq:
 *   layer.enable_accelerometer(true)  #=> true or false
 *
 * Enables/disables the accelerometer of the layer. The layer should
 * implement <tt>did_accelerate(acceleration)</tt> method. The
 * <tt>acceleration</tt> parameter is an array of 3 floats representing
 * the acceleration in the 3 axes.
 */
VALUE rb_cLayer_enable_accelerometer(VALUE obj, VALUE enable) {
	cocos_holder *ptr;
	Data_Get_Struct(obj, cocos_holder, ptr);
	CC_LAYER(ptr).isAccelerometerEnabled = !(enable == Qfalse);
	return !(enable == Qfalse);
}

/*
 * The ruby equivalent of the Layer node
 */
void init_rb_cLayer() {
	rb_cLayer = rb_define_class_under(rb_mCocos2D, "Layer", rb_cCocosNode);
	rb_define_singleton_method(rb_cLayer, "new", rb_cLayer_s_new, -1);
	
	rb_define_method(rb_cLayer, "enable_touch", rb_cLayer_enable_touch, 1);
	rb_define_method(rb_cLayer, "enable_accelerometer", rb_cLayer_enable_accelerometer, 1);
}
