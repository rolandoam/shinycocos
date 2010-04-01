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

extern ID id_sc_animate;
extern ID id_sc_capacity;
extern ID id_sc_data;
extern ID id_sc_delay;
extern ID id_sc_delete;
extern ID id_sc_did_accelerate;
extern ID id_sc_disabled;
extern ID id_sc_frames;
extern ID id_sc_horizontally;
extern ID id_sc_inspect;
extern ID id_sc_item_action;
extern ID id_sc_join;
extern ID id_sc_location;
extern ID id_sc_manager;
extern ID id_sc_map_height;
extern ID id_sc_map_width;
extern ID id_sc_message;
extern ID id_sc_move_by;
extern ID id_sc_move_to;
extern ID id_sc_name;
extern ID id_sc_normal;
extern ID id_sc_draw;
extern ID id_sc_on_enter;
extern ID id_sc_on_exit;
extern ID id_sc_on_stop;
extern ID id_sc_parallax_ratio;
extern ID id_sc_push;
extern ID id_sc_read;
extern ID id_sc_rect;
extern ID id_sc_repeat_forever;
extern ID id_sc_selected;
extern ID id_sc_tag;
extern ID id_sc_tap_count;
extern ID id_sc_tile_height;
extern ID id_sc_tile_width;
extern ID id_sc_tiles;
extern ID id_sc_timestamp;
extern ID id_sc_touch_began;
extern ID id_sc_touch_cancelled;
extern ID id_sc_touch_ended;
extern ID id_sc_touch_moved;
extern ID id_sc_touches_began;
extern ID id_sc_touches_cancelled;
extern ID id_sc_touches_ended;
extern ID id_sc_touches_moved;
extern ID id_sc_vertically;
extern ID id_sc_z;
extern ID id_sc_starting_gid;
extern ID id_sc_text_field_action;
extern ID id_sc_alert_view_clicked_button;
extern ID id_sc_alert_view_cancel;
extern ID id_sc_alert_view_did_dismiss;
extern ID id_sc_av_player_did_finish_playing;
extern ID id_sc_ui_action;
extern ID id_sc_parallax;
// ivars
extern ID id_sc_ivar_scheduled_methods;
extern ID id_sc_ivar_space;
extern ID id_sc_ivar_children;
extern ID id_sc_ivar_cc_node;
extern ID id_sc_ivar_shape;
extern ID id_sc_ivar_running_scene;
extern ID id_sc_ivar_items;
extern ID id_sc_ivar_delegate;

// transitions
extern ID sc_id_on_enter_transition_did_finish;
extern ID sc_id_transition_scene;
extern ID sc_id_oriented_transition_scene;
extern ID sc_id_roto_zoom_transition;
extern ID sc_id_jump_zoom_transition;
extern ID sc_id_move_in_l_transition;
extern ID sc_id_move_in_r_transition;
extern ID sc_id_move_in_t_transition;
extern ID sc_id_move_in_b_transition;
extern ID sc_id_slide_in_l_transition;
extern ID sc_id_slide_in_r_transition;
extern ID sc_id_slide_in_b_transition;
extern ID sc_id_slide_in_t_transition;
extern ID sc_id_shrink_grow_transition;
extern ID sc_id_flip_x_transition;
extern ID sc_id_flip_y_transition;
extern ID sc_id_flip_angular_transition;
extern ID sc_id_zoom_flip_x_transition;
extern ID sc_id_zoom_flip_y_transition;
extern ID sc_id_zoom_flip_angular_transition;
extern ID sc_id_fade_transition;
extern ID sc_id_turn_off_tiles_transition;
extern ID sc_id_split_cols_transition;
extern ID sc_id_split_rows_transition;
extern ID sc_id_fade_t_r_transition;
extern ID sc_id_fade_b_l_transition;
extern ID sc_id_fade_up_transition;
extern ID sc_id_fade_down_transition;

/* symbols */
extern VALUE sym_sc_map_width;
extern VALUE sym_sc_map_height;
extern VALUE sym_sc_tile_width;
extern VALUE sym_sc_tile_height;
extern VALUE sym_sc_starting_gid;
extern VALUE sym_sc_data;
extern VALUE sym_sc_location;
extern VALUE sym_sc_tap_count;
extern VALUE sym_sc_capacity;
extern VALUE sym_sc_manager;
extern VALUE sym_sc_rect;
extern VALUE sym_sc_name;
extern VALUE sym_sc_delay;
extern VALUE sym_sc_frames;
extern VALUE sym_sc_normal;
extern VALUE sym_sc_selected;
extern VALUE sym_sc_disabled;
extern VALUE sym_sc_horizontally;
extern VALUE sym_sc_vertically;
extern VALUE sym_sc_parallax;
extern VALUE sym_sc_z;
extern VALUE sym_sc_tag;
extern VALUE sym_sc_parallax_ratio;

void init_sc_ids();