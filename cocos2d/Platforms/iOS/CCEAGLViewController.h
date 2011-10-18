/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * This Class was created by CJ Hanson on 17 OCT 2011.
 * Copyright (c) 2010 Ricardo Quesada
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
 *
 *
 */

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "CCProtocols.h"
#import "ccConfig.h"
#import "ccTypes.h"

// OpenGL related
#import "EAGLViewController.h"
#import "EAGLConfiguration.h"

@class CCLabelAtlas;
@class CCScene;
@class CCTexture2D;
@class CCScheduler;
@class CCTouchDispatcher;

@interface CCEAGLViewController : EAGLViewController {
	CCScheduler			*scheduler_;
	CCTouchDispatcher	*touchDispatcher_;
	
	/* projection used */
	ccDirectorProjection projection_;
	
	/* Projection protocol delegate */
	id<CCProjectionProtocol>	projectionDelegate_;
	
	/* Pre render protocol delegate */
	id<CCPreRenderProtocol>		preRenderDelegate_;
	
	/* Post render protocol delegate */
	id<CCPostRenderProtocol>	postRenderDelegate_;
	
	/* A stack of scenes */
	NSMutableArray		*scenesStack_;
	
	/* The root node will be visited first, and is the primary node of the display hierarchy */
	CCScene				*rootNode_;
	
	// FPS Label
	BOOL				displayFPS_;
	NSUInteger			frames;
	ccTime				accumDt;
	ccTime				frameRate;
	CCLabelAtlas		*FPSLabel_;
	
	// Total frames drawn
	NSUInteger			totalFrames_;
}

/** The root of the display list */
@property (nonatomic, retain) CCScene *rootNode;

@property (nonatomic, assign) CCScheduler *scheduler;

@property (nonatomic, assign) CCTouchDispatcher *touchDispatcher;

/** Whether or not to display the FPS on the bottom-left corner */
@property (nonatomic, readwrite, assign) BOOL displayFPS;

/** Total frames displayed */
@property (nonatomic, readonly) NSUInteger totalFrames;

/** Sets an OpenGL projection
 @since v0.8.2
 */
@property (nonatomic,readwrite) ccDirectorProjection projection;

/** This object will be visited before the main scene is visited.
 This object MUST implement the "visit" selector.
 Useful to hook a notification object, like CCNotifications (http://github.com/manucorporat/CCNotifications)
 @since v2.0
 */
@property (nonatomic, readwrite, retain) id<CCPreRenderProtocol> preRenderDelegate;

/** This object will be visited after the main scene is visited.
 This object MUST implement the "visit" selector.
 Useful to hook a notification object, like CCNotifications (http://github.com/manucorporat/CCNotifications)
 @since v2.0
 */
@property (nonatomic, readwrite, retain) id<CCPostRenderProtocol> postRenderDelegate;

/** This object will be called when the OpenGL projection is udpated and only when the kCCDirectorProjectionCustom projection is used.
 @since v0.99.5
 */
@property (nonatomic, readwrite, retain) id<CCProjectionProtocol> projectionDelegate;

/// XXX: missing description
- (float) getZEye;

/** Will enable Retina Display on devices that supports it.
 It will enable Retina Display on iPhone4 and iPod Touch 4.
 It will return YES, if it could enabled it, otherwise it will return NO.
 
 This is the recommened way to enable Retina Display.
 @since v0.99.5
 */
-(BOOL) enableRetinaDisplay:(BOOL)enableRetina;

/** legacy interfaces kept for convenience of compatibility with old code */

/** Sets the scene and starts animation
 */
- (void)runWithScene:(CCScene*) scene;

/** Replaces the running scene with a new one. The running scene is terminated.
 */
- (void) replaceScene: (CCScene*) scene;

/** Replaces the running scene with a new one created from the passed block
 */
- (void) replaceSceneUsingCreationBlock:(CCScene*(^)())sceneCreatorBlock;

@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
