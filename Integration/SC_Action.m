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

VALUE rb_cAction;


/*
 * call-seq:
 *   Action.new   #=> new action
 */
VALUE rb_cAction_s_new(int argc, VALUE *argv, VALUE klass) {
	Action *action = [[Action alloc] init];
	VALUE ret = sc_init(klass, nil, action, argc, argv, YES);
	return ret;
}


/*
 * call-seq:
 *   action.start   #=> nil
 *
 * starts running the action
 */
VALUE rb_cAction_start(VALUE object) {
	[CC_ACTION(object) start];
	return Qnil;
}


/*
 * call-seq:
 *   action.stop   #=> nil
 *
 * stops the running action
 */
VALUE rb_cAction_stop(VALUE object) {
	[CC_ACTION(object) stop];
	return Qnil;
}


/*
 * call-seq:
 *   action.done?   #=> true/false
 *
 * returns true if the action is done
 */
VALUE rb_cAction_done_p(VALUE object) {
	return [CC_ACTION(object) done] ? Qtrue : Qfalse;
}

void init_rb_cAction() {
	rb_cAction = rb_define_class_under(rb_mCocos2D, "Action", rb_cObject);
	rb_define_singleton_method(rb_cAction, "new", rb_cAction_s_new, -1);
	// action methods
	rb_define_method(rb_cAction, "start", rb_cAction_start, 0);
	rb_define_method(rb_cAction, "stop", rb_cAction_stop, 0);
	rb_define_method(rb_cAction, "done?", rb_cAction_done_p, 0);
}
