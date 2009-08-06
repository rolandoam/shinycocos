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
#import "SC_TextField.h"
#import "SC_CocosNode.h"

VALUE rb_cTextField;


/*
 * call-seq:
 *   TextField.new(size, landscape)   #=> a text field
 *
 * size is an array of 4 floats. Landscape is to rotate the textfield
 */
VALUE rb_cTextField_s_new(int argc, VALUE *argv, VALUE klass) {
	if (argc < 2) {
		rb_raise(rb_eArgError, "Invalid number of arguments");
	}
	Check_Type(argv[0], T_ARRAY);
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(FIX2INT(RARRAY_PTR(argv[0])[0]), FIX2INT(RARRAY_PTR(argv[0])[1]), FIX2INT(RARRAY_PTR(argv[0])[2]), FIX2INT(RARRAY_PTR(argv[0])[3]))];
	// rotate to portrait
	if (argv[1] != Qfalse)
		[textField setTransform:CGAffineTransformMakeRotation(3.14/2)];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.returnKeyType = UIReturnKeyDone;
	VALUE ret = sc_init(klass, nil, textField, argc-2, argv+2, YES);
	sc_add_tracking(sc_object_hash, textField, ret);
	
	return ret;
}


/*
 * call-seq:
 *   text_field.attach   #=> nil
 *
 * attaches the text field to the Director's OpenGL view
 */
VALUE rb_cTextField_attach(VALUE object) {
	[[Director sharedDirector].openGLView addSubview:UI_TFIELD(object)];
	return Qnil;
}

/*
 * call-seq:
 *   text_field.detach   #=> nil
 *
 * detaches the text field from the Director's OpenGL view
 */
VALUE rb_cTextField_detach(VALUE object) {
	[UI_TFIELD(object) removeFromSuperview];
	return Qnil;
}

/*
 * call-seq:
 *   text_field.value   #=> string
 *
 * returns the value (as a string) of the text field
 */
VALUE rb_cTextField_value(VALUE object) {
	return rb_str_new2([UI_TFIELD(object).text cStringUsingEncoding:NSUTF8StringEncoding]);
}

/*
 * call-seq:
 *   text_field.value = string   #=> string
 *
 * sets the value (string) of the text field
 */
VALUE rb_cTextField_set_value(VALUE object, VALUE rb_str) {
	Check_Type(rb_str, T_STRING);
	UI_TFIELD(object).text = [NSString stringWithCString:RSTRING_PTR(rb_str) encoding:NSUTF8StringEncoding];
	return rb_str;
}


/*
 * call-seq:
 *   text_field.delegate = cocos_node   #=> cocos_node
 *
 * the delegate must be a subclass of cocos_node
 */
VALUE rb_cTextField_set_delegate(VALUE object, VALUE delegate) {
	UI_TFIELD(object).delegate = (id)CC_NODE(delegate);
	rb_ivar_set(object, id_sc_ivar_delegate, delegate);
	return delegate;
}


/*
 * call-seq:
 *   text_field.secure_text(true/false)   #=> true/false
 *
 * sets the secure text entry property of the text field.
 */
VALUE rb_cTextField_secure_text(VALUE object, VALUE isSecure) {
	UI_TFIELD(object).secureTextEntry = (isSecure == Qfalse) ? NO : YES;
	return (isSecure == Qfalse) ? Qfalse : Qtrue;
}

/*
 * call-seq:
 *   text_field.resign_first_responder   #=> nil
 *
 * Will resign as a first responder
 */
VALUE rb_cTextField_resign_first_responder(VALUE object) {
	[UI_TFIELD(object) resignFirstResponder];
	return Qnil;
}

void init_rb_cTextField() {
	rb_cTextField = rb_define_class_under(rb_mCocos2D, "TextField", rb_cObject);
	rb_define_singleton_method(rb_cTextField, "new", rb_cTextField_s_new, -1);
	rb_define_method(rb_cTextField, "attach", rb_cTextField_attach, 0);
	rb_define_method(rb_cTextField, "detach", rb_cTextField_detach, 0);
	rb_define_method(rb_cTextField, "value", rb_cTextField_value, 0);
	rb_define_method(rb_cTextField, "value=", rb_cTextField_set_value, 1);
	rb_define_method(rb_cTextField, "delegate=", rb_cTextField_set_delegate, 1);
	rb_define_method(rb_cTextField, "secure_text", rb_cTextField_secure_text, 1);
	rb_define_method(rb_cTextField, "resign_first_responder", rb_cTextField_resign_first_responder, 0);
}
