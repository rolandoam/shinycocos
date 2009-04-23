//
//  SC_CocosNode.h
//  ShinyCocos
//
//  Created by Rolando Abarca on 4/11/09.
//  Copyright 2009 Games For Food SpA. All rights reserved.
//

extern VALUE rb_cAtlasSpriteManager;

#pragma mark Methods

/* manager = AtlasSpriteManager.manager_with_file(file, :capacity => 10) */
VALUE rb_cAtlasSpriteManager_s_Sprite_Manager_With_File(int argc, VALUE *argv, VALUE klass);

/* sprite = manager.create_sprite([top, left, width, height]) */
VALUE rb_cAtlasSpriteManager_create_sprite(VALUE obj, VALUE rect);

void init_rb_cAtlasSpriteManager();
