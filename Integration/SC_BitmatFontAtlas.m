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

#import "SC_common.h"
#import "SC_AtlasSpriteManager.h"
#import "SC_BitmatFontAtlas.h"

VALUE rb_cBitmapFontAtlas;

/*
 * call-seq:
 *   label = BitmapFontAtlas.new("string", "file.fnt")   #=> BitmapFontAtlas instance
 *
 * returns a new bitmap font atlas from a fnt file (created using the hiero bitmap font tool)
 */
VALUE rb_cBitmapFontAtlas_s_new(VALUE klass, VALUE string, VALUE fnt_file) {
	Check_Type(string, T_STRING);
	Check_Type(fnt_file, T_STRING);
	BitmapFontAtlas *bm = [[BitmapFontAtlas alloc] initWithString:[NSString stringWithCString:StringValueCStr(string) encoding:NSUTF8StringEncoding]
														  fntFile:[NSString stringWithCString:StringValueCStr(fnt_file) encoding:NSUTF8StringEncoding]];
	VALUE ret = sc_init(klass, nil, bm, 0, 0, YES);
	return ret;
}


/*
 * call-seq:
 *   label.string = "new string"   #=> the new string
 *
 * sets the new string of the label
 */
VALUE rb_cBitmapFontAtlas_set_string(VALUE object, VALUE string) {
	Check_Type(string, T_STRING);
	[CC_BMFONT(object) setString:[NSString stringWithCString:StringValueCStr(string) encoding:NSUTF8StringEncoding]];
	return string;
}

void init_rb_cBitmapFontAtlas() {
	rb_cBitmapFontAtlas = rb_define_class_under(rb_mCocos2D, "BitmapFontAtlas", rb_cAtlasSpriteManager);
	rb_define_singleton_method(rb_cBitmapFontAtlas, "new", rb_cBitmapFontAtlas_s_new, 2);
	rb_define_method(rb_cBitmapFontAtlas, "string=", rb_cBitmapFontAtlas_set_string, 1);
}
