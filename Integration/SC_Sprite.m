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
#import "ruby.h"
#import "SC_common.h"
#import "SC_CocosNode.h"
#import "SC_TextureNode.h"
#import "SC_Sprite.h"

VALUE rb_cSprite;

/* 
 * call-seq:
 *   sprite = Sprite.new("sprite.png")   #=> Sprite
 *
 * Creates a new sprite using the given file
 */
VALUE rb_cSprite_s_new(int argc, VALUE *argv, VALUE klass) {
	if (argc < 1) {
		rb_raise(rb_eArgError, "Invalid number of arguments");
	}
	Check_Type(argv[0], T_STRING);
	Sprite *obj = [[Sprite alloc] initWithFile:[NSString stringWithCString:StringValueCStr(argv[0]) encoding:NSUTF8StringEncoding]];
	VALUE rb_obj = sc_init(klass, nil, obj, argc-1, argv+1, YES);
	obj.userData = (void *)rb_obj;
	
	return rb_obj;
}


/*
 * call-seq:
 *   sprite.antialias(true/false)   #=> true/false
 *
 * sets (or unsets) the antialias tex parameters
 */
VALUE rb_cSprite_antialias(VALUE obj, VALUE antialias) {
	if (antialias != Qfalse) {
		[CC_SPRITE(obj).texture setAntiAliasTexParameters];
	} else {
		[CC_SPRITE(obj).texture setAliasTexParameters];
	}
	return antialias;
}

void init_rb_cSprite() {
	rb_cSprite = rb_define_class_under(rb_mCocos2D, "Sprite", rb_cTextureNode);
	rb_define_singleton_method(rb_cSprite, "new", rb_cSprite_s_new, -1);
	rb_define_method(rb_cSprite, "antialias", rb_cSprite_antialias, 1);
}
