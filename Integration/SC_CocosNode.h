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
 *   add_child(obj)
 *   add_child(obj, :z => z, :tag => tag, :parallaxRatio => ratio)
 */
VALUE rb_cCocosNode_add_child(int argc, VALUE *_args, VALUE object);
/*
 *  node.run_action(action, *args) do |action|
 *  end
 *
 *  +action+ it's a symbol representing an action. Valid symbols are all
 *  Cocos2D-iphone (0.7.2) actions, camel cased. e.g.: RepeatForever =>
 *  repeat_forever; RotateBy => rotate_by.
 *  
 *  The other arguments are the valid arguments for the new action:
 *  
 *    node.run_action(:rotate_by, duration, angle)
 *  
 *  The optional block passes the newly created action. You can there
 *  further configure the action. Each action has it's own properties. In
 *  order to simplify the configuration, each action is a struct, where the
 *  +name+ property specifies the corresponding Objective-C class.
 *  
 *  The way to specify nested actions is with an array. This is commonly
 *  used in the repeat actions:
 *  
 *    animation = AtlasAnimation.animation(:name => "walk", :delay => 1/30.0) do |walk|
 *      (0..37).each { |i|
 *        x = i % 10
 *        y = i / 10
 *        walk.add_frame [x*100, y*160, 100, 160]
 *      }
 *    end
 *  
 *    node.run_action(:repeat_forever) do |action|
 *      action.action = [:animate, animation]
 *    end
 */
VALUE rb_cCocosNode_run_action(int argc, VALUE *_args, VALUE object);

#pragma mark Override Points

VALUE rb_cCocosNode_on_enter(VALUE object);
VALUE rb_cCocosNode_on_exit(VALUE object);
VALUE rb_cCocosNode_draw(VALUE object);
VALUE rb_cCocosNode_transform(VALUE object);

void init_rb_cCocosNode();
