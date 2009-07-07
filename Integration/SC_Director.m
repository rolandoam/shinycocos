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
#import <AVFoundation/AVAudioPlayer.h>

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
	// store the scene in an instance variable
	rb_iv_set(module, "@running_scene", scene);
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
	// replace the running scene instance variable
	rb_iv_set(module, "@running_scene", scene);
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
VALUE rb_mDirector_add_touch_handler(VALUE module, VALUE node) {
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:(id)CC_NODE(node) priority:0 swallowsTouches:YES];
	return node;
}

/*
 * call-seq:
 *   Director.remove_touch_handler(some_node)   #=> some_node
 */
VALUE rb_mDirector_remove_touch_handler(VALUE module, VALUE node) {
	[[TouchDispatcher sharedDispatcher] removeDelegate:CC_NODE(node)];
	return node;
}


/*
 * call-seq:
 *   Director.pause   #=> nil
 *
 * Pauses the game
 */
VALUE rb_mDirector_pause(VALUE module) {
	[[Director sharedDirector] pause];
	return Qnil;
}

/*
 * call-seq:
 *   Director.resume   #=> nil
 *
 * Resumes the game
 */
VALUE rb_mDirector_resume(VALUE module) {
	[[Director sharedDirector] resume];
	return Qnil;
}


/*
 * call-seq:
 *   Director.win_size   #=> Array
 *
 * Returns an array as with two elements representing the width and height of
 * the current director's window.
 */
VALUE rb_mDirector_win_size(VALUE module) {
	CGSize size = [[Director sharedDirector] winSize];
	VALUE ret = rb_ary_new3(2, rb_float_new(size.width), rb_float_new(size.height));
	return ret;
}


/*
 * call-seq:
 *   Director.set_2d_projection   #=> nil
 *
 * Sets the Directors' projection to 2D
 */
VALUE rb_mDirector_set_2d_projection(VALUE module) {
	[[Director sharedDirector] set2Dprojection];
	return Qnil;
}


/*
 * call-seq:
 *   Director.set_3d_projection   #=> nil
 *
 * Sets the Directors' projection to 3D
 */
VALUE rb_mDirector_set_3d_projection(VALUE module) {
	[[Director sharedDirector] set3Dprojection];
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
	rb_define_module_function(rb_mDirector, "add_touch_handler", rb_mDirector_add_touch_handler, 1);
	rb_define_module_function(rb_mDirector, "remove_touch_handler", rb_mDirector_remove_touch_handler, 1);
	rb_define_module_function(rb_mDirector, "pause", rb_mDirector_pause, 0);
	rb_define_module_function(rb_mDirector, "resume", rb_mDirector_resume, 0);
	rb_define_module_function(rb_mDirector, "win_size", rb_mDirector_win_size, 0);
	rb_define_module_function(rb_mDirector, "set_2d_projection", rb_mDirector_set_2d_projection, 0);
	rb_define_module_function(rb_mDirector, "set_3d_projection", rb_mDirector_set_3d_projection, 0);
	// orientation constants
	rb_define_const(rb_mDirector, "ORIENTATION_LANDSCAPE_LEFT", INT2FIX(CCDeviceOrientationLandscapeLeft));
	rb_define_const(rb_mDirector, "ORIENTATION_LANDSCAPE_RIGHT", INT2FIX(CCDeviceOrientationLandscapeRight));
	rb_define_const(rb_mDirector, "ORIENTATION_PORTRAIT", INT2FIX(CCDeviceOrientationPortrait));
}
