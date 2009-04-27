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


extern VALUE rb_cAtlasSpriteManager;

#pragma mark Methods

/* manager = AtlasSpriteManager.manager_with_file(file, :capacity => 10) */
VALUE rb_cAtlasSpriteManager_s_Sprite_Manager_With_File(int argc, VALUE *argv, VALUE klass);

/* sprite = manager.create_sprite([top, left, width, height]) */
VALUE rb_cAtlasSpriteManager_create_sprite(VALUE obj, VALUE rect);

void init_rb_cAtlasSpriteManager();
