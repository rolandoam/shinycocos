/*
 *  ShinyCocos.c
 *  ShinyCocos
 *
 *  Created by Rolando Abarca on 4/7/09.
 *  Copyright 2009 Games For Food SpA. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import "ShinyCocos.h"
#import "SC_common.h"
#import "SC_Director.h"

VALUE rb_mCocos2D;
VALUE rb_object_hash;
VALUE rb_acc_delegate;
id accDelegate;

@interface AccDelegate : NSObject
{
}
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
@end

@implementation AccDelegate
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	if (rb_acc_delegate != Qnil) {
		float acc_abs = sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z);
		VALUE acc_ary = rb_ary_new3(4, rb_float_new(acceleration.x), rb_float_new(acceleration.y), rb_float_new(acceleration.z), rb_float_new(acc_abs));
		rb_funcall(rb_acc_delegate, rb_intern("got_acceleration"), 1, acc_ary);
	}
}
@end

#pragma mark Common

void common_free(void *ptr) {
	[GET_OBJC(ptr) release];
	common_free_no_release(ptr);
}

void common_free_no_release(void *ptr) {
	free(ptr);
}

VALUE common_init(VALUE klass, cocos_holder *ptr, BOOL release_on_free) {
	VALUE tdata;
	if (release_on_free)
		tdata = Data_Wrap_Struct(klass, 0, common_free, ptr);
	else
		tdata = Data_Wrap_Struct(klass, 0, common_free_no_release, ptr);
	rb_obj_call_init(tdata, 0, 0);
	return tdata;
}

void common_method_swap(Class cls, SEL orig, SEL repl, const char *signature) {
	//NSLog(@"replacing %@ with %@ in %@", NSStringFromSelector(orig), NSStringFromSelector(repl), cls);
	Method m1 = class_getInstanceMethod(cls, orig);
	Method m2 = class_getInstanceMethod(cls, repl);
	method_exchangeImplementations(m1, m2);
}

VALUE common_rb_ns_log(int argc, VALUE *argv, VALUE module) {
	/* create the template string */
	VALUE template_ary = rb_ary_new();
	int i;
	for (i=0; i < argc; i++) {
		if (TYPE(argv[i]) == T_STRING)
			rb_funcall(template_ary, rb_intern("push"), 1, argv[i]);
		else
			rb_funcall(template_ary, rb_intern("push"), 1, rb_funcall(argv[i], rb_intern("inspect"), 0, 0));
	}
	VALUE template_final = rb_funcall(template_ary, rb_intern("join"), 1, rb_str_new2(" "));	
	
	NSLog([NSString stringWithCString:STR2CSTR(template_final) encoding:NSUTF8StringEncoding]);
	return Qnil;
}

VALUE common_rb_set_acceleration_delegate(VALUE module, VALUE obj) {
	rb_acc_delegate = obj;
	rb_gv_set("sc_acc_delegate", obj); // we set it as a global variable, or else ruby will clean it on GC
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
	
	/* common utility functions */
	rb_define_method(rb_mCocos2D, "ns_log", common_rb_ns_log, -1);
	rb_define_method(rb_mCocos2D, "set_acceleration_delegate", common_rb_set_acceleration_delegate, 1);
	rb_acc_delegate = Qnil;
}

void ShinyCocosSetup(UIWindow *window) {
	RUBY_INIT_STACK;
	ruby_init();

#if defined(DEBUG)
//	enable_gc_profile();
#endif
	
	/* add the bundle resource path to the search path */
	NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	VALUE load_path = rb_gv_get(":");
	rb_funcall(load_path, rb_intern("push"), 1, rb_str_new2([resourcePath cStringUsingEncoding:NSUTF8StringEncoding]));

	/* init our stuff */
	Init_ShinyCocos();
	
	/* hide the top bar */
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	/* init the window stuff */
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
	[[Director sharedDirector] attachInWindow:window];
	[window makeKeyAndVisible];
}

void ShinyCocosStart() {
	int state = 0;
	accDelegate = [[AccDelegate alloc] init];
	ruby_script("main.rb");
	rb_protect(RUBY_METHOD_FUNC(rb_require), (VALUE)"main", &state);
	if (state != 0) {
		VALUE error = rb_gv_get("@");
		NSLog(@"Ruby Error: %s\n%s", STR2CSTR(rb_gv_get("!")), STR2CSTR(rb_funcall(error, rb_intern("join"), 1, rb_str_new2("\n"))));
	}
}

void ShinyCocosInitChipmunk() {
	Init_chipmunk();
}

void ShinyCocosStop() {
	[accDelegate release];
}

