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
#import "SC_common.h"
#import "ruby.h"
#import "SC_UserDefaults.h"

VALUE rb_mUserDefaults;

/*
 * call-seq:
 *   UserDefaults[key] = value   #=> value
 *
 * sets the value for the given key
 */
VALUE rb_mUserDefaults_aset(VALUE module, VALUE key, VALUE value) {
	Check_Type(key, T_STRING);
	Check_Type(value, T_STRING);
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithCString:StringValueCStr(value) encoding:NSUTF8StringEncoding]
											  forKey:[NSString stringWithCString:StringValueCStr(key) encoding:NSUTF8StringEncoding]];
	return value;
}

/*
 * call-seq:
 *   UserDefaults[key]   #=> string
 *
 * retrieves the string associated to the given key
 */
VALUE rb_mUserDefaults_aget(VALUE module, VALUE key) {
	NSString *obj = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithCString:StringValueCStr(key) encoding:NSUTF8StringEncoding]];
	if (obj) {
		return rb_str_new2([obj cStringUsingEncoding:NSUTF8StringEncoding]);
	}
	return Qnil;
}

/*
 * call-seq:
 *   UserDefaults.synchronize   #=> true / false
 *
 * If true, data was saved to disk.
 */
VALUE rb_mUserDefaults_synchronize(VALUE module) {
	return ([[NSUserDefaults standardUserDefaults] synchronize]) ? Qtrue : Qfalse;
}

void init_rb_mUserDefaults() {
	rb_mUserDefaults = rb_define_module_under(rb_mCocos2D, "UserDefaults");
	rb_define_module_function(rb_mUserDefaults, "[]=", rb_mUserDefaults_aset, 2);
	rb_define_module_function(rb_mUserDefaults, "[]", rb_mUserDefaults_aget, 1);
	rb_define_module_function(rb_mUserDefaults, "synchronize", rb_mUserDefaults_synchronize, 0);
}
