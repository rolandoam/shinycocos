//
//  ___PROJECTNAMEASIDENTIFIER___AppDelegate.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "___PROJECTNAMEASIDENTIFIER___AppDelegate.h"
#import "ShinyCocos.h"

// dummy sc_require
// used when not implementing code obfuscation
unsigned long sc_require(unsigned long file) {
	return (unsigned long)4; // Qnil == 4
}

@implementation ___PROJECTNAMEASIDENTIFIER___AppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
#if COCOS2D_DEBUG
	// add a special place to look for ruby scripts
	ShinyCocosSetup(@"/Somewhere/In/Your/HD");
#else
	ShinyCocosSetup(nil);
#endif
	ShinyCocosInitChipmunk();
	ShinyCocosStart(window, self);
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
	ShinyCocosStop();
	[[Director sharedDirector] release];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}
@end
