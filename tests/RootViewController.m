//
//  RootViewController.m
//  TestCocos2d
//
//  Created by Ricardo Quesada on 6/22/11.
//  Copyright Sapus Media 2011. All rights reserved.
//

//
// RootViewController
//
// Use this class to control rotation and integtration with iAd and any other View Controller
//

#import "cocos2d.h"

#import "RootViewController.h"

@implementation RootViewController

//Override the default initializer or create a new one and call this one on the parent
- (id) initWithRenderer:renderer andConfiguration:configuration
{
	self = [super initWithRenderer:renderer andConfiguration:configuration];
	if(self){
		
	}
	return self;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
	// EAGLView will be rotated by the UIViewController
	//
	// return YES for the supported orientations
	
	// For landscape only, uncomment the following line
//	return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );


	// For portrait only, uncomment the following line
//	return ( ! UIInterfaceOrientationIsLandscape( interfaceOrientation ) );

	// To support all oritentatiosn return YES
	return YES;
}

- (void)dealloc
{
    [super dealloc];
}


@end

