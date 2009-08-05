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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SC_common.h"
#import "SC_Layer.h"
#import "SC_CocosNode.h"

VALUE rb_cLayer;

@interface RBLayer : Layer
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
@end

@implementation RBLayer
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (userData) {
		if (sc_protect_funcall((VALUE)userData, id_sc_touch_began, 1, rb_hash_with_touch(touch)) != Qfalse) {
			return YES;
		}
	}
	return NO;
}
@end


/*
 * call-seq:
 *   layer = Layer.new   #=> Layer
 *
 * Creates a new layer
 */
VALUE rb_cLayer_s_new(int argc, VALUE *argv, VALUE klass) {
	RBLayer *layer = [[RBLayer alloc] init];
	VALUE ret = sc_init(klass, nil, layer, argc, argv, YES);
	layer.userData = (void *)ret;
	
	return ret;
}


/*
 * call-seq:
 *   layer.register_with_touch_dispatcher   #=> nil
 *
 * register the layer with the touch dispatcher. You should implement the method +touch_began(touch)+
 * in your subclass.
 */
VALUE rb_cLayer_register_with_touch_dispatcher(VALUE object) {
	[CC_LAYER(object) registerWithTouchDispatcher];
	return Qnil;
}


/*
 * The ruby equivalent of the Layer node
 */
void init_rb_cLayer() {
	rb_cLayer = rb_define_class_under(rb_mCocos2D, "Layer", rb_cCocosNode);
	rb_define_singleton_method(rb_cLayer, "new", rb_cLayer_s_new, -1);
	rb_define_method(rb_cLayer, "register_with_touch_dispatcher", rb_cLayer_register_with_touch_dispatcher, 0);
}
