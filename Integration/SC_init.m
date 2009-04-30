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
VALUE rb_object_hash;
VALUE rb_acc_delegate;
id accDelegate;

#pragma mark Common

VALUE common_init(VALUE klass, cocos_holder **ret_ptr, id object, BOOL release_on_free) {
	VALUE tdata;
	cocos_holder *ptr;
	if (release_on_free)
		tdata = Data_Make_Struct(klass, cocos_holder, 0, common_free, ptr);
	else
		tdata = Data_Make_Struct(klass, cocos_holder, 0, common_free_no_release, ptr);
	ptr->_obj = object;
	rb_obj_call_init(tdata, 0, 0);
	if (ret_ptr != nil)
		*ret_ptr = ptr;
	return tdata;
}

/*
 * use this with caution, since it's really slow!
 */
VALUE common_rb_ns_log(int argc, VALUE *argv, VALUE module) {
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
	
	NSLog([NSString stringWithCString:STR2CSTR(template_final) encoding:NSUTF8StringEncoding]);
	return Qnil;
}

/*
 * set the acceleration delegate. It will receive an array with 4
 * floats: acceleration on axis x, y, z and the absolute acceleration.
 * 
 * The object must respond to <tt>got_acceleration(accel)</tt>.
 */
VALUE common_rb_set_acceleration_delegate(VALUE module, VALUE obj) {
	rb_acc_delegate = obj;
	rb_gv_set("_sc_acc_delegate", obj); // we set it as a global variable, or else ruby will clean it on GC
	[UIAccelerometer sharedAccelerometer].delegate = accDelegate;
	return obj;
}

void Init_ShinyCocos() {
	rb_mCocos2D = rb_define_module("Cocos2D");
	
	/* init mini object table */
	rb_object_hash = rb_hash_new();
	
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
	
	/* common utility functions */
	rb_define_method(rb_mCocos2D, "ns_log", common_rb_ns_log, -1);
	rb_define_method(rb_mCocos2D, "set_acceleration_delegate", common_rb_set_acceleration_delegate, 1);
	rb_acc_delegate = Qnil;
}
