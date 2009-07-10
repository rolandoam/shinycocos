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

void ShinyCocosSetup(UIWindow *window) {
	if (![NSThread isMainThread]) {
		NSLog(@"must call ShiniCocosSetup from main thread!");
		exit(0);
	}
	
	/* prepare ruby stuff */
	NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	NSString *rubyLib = [NSString stringWithFormat:@"%@/lib", resourcePath];
	NSString *rubyVendor = [NSString stringWithFormat:@"%@/vendor", resourcePath];
	NSString *entryPoint = [NSString stringWithFormat:@"%@/main.rb", resourcePath];

	sc_argc = 2;
	sc_argv = (char **)malloc(sizeof(char *) * 2);
	sc_argv[0] = "ShinyCocos";
	sc_argv[1] = (char *)[entryPoint cStringUsingEncoding:NSUTF8StringEncoding];
	
	ruby_sysinit(&sc_argc, &sc_argv);
	{
	RUBY_INIT_STACK;
	ruby_init();
	}
	
	/* add the bundle resource path to the search path */
	VALUE load_path = rb_gv_get(":");
	rb_funcall(load_path, rb_intern("push"), 1, rb_str_new2([resourcePath cStringUsingEncoding:NSUTF8StringEncoding]));
	rb_funcall(load_path, rb_intern("push"), 1, rb_str_new2([rubyLib cStringUsingEncoding:NSUTF8StringEncoding]));
	rb_funcall(load_path, rb_intern("push"), 1, rb_str_new2([rubyVendor cStringUsingEncoding:NSUTF8StringEncoding]));

	/* init our stuff */
	Init_ShinyCocos();
	Init_SC_Ruby_Extensions();
	
	/* hide the top bar */
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	/* init the window stuff */
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
	[[Director sharedDirector] attachInWindow:window];
	[window makeKeyAndVisible];
}

extern void sc_require(char *fname);

void ShinyCocosStart() {
	int state;
	ruby_script("main.rb");
	// test for secure_require
	if (rb_obj_respond_to(rb_mKernel, rb_intern("secure_require"), 0)) {
		rb_protect(RUBY_METHOD_FUNC(sc_require), (VALUE)"main", &state);
	} else {
		rb_protect(RUBY_METHOD_FUNC(rb_require), (VALUE)"main", &state);
	}
	if (state != 0)
		sc_error(state);
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
