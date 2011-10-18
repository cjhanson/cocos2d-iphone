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


#import "ccConfig.h"
#import "ccTypes.h"

#import "Platforms/CCGL.h"
#import "CCProtocols.h"

@class CCScene;

/** In cocos2d 2.0 CCDirector is merely a convenience class that manages a gl based view controller and node hierarchy.
 
 Since it was once almighty it retains many wrapper methods to access the view controller and node hierarchy.
 
 Since the CCDirector is a singleton, the standard way to use it is by calling:
  - [[CCDirector sharedDirector] methodName];
 
 You could also build a complete app without using this singleton if you want more control or you want to use multiple view hierarchies with multiple views/windows/screens.
*/
@interface CCDirector : NSObject
{
	CC_GLVIEWCONTROLLER	*openGLViewController_;
}

/** The OpenGLView, where everything is rendered */
@property (nonatomic,readwrite,retain) CC_GLVIEWCONTROLLER *openGLViewController;

/** All of the methods below are merely convenience wrappers for the viewcontroller or view */

/** The current running Scene. Director can only run one Scene at the time */
@property (nonatomic,readonly) CCScene* runningScene;
/** The FPS value */
@property (nonatomic,readwrite, assign) NSTimeInterval animationInterval;
/** Whether or not to display the FPS on the bottom-left corner */
@property (nonatomic,readwrite, assign) BOOL displayFPS;

/** Whether or not the Director is paused */
@property (nonatomic,readonly) BOOL isPaused;
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

/** returns the single instance of the director */
+(CCDirector *)sharedDirector;

// Window size

/** returns the size of the OpenGL view in points */
- (CGSize) winSize;

/** returns the size of the OpenGL view in pixels.
 On Mac winSize and winSizeInPixels return the same value.
 */
- (CGSize) winSizeInPixels;

/** converts a UIKit coordinate to an OpenGL coordinate
 Useful to convert (multi) touchs coordinates to the current layout (portrait or landscape)
 */
-(CGPoint) convertToGL:(CGPoint)p;
/** converts an OpenGL coordinate to a UIKit coordinate
 Useful to convert node points to window points for calls such as glScissor
 */
-(CGPoint) convertToUI:(CGPoint)p;

/** Used by the 3D projection */
-(float) getZEye;

// Scene Management

/** Sets the scene and starts animation
 */
- (void) runWithScene:(CCScene*) scene;

/** Replaces the running scene with a new one. The running scene is terminated.
 */
-(void) replaceScene: (CCScene*) scene;

/** Replaces the running scene with a new one created from the passed block
 */
- (void) replaceSceneUsingCreationBlock:(CCScene*(^)())sceneCreatorBlock;

/** Ends the execution, releases the running scene.
 It doesn't remove the OpenGL view from its parent. You have to do it manually.
 */
-(void) end;

/** Pauses the running scene.
 The running scene will be _drawed_ but all scheduled timers will be paused
 While paused, the draw rate will be 4 FPS to reduce CPU consuption
 */
-(void) pause;

/** Resumes the paused scene
 The scheduled timers will be activated again.
 The "delta time" will be 0 (as if the game wasn't paused)
 */
-(void) resume;

/** Stops the animation. Nothing will be drawn. The main loop won't be triggered anymore.
 If you wan't to pause your animation call [pause] instead.
 */
-(void) stopAnimation;

/** The main loop is triggered again.
 Call this function only if [stopAnimation] was called earlier
 @warning Dont' call this function to start the main loop. To run the main loop call runWithScene
 */
-(void) startAnimation;

// Memory Helper

/** Removes all the cocos2d data that was cached automatically.
 It will purge the CCTextureCache, CCLabelBMFont cache.
 IMPORTANT: The CCSpriteFrameCache won't be purged. If you want to purge it, you have to purge it manually.
 @since v0.99.3
 */
-(void) purgeCachedData; 

// OpenGL Helper

/** enables/disables OpenGL alpha blending */
- (void) setAlphaBlending: (BOOL) on;
/** enables/disables OpenGL depth test */
- (void) setDepthTest: (BOOL) on;

/** Will enable Retina Display on devices that supports it.
 It will enable Retina Display on iPhone4 and iPod Touch 4.
 It will return YES, if it could enabled it, otherwise it will return NO.
 
 This is the recommened way to enable Retina Display.
 @since v0.99.5
 */
-(BOOL) enableRetinaDisplay:(BOOL)enableRetina;

@end

