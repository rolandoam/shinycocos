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
#import "SC_CocoaAdditions.h"

/*
 * call-seq:
 *     str = File.read_from_resources("some_file.txt")   #=> String
 *
 * Will return a string from the file found on resources in the App
 * bundle.
 *
 * Returns nil if no file is found.
 */
VALUE rb_cFile_s_read_from_resources(VALUE klass, VALUE fpath) {
	Check_Type(fpath, T_STRING);
	NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithCString:StringValueCStr(fpath) encoding:NSUTF8StringEncoding] ofType:nil];
	if (path == nil)
		return Qnil;
	return sc_protect_funcall(klass, id_sc_read, 1, rb_str_new2([path cStringUsingEncoding:NSUTF8StringEncoding]));
}

void init_sc_cocoa_additions() {
	rb_define_singleton_method(rb_cFile, "read_from_resources", rb_cFile_s_read_from_resources, 1);
}
