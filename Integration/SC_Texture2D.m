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
#import "SC_Texture2D.h"

VALUE rb_cTexture2D;

/* 
 * Must complete doc
 */
VALUE rb_cTexture2D_s_save_tex_parameters(VALUE klass) {
	[Texture2D saveTexParameters];
	return Qnil;
}

/* 
 * Must complete doc
 */
VALUE rb_cTexture2D_s_set_alias_tex_parameters(VALUE klass) {
	[Texture2D setAliasTexParameters];
	return Qnil;
}

/* 
 * Must complete doc
 */
VALUE rb_cTexture2D_s_restore_tex_parameters(VALUE klass) {
	[Texture2D restoreTexParameters];
	return Qnil;
}

/* 
 * Must complete doc
 */
VALUE rb_cTexture2D_s_aliased(VALUE klass) {
	if (rb_block_given_p()) {
		[Texture2D saveTexParameters];
		[Texture2D setAliasTexParameters];
		rb_yield(Qnil);
		[Texture2D restoreTexParameters];
	}
	return Qnil;
}

void init_rb_cTexture2D() {
	rb_cTexture2D = rb_define_class_under(rb_mCocos2D, "Texture2D", rb_cObject);
	rb_define_singleton_method(rb_cTexture2D, "save_tex_parameters", rb_cTexture2D_s_save_tex_parameters, 0);
	rb_define_singleton_method(rb_cTexture2D, "set_alias_tex_parameters", rb_cTexture2D_s_set_alias_tex_parameters, 0);
	rb_define_singleton_method(rb_cTexture2D, "restore_tex_parameters", rb_cTexture2D_s_restore_tex_parameters, 0);
	rb_define_singleton_method(rb_cTexture2D, "aliased", rb_cTexture2D_s_aliased, 0);
}
