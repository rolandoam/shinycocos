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
#import "SC_ids.h"

ID id_sc_animate;
ID id_sc_capacity;
ID id_sc_data;
ID id_sc_delay;
ID id_sc_delete;
ID id_sc_did_accelerate;
ID id_sc_disabled;
ID id_sc_frames;
ID id_sc_horizontally;
ID id_sc_inspect;
ID id_sc_item_action;
ID id_sc_join;
ID id_sc_location;
ID id_sc_manager;
ID id_sc_map_height;
ID id_sc_map_width;
ID id_sc_message;
ID id_sc_move_by;
ID id_sc_move_to;
ID id_sc_name;
ID id_sc_normal;
ID id_sc_on_enter;
ID id_sc_on_exit;
ID id_sc_on_stop;
ID id_sc_parallax_ratio;
ID id_sc_push;
ID id_sc_read;
ID id_sc_rect;
ID id_sc_repeat_forever;
ID id_sc_selected;
ID id_sc_tag;
ID id_sc_tap_count;
ID id_sc_tile_height;
ID id_sc_tile_width;
ID id_sc_tiles;
ID id_sc_timestamp;
ID id_sc_touch_began;
ID id_sc_touch_cancelled;
ID id_sc_touch_ended;
ID id_sc_touch_moved;
ID id_sc_vertically;
ID id_sc_z;
ID id_sc_starting_gid;
ID id_sc_text_field_action;
ID id_sc_alert_view_clicked_button;
ID id_sc_alert_view_cancel;
ID id_sc_alert_view_did_dismiss;
ID id_sc_av_player_did_finish_playing;

// transitions
ID sc_id_transition_scene;
ID sc_id_oriented_transition_scene;
ID sc_id_roto_zoom_transition;
ID sc_id_jump_zoom_transition;
ID sc_id_move_in_l_transition;
ID sc_id_move_in_r_transition;
ID sc_id_move_in_t_transition;
ID sc_id_move_in_b_transition;
ID sc_id_slide_in_l_transition;
ID sc_id_slide_in_r_transition;
ID sc_id_slide_in_b_transition;
ID sc_id_slide_in_t_transition;
ID sc_id_shrink_grow_transition;
ID sc_id_flip_x_transition;
ID sc_id_flip_y_transition;
ID sc_id_flip_angular_transition;
ID sc_id_zoom_flip_x_transition;
ID sc_id_zoom_flip_y_transition;
ID sc_id_zoom_flip_angular_transition;
ID sc_id_fade_transition;
ID sc_id_turn_off_tiles_transition;
ID sc_id_split_cols_transition;
ID sc_id_split_rows_transition;
ID sc_id_fade_t_r_transition;
ID sc_id_fade_b_l_transition;
ID sc_id_fade_up_transition;
ID sc_id_fade_down_transition;
ID sc_id_on_enter_transition_did_finish;

void init_sc_ids() {
	id_sc_animate = rb_intern("animate");
	id_sc_capacity = rb_intern("capacity");
	id_sc_data = rb_intern("data");
	id_sc_delay = rb_intern("delay");
	id_sc_delete = rb_intern("delete");
	id_sc_did_accelerate = rb_intern("did_accelerate");
	id_sc_disabled = rb_intern("disabled");
	id_sc_frames = rb_intern("frames");
	id_sc_horizontally = rb_intern("horizontally");
	id_sc_inspect = rb_intern("inspect");
	id_sc_item_action = rb_intern("item_action");
	id_sc_join = rb_intern("join");
	id_sc_location = rb_intern("location");
	id_sc_manager = rb_intern("manager");
	id_sc_map_height = rb_intern("map_height");
	id_sc_map_width = rb_intern("map_width");
	id_sc_message = rb_intern("message");
	id_sc_move_by = rb_intern("move_by");
	id_sc_move_to = rb_intern("move_to");
	id_sc_name = rb_intern("name");
	id_sc_normal = rb_intern("normal");
	id_sc_on_enter = rb_intern("on_enter");
	id_sc_on_exit = rb_intern("on_exit");
	id_sc_on_stop = rb_intern("on_stop");
	id_sc_parallax_ratio = rb_intern("parallax_ratio");
	id_sc_push = rb_intern("push");
	id_sc_read = rb_intern("read");
	id_sc_rect = rb_intern("rect");
	id_sc_repeat_forever = rb_intern("repeat_forever");
	id_sc_selected = rb_intern("selected");
	id_sc_tag = rb_intern("tag");
	id_sc_tap_count = rb_intern("tap_count");
	id_sc_tile_height = rb_intern("tile_height");
	id_sc_tile_width = rb_intern("tile_width");
	id_sc_tiles = rb_intern("tiles");
	id_sc_timestamp = rb_intern("timestamp");
	id_sc_touch_began = rb_intern("touch_began");
	id_sc_touch_cancelled = rb_intern("touch_cancelled");
	id_sc_touch_ended = rb_intern("touch_ended");
	id_sc_touch_moved = rb_intern("touch_moved");
	id_sc_vertically = rb_intern("vertically");
	id_sc_z = rb_intern("z");
	id_sc_starting_gid = rb_intern("starting_gid");
	id_sc_text_field_action = rb_intern("text_field_action");
	id_sc_alert_view_clicked_button = rb_intern("alert_view_clicked_button");
	id_sc_alert_view_cancel = rb_intern("alert_view_cancel");
	id_sc_alert_view_did_dismiss = rb_intern("alert_view_did_dismiss");
	id_sc_av_player_did_finish_playing = rb_intern("player_did_finish_playing");
	// transitions
	sc_id_on_enter_transition_did_finish = rb_intern("on_enter_transition_did_finish");
	sc_id_transition_scene = rb_intern("transition_scene");
	sc_id_oriented_transition_scene = rb_intern("oriented_transition_scene");
	sc_id_roto_zoom_transition = rb_intern("roto_zoom_transition");
	sc_id_jump_zoom_transition = rb_intern("jump_zoom_transition");
	sc_id_move_in_l_transition = rb_intern("move_in_l_transition");
	sc_id_move_in_r_transition = rb_intern("move_in_r_transition");
	sc_id_move_in_t_transition = rb_intern("move_in_t_transition");
	sc_id_move_in_b_transition = rb_intern("move_in_b_transition");
	sc_id_slide_in_l_transition = rb_intern("slide_in_l_transition");
	sc_id_slide_in_r_transition = rb_intern("slide_in_r_transition");
	sc_id_slide_in_b_transition = rb_intern("slide_in_b_transition");
	sc_id_slide_in_t_transition = rb_intern("slide_in_t_transition");
	sc_id_shrink_grow_transition = rb_intern("shrink_grow_transition");
	sc_id_flip_x_transition = rb_intern("flip_x_transition");
	sc_id_flip_y_transition = rb_intern("flip_y_transition");
	sc_id_flip_angular_transition = rb_intern("flip_angular_transition");
	sc_id_zoom_flip_x_transition = rb_intern("zoom_flip_x_transition");
	sc_id_zoom_flip_y_transition = rb_intern("zoom_flip_y_transition");
	sc_id_zoom_flip_angular_transition = rb_intern("zoom_flip_angular_transition");
	sc_id_fade_transition = rb_intern("fade_transition");
	sc_id_turn_off_tiles_transition = rb_intern("turn_off_tiles_transition");
	sc_id_split_cols_transition = rb_intern("split_cols_transition");
	sc_id_split_rows_transition = rb_intern("split_rows_transition");
	sc_id_fade_t_r_transition = rb_intern("fade_t_r_transition");
	sc_id_fade_b_l_transition = rb_intern("fade_b_l_transition");
	sc_id_fade_up_transition = rb_intern("fade_up_transition");
	sc_id_fade_down_transition = rb_intern("fade_down_transition");
}
