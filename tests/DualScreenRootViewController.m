//
//  DualScreenRootViewController.m
//  cocos2d-ios
//
//  Created by CJ Hanson on 10/17/11.
//  Copyright (c) 2011 Hanson Interactive. All rights reserved.
//

#import "DualScreenRootViewController.h"

@implementation DualScreenRootViewController

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
