//
//  SC_CocosNode.h
//  ShinyCocos
//
//  Created by Rolando Abarca on 4/11/09.
//  Copyright 2009 Games For Food SpA. All rights reserved.
//

extern VALUE rb_cAtlasSprite;

/* sprite = AtlasSprite.sprite_with_options(:rect => [top, left, width, height], :manager => manager) */
VALUE rb_cAtlasSprite_s_sprite(VALUE klass, VALUE opts);

void init_rb_cAtlasSprite();
