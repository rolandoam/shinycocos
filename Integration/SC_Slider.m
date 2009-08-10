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
#import "SC_Slider.h"

VALUE rb_cSlider;


/*
 * call-seq:
 *   Slider.new(size, landscape, text)   #=> a UISlider
 *
 * size is an array of 4 floats, text is a string, can be nil. Landscape is to rotate the slider
 */
VALUE rb_cSlider_s_new(int argc, VALUE *argv, VALUE klass) {
	if (argc < 2) {
		rb_raise(rb_eArgError, "Invalid number of arguments");
	}
	Check_Type(argv[0], T_ARRAY);
	UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(FIX2INT(RARRAY_PTR(argv[0])[0]), FIX2INT(RARRAY_PTR(argv[0])[1]), FIX2INT(RARRAY_PTR(argv[0])[2]), FIX2INT(RARRAY_PTR(argv[0])[3]))];
	// rotate to portrait
	if (argv[1] != Qfalse)
		[slider setTransform:CGAffineTransformMakeRotation(3.14/2)];
	VALUE ret = sc_init(klass, nil, slider, argc-2, argv+2, YES);
	sc_add_tracking(sc_object_hash, slider, ret);
	
	return ret;
}


/*
 * call-seq:
 *   slider.attach   #=> nil
 *
 * attaches the slider to the openGLView of the Director
 */
VALUE rb_cSlider_attach(VALUE object) {
	[[Director sharedDirector].openGLView addSubview:UI_SLIDER(object)];
	return Qnil;
}


/*
 * call-seq:
 *   slider.detach   #=> nil
 *
 * detaches the slider from the openGLView of the Director
 */
VALUE rb_cSlider_detach(VALUE object) {
	[UI_SLIDER(object) removeFromSuperview];
	return Qnil;
}


/*
 * call-seq:
 *   slider.value   #=> float
 *
 * returns the current value of the slider as a float
 */
VALUE rb_cSlider_value(VALUE object) {
	return rb_float_new(UI_SLIDER(object).value);
}


/*
 * call-seq:
 *   slider.value = float   #=> float
 *
 * sets the current value of the slider
 */
VALUE rb_cSlider_set_value(VALUE object, VALUE rb_value) {
	Check_Type(rb_value, T_FLOAT);
	UI_SLIDER(object).value = NUM2DBL(rb_value);
	return rb_value;
}


/*
 * call-seq:
 *   slider.add_target(target, event)   #=> target
 *
 * adds a target for the specified event. target *must* be a cocos node subclass.
 */
VALUE rb_cSlider_add_target(VALUE object, VALUE target, VALUE event) {
	CHECK_SUBCLASS(target, rb_cCocosNode)
	[UI_SLIDER(object) addTarget:CC_NODE(target) action:@selector(action:) forControlEvents:FIX2INT(event)];
	return target;
}


void init_rb_cSlider() {
	rb_cSlider = rb_define_class_under(rb_mCocos2D, "Slider", rb_cObject);
	rb_define_singleton_method(rb_cSlider, "new", rb_cSlider_s_new, -1);
	rb_define_method(rb_cSlider, "attach", rb_cSlider_attach, 0);
	rb_define_method(rb_cSlider, "detach", rb_cSlider_detach, 0);
	rb_define_method(rb_cSlider, "value", rb_cSlider_value, 0);
	rb_define_method(rb_cSlider, "value=", rb_cSlider_set_value, 1);
	rb_define_method(rb_cSlider, "add_target", rb_cSlider_add_target, 2);
	// need to add the rest of the constants, but first check issue#12 !!!
	rb_define_const(rb_cSlider, "EVENT_VALUE_CHANGED", INT2FIX(UIControlEventValueChanged));
	rb_define_const(rb_cSlider, "EVENT_ALL_EVENTS", INT2FIX(UIControlEventAllEvents));
}
