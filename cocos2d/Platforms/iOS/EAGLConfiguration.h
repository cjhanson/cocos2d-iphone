/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * This Class was created by CJ Hanson on 4/5/10.
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>

@interface EAGLConfiguration : NSObject {
	NSString		*colorFormat_;
	GLuint			depthFormat_;
	BOOL			retainedBacking_;
	NSUInteger		animationFrameInterval_;
	BOOL			opaque_;
	//fsaa addition
	BOOL			multisampling_;
	unsigned int	requestedSamples_;
}

/** color format: it could be RGBA8 (32-bit) or RGB565 (16-bit) */
@property(nonatomic, retain) NSString *colorFormat;
/** depth format of the render buffer: 0, 16 or 24 bits*/
@property(nonatomic, assign) GLuint depthFormat;
/** retain the back buffer */
@property (nonatomic, assign) BOOL retainedBacking;
/** animation interval to use with Display link */
@property (nonatomic, assign) NSUInteger animationFrameInterval;
/** opaque property to assign to view */
@property (nonatomic, assign) BOOL opaque;

/** Use multisampling Full scene anti-aliasing (FSAA) */
@property(nonatomic, assign) BOOL multiSampling;
@property(nonatomic, assign) unsigned int requestedSamples;

- (id) initWithColorFormat:(NSString * const)colorFormat depthFormat:(GLuint)depthFormat retainedBacking:(BOOL)retainedBacking animationFrameInterval:(NSUInteger)animationFrameInterval useMultiSampling:(BOOL)useMultiSampling requestedSamples:(unsigned int)requestedSamples;

+ (id) configuration;

@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
