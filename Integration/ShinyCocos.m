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

#import <UIKit/UIKit.h>
#import "ShinyCocos.h"
#import "SC_common.h"

void sc_method_swap(Class cls, SEL orig, SEL repl) {
//	NSLog(@"replacing %@ with %@ in %@", NSStringFromSelector(orig), NSStringFromSelector(repl), cls);
	Method m1 = class_getInstanceMethod(cls, orig);
	Method m2 = class_getInstanceMethod(cls, repl);
	method_exchangeImplementations(m1, m2);
}

static char **sc_argv;
static int    sc_argc;
id _appDelegate;

void ShinyCocosSetup(NSString *devLibs) {	
	/* prepare ruby stuff */
	NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	NSString *rubyLib = [NSString stringWithFormat:@"%@/lib", resourcePath];
	NSString *rubyVendor = [NSString stringWithFormat:@"%@/vendor", resourcePath];
	NSString *entryPoint = [NSString stringWithFormat:@"%@/main.rb", rubyVendor];

	sc_argc = 2;
	sc_argv = (char **)malloc(sizeof(char *) * (sc_argc));
	sc_argv[0] = "ShinyCocos";
	sc_argv[1] = (char *)[entryPoint UTF8String];
	
	{
	RUBY_INIT_STACK;
	ruby_init();
	ruby_options(sc_argc, sc_argv);
	}
	
	/* add the bundle resource path to the search path */
	VALUE load_path = rb_gv_get(":");
	if (devLibs) {
		rb_funcall(load_path, rb_intern("push"), 1, rb_str_new2([devLibs UTF8String]));
	}
	rb_funcall(load_path, rb_intern("push"), 1, rb_str_new2([resourcePath UTF8String]));
	rb_funcall(load_path, rb_intern("push"), 1, rb_str_new2([rubyLib UTF8String]));
	rb_funcall(load_path, rb_intern("push"), 1, rb_str_new2([rubyVendor UTF8String]));
	
	/* init our stuff */
	Init_ShinyCocos();
	Init_SC_Ruby_Extensions();
}

extern void sc_require(char *fname);

void ShinyCocosStart(UIWindow *window, id appDelegate) {
	int state_;
	_appDelegate = appDelegate;
	/* hide the top bar */
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	/* init the window stuff */
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
	[[Director sharedDirector] attachInWindow:window];
	[window makeKeyAndVisible];
	
	ruby_script("ShinyCocos"); // set the name script
	// test for secure_require
	if (rb_obj_respond_to(rb_mKernel, rb_intern("secure_require"), 0)) {
		rb_protect(RUBY_METHOD_FUNC(sc_require), (VALUE)"main", &state_);
	} else {
		rb_protect(RUBY_METHOD_FUNC(rb_require), (VALUE)"main", &state_);
	}
	if (state_ != 0)
		sc_error(state_);
}

void ShinyCocosInitChipmunk() {
	Init_chipmunk();
}

void ShinyCocosStop() {
	// release handlers
	[sc_object_hash release];
	[sc_handler_hash release];
	[sc_schedule_methods release];

	ruby_stop(0);
	free(sc_argv);
}
