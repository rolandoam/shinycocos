//
//  SC_CocosNode.h
//  ShinyCocos
//
//  Created by Rolando Abarca on 4/11/09.
//  Copyright 2009 Games For Food SpA. All rights reserved.
//

extern VALUE rb_cCocosNode;

# pragma mark Properties

VALUE rb_cCocosNode_z_order(VALUE object);
VALUE rb_cCocosNode_rotation(VALUE object);
VALUE rb_cCocosNode_set_rotation(VALUE object, VALUE rotation);
VALUE rb_cCocosNode_scale(VALUE object);
VALUE rb_cCocosNode_set_scale(VALUE object, VALUE scale);
VALUE rb_cCocosNode_scale_x(VALUE object);
VALUE rb_cCocosNode_set_scale_x(VALUE object, VALUE scale_x);
VALUE rb_cCocosNode_scale_y(VALUE object);
VALUE rb_cCocosNode_set_scale_y(VALUE object, VALUE scale_y);
VALUE rb_cCocosNode_position(VALUE object);
VALUE rb_cCocosNode_set_position(VALUE object, VALUE position);
VALUE rb_cCocosNode_visible(VALUE object);
VALUE rb_cCocosNode_set_visible(VALUE object, VALUE visible);
VALUE rb_cCocosNode_tag(VALUE object);
VALUE rb_cCocosNode_set_tag(VALUE object, VALUE tag);

#pragma mark Methods

VALUE rb_cCocosNode_s_node(VALUE klass);
VALUE rb_cCocosNode_s_new(VALUE klass);
/*
 add_child(obj)
 add_child(obj, :z => z, :tag => tag, :parallaxRatio => ratio)
*/
VALUE rb_cCocosNode_add_child(int argc, VALUE *_args, VALUE object);

#pragma mark Override Points

VALUE rb_cCocosNode_on_enter(VALUE object);
VALUE rb_cCocosNode_on_exit(VALUE object);
VALUE rb_cCocosNode_draw(VALUE object);
VALUE rb_cCocosNode_transform(VALUE object);

void init_rb_cCocosNode();
