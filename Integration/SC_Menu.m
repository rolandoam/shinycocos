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
#import "SC_CocosNode.h"
#import "SC_Menu.h"
#import "SC_Layer.h"

#pragma mark MenuItemProxy

@implementation MenuItemProxy
@synthesize rbObject;
+ (id)proxy {
	return [[[self alloc] initWithRubyObject:Qnil] autorelease];
}

- (id)initWithRubyObject:(VALUE)object {
	if (self = [super init]) {
		if (object != Qnil)
			rbObject = object;
	}
	return self;
}

- (void)proxyRuby:(id)sender {
	if (rbObject != Qnil)
		sc_protect_funcall(rbObject, id_sc_item_action, 0, 0);
}
@end

#pragma mark MenuItemLabel

VALUE rb_cMenuItemLabel;

VALUE rb_cMenuItemLabel_s_new(VALUE klass, VALUE label) {
	CHECK_SUBCLASS(label, rb_cLabel);
	MenuItemProxy *mp = [[MenuItemProxy alloc] initWithRubyObject:Qnil];
	MenuItemLabel *ml = [[MenuItemLabel alloc] initWithLabel:CC_LABEL(label) target:mp selector:@selector(proxyRuby:)];

	VALUE ret = sc_init(klass, nil, ml, 0, 0, YES);
	mp.rbObject = ret;
	return ret;
}


void init_rb_cMenuItemLabel() {
	rb_cMenuItemLabel = rb_define_class_under(rb_mCocos2D, "MenuItemLabel", rb_cCocosNode);
	rb_define_singleton_method(rb_cMenuItemLabel, "new", rb_cMenuItemLabel_s_new, 1);
}

#pragma mark MenuItemImage

VALUE rb_cMenuItemImage;

/*
 * call-seq:
 *   item = MenuItemImage.new(:normal => "normal_image.png",
 *                            :selected => "selected_image.png",
 *                            :disabled => "disabled_image.png")   #=> MenuItemImage
 *
 * <tt>:normal</tt> and <tt>:selected</tt> are required.
 */
VALUE rb_cMenuItemImage_s_new(VALUE klass, VALUE opts) {
	Check_Type(opts, T_HASH);
	// check options
	VALUE normal_image = rb_hash_aref(opts, sym_sc_normal);
	if (normal_image == Qnil)
		rb_raise(rb_eArgError, "normal image required");
	VALUE selected_image = rb_hash_aref(opts, sym_sc_selected);
	if (selected_image == Qnil)
		rb_raise(rb_eArgError, "selected image required");
	VALUE disabled_image = rb_hash_aref(opts, sym_sc_disabled);
	NSString *normalImage = [NSString stringWithCString:StringValueCStr(normal_image) encoding:NSUTF8StringEncoding];
	NSString *selectedImage = [NSString stringWithCString:StringValueCStr(selected_image) encoding:NSUTF8StringEncoding];
	NSString *disabledImage = (disabled_image != Qnil) ? [NSString stringWithCString:StringValueCStr(disabled_image) encoding:NSUTF8StringEncoding] : nil;
	// create proxy
	MenuItemProxy *mp = [[MenuItemProxy alloc] initWithRubyObject:Qnil];
	MenuItemImage *mi = [[MenuItemImage alloc] initFromNormalImage:normalImage
													 selectedImage:selectedImage
													 disabledImage:disabledImage
															target:mp
														  selector:@selector(proxyRuby:)];
	VALUE ret = sc_init(klass, nil, mi, 0, 0, YES);
	mp.rbObject = ret;
	
	return ret;
}

void init_rb_cMenuItemImage() {
	rb_cMenuItemImage = rb_define_class_under(rb_mCocos2D, "MenuItemImage", rb_cCocosNode);
	rb_define_singleton_method(rb_cMenuItemImage, "new", rb_cMenuItemImage_s_new, 1);
}

#pragma mark MenuItemAtlasSprite

VALUE rb_cMenuItemAtlasSprite;


/*
 * call-seq:
 *   item = MenuItemAtlasSprite.new(:normal => normal_atlas_sprite,
 *                                  :selected => selected_atlas_sprite,
 *                                  :disabled => disabled_atlas_sprite)   #=> MenuItemAtlasSprite
 *
 * <tt>:normal</tt> and <tt>:selected</tt> are required.
 */
VALUE rb_cMenuItemAtlasSprite_s_new(VALUE klass, VALUE opts) {
	Check_Type(opts, T_HASH);
	// check options
	VALUE normal_sprite = rb_hash_aref(opts, sym_sc_normal);
	if (normal_sprite == Qnil)
		rb_raise(rb_eArgError, "normal sprite required");
	VALUE selected_sprite = rb_hash_aref(opts, sym_sc_selected);
	if (selected_sprite == Qnil)
		rb_raise(rb_eArgError, "selected sprite required");
	VALUE disabled_sprite = rb_hash_aref(opts, sym_sc_disabled);
	AtlasSprite *normalSprite = CC_ATLAS_SPRITE(normal_sprite);
	AtlasSprite *selectedSprite = CC_ATLAS_SPRITE(selected_sprite);
	AtlasSprite *disabledSprite = (disabled_sprite != Qnil) ? CC_ATLAS_SPRITE(disabled_sprite) : nil;
	// create proxy
	MenuItemProxy *mp = [[MenuItemProxy alloc] initWithRubyObject:Qnil];
	MenuItemAtlasSprite *mi = [[MenuItemAtlasSprite alloc] initFromNormalSprite:normalSprite
																 selectedSprite:selectedSprite
																 disabledSprite:disabledSprite
																		 target:mp
																	   selector:@selector(proxyRuby:)];
	VALUE ret = sc_init(klass, nil, mi, 0, 0, YES);
	mp.rbObject = ret;
	
	return ret;
}

void init_rb_cMenuItemAtlasSprite() {
	// FIXME: MenuItemAtlasSprite should be a subclass of MenuItemSprite...
	rb_cMenuItemAtlasSprite = rb_define_class_under(rb_mCocos2D, "MenuItemAtlasSprite", rb_cCocosNode);
	rb_define_singleton_method(rb_cMenuItemAtlasSprite, "new", rb_cMenuItemAtlasSprite_s_new, 1);
}

#pragma mark Menu

VALUE rb_cMenu;

typedef union {
	va_list varargs;
	void *packedArray;
} fakeArray;

/*
 * call-seq:
 *   menu = Menu.new(item1, item2, item3)   #=> Menu
 *
 *   menu = Menu.new do |items|   #=> Menu
 *     items << MyMenuItem.new
 *     items << OtherMenuItem.new
 *     ...
 *   end
 *
 * There are two ways of creating the menu: passing the items as arguments, or
 * using the block initializer. In the latter version, the argument of the block
 * is an empty array.
 */
VALUE rb_cMenu_s_new(VALUE klass, VALUE args) {
	Check_Type(args, T_ARRAY);
	if (RARRAY_LEN(args) < 1 && rb_block_given_p()) {
		rb_yield(args);
	} else if (RARRAY_LEN(args) < 1) {
		rb_raise(rb_eArgError, "Invalid number of items or no block given");
	}
	int i;
	// get first element
	id first = CC_NODE(RARRAY_PTR(args)[0]);
	// create a va_list for the rest of the elements
	fakeArray fa;
	fa.packedArray = alloca(sizeof(id) * RARRAY_LEN(args));
	void *p = fa.packedArray;
	for (i=1; i < RARRAY_LEN(args); i++) {
		*(id *)p = CC_NODE(RARRAY_PTR(args)[i]);
		p += sizeof(id);
	}
	// terminator of the va_list
	*(id *)p = nil;
	
	Menu *menu = [[Menu alloc] initWithItems:first vaList:fa.varargs];
	VALUE ret = sc_init(klass, nil, menu, 0, 0, YES);
	// keep track of the items in the ruby world
	rb_ivar_set(ret, id_sc_ivar_items, args);
	menu.userData = (void *)ret;
	
	return ret;
}


/*
 * call-seq:
 *   menu.align(:horizontally, padding)   #=> menu
 *
 * Align the items horizontally or vertically, with or without padding.
 *
 * Valid options:
 *
 * * <tt>:horizontally</tt>
 * * <tt>:vertically</tt>
 */
VALUE rb_cMenu_align(int argc, VALUE *argv, VALUE obj) {
	if (argc < 1 || argc > 2) {
		rb_raise(rb_eArgError, "Invalid arguments");
	}
	Check_Type(argv[0], T_SYMBOL);
	if (argv[0] == sym_sc_horizontally) {
		if (argc == 2) {
			Check_Type(argv[1], T_FLOAT);
			[CC_MENU(obj) alignItemsHorizontallyWithPadding:NUM2DBL(argv[1])];
		} else {
			[CC_MENU(obj) alignItemsHorizontally];
		}
	} else if (argv[0] == sym_sc_vertically) {
		if (argc == 2) {
			[CC_MENU(obj) alignItemsVerticallyWithPadding:NUM2DBL(argv[1])];
		} else {
			[CC_MENU(obj) alignItemsVertically];
		}
	}
	return obj;
}

void init_rb_cMenu() {
	rb_cMenu = rb_define_class_under(rb_mCocos2D, "Menu", rb_cLayer);
	rb_define_singleton_method(rb_cMenu, "new", rb_cMenu_s_new, -2);
	rb_define_method(rb_cMenu, "align", rb_cMenu_align, -1);
}
