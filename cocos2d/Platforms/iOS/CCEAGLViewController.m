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

#import "CCEAGLViewController.h"
#import "ccMacros.h"

#import "CCScheduler.h"
#import "CCTouchDispatcher.h"
#import "CCTextureCache.h"

#import "CCTexture2D.h"
#import "CCNode.h"
#import "CCScene.h"
#import "CCLayer.h"
#import "CCSprite.h"
#import "CCRenderTexture.h"

#import "CCLabelAtlas.h"

// support imports
#import "../../Support/OpenGL_Internal.h"
#import "../../Support/CGPointExtension.h"
#import "../../Support/TransformUtils.h"
#import "ccGLState.h"

#import "kazmath/kazmath.h"
#import "kazmath/GL/matrix.h"

extern NSString * cocos2dVersion(void);

@interface CCEAGLViewController (Private)
- (void) setRootNodeNow:(CCScene *)aNode;
- (void) updateRenderState:(CFTimeInterval)timestamp;
- (void) showFPS;
- (void) createFPSLabel;
- (void) destroyFPSLabel;
@end

@implementation CCEAGLViewController

@synthesize rootNode		= rootNode_;
@synthesize displayFPS		= displayFPS_;
@synthesize projection		= projection_;
@synthesize scheduler		= scheduler_;
@synthesize touchDispatcher	= touchDispatcher_;
@synthesize projectionDelegate = projectionDelegate_;
@synthesize preRenderDelegate = preRenderDelegate_;
@synthesize postRenderDelegate = postRenderDelegate_;
@synthesize totalFrames		= totalFrames_;

- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	
	if([rootNode_ isRunning])
		[rootNode_ onExit];
	[rootNode_ cleanup];
	[rootNode_ release], rootNode_ = nil;
	
	[projectionDelegate_ release];
	[preRenderDelegate_ release];
	[postRenderDelegate_ release];
	
	[self destroyFPSLabel];
	
	[super dealloc];
}

- (id) initWithRenderer:(id<ESRenderer>)renderer andConfiguration:(EAGLConfiguration *)configuration
{
	CCLOG(@"cocos2d: Version: %@", cocos2dVersion());
	self = [super initWithRenderer:renderer andConfiguration:configuration];
	if(self){
		CCLOG(@"cocos2d: Using EAGLViewController Type:%@", [self class]);
		CCScene *aNode			= [[CCScene alloc] init];
		[self setRootNodeNow:aNode];
		
		scenesStack_			= [[NSMutableArray alloc] initWithCapacity:10];
		projectionDelegate_		= nil;
		preRenderDelegate_		= nil;
		postRenderDelegate_		= nil;
		
		scheduler_				= [CCScheduler sharedScheduler];
		touchDispatcher_		= [CCTouchDispatcher sharedDispatcher];
		
		projection_				= kCCDirectorProjectionDefault;
		
		// FPS
		displayFPS_				= NO;
	}
	return self;
}

- (id) init
{  
	EAGLConfiguration	*defaultConfiguration	= [EAGLConfiguration configuration];
	NSAssert(defaultConfiguration, @"cocos2d: CCEAGLViewController unable to create deafult EAGLConfiguraiton");
	id<ESRenderer>		defaultRenderer			= [[[ES2Renderer alloc] initWithDepthFormat:defaultConfiguration.depthFormat sharegroup:nil useMultiSampling:defaultConfiguration.multiSampling numberOfSamples:defaultConfiguration.requestedSamples] autorelease];
	NSAssert(defaultRenderer, @"cocos2d: CCEAGLViewController unable to create deafult ESRenderer");
	
	return [self initWithRenderer:defaultRenderer andConfiguration:defaultConfiguration];
}

#pragma mark -
#pragma mark Overrides of UIViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	totalFrames_ = 0;
	
	[rootNode_ setContentSize:winSizeInPoints_];
	
	if(displayFPS_){
		[self createFPSLabel];
	}
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[FPSLabel_ release];
	FPSLabel_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[touchDispatcher_ setDispatchEvents:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[touchDispatcher_ setDispatchEvents:NO];
}

#pragma mark -
#pragma mark Render Loop

- (void) render:(CADisplayLink *)sender
{
	[self makeCurrentAndBindBuffers];
	//	while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.004f, FALSE) == kCFRunLoopRunHandledSource);
	[self updateRenderState:sender.timestamp];
	[self render];
}

- (void) updateRenderState:(CFTimeInterval)timestamp
{
	dt_				= timestamp - lastTimestamp_;
	lastTimestamp_	= timestamp;
	
	if(isPaused_)
		return;
	
	[scheduler_ tick:(ccTime)dt_];
}

- (void) render
{
	if(isPaused_)
		return;
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// pre render
	[preRenderDelegate_ visit];
	
	// visit / draw
	[rootNode_ visit];
	
	// post render
	[postRenderDelegate_ visit];
	
	if( displayFPS_ )
		[self showFPS];
	
	// swap buffers
	[renderer_ presentRenderbuffer];
	
	totalFrames_++;
}

#pragma mark -
#pragma mark Display List Management

- (void) replaceScene:(CCScene *)aNode
{
	self.rootNode = aNode;
}

- (void) replaceSceneUsingCreationBlock:(CCScene*(^)())sceneCreatorBlock
{
	if(!sceneCreatorBlock)
		return;
	
	[rootNode_ onExit];
	[rootNode_ cleanup];
	[rootNode_ release], rootNode_ = nil;
	
	CCScene *aNode = sceneCreatorBlock();
		
	[self setRootNode:aNode];
}

- (void) setRootNode:(CCScene *)aNode
{
	NSAssert(aNode != nil, @"CCEAGLViewController: rootNode must not be nil");
	if(rootNode_ == aNode)
		return;
	
	[aNode retain];
	
	double delayInSeconds = 0.01;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self setRootNodeNow:aNode];
	});
}

//Important, this method expects aNode will have a positive retain count (call retain before it gets here)
- (void) setRootNodeNow:(CCScene *)aNode
{
	if(aNode == rootNode_ || aNode == nil)
		return;
	
	NSAssert([aNode isKindOfClass:[CCScene class]], @"Only CCScene or a subclass can be the root node!");
	
	if(![aNode isKindOfClass:[CCScene class]]){
		[aNode release];
		return;
	}
	
	[rootNode_ onExit];
	[rootNode_ cleanup];
	[rootNode_ release], rootNode_ = nil;
	
	rootNode_ = aNode;
	
	rootNode_.rootNode = rootNode_;
	rootNode_.openGLViewController = self;
	
	if(![rootNode_ isRunning]){
		[rootNode_ onEnter];
		[rootNode_ onEnterTransitionDidFinish];
	}
}

#pragma mark -
#pragma mark OpenGL

- (void) setupOpenGL
{
	[super setupOpenGL];
	
//	CC_ENABLE_DEFAULT_GL_STATES();
	
	[self setProjection:projection_];
}

-(float) getZEye
{
	return ( winSizeInPixels_.height / 1.1566f );
}

// overriden, don't call super
-(void) setContentScaleFactor:(CGFloat)scaleFactor
{
	if( scaleFactor != contentScaleFactor_ ) {
		
		contentScaleFactor_ = scaleFactor;
		
		if( eaglView_ )
			[self updateWinSize];
		
		// update projection
		[self setProjection:projection_];
	}
}

/**
 Note that this leaves a matrix pushed onto the stack so that there is no need to push/pop on every iteration of the render loop :)
 - Optimization by CJ Hanson @ Hanson Interactive
 */
-(void) setProjection:(ccDirectorProjection)projection
{
	[self makeCurrentAndBindBuffers];
	
	CGSize size = winSizeInPixels_;
	CGSize sizePoint = winSizeInPoints_;
	
	if(projection == kCCDirectorProjection3D && contentScaleFactor_ != 1)
		glViewport(-size.width/2, -size.height/2, size.width * contentScaleFactor_, size.height * contentScaleFactor_ );
	else
		glViewport(0, 0, size.width * contentScaleFactor_, size.height * contentScaleFactor_ );
	
	switch (projection) {
		case kCCDirectorProjection2D:
			kmGLMatrixMode(KM_GL_PROJECTION);
			kmGLLoadIdentity();
			
			kmMat4 orthoMatrix;
			kmMat4OrthographicProjection(&orthoMatrix, 0, size.width, 0, size.height, -1024, 1024 );
			kmGLMultMatrix( &orthoMatrix );
			
			kmGLMatrixMode(KM_GL_MODELVIEW);
			kmGLPopMatrix();
			kmGLLoadIdentity();
			kmGLPushMatrix();
			break;
			
		case kCCDirectorProjection3D:
		{
			kmGLMatrixMode(KM_GL_PROJECTION);
			kmGLLoadIdentity();
			
			float zeye = [self getZEye];
			
			kmMat4 matrixPerspective, matrixLookup;
			
			kmMat4PerspectiveProjection( &matrixPerspective, 60, (GLfloat)sizePoint.width/sizePoint.height, 0.5f, 1500.0f );
			kmGLMultMatrix(&matrixPerspective);
			
			kmGLMatrixMode(KM_GL_MODELVIEW);
			kmGLPopMatrix();
			kmGLLoadIdentity();
			kmVec3 eye, center, up;
			kmVec3Fill( &eye, sizePoint.width/2, sizePoint.height/2, zeye );
			kmVec3Fill( &center, sizePoint.width/2, sizePoint.height/2, 0 );
			kmVec3Fill( &up, 0, 1, 0);
			kmMat4LookAt(&matrixLookup, &eye, &center, &up);
			kmGLMultMatrix(&matrixLookup);
			kmGLPushMatrix();
			break;
		}
			
		case kCCDirectorProjectionCustom:
			if( projectionDelegate_ )
				[projectionDelegate_ updateProjection];
			break;
			
		default:
			CCLOG(@"cocos2d: Director: unrecognized projecgtion");
			break;
	}
	
	projection_ = projection;
	
	ccSetProjectionMatrixDirty();
	
	kmGLGetMatrix(KM_GL_PROJECTION, &projectionMatrix_);
	kmGLGetMatrix(KM_GL_MODELVIEW, &modelViewMatrix_);
}

- (void) setAlphaBlending: (BOOL) on
{
	[self makeCurrentAndBindBuffers];
	
	if(on){
		glEnable(GL_BLEND);
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	}else{
		glDisable(GL_BLEND);
	}
}

-(BOOL) enableRetinaDisplay:(BOOL)enabled
{
	// Already enabled ?
	if( enabled && contentScaleFactor_ == 2 )
		return YES;
	
	// Already disabled
	if( ! enabled && contentScaleFactor_ == 1 )
		return YES;
	
	// setContentScaleFactor is not supported
	if (! [eaglView_ respondsToSelector:@selector(setContentScaleFactor:)])
		return NO;
	
	// SD device
	if ([[UIScreen mainScreen] scale] == 1.0)
		return NO;
	
	float newScale = enabled ? 2 : 1;
	[self setContentScaleFactor:newScale];
	
	// Load Hi-Res FPS label
	[self createFPSLabel];
	
	return YES;
}

#pragma mark -
#pragma mark Resizing / Rotation

- (void) viewDidResize:(NSNotification *)notification
{
	CCLOG(@"cocos2d: CC ViewController got viewDidResize notification. Updating values of winSize and forcing a render");
	[self makeCurrentAndBindBuffers];
	[self updateWinSize];
	[self setupOpenGL];
	[self render];
}

#pragma mark -
#pragma mark Input (UIResponder)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDispatcher_ touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDispatcher_ touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDispatcher_ touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[touchDispatcher_ touchesCancelled:touches withEvent:event];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	
}

#pragma mark -
#pragma mark FPS Label

- (void) setDisplayFPS:(BOOL)yn
{
	if(displayFPS_ == yn)
		return;
	
	displayFPS_ = yn;
	
	if(displayFPS_){
		[self createFPSLabel];
	}
}

// display the FPS using a LabelAtlas
// updates the FPS every frame
-(void) showFPS
{
	frames++;
	accumDt += (ccTime)dt_;
	
	if ( accumDt > CC_DIRECTOR_FPS_INTERVAL)  {
		frameRate = frames/accumDt;
		accumDt = 0;
		frames	= 0;
		NSString *str = [[NSString alloc] initWithFormat:@"%2.1f", frameRate];
		[FPSLabel_ setString:str];
		[str release];
	}
	
	[FPSLabel_ visit];
}

-(void) destroyFPSLabel
{
	if(!FPSLabel_)
		return;
	
	CCTexture2D *texture = [[FPSLabel_ texture] retain];
	
	[FPSLabel_ release], FPSLabel_ = nil;
	[[CCTextureCache sharedTextureCache ] removeTexture:texture];
	[texture release];
}

-(void) createFPSLabel
{
	if(!displayFPS_)
		return;
	[self destroyFPSLabel];
	
	NSString *filePath	= @"fps_images.png";
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:@"fps_images.png" ofType:nil]])
		return;
	
	CCTexture2DPixelFormat currentFormat = [CCTexture2D defaultAlphaPixelFormat];
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	FPSLabel_ = [[CCLabelAtlas alloc]  initWithString:@"00.0" charMapFile:filePath itemWidth:16 itemHeight:24 startCharMap:'.'];
	[CCTexture2D setDefaultAlphaPixelFormat:currentFormat];
	
	[FPSLabel_ setPosition: CC_DIRECTOR_FPS_POSITION];
}

#pragma mark -
#pragma mark LEGACY convenience methods

- (void)runWithScene:(CCScene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
	
	[self replaceScene:scene];
	[self startAnimation];	
}

@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
