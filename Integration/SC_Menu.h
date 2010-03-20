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

// proxy for the MenuItem, it will hold the reference to a ruby object that will
// be called when this object is called by the menu item
@interface MenuItemProxy : NSObject
{
	VALUE rbObject;
	id    menuItem;
}

@property (readwrite, assign) VALUE rbObject;

+ (id)proxy;
- (id)initWithRubyObject:(VALUE)object;
- (void)proxyRuby:(id)sender;
@end

extern VALUE rb_cMenu;
extern VALUE rb_cMenuItemLabel;
extern VALUE rb_cMenuItemImage;
extern VALUE rb_cMenuItemAtlasSprite;

void init_rb_cMenu();
void init_rb_cMenuItem();
void init_rb_cMenuItemLabel();
void init_rb_cMenuItemAtlasSprite();
void init_rb_cMenuItemImage();
