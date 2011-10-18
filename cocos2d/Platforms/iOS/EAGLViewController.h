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
#import "ESRenderer.h"
#import "ES2Renderer.h"

#import "kazmath/mat4.h"

@class EAGLConfiguration;
@class EAGLView;

@protocol EAGLTouchDelegate <NSObject>
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@interface EAGLViewController : UIViewController {
	/* the cocos2d running thread */
	NSThread			*runningThread_;
	
	// Although these two are used by the View,
	// they are stored by the view controller
	// as well to facilitate delayed view creation
	EAGLConfiguration	*configuration_;
	id<ESRenderer>		renderer_;
	
	//The GL view
	EAGLView			*eaglView_;
	
	CADisplayLink		*displayLink_;
	id<EAGLTouchDelegate>   touchDelegate_;
	
	kmMat4				projectionMatrix_;
	kmMat4				modelViewMatrix_;
	
	/* content scale */
	float				contentScaleFactor_;
	BOOL				isContentScaleSupported_;
	
	/* window size in points */
	CGSize				winSizeInPoints_;
	
	/* window size in pixels */
	CGSize				winSizeInPixels_;
	
	CFTimeInterval		lastTimestamp_;
	CFTimeInterval		dt_;
	
	BOOL				isPaused_;
}

/** returns the cocos2d thread.
 If you want to run any cocos2d task, run it in this thread.
 On iOS usually it is the main thread.
 @since v0.99.5
 */
@property (readonly, nonatomic) NSThread *runningThread;
/* gl configuration */
@property (nonatomic, retain) EAGLConfiguration *configuration;
/* gl renderer */
@property (nonatomic, readonly) id<ESRenderer> renderer;
/** touch delegate */
@property(nonatomic,readwrite,assign) id<EAGLTouchDelegate> touchDelegate;
/** Display link */
@property (nonatomic, readonly) CADisplayLink *displayLink;
/** Set the frameInterval property of the DisplayLink (assumes a 60fps display) */
@property (nonatomic, assign) NSTimeInterval animationInterval;
/* winSize reports the logical size of the stage in points */
@property (nonatomic, readonly) CGSize winSize;
/** returns the size of the OpenGL view in pixels (accounting for contentScale) */
@property (nonatomic, readonly) CGSize winSizeInPixels;
/** content scale factor (can be adjusted to any value) */
@property (nonatomic, assign) float contentScaleFactor;
@property (nonatomic, readonly) BOOL isContentScaleSupported;
/* paused */
@property (nonatomic, readonly) BOOL isPaused;
/* EAGLView */
@property (nonatomic, readonly) EAGLView *glView;

- (id) initWithRenderer:(id<ESRenderer>)renderer andConfiguration:(EAGLConfiguration *)configuration;

- (void) render;

- (void) setupOpenGL;

- (void) setProjectionMatrix:(kmMat4)projectionMatrix modelViewMatrix:(kmMat4)modelViewMatrix;

- (void) updateWinSize;

- (void) makeCurrentAndBindBuffers;

/** Stops the animation. Nothing will be drawn or updated.
 */
- (void) stopAnimation;

/** Stops animation and also disables interaction. Normally this would be the preferred method to use over stopAnimation directly. */
- (void) pause;

/** The main loop is triggered again.
 Call this function to start the main loop.
 */
- (void) startAnimation;
/** Starts animation and also enables interaction. Normally this would be the preferred method to use over startAnimation directly. */
- (void) resume;

/** enables/disables OpenGL alpha blending */
- (void) setAlphaBlending: (BOOL) on;

/** enables/disables OpenGL depth test */
- (void) setDepthTest: (BOOL) on;

/** converts a UIKit coordinate to an OpenGL coordinate
 Useful to convert (multi) touchs coordinates to the current layout (portrait or landscape)
 */
-(CGPoint) convertToGL: (CGPoint) p;

/** converts an OpenGL coordinate to a UIKit coordinate
 Useful to convert node points to window points for calls such as glScissor
 */
-(CGPoint) convertToUI:(CGPoint)p;

@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
