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

#pragma mark AccDelegate

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

void common_free(void *ptr) {
	[GET_OBJC(ptr) release];
	common_free_no_release(ptr);
}

void common_free_no_release(void *ptr) {
	free(ptr);
}

void common_method_swap(Class cls, SEL orig, SEL repl) {
//	NSLog(@"replacing %@ with %@ in %@", NSStringFromSelector(orig), NSStringFromSelector(repl), cls);
	Method m1 = class_getInstanceMethod(cls, orig);
	Method m2 = class_getInstanceMethod(cls, repl);
	method_exchangeImplementations(m1, m2);
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
