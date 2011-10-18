//
//  ExternalScreenTest.m
//  cocos2d-ios
//
//  Created by CJ Hanson on 10/17/11.
//  Copyright (c) 2011 Hanson Interactive. All rights reserved.
//

#import "ExternalScreenTest.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "DualScreenRootViewController.h"
#endif

@implementation ExternalScreenTest

-(NSString *) title
{
	return @"External Screen Test";
}

-(NSString*) subtitle
{
	return @"Use the TV out feature of the simulator or connect your device to an external display with AirPlay or a cable.";
}

@end

#pragma mark -
#pragma mark AppController

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	isApplicationActive_	= YES;
	isInBackground_			= NO;
	
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [viewController_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Turn on display FPS
	[viewController_ setDisplayFPS:YES];
	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// When in iPad / RetinaDisplay mode, CCFileUtils will append the "-ipad" / "-hd" to all loaded files
	// If the -ipad  / -hdfile is not found, it will load the non-suffixed version
	[CCFileUtils setiPadSuffix:@"-ipad"];			// Default on iPad is "" (empty string)
	[CCFileUtils setRetinaDisplaySuffix:@"-hd"];	// Default on RetinaDisplay is "-hd"
	
	CCScene *scene		= [CCScene node];
	CCSprite *aSprite	= [CCSprite spriteWithFile:@"background1.jpg"];
	aSprite.anchorPoint	= CGPointZero;
	[scene addChild:aSprite z:0];
	
	[viewController_ runWithScene: scene];
}

-(void) applicationWillResignActive:(UIApplication *)application
{
	isApplicationActive_ = NO;
    // Incoming phone call...
	if(viewController_.isPaused){
		directorWasPausedWhenResigned_ = YES;
	}else{
		directorWasPausedWhenResigned_ = NO;
		[viewController_ pause];
	}
}

-(void) applicationDidBecomeActive:(UIApplication *)application
{
	isApplicationActive_ = YES;
    // Phone call rejected...
	if(!isInBackground_ && !directorWasPausedWhenResigned_)
		[viewController_ resume];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	isInBackground_ = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	isInBackground_ = NO;
	
	if(!directorWasPausedWhenResigned_)
		[viewController_ resume];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

- (void) dealloc
{
	[viewController_ release];
	[window_ release];
	[super dealloc];
}

@end
