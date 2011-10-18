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

#import "EAGLViewController.h"
#import "EAGLView.h"
#import "EAGLConfiguration.h"
#import "ccMacros.h"

#import "kazmath/kazmath.h"
#import "kazmath/GL/matrix.h"
#import "ccGLState.h"

@interface EAGLViewController(PrivateMethods)
- (void) updateWinSize;
@end


@implementation EAGLViewController

@synthesize	configuration	= configuration_,
			renderer		= renderer_,
			displayLink		= displayLink_,
			contentScaleFactor = contentScaleFactor_,
			isContentScaleSupported = isContentScaleSupported_,
			winSize			= winSizeInPoints_,
			winSizeInPixels	= winSizeInPixels_,
			isPaused		= isPaused_,
			touchDelegate	= touchDelegate_,
			runningThread	= runningThread_,
			glView			= eaglView_;

-(void)dealloc
{
	[eaglView_ release];
	[displayLink_ invalidate];
	[configuration_ release];
	[renderer_ release];
	[super dealloc];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.wantsFullScreenLayout = YES;
		self.configuration	= nil;
		eaglView_			= nil;
		displayLink_		= nil;
		renderer_			= nil;
		contentScaleFactor_	= 1;
		isContentScaleSupported_ = NO;
		winSizeInPixels_ = winSizeInPoints_ = CGSizeZero;
		isPaused_			= NO;
		kmMat4Identity(&projectionMatrix_);
		kmMat4Identity(&modelViewMatrix_);
		
		// running thread is main thread on iOS
		runningThread_		= [NSThread currentThread];
	}
	return self;
}

- (id) initWithRenderer:(id<ESRenderer>)renderer andConfiguration:(EAGLConfiguration *)configuration
{
	self = [self initWithNibName:nil bundle:nil];
	if(self){
		self.configuration	= configuration;
		renderer_			= [renderer retain];
	}
	return self;
}

-(void)loadView
{
	if(eaglView_ == nil){
		eaglView_	= [[EAGLView alloc] initWithFrame:[[UIScreen mainScreen] bounds] renderer:renderer_ andConfiguration:self.configuration];
	}
	
	self.view	= eaglView_;
	
	[renderer_ makeCurrentAndBindBuffers];
	
	kmGLMatrixMode(KM_GL_MODELVIEW);
	kmGLPushMatrix();
	
	[self updateWinSize];
	[self setupOpenGL];
}

- (void) viewDidLoad
{
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(applicationSignificantTimeChange:)
	 name:UIApplicationSignificantTimeChangeNotification
	 object:nil];
}

- (void)viewDidUnload
{
	//[self stopAnimation];
	
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:UIApplicationSignificantTimeChangeNotification
	 object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(viewDidResize:)
	 name:kEAGLViewResizedNotification
	 object:self.view];
	
	[self resume];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:kEAGLViewResizedNotification
	 object:self.view];
	
	[self pause];
}

#pragma mark -
#pragma mark OpenGL Setup

- (void) setupOpenGL
{
	CCLOG(@"EAGLViewController: setupOpenGL resetting Matrices %.2f,%.2f %.2fx%.2f", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
	
	[renderer_ makeCurrentAndBindBuffers];
	
	// set other opengl default values
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	
	[self setAlphaBlending:YES];
	
	if(configuration_.depthFormat == 0){
		[self setDepthTest:NO];
	}else{
		[self setDepthTest:YES];
	}
	
	[self setProjectionMatrix:projectionMatrix_ modelViewMatrix:modelViewMatrix_];
}

- (void) setProjectionMatrix:(kmMat4)projectionMatrix modelViewMatrix:(kmMat4)modelViewMatrix
{
	[renderer_ makeCurrentAndBindBuffers];
	
	projectionMatrix_	= projectionMatrix;
	modelViewMatrix_	= modelViewMatrix;
	
	kmGLMatrixMode(KM_GL_PROJECTION);
	kmGLLoadIdentity();
	kmGLMultMatrix(&projectionMatrix_);
	
	kmGLMatrixMode(KM_GL_MODELVIEW);
	kmGLPopMatrix();
	kmGLLoadIdentity();
	kmGLMultMatrix(&modelViewMatrix_);
	kmGLPushMatrix();
	
	ccSetProjectionMatrixDirty();
}

- (void) setAlphaBlending: (BOOL) on
{
	[renderer_ makeCurrentAndBindBuffers];
	
	if(on){
		glEnable(GL_BLEND);
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	}else{
		glDisable(GL_BLEND);
	}
}

- (void) setDepthTest: (BOOL) on
{
	[renderer_ makeCurrentAndBindBuffers];
	
	if(on){
		glClearDepthf(1.0f);
		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LEQUAL);
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	}else{
		glDisable(GL_DEPTH_TEST);
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
	}
}

- (void) makeCurrentAndBindBuffers
{
	[renderer_ makeCurrentAndBindBuffers];
}

#pragma mark -
#pragma mark Animation

-(void) render
{
	//do drawing here
}

- (void) render:(CADisplayLink *)sender
{
	//	while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.004f, FALSE) == kCFRunLoopRunHandledSource);
	dt_	= sender.timestamp - lastTimestamp_;
	lastTimestamp_	= sender.timestamp;
	if(isPaused_)
		return;
	
	[renderer_ makeCurrentAndBindBuffers];
	[self render];
}

- (void) setAnimationInterval:(NSTimeInterval)frameTimeInterval
{
	NSInteger frameInterval = ceil(frameTimeInterval * 60.0);
	// Frame interval defines how many display frames must pass between each time the
	// display link fires. The display link will only fire 30 times a second when the
	// frame internal is two on a display that refreshes 60 times a second. The default
	// frame interval setting of one will fire 60 times a second when the display refreshes
	// at 60 times a second. A frame interval setting of less than one results in undefined
	// behavior.
	if(frameInterval > 0){
		configuration_.animationFrameInterval = frameInterval;
		
		BOOL isAnimating	= (displayLink_ && !displayLink_.isPaused);
		[displayLink_ invalidate];
		displayLink_	= nil;
		if(isAnimating)
			[self startAnimation];
	}
}

- (NSTimeInterval) animationInterval
{
	return (NSTimeInterval)configuration_.animationFrameInterval / 60.0;
}

- (void) resume
{
	if(!isPaused_)
		return;
	
	isPaused_ = NO;
	
	[self startAnimation];
	[self.view setUserInteractionEnabled:YES];
}

- (void) startAnimation
{
	lastTimestamp_	= CACurrentMediaTime();
	
	if(!displayLink_){
		// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
		// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
		// not be called in system versions earlier than 3.1.
		
		displayLink_ = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
		[displayLink_ setFrameInterval:configuration_.animationFrameInterval];
		[displayLink_ addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		
		[self render:displayLink_];
	}else{
		[displayLink_ setPaused:NO];
	}
}

- (void) pause
{
	if(isPaused_)
		return;
	
	isPaused_ = YES;
	
	[self stopAnimation];
	[self.view setUserInteractionEnabled:NO];
}

- (void)stopAnimation
{
	[displayLink_ setPaused:YES];
}

#pragma mark -
#pragma mark Resize

- (void) viewDidResize:(NSNotification *)notification
{
	CCLOG(@"EAGLViewController:  got viewDidResize notification. Updating values of winSize and forcing a render");
	[renderer_ makeCurrentAndBindBuffers];
	[self updateWinSize];
	[self setupOpenGL];
	[self render];
}

- (void) updateWinSize
{
	// Based on code snippet from: http://developer.apple.com/iphone/prerelease/library/snippets/sp2010/sp28.html
	if ([eaglView_ respondsToSelector:@selector(setContentScaleFactor:)])
	{			
		[eaglView_ setContentScaleFactor: contentScaleFactor_];
		
		isContentScaleSupported_ = YES;
	}
	else
		CCLOG(@"cocos2d: 'setContentScaleFactor:' is not supported on this device");
	
	
	CGSize viewSize			= self.view.frame.size;
	winSizeInPoints_		= CGSizeMake(viewSize.width, viewSize.height);
	
	if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
		// swap x,y in landscape mode
		winSizeInPoints_.width		= viewSize.height;
		winSizeInPoints_.height		= viewSize.width;
	}
	
	winSizeInPixels_ = CGSizeMake(winSizeInPoints_.width * contentScaleFactor_, winSizeInPoints_.height * contentScaleFactor_);
	
	CCLOG(@"EAGLViewController: updateWinSize: %s %.2f x %.2f to %.2f x %.2f", (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))?"L":"P", viewSize.width, viewSize.height, winSizeInPoints_.width, winSizeInPoints_.height);
}

-(void) setContentScaleFactor:(CGFloat)scaleFactor
{
	if( scaleFactor != contentScaleFactor_ ) {
		
		contentScaleFactor_ = scaleFactor;
		
		if( eaglView_ )
			[self updateWinSize];
	}
}

#pragma mark -
#pragma mark Coordinate Conversion

-(CGPoint)convertToGL:(CGPoint)uiPoint
{
	return CGPointMake(uiPoint.x, winSizeInPoints_.height- uiPoint.y);
}

-(CGPoint)convertToUI:(CGPoint)glPoint
{
	return CGPointMake(glPoint.x, winSizeInPoints_.height - glPoint.y);
}

#pragma mark -
#pragma mark Rotation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark Application Notifications

- (void) applicationSignificantTimeChange:(NSNotification *)notification
{
	CCLOG(@"EAGLViewController: applicationSignificantTimeChange");
	lastTimestamp_	= displayLink_.timestamp;
}

- (void)didReceiveMemoryWarning
{
	CCLOG(@"EAGLViewController: didReceiveMemoryWarning");
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Touch delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDelegate_ touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDelegate_ touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDelegate_ touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDelegate_ touchesCancelled:touches withEvent:event];
}

@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
