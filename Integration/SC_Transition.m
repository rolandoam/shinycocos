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

#import "ruby.h"
#import "SC_common.h"
#import "SC_Scene.h"
#import "SC_Transition.h"

VALUE rb_cTransitionScene;


/*
 * call-seq:
 *   TransitionScene.new(transition_name, final_scene, *args)   #=> TransitionScene
 *
 * transition_name can be one of the following:
 *
 * *<tt>:transition_scene</tt> (duration)
 * *<tt>:oriented_transition_scene</tt> (duration, orientation)
 * *<tt>:roto_zoom_transition</tt> (duration)
 * *<tt>:jump_zoom_transition</tt> (duration)
 * *<tt>:move_in_l_transition</tt> (duration)
 * *<tt>:move_in_r_transition</tt>
 * *<tt>:move_in_t_transition</tt>
 * *<tt>:move_in_b_transition</tt>
 * *<tt>:slide_in_l_transition</tt>
 * *<tt>:slide_in_r_transition</tt>
 * *<tt>:slide_in_b_transition</tt>
 * *<tt>:slide_in_t_transition</tt>
 * *<tt>:shrink_grow_transition</tt>
 * *<tt>:flip_x_transition</tt>
 * *<tt>:flip_y_transition</tt>
 * *<tt>:flip_angular_transition</tt>
 * *<tt>:zoom_flip_x_transition</tt>
 * *<tt>:zoom_flip_y_transition</tt>
 * *<tt>:zoom_flip_angular_transition</tt>
 * *<tt>:fade_transition</tt>
 * *<tt>:turn_off_tiles_transition</tt>
 * *<tt>:split_cols_transition</tt>
 * *<tt>:split_rows_transition</tt>
 * *<tt>:fade_t_r_transition</tt>
 * *<tt>:fade_b_l_transition</tt>
 * *<tt>:fade_up_transition</tt>
 * *<tt>:fade_down_transition</tt>
 *
 * The rest of the arguments are the final scene and the arguments needed to build the
 * transition.
 */

VALUE rb_cTransitionScene_s_new(int argc, VALUE *argv, VALUE klass) {
	if (argc < 3) {
		rb_raise(rb_eArgError, "Invalid number of arguments");
	}
	TransitionScene *ts = nil;
	ID tr_id = SYM2ID(argv[0]);
	Check_Type(argv[2], T_FLOAT);
	if (tr_id == sc_id_transition_scene) {
		ts = [[TransitionScene alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_oriented_transition_scene) {
		if (argc < 4) goto error;
		Check_Type(argv[3], T_FIXNUM);
		ts = [[OrientedTransitionScene alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1]) orientation:FIX2INT(argv[3])];
		argc -= 1;
		argv += 1;
	} else if (tr_id == sc_id_roto_zoom_transition) {
		ts = [[RotoZoomTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_jump_zoom_transition) {
		ts = [[JumpZoomTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_move_in_l_transition) {
		ts = [[MoveInLTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_move_in_r_transition) {
		ts = [[MoveInRTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_move_in_t_transition) {
		ts = [[MoveInTTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_move_in_b_transition) {
		ts = [[MoveInBTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_slide_in_l_transition) {
		ts = [[SlideInLTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_slide_in_r_transition) {
		ts = [[SlideInRTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_slide_in_b_transition) {
		ts = [[SlideInBTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_slide_in_t_transition) {
		ts = [[SlideInTTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_shrink_grow_transition) {
		ts = [[ShrinkGrowTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_flip_x_transition) {
		ts = [[FlipXTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_flip_y_transition) {
		ts = [[FlipYTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_flip_angular_transition) {
		ts = [[FlipAngularTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_zoom_flip_x_transition) {
		ts = [[ZoomFlipXTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_zoom_flip_y_transition) {
		ts = [[ZoomFlipYTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_zoom_flip_angular_transition) {
		ts = [[ZoomFlipAngularTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_fade_transition) {
		if (argc < 4) goto error;
		Check_Type(argv[3], T_ARRAY);
		ccColor3B color;
		color.r = FIX2INT(RARRAY_PTR(argv[3])[0]);
		color.g = FIX2INT(RARRAY_PTR(argv[3])[1]);
		color.b = FIX2INT(RARRAY_PTR(argv[3])[2]);
		ts = [[FadeTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1]) withColor:color];
		argc -= 1;
		argv += 1;
	} else if (tr_id == sc_id_turn_off_tiles_transition) {
		ts = [[TurnOffTilesTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_split_cols_transition) {
		ts = [[SplitColsTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_split_rows_transition) {
		ts = [[SplitRowsTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
	} else if (tr_id == sc_id_fade_t_r_transition) {
		if (argc < 4) goto error;
		Check_Type(argv[3], T_FIXNUM);
		ts = [[FadeTRTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
		argc -= 1;
		argv += 1;
	} else if (tr_id == sc_id_fade_b_l_transition) {
		if (argc < 4) goto error;
		Check_Type(argv[3], T_FIXNUM);
		ts = [[FadeBLTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
		argc -= 1;
		argv += 1;
	} else if (tr_id == sc_id_fade_up_transition) {
		if (argc < 4) goto error;
		Check_Type(argv[3], T_FIXNUM);
		ts = [[FadeUpTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
		argc -= 1;
		argv += 1;
	} else if (tr_id == sc_id_fade_down_transition) {
		if (argc < 4) goto error;
		Check_Type(argv[3], T_FIXNUM);
		ts = [[FadeDownTransition alloc] initWithDuration:NUM2DBL(argv[2]) scene:CC_SCENE(argv[1])];
		argc -= 1;
		argv += 1;
	}
	argc -= 3;
	argv += 3;

error:
	if (ts == nil) {
		rb_raise(rb_eArgError, "Invalid arguments for transition %s", rb_str_new2(rb_id2name(SYM2ID(argv[0]))));
	}
	VALUE ret = sc_init(klass, nil, ts, argc, argv, YES);
	return ret;
}


void init_rb_cTransitionScene() {
	rb_cTransitionScene = rb_define_class_under(rb_mCocos2D, "TransitionScene", rb_cScene);
	rb_define_singleton_method(rb_cTransitionScene, "new", rb_cTransitionScene_s_new, -1);
	rb_define_const(rb_cTransitionScene, "ORIENTATION_LEFT_OVER", 0);
	rb_define_const(rb_cTransitionScene, "ORIENTATION_RIGHT_OVER", 1);
	rb_define_const(rb_cTransitionScene, "ORIENTATION_UP_OVER", 0);
	rb_define_const(rb_cTransitionScene, "ORIENTATION_DOWN_OVER", 1);
}
