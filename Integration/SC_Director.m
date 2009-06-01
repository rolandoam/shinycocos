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

VALUE rb_cDirector;

/* 
 * Sets the orientation to landscape
 */
VALUE rb_cDirector_landscape(VALUE klass, VALUE landscape) {
	[Director sharedDirector].landscape = (landscape == Qtrue) ? YES : NO;
	return landscape;
}

/* 
 * Sets the animation interval of the Director
 */
VALUE rb_cDirector_animation_interval(VALUE klass, VALUE interval) {
	Check_Type(interval, T_FLOAT);
	[Director sharedDirector].animationInterval = NUM2DBL(interval);
	return interval;
}

/* 
 * Will run a scene
 */
VALUE rb_cDirector_run_scene(VALUE klass, VALUE scene) {
	cocos_holder *ptr;
	Data_Get_Struct(scene, cocos_holder, ptr);
	[[Director sharedDirector] runWithScene:GET_OBJC(ptr)];
	return scene;
}

/*
 * call-seq:
 *   Director.replace_scene some_scene   #=> some_scene
 *
 * Replaces the current scene with a new one
 */
VALUE rb_cDirector_replace_scene(VALUE klass, VALUE scene) {
	cocos_holder *ptr;
	Data_Get_Struct(scene, cocos_holder, ptr);
	[[Director sharedDirector] replaceScene:GET_OBJC(ptr)];
	return scene;
}

/*
 * call-seq:
 *   Director.display_fps(true)
 *
 * Will display (or not) the fps
 */
VALUE rb_cDirector_display_fps(VALUE klass, VALUE display) {
	[Director sharedDirector].displayFPS = (display == Qtrue) ? YES : NO;
	return display;
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
VALUE rb_cDirector_add_text_field(VALUE klass, VALUE size, VALUE landscape, VALUE delegate) {
	Check_Type(size, T_ARRAY);
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(FIX2INT(RARRAY_PTR(size)[0]), FIX2INT(RARRAY_PTR(size)[1]), FIX2INT(RARRAY_PTR(size)[2]), FIX2INT(RARRAY_PTR(size)[3]))];
	// rotate to portrait
	if (landscape != Qfalse)
		[textField setTransform:CGAffineTransformMakeRotation(3.14/2)];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.returnKeyType = UIReturnKeyDone;
	if (delegate != Qnil)
		SC_DATA(textField.delegate, delegate);
	[[Director sharedDirector].openGLView addSubview:textField];
	
	return Qnil;
}

/* create the Director class, set the methods */
void init_rb_cDirector() {
	rb_cDirector = rb_define_class_under(rb_mCocos2D, "Director", rb_cObject);
	rb_define_singleton_method(rb_cDirector, "landscape", rb_cDirector_landscape, 1);
	rb_define_singleton_method(rb_cDirector, "animation_interval=", rb_cDirector_animation_interval, 1);
	rb_define_singleton_method(rb_cDirector, "display_fps", rb_cDirector_display_fps, 1);
	rb_define_singleton_method(rb_cDirector, "run_scene", rb_cDirector_run_scene, 1);
	rb_define_singleton_method(rb_cDirector, "replace_scene", rb_cDirector_replace_scene, 1);
	rb_define_singleton_method(rb_cDirector, "add_text_field", rb_cDirector_add_text_field, 3);
}
