/*
 *  ShinyCocos.h
 *  ShinyCocos
 *
 *  Created by Rolando Abarca on 4/7/09.
 *  Copyright 2009 Games For Food SpA. All rights reserved.
 *
 */

/* setup cocos2d <-> ruby integration */
void ShinyCocosSetup(UIWindow *window);
/* will require "main.rb" from the Resource Path */
void ShinyCocosStart();
/* clean up things */
void ShinyCocosStop();
