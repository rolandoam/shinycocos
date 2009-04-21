//
//  Director.h
//  ShinyCocos
//
//  Created by Rolando Abarca on 4/11/09.
//  Copyright 2009 Games For Food SpA. All rights reserved.
//

extern VALUE rb_cDirector;

VALUE rb_cDirector_landscape(VALUE klass, VALUE landscape);
VALUE rb_cDirector_animation_interval(VALUE klass, VALUE interval);
VALUE rb_cDirector_run_scene(VALUE klass, VALUE scene);

void init_rb_cDirector();
