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
#import "SC_Label.h"
#import "SC_CocosNode.h"

VALUE rb_cLabel;

/*
 * call-seq:
 *   label = Label.new(string, fontname, fontsize)   #=> Label
 *
 * Creates a new label
 */
VALUE rb_cLabel_s_new(int argc, VALUE *argv, VALUE klass) {
	if (argc < 3) {
		rb_raise(rb_eArgError, "Invalid number of arguments");
	}
	Check_Type(argv[0], T_STRING);
	Check_Type(argv[1], T_STRING);
	Label *label = [[Label alloc] initWithString:[NSString stringWithCString:StringValueCStr(argv[0]) encoding:NSUTF8StringEncoding]
										fontName:[NSString stringWithCString:StringValueCStr(argv[1]) encoding:NSUTF8StringEncoding]
										fontSize:FIX2INT(argv[2])];
	VALUE ret = sc_init(klass, nil, label, argc-3, argv+3, YES);
	label.userData = (void *)ret;
	
	return ret;
}

/*
 * call-seq:
 *   label.string = "new string"   #=> "new string"
 *
 * Sets the string of the label
 */
VALUE rb_clabel_set_string(VALUE object, VALUE string) {
	[CC_LABEL(object) setString:[NSString stringWithCString:StringValueCStr(string) encoding:NSUTF8StringEncoding]];
	return string;
}


/*
 * The ruby equivalent of the Layer node
 */
void init_rb_cLabel() {
	rb_cLabel = rb_define_class_under(rb_mCocos2D, "Label", rb_cCocosNode);
	rb_define_singleton_method(rb_cLabel, "new", rb_cLabel_s_new, -1);
	rb_define_method(rb_cLabel, "string=", rb_clabel_set_string, 1);
}
