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
ID id_sc_touches_began;
ID id_sc_touches_cancelled;
ID id_sc_touches_ended;
ID id_sc_touches_moved;
ID id_sc_vertically;
ID id_sc_z;
ID id_sc_starting_gid;
ID id_sc_text_field_action;

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
	id_sc_touches_began = rb_intern("touches_began");
	id_sc_touches_cancelled = rb_intern("touches_cancelled");
	id_sc_touches_ended = rb_intern("touches_ended");
	id_sc_touches_moved = rb_intern("touches_moved");
	id_sc_vertically = rb_intern("vertically");
	id_sc_z = rb_intern("z");
	id_sc_starting_gid = rb_intern("starting_gid");
	id_sc_text_field_action = rb_intern("text_field_action");
}
