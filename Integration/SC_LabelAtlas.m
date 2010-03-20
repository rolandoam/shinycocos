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
#import "SC_LabelAtlas.h"
#import "SC_CocosNode.h"

VALUE rb_cLabelAtlas;

/*
 * call-seq:
 *   label = LabelAtlas.new(string, charmapfile, item_width, item_height, start_char)   #=> LabelAtlas
 *
 * Creates a new label atlas
 */
VALUE rb_cLabelAtlas_s_new(int argc, VALUE *argv, VALUE klass) {
	if (argc < 5) {
		rb_raise(rb_eArgError, "Invalid number of arguments");
	}
	Check_Type(argv[0], T_STRING);
	Check_Type(argv[1], T_STRING);
	Check_Type(argv[2], T_FIXNUM);
	Check_Type(argv[3], T_FIXNUM);
	Check_Type(argv[4], T_STRING);
	LabelAtlas *label = [[LabelAtlas alloc] initWithString:[NSString stringWithCString:StringValueCStr(argv[0]) encoding:NSUTF8StringEncoding]
											   charMapFile:[NSString stringWithCString:StringValueCStr(argv[1]) encoding:NSUTF8StringEncoding]
												 itemWidth:FIX2INT(argv[2])
												itemHeight:FIX2INT(argv[3])
											  startCharMap:((char)(RSTRING_PTR(argv[4])[0]))];
	VALUE ret = sc_init(klass, nil, label, argc-5, argv+5, YES);
	label.userData = (void *)ret;
	
	return ret;
}

/*
 * call-seq:
 *   label.string = "new string"   #=> "new string"
 *
 * Sets the string of the label
 */
VALUE rb_cLabelAtlas_set_string(VALUE object, VALUE string) {
	[CC_LABEL(object) setString:[NSString stringWithCString:StringValueCStr(string) encoding:NSUTF8StringEncoding]];
	return string;
}


/*
 * The ruby equivalent of the Layer node
 */
void init_rb_cLabelAtlas() {
	rb_cLabelAtlas = rb_define_class_under(rb_mCocos2D, "LabelAtlas", rb_cCocosNode);
	rb_define_singleton_method(rb_cLabelAtlas, "new", rb_cLabelAtlas_s_new, -1);
	rb_define_method(rb_cLabelAtlas, "string=", rb_cLabelAtlas_set_string, 1);
}
