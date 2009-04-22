//
//  TestShinyCocosAppDelegate.m
//  TestShinyCocos
//
//  Created by Rolando Abarca on 4/21/09.
//  Copyright Games For Food SpA 2009. All rights reserved.
//

#import "TestShinyCocosAppDelegate.h"
#import "ShinyCocos.h"
#import "cocos2d.h"

@implementation TestShinyCocosAppDelegate


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	ShinyCocosSetup(window);
	ShinyCocosStart();
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

-(void) applicationWillTerminate: (UIApplication*) application {
	[[Director sharedDirector] release];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
