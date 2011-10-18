/*
 
Modified by CJ Hanson on 17 OCT 2011

===== IMPORTANT =====

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not
final. Apple is supplying this information to help you plan for the adoption of
the technologies and programming interfaces described herein. This information
is subject to change, and software implemented based on this sample code should
be tested with final operating system software and final documentation. Newer
versions of this sample code may be provided with future seeds of the API or
technology. For information about updates to this and other developer
documentation, view the New & Updated sidebars in subsequent documentation
seeds.

=====================

File: EAGLView.m
Abstract: Convenience class that wraps the CAEAGLLayer from CoreAnimation into a
UIView subclass.

Version: 1.3

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import <QuartzCore/QuartzCore.h>

#import "EAGLView.h"
#import "EAGLConfiguration.h"
#import "ES2Renderer.h"
#import "../../ccMacros.h"
#import "../../CCConfiguration.h"
#import "../../Support/OpenGL_Internal.h"

NSString *const kEAGLViewResizedNotification	= @"kEAGLViewResizedNotification";

//CLASS IMPLEMENTATIONS:

@interface EAGLView (Private)
- (BOOL) setupSurface;
@end

@implementation EAGLView

@synthesize renderer=renderer_;
@synthesize configuration=configuration_;

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

+ (id) viewWithFrame:(CGRect)frame
{
	return [[[self alloc] initWithFrame:frame] autorelease];
}

+ (id) viewWithFrame:(CGRect)frame renderer:(id<ESRenderer>)renderer andConfiguration:(EAGLConfiguration *)configuration
{
	return [[[self alloc] initWithFrame:frame renderer:renderer andConfiguration:configuration] autorelease];
}

- (id) initWithFrame:(CGRect)frame
{
	EAGLConfiguration *configuration	= [EAGLConfiguration configuration];
	ES2Renderer *renderer				= [[ES2Renderer alloc] initWithDepthFormat:configuration.depthFormat sharegroup:nil useMultiSampling:configuration.multiSampling numberOfSamples:configuration.requestedSamples];
	
	self = [self initWithFrame:frame renderer:renderer andConfiguration:configuration];
	
	[renderer release];
	
	return self;
}

- (id) initWithFrame:(CGRect)frame renderer:(id<ESRenderer>)renderer andConfiguration:(EAGLConfiguration *)configuration
{
	if((self = [super initWithFrame:frame]))
	{
		renderer_		= [renderer retain];
		configuration_	= [configuration retain];
		
		if( ! [self setupSurface] ) {
			[self release];
			return nil;
		}

		CHECK_GL_ERROR_DEBUG();
	}

	return self;
}

//NOTE: CJ has not tested this method of initialization (anyone care to explain what triggers this method?)
-(id) initWithCoder:(NSCoder *)aDecoder
{
	if( (self = [super initWithCoder:aDecoder]) ) {
		
		if( ! [self setupSurface] ) {
			[self release];
			return nil;
		}

		CHECK_GL_ERROR_DEBUG();
    }
	
    return self;
}

-(BOOL) setupSurface
{
	NSAssert(renderer_, @"OpenGL ES 2.0 renderer is required");
	
	self.opaque						= configuration_.opaque;
	
	CAEAGLLayer *eaglLayer			= (CAEAGLLayer *)self.layer;
	eaglLayer.opaque				= self.opaque;
	eaglLayer.drawableProperties	= [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSNumber numberWithBool:configuration_.retainedBacking], kEAGLDrawablePropertyRetainedBacking,
									   configuration_.colorFormat, kEAGLDrawablePropertyColorFormat,
									   nil];
	
	if(![renderer_ setupOpenGLFromLayer:eaglLayer])
		return NO;
	
	CHECK_GL_ERROR_DEBUG();
	
	return YES;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[configuration_ release];
	[renderer_ release];
	[super dealloc];
}

- (void)layoutSubviews
{
	if([renderer_ resizeFromLayer:(CAEAGLLayer *)(self.layer)]){
		[[NSNotificationCenter defaultCenter] postNotificationName:kEAGLViewResizedNotification object:self];
	}
}

- (void) swapBuffers
{
	[renderer_ presentRenderbuffer];
}

#pragma mark EAGLView - Point conversion

- (CGPoint) convertPointFromViewToSurface:(CGPoint)point
{
	CGRect bounds	= [self bounds];
	CGSize size		= [self surfaceSize];
	
	return CGPointMake((point.x - bounds.origin.x) / bounds.size.width * size.width, (point.y - bounds.origin.y) / bounds.size.height * size.height);
}

- (CGRect) convertRectFromViewToSurface:(CGRect)rect
{
	CGRect bounds	= [self bounds];
	CGSize size		= [self surfaceSize];
	
	return CGRectMake((rect.origin.x - bounds.origin.x) / bounds.size.width * size.width, (rect.origin.y - bounds.origin.y) / bounds.size.height * size.height, rect.size.width / bounds.size.width * size.width, rect.size.height / bounds.size.height * size.height);
}

//TODO (Can somebody step in here and do the opposite of this coordinate conversion?)
- (CGPoint) convertPointFromSurfaceToView:(CGPoint)point
{
	CGRect bounds	= [self bounds];
	CGSize size		= [self surfaceSize];
	
	return CGPointMake((point.x - bounds.origin.x) / bounds.size.width * size.width, (point.y - bounds.origin.y) / bounds.size.height * size.height);
}

//TODO (Can somebody step in here and do the opposite of this coordinate conversion?)
- (CGRect) convertRectFromSurfaceToView:(CGRect)rect
{
	CGRect bounds	= [self bounds];
	CGSize size		= [self surfaceSize];
	
	return CGRectMake((rect.origin.x - bounds.origin.x) / bounds.size.width * size.width, (rect.origin.y - bounds.origin.y) / bounds.size.height * size.height, rect.size.width / bounds.size.width * size.width, rect.size.height / bounds.size.height * size.height);
}

#pragma mark Renderer convenience methods

- (EAGLContext *) context
{
	return [renderer_ context];
}

- (CGSize) surfaceSize
{
	if(!renderer_)
		return self.frame.size;
	return [renderer_ backingSize];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"%@ %@", [super description], configuration_];
}

@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED