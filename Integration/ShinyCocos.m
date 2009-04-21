/*
 *  ShinyCocos.c
 *  ShinyCocos
 *
 *  Created by Rolando Abarca on 4/7/09.
 *  Copyright 2009 Games For Food SpA. All rights reserved.
 *
 */

#import "ShinyCocos.h"
#import "SC_Director.h"

VALUE rb_mCocos2D;
VALUE rb_object_hash;

#pragma mark Common

void common_free(void *ptr) {
	[GET_OBJC(ptr) release];
	common_free_no_release(ptr);
}

void common_free_no_release(void *ptr) {
	free(ptr);
}

VALUE common_init(VALUE klass, cocos_holder *ptr, BOOL release_on_free) {
	//*ptr = malloc(sizeof(cocos_holder));
	VALUE tdata;
	if (release_on_free)
		tdata = Data_Wrap_Struct(klass, 0, common_free, ptr);
	else
		tdata = Data_Wrap_Struct(klass, 0, common_free_no_release, ptr);
	rb_obj_call_init(tdata, 0, 0);
	return tdata;
}

VALUE common_ns_log(int argc, VALUE *argv, VALUE module) {
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

void common_method_swap(Class cls, SEL orig, SEL repl, const char *signature) {
	//NSLog(@"replacing %@ with %@ in %@", NSStringFromSelector(orig), NSStringFromSelector(repl), cls);
	Method m1 = class_getInstanceMethod(cls, orig);
	Method m2 = class_getInstanceMethod(cls, repl);
	method_exchangeImplementations(m1, m2);
}

void Init_ShinyCocos() {
	rb_mCocos2D = rb_define_module("Cocos2D");
	/* init mini object table */
	rb_object_hash = rb_hash_new();
	/* init the ruby classes */
	init_rb_cDirector();
	init_rb_cCocosNode();
	init_rb_cScene();
	init_rb_cTextureNode();
	init_rb_cSprite();
	/* common utility functions */
	rb_define_method(rb_mKernel, "ns_log", common_ns_log, -1);
}

void ShinyCocosSetup(UIWindow *window) {
	NSLog(@"setting up shiny cocos");
	RUBY_INIT_STACK;
	ruby_script("ShinyCocos");
	ruby_init();

#if defined(DEBUG)
//	enable_gc_profile();
#endif
	
	/* add the bundle resource path to the search path */
	// NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	// VALUE load_path = rb_gv_get(":");
	// rb_funcall(load_path, rb_intern("push"), 1, rb_str_new2([resourcePath cStringUsingEncoding:NSUTF8StringEncoding]));

	/* init our stuff */
	//Init_ShinyCocos();
	
	/* hide the top bar */
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	/* init the window stuff */
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
	[[Director sharedDirector] attachInView:window];
	[window makeKeyAndVisible];
}

void ShinyCocosStart() {
	NSLog(@"starting shiny cocos");
	NSString *path = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"rb"];
	// rb_load(rb_str_new2([path cStringUsingEncoding:NSUTF8StringEncoding]), 0);
	int state;
	rb_protect(RUBY_METHOD_FUNC(rb_require), (VALUE)[path cStringUsingEncoding:NSUTF8StringEncoding], &state);
	if (state != 0) {
		VALUE error = rb_gv_get("@");
		VALUE error_class = rb_funcall(rb_funcall(error, rb_intern("class"), 0, 0), rb_intern("to_s"), 0, 0);
		NSLog(@"RubyError: %s (%s)\n", STR2CSTR(rb_funcall(error, rb_intern("inspect"), 0, 0)), STR2CSTR(error_class));
	}
}
