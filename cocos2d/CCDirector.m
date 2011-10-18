/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


/* Idea of decoupling Window from Director taken from OC3D project: http://code.google.com/p/oc3d/
 */

#import <unistd.h>
#import <Availability.h>

// cocos2d imports
#import "CCDirector.h"
#import "CCScheduler.h"
#import "CCActionManager.h"
#import "CCTextureCache.h"
#import "CCAnimationCache.h"
#import "CCLabelAtlas.h"
#import "ccMacros.h"
#import "CCTransition.h"
#import "CCNode.h"
#import "CCSpriteFrameCache.h"
#import "CCTexture2D.h"
#import "CCLabelBMFont.h"
#import "CCLayer.h"
#import "ccGLState.h"
#import "CCShaderCache.h"

// support imports
#import "Platforms/CCGL.h"
#import "Platforms/CCNS.h"

#import "Support/OpenGL_Internal.h"
#import "Support/CGPointExtension.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "Platforms/iOS/CCDirectorIOS.h"
#import "Platforms/iOS/CCEAGLViewController.h"
#define CC_DIRECTOR_DEFAULT CCDirectorDisplayLink
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import "Platforms/Mac/CCDirectorMac.h"
#import "Platforms/Mac/CCMacViewController.h"
#define CC_DIRECTOR_DEFAULT CCDirectorDisplayLink
#endif

#import "Support/CCProfiling.h"

#define kDefaultFPS		60.0	// 60 frames per second

extern NSString * cocos2dVersion(void);

@implementation CCDirector

//
// singleton stuff
//
static CCDirector *_sharedDirector = nil;

+ (CCDirector *)sharedDirector
{
	if (!_sharedDirector) {

		//
		// Default Director is Display link director
		// 
		if( [ [CCDirector class] isEqual:[self class]] )
			_sharedDirector = [[CC_DIRECTOR_DEFAULT alloc] init];
		else
			_sharedDirector = [[self alloc] init];
	}
		
	return _sharedDirector;
}

+(id)alloc
{
	NSAssert(_sharedDirector == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

- (id) init
{  
	CCLOG(@"cocos2d: %@", cocos2dVersion() );

	if( (self=[super init]) ) {
		CCLOG(@"cocos2d: Using Director Type:%@", [self class]);
	}

	return self;
}

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	
	[openGLViewController_ release];
	
	_sharedDirector = nil;
	
	[super dealloc];
}

#pragma mark Director - Memory Helper

-(void) end
{
	[openGLViewController_ makeCurrentAndBindBuffers];
	
	// Purge bitmap cache
	[CCLabelBMFont purgeCachedData];
	
	// Purge all managers / caches
	[CCAnimationCache purgeSharedAnimationCache];
	[CCSpriteFrameCache purgeSharedSpriteFrameCache];
	[CCScheduler purgeSharedScheduler];
	[CCActionManager purgeSharedManager];
	[CCTextureCache purgeSharedTextureCache];
	[CCShaderCache purgeSharedShaderCache];
	
	// Invalidate GL state cache
	ccGLInvalidateStateCache();
	
	CHECK_GL_ERROR();
	
	//important to do this last since the above rely on opengl calls
	[openGLViewController_ stopAnimation];
	[openGLViewController_ release];
	openGLViewController_ = nil;
}

-(void) purgeCachedData
{
	[CCLabelBMFont purgeCachedData];	
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

#pragma mark -
#pragma mark Convenience methods to the view controller / view

#pragma mark Director - Scene OpenGL Helper

-(ccDirectorProjection) projection
{
	return openGLViewController_.projection;
}

-(float) getZEye
{
	return [openGLViewController_ getZEye];
}

-(void) setProjection:(ccDirectorProjection)projection
{
	[openGLViewController_ setProjection:projection];
}

- (void) setAlphaBlending: (BOOL) on
{
	[openGLViewController_ setAlphaBlending:on];
}

- (void) setDepthTest: (BOOL) on
{
	[openGLViewController_ setDepthTest:on];
}

#pragma mark Director Integration with a UIKit view

-(CC_GLVIEWCONTROLLER*) openGLViewController
{
	return openGLViewController_;
}

-(void) setOpenGLViewController:(CC_GLVIEWCONTROLLER *)viewcontroller
{
	NSAssert( viewcontroller, @"OpenGLViewController must be non-nil");

	if( viewcontroller != openGLViewController_ ) {
		[openGLViewController_ release];
		openGLViewController_ = [viewcontroller retain];
	}
}

- (id<CCPreRenderProtocol>) preRenderDelegate
{
	return [openGLViewController_ preRenderDelegate];
}

- (void) setPreRenderDelegate:(id<CCPreRenderProtocol>)preRenderDelegate
{
	[openGLViewController_ setPreRenderDelegate:preRenderDelegate];
}

- (id<CCPostRenderProtocol>) postRenderDelegate
{
	return [openGLViewController_ postRenderDelegate];
}

- (void) setPostRenderDelegate:(id<CCPostRenderProtocol>)postRenderDelegate
{
	[openGLViewController_ setPostRenderDelegate:postRenderDelegate];
}

- (id<CCProjectionProtocol>) projectionDelegate
{
	return [openGLViewController_ projectionDelegate];
}

- (void) setProjectionDelegate:(id<CCProjectionProtocol>)projectionDelegate
{
	[openGLViewController_ setProjectionDelegate:projectionDelegate];
}

#pragma mark Director Scene Coordinate conversion

-(CGPoint)convertToGL:(CGPoint)uiPoint
{
	return [openGLViewController_ convertToGL:uiPoint];
}

-(CGPoint)convertToUI:(CGPoint)glPoint
{
	return [openGLViewController_ convertToUI:glPoint];
}

-(CGSize)winSize
{
	return [openGLViewController_ winSize];
}

-(CGSize)winSizeInPixels
{
	return [openGLViewController_ winSizeInPixels];
}

#pragma mark Director Scene Management

- (CCScene *)runningScene
{
	return [openGLViewController_ rootNode];
}

- (void)runWithScene:(CCScene*) scene
{
	[openGLViewController_ runWithScene:scene];
}

-(void) replaceScene: (CCScene*) scene
{
	[openGLViewController_ replaceScene:scene];
}

- (void) replaceSceneUsingCreationBlock:(CCScene*(^)())sceneCreatorBlock
{
	[openGLViewController_ replaceSceneUsingCreationBlock:sceneCreatorBlock];
}

#pragma mark Animation

- (BOOL) isPaused
{
	return [openGLViewController_ isPaused];
}

-(void) pause
{
	[openGLViewController_ pause];
}

-(void) resume
{
	[openGLViewController_ resume];
}

- (void)startAnimation
{
	[openGLViewController_ startAnimation];
}

- (void)stopAnimation
{
	[openGLViewController_ stopAnimation];
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	[openGLViewController_ setAnimationInterval:interval];
}

- (NSTimeInterval) animationInterval
{
	return [openGLViewController_ animationInterval];
}

#pragma mark FPS

- (void) setDisplayFPS:(BOOL)displayFPS
{
	[openGLViewController_ setDisplayFPS:displayFPS];
}

- (BOOL) displayFPS
{
	return [openGLViewController_ displayFPS];
}

-(BOOL) enableRetinaDisplay:(BOOL)enableRetina
{
	return [openGLViewController_ enableRetinaDisplay:enableRetina];
}

@end

