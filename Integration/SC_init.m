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

#import "SC_common.h"

VALUE rb_mCocos2D;
VALUE sc_acc_delegate;
NSMutableDictionary *sc_object_hash;
NSMutableDictionary *sc_schedule_methods;
NSMutableDictionary *sc_handler_hash;
id accDelegate;

#pragma mark Common

void sc_free(void *ptr) {
	[GET_OBJC(ptr) release];
	free(ptr);
}

VALUE sc_init(VALUE klass, cocos_holder **ret_ptr, id object, int argc, VALUE *argv, BOOL release_on_free) {
	VALUE obj;
	cocos_holder *ptr;
	if (release_on_free)
		obj = Data_Make_Struct(klass, cocos_holder, 0, sc_free, ptr);
	else
		obj = Data_Make_Struct(klass, cocos_holder, 0, free, ptr);
	ptr->_obj = object;
	rb_obj_call_init(obj, argc, argv);
	if (ret_ptr != nil)
		*ret_ptr = ptr;
	return obj;
}

/*
 * use this with caution, this is really slow!
 */
VALUE sc_ns_log(int argc, VALUE *argv, VALUE module) {
	/* create the template string */
	VALUE template_ary = rb_ary_new();
	int i;
	for (i=0; i < argc; i++) {
		if (TYPE(argv[i]) == T_STRING)
			rb_funcall(template_ary, rb_intern("push"), 1, argv[i]);
		else
			rb_funcall(template_ary, rb_intern("push"), 1, INSPECT(argv[i]));
	}
	VALUE template_final = rb_funcall(template_ary, rb_intern("join"), 1, rb_str_new2(" "));	
	
	NSLog([NSString stringWithCString:StringValueCStr(template_final) encoding:NSUTF8StringEncoding]);
	return Qnil;
}

/*
 * set the acceleration delegate. It will receive an array with 4
 * floats: acceleration on axis x, y, z and the absolute acceleration.
 * 
 * The object must respond to <tt>got_acceleration(accel)</tt>.
 */
VALUE sc_set_acceleration_delegate(VALUE module, VALUE obj) {
	sc_acc_delegate = obj;
	// let know the GC that we're using it
	rb_global_variable(&sc_acc_delegate);
	[UIAccelerometer sharedAccelerometer].delegate = accDelegate;
	return obj;
}

/*
 * ShinyCocos
 * 
 * ## Notes
 * 
 * The "vendor" directory is where you put your ruby code. Make sure
 * that when adding the directory to your project, the option "Create
 * Folder References for any added folder" is set. That way, the
 * directory structure will be created in the app package.
 */
void Init_ShinyCocos() {
	rb_mCocos2D = rb_define_module("Cocos2D");
	
	/* init mini object table */
	sc_object_hash = [[NSMutableDictionary alloc] init];
	sc_handler_hash = [[NSMutableDictionary alloc] init];
	sc_schedule_methods = [[NSMutableDictionary alloc] init];
	sc_acc_delegate = Qnil;
	
	/* init the integration classes */
	init_rb_cTexture2D();
	init_rb_cDirector();
	init_rb_cCocosNode();
	init_rb_cScene();
	init_rb_cTextureNode();
	init_rb_cSprite();
	init_rb_cAtlasSpriteManager();
	init_rb_cAtlasSprite();
	init_rb_cAtlasAnimation();
	init_rb_cTiledMap();
	init_sc_cocoa_additions();
	
	/* common utility functions */
	rb_define_method(rb_mCocos2D, "ns_log", sc_ns_log, -1);
	rb_define_method(rb_mCocos2D, "set_acceleration_delegate", sc_set_acceleration_delegate, 1);
}

void Init_SC_Ruby_Extensions() {
	Init_encdb();
	Init_stringio();
	Init_syck();
	// add your extensions init here!
}
