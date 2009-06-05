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

#import "ruby.h"
#import "cocos2d.h"
#import "SC_common.h"
#import "SC_Director.h"
#import "SC_Scene.h"

VALUE rb_mDirector;

/* 
 * call-seq:
 *   Director.set_orientation(orientation)   #=> orientation
 * 
 * Sets the orientation. You can use one of the constants defined:
 *
 * * <tt>ORIENTATION_LANDSCAPE_LEFT</tt>
 * * <tt>ORIENTATION_LANDSCAPE_RIGHT</tt>
 * * <tt>ORIENTATION_PORTRAIT</tt>
 *
 */
VALUE rb_mDirector_set_orientation(VALUE module, VALUE orientation) {
	[[Director sharedDirector] setDeviceOrientation:FIX2INT(orientation)];
	return orientation;
}

/* 
 * Sets the animation interval of the Director
 */
VALUE rb_mDirector_set_animation_interval(VALUE module, VALUE interval) {
	Check_Type(interval, T_FLOAT);
	[Director sharedDirector].animationInterval = NUM2DBL(interval);
	return interval;
}

/* 
 * Will run a scene
 */
VALUE rb_mDirector_run_scene(VALUE module, VALUE scene) {
	[[Director sharedDirector] runWithScene:CC_SCENE(scene)];
	return scene;
}

/*
 * call-seq:
 *   Director.replace_scene some_scene   #=> some_scene
 *
 * Replaces the current scene with a new one
 */
VALUE rb_mDirector_replace_scene(VALUE module, VALUE scene) {
	[[Director sharedDirector] replaceScene:CC_SCENE(scene)];
	return scene;
}

/*
 * call-seq:
 *   Director.display_fps(true)
 *
 * Will display (or not) the fps
 */
VALUE rb_mDirector_display_fps(VALUE module, VALUE display) {
	[Director sharedDirector].displayFPS = (display == Qtrue) ? YES : NO;
	return display;
}

/*
 * call-seq:
 *   Director.add_event_handler(some_node)   #=> some_node
 */
VALUE rb_mDirector_add_event_handler(VALUE module, VALUE node) {
	[[Director sharedDirector] addEventHandler:CC_NODE(node)];
	return node;
}

/*
 * call-seq:
 *   Director.add_text_field([top, left, width, height], landscape_mode, delegate)   #=> nil
 *
 * Set <tt>landscape_mode</tt> to true if your current orientation is landscape.
 *
 * <tt>delegate</tt> *must* be a CocosNode subclass. Setting a delegate means you have to implement
 * a method <tt>text_field_action</tt> in your class. This method will be called after receiving
 * the <tt>textFieldShouldReturn:</tt> selector in the Obj-C world. It must return true if the
 * text field should resign its first reponder status.
 */
VALUE rb_mDirector_add_text_field(VALUE module, VALUE size, VALUE landscape, VALUE delegate) {
	Check_Type(size, T_ARRAY);
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(FIX2INT(RARRAY_PTR(size)[0]), FIX2INT(RARRAY_PTR(size)[1]), FIX2INT(RARRAY_PTR(size)[2]), FIX2INT(RARRAY_PTR(size)[3]))];
	// rotate to portrait
	if (landscape != Qfalse)
		[textField setTransform:CGAffineTransformMakeRotation(3.14/2)];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.returnKeyType = UIReturnKeyDone;
	if (delegate != Qnil)
		textField.delegate = CC_NODE(delegate);
	[[Director sharedDirector].openGLView addSubview:textField];
	
	return Qnil;
}

/* create the Director class, set the methods */
void init_rb_mDirector() {
	rb_mDirector = rb_define_module_under(rb_mCocos2D, "Director");
	rb_define_module_function(rb_mDirector, "set_orientation", rb_mDirector_set_orientation, 1);
	rb_define_module_function(rb_mDirector, "set_animation_interval", rb_mDirector_set_animation_interval, 1);
	rb_define_module_function(rb_mDirector, "display_fps", rb_mDirector_display_fps, 1);
	rb_define_module_function(rb_mDirector, "run_scene", rb_mDirector_run_scene, 1);
	rb_define_module_function(rb_mDirector, "replace_scene", rb_mDirector_replace_scene, 1);
	rb_define_module_function(rb_mDirector, "add_event_handler", rb_mDirector_add_event_handler, 1);
	rb_define_module_function(rb_mDirector, "add_text_field", rb_mDirector_add_text_field, 3);
	// orientation constants
	rb_define_const(rb_mDirector, "ORIENTATION_LANDSCAPE_LEFT", INT2FIX(CCDeviceOrientationLandscapeLeft));
	rb_define_const(rb_mDirector, "ORIENTATION_LANDSCAPE_RIGHT", INT2FIX(CCDeviceOrientationLandscapeRight));
	rb_define_const(rb_mDirector, "ORIENTATION_PORTRAIT", INT2FIX(CCDeviceOrientationPortrait));
}
