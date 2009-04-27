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

extern VALUE rb_cAtlasSprite;
extern VALUE rb_cAtlasAnimation;

#pragma mark AtlasSprite

/* sprite = AtlasSprite.sprite_with_options(:rect => [top, left, width, height], :manager => manager) */
VALUE rb_cAtlasSprite_s_sprite(VALUE klass, VALUE opts);

void init_rb_cAtlasSprite();

#pragma mark AtlasAnimation

/*
frame argument is optional
  animation = AltasAnimation.animation(:name => "name", :delay => 1/60.0, :frame => [frame1, frame2])
*/
VALUE rb_cAtlasAnimation_s_animation(VALUE klass, VALUE opts);
/*
animation.add(frame, rect)
*/
VALUE rb_cAtlasAnimation_add(VALUE obj, VALUE frame, VALUE rect);
void init_rb_cAtlasAnimation();
