//
//  EAGLConfiguration.m
//  iDance-uDance
//
//  Created by CJ Hanson on 4/5/10.
//  Copyright 2010 Hanson Interactive. All rights reserved.
//

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import "EAGLConfiguration.h"
#import <OpenGLES/EAGLDrawable.h>

@implementation EAGLConfiguration

@synthesize colorFormat=colorFormat_, depthFormat=depthFormat_, retainedBacking=retainedBacking_, opaque=opaque_, animationFrameInterval=animationFrameInterval_, multiSampling=multisampling_, requestedSamples=requestedSamples_;

- (void) dealloc
{
	[colorFormat_ release];
	[super dealloc];
}

+ (id) configuration
{
	return [[[self alloc] init] autorelease];
}

- (id) init
{
	self = [super init];
	if(self){
		self.colorFormat	= kEAGLColorFormatRGB565;
		self.depthFormat	= 0;
		self.retainedBacking= NO;
		self.opaque			= YES;
		animationFrameInterval_= 1;
		self.multiSampling	= NO;
		self.requestedSamples = 0;
	}
	return self;
}

- (id) initWithColorFormat:(NSString * const)colorFormat depthFormat:(GLuint)depthFormat retainedBacking:(BOOL)retainedBacking animationFrameInterval:(NSUInteger)animationFrameInterval useMultiSampling:(BOOL)useMultiSampling requestedSamples:(unsigned int)requestedSamples
{
	self = [self init];
	if(self){
		self.colorFormat	= colorFormat;
		self.depthFormat	= depthFormat;
		self.retainedBacking= retainedBacking;
		self.opaque			= (colorFormat_ != kEAGLColorFormatRGBA8);
		self.animationFrameInterval = animationFrameInterval;
		self.multiSampling	= useMultiSampling;
		self.requestedSamples = requestedSamples;
	}
	return self;
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"%@ ColorFormat: %@ DepthFormat: %u RetainedBacking: %s Opaque: %s FrameInterval: %u MultiSampling: %s (%d)", [super description], colorFormat_, depthFormat_, (retainedBacking_)?"Y":"N", (opaque_)?"Y":"N", animationFrameInterval_, multisampling_?"Y":"N", requestedSamples_];
}

@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
