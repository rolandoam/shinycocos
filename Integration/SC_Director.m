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
	rb_ivar_set(module, id_sc_ivar_running_scene, scene);
	return scene;
}

/*
 * call-seq:
 *   Director.replace_scene some_scene   #=> some_scene
 *
 * Replaces the current scene with a new one
 */
VALUE rb_mDirector_replace_scene(VALUE module, VALUE scene) {
	// register current scene and de-register old scene
	rb_gc_register_address(&scene);
	CocosNode *oldScene = [Director sharedDirector].runningScene;
	VALUE rbOldScene = (VALUE)oldScene.userData;
	[[Director sharedDirector] replaceScene:CC_SCENE(scene)];
	rb_gc_unregister_address(&rbOldScene);

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
 *   Director.add_touch_handler(some_node, standard = true, priority = 0)   #=> some_node
 *
 * Adds a touch handler. By default it's a standard handler, that means the object
 * should respond to touches_(began|cancelled|ended). If it's not a standard handler,
 * it's assumed to be a targeted handler. In that case, the object should respond to
 * touch_(began|cancelled|ended).
 *
 * In all cases, some_node MUST BE a CocosNode subclass.
 */
VALUE rb_mDirector_add_touch_handler(int argc, VALUE *argv, VALUE module) {
	if (argc < 1 || argc > 3 || !(rb_obj_is_kind_of(argv[0], rb_cCocosNode))) {
		rb_raise(rb_eArgError, "Invalid arguments. Check that node is a subclass of CocosNode");
	}
	VALUE standard = ((argc >= 2) ? argv[1] : Qtrue);
	VALUE priority = ((argc == 3) ? argv[2] : INT2FIX(0));
	if (RTEST(standard)) {
		[[TouchDispatcher sharedDispatcher] addStandardDelegate:(id)CC_NODE(argv[0]) priority:FIX2INT(priority)];
	} else {
		[[TouchDispatcher sharedDispatcher] addTargetedDelegate:(id)CC_NODE(argv[0]) priority:FIX2INT(priority) swallowsTouches:YES];
	}
	return argv[0];
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
	[[Director sharedDirector] setProjection:CCDirectorProjection2D];
	return Qnil;
}


/*
 * call-seq:
 *   Director.set_3d_projection   #=> nil
 *
 * Sets the Directors' projection to 3D
 */
VALUE rb_mDirector_set_3d_projection(VALUE module) {
	[[Director sharedDirector] setProjection:CCDirectorProjection3D];
	return Qnil;
}


/*
 * call-seq:
 *   Director.convert_to_gl([x,y])  #=> [new_x, new_y]
 *
 * Converts a given point to GL coordinates
 */
VALUE rb_mDirector_convert_to_gl(VALUE module, VALUE point) {
	Check_Type(point, T_ARRAY);
	CGPoint p = CGPointMake(NUM2DBL(RARRAY_PTR(point)[0]), NUM2DBL(RARRAY_PTR(point)[1]));
	p = [[Director sharedDirector] convertToGL:p];
	return rb_ary_new3(2, rb_float_new(p.x), rb_float_new(p.y));
}


/* create the Director class, set the methods */
void init_rb_mDirector() {
	rb_mDirector = rb_define_module_under(rb_mCocos2D, "Director");
	rb_define_module_function(rb_mDirector, "set_orientation", rb_mDirector_set_orientation, 1);
	rb_define_module_function(rb_mDirector, "set_animation_interval", rb_mDirector_set_animation_interval, 1);
	rb_define_module_function(rb_mDirector, "display_fps", rb_mDirector_display_fps, 1);
	rb_define_module_function(rb_mDirector, "run_scene", rb_mDirector_run_scene, 1);
	rb_define_module_function(rb_mDirector, "replace_scene", rb_mDirector_replace_scene, 1);
	rb_define_module_function(rb_mDirector, "add_touch_handler", rb_mDirector_add_touch_handler, -1);
	rb_define_module_function(rb_mDirector, "remove_touch_handler", rb_mDirector_remove_touch_handler, 1);
	rb_define_module_function(rb_mDirector, "pause", rb_mDirector_pause, 0);
	rb_define_module_function(rb_mDirector, "resume", rb_mDirector_resume, 0);
	rb_define_module_function(rb_mDirector, "win_size", rb_mDirector_win_size, 0);
	rb_define_module_function(rb_mDirector, "set_2d_projection", rb_mDirector_set_2d_projection, 0);
	rb_define_module_function(rb_mDirector, "set_3d_projection", rb_mDirector_set_3d_projection, 0);
	rb_define_module_function(rb_mDirector, "convert_to_gl", rb_mDirector_convert_to_gl, 1);
	// orientation constants
	rb_define_const(rb_mDirector, "ORIENTATION_LANDSCAPE_LEFT", INT2FIX(CCDeviceOrientationLandscapeLeft));
	rb_define_const(rb_mDirector, "ORIENTATION_LANDSCAPE_RIGHT", INT2FIX(CCDeviceOrientationLandscapeRight));
	rb_define_const(rb_mDirector, "ORIENTATION_PORTRAIT", INT2FIX(CCDeviceOrientationPortrait));
}
