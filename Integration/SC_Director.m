//
//  Director.m
//  ShinyCocos
//
//  Created by Rolando Abarca on 4/11/09.
//  Copyright 2009 Games For Food SpA. All rights reserved.
//

#import "ruby.h"
#import "cocos2d.h"
#import "SC_common.h"
#import "SC_Director.h"

VALUE rb_cDirector;

VALUE rb_cDirector_landscape(VALUE klass, VALUE landscape) {
	[Director sharedDirector].landscape = (landscape == Qtrue) ? YES : NO;
	return landscape;
}

VALUE rb_cDirector_animation_interval(VALUE klass, VALUE interval) {
	Check_Type(interval, T_FLOAT);
	[Director sharedDirector].animationInterval = NUM2DBL(interval);
	return interval;
}

VALUE rb_cDirector_run_scene(VALUE klass, VALUE scene) {
	Check_Type(scene, T_DATA);
	cocos_holder *ptr;
	Data_Get_Struct(scene, cocos_holder, ptr);
	[[Director sharedDirector] runWithScene:GET_OBJC(ptr)];
	return Qnil;
}

/* create the Director class, set the methods */
void init_rb_cDirector() {
	rb_cDirector = rb_define_class_under(rb_mCocos2D, "Director", rb_cObject);
	rb_define_singleton_method(rb_cDirector, "landscape=", rb_cDirector_landscape, 1);
	rb_define_singleton_method(rb_cDirector, "animation_interval=", rb_cDirector_animation_interval, 1);
	rb_define_singleton_method(rb_cDirector, "run_scene", rb_cDirector_run_scene, 1);
}
