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
#import "SC_Menu.h"
#import "MenuItemAtlasSprite.h"
#import "SC_MenuItemAtlasSprite.h"

VALUE rb_cMenuItemAtlasSprite;

/*
 * call-seq:
 *   item = MenuItemAtlasSprite.new(:normal => sprite_normal,
 *                                  :selected => sprite_selected,
 *                                  :disabled => sprite_disabled)   #=> MenuItemAtlasSprite
 *
 * <tt>:normal</tt> and <tt>:selected</tt> are required.
 */
VALUE rb_cMenuItemAtlasSprite_s_new(VALUE klass, VALUE opts) {
	Check_Type(opts, T_HASH);
	// check options
	VALUE normal_image = rb_hash_aref(opts, ID2SYM(id_sc_normal));
	if (normal_image == Qnil)
		rb_raise(rb_eArgError, "normal image required");
	VALUE selected_image = rb_hash_aref(opts, ID2SYM(id_sc_selected));
	if (selected_image == Qnil)
		rb_raise(rb_eArgError, "selected image required");
	VALUE disabled_image = rb_hash_aref(opts, ID2SYM(id_sc_disabled));
	AtlasSprite *normalImage; SC_DATA(normalImage, normal_image);
	AtlasSprite *selectedImage; SC_DATA(selectedImage, selected_image);
	AtlasSprite *disabledImage = nil;
	if (disabled_image != Qnil)
		SC_DATA(disabledImage, disabled_image);
	// create proxy
	MenuItemProxy *mp = [[MenuItemProxy alloc] initWithRubyObject:Qnil];
	MenuItemAtlasSprite *mi = [[MenuItemAtlasSprite alloc] initFromNormalSprite:normalImage
																 selectedSprite:selectedImage
																 disabledSprite:disabledImage
																		 target:mp
																	   selector:@selector(proxyRuby:)];
	VALUE ret = sc_init(klass, nil, mi, 0, 0, YES);
	mp.rbObject = ret;
	
	return ret;
}

void init_rb_cMenuItemAtlasSprite() {
	rb_cMenuItemAtlasSprite = rb_define_class_under(rb_mCocos2D, "MenuItemAtlasSprite", rb_cCocosNode);
	rb_define_singleton_method(rb_cMenuItemAtlasSprite, "new", rb_cMenuItemAtlasSprite_s_new, 1);
}
