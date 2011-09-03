/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 CJ Hanson
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

#import "CCNode.h"
#import "CCProtocols.h"
#import "CCTextureAtlas.h"
#import "ccMacros.h"
#import "ccTypes.h"

@class CCShapeBatchNode;
@class CCSpriteFrame;
@class CCAnimation;

#pragma mark CCShapePrimitive

#define CCShapeBatchIndexNotInitialized 0xffffffff 	// invalid index on the CCShapeBatchnode

/**
 Whether or not a node will rotate, scale or translate with it's parent.
 Useful in health bars, when you want that the health bar translates with it's parent but you don't
 want it to rotate with its parent.
 @since v0.99.0
 */
typedef enum {
	//! Translate with it's parent
	CC_HONOR_PARENT_TRANSFORM_TRANSLATE =  1 << 0,
	//! Rotate with it's parent
	CC_HONOR_PARENT_TRANSFORM_ROTATE	=  1 << 1,
	//! Scale with it's parent
	CC_HONOR_PARENT_TRANSFORM_SCALE		=  1 << 2,
	//! Skew with it's parent
	CC_HONOR_PARENT_TRANSFORM_SKEW		=  1 << 3,
	
	//! All possible transformation enabled. Default value.
	CC_HONOR_PARENT_TRANSFORM_ALL		=  CC_HONOR_PARENT_TRANSFORM_TRANSLATE | CC_HONOR_PARENT_TRANSFORM_ROTATE | CC_HONOR_PARENT_TRANSFORM_SCALE | CC_HONOR_PARENT_TRANSFORM_SKEW,
	
} ccHonorParentTransform;

/** CCShapePrim is a 2d image ( http://en.wikipedia.org/wiki/Sprite_(computer_graphics) )
 *
 * CCSprite can be created with an image, or with a sub-rectangle of an image.
 *
 * If the parent or any of its ancestors is a CCSpriteBatchNode then the following features/limitations are valid
 *	- Features when the parent is a CCBatchNode:
 *		- MUCH faster rendering, specially if the CCSpriteBatchNode has many children. All the children will be drawn in a single batch.
 *
 *	- Limitations
 *		- Camera is not supported yet (eg: CCOrbitCamera action doesn't work)
 *		- GridBase actions are not supported (eg: CCLens, CCRipple, CCTwirl)
 *		- The Alias/Antialias property belongs to CCSpriteBatchNode, so you can't individually set the aliased property.
 *		- The Blending function property belongs to CCSpriteBatchNode, so you can't individually set the blending function property.
 *		- Parallax scroller is not supported, but can be simulated with a "proxy" sprite.
 *
 *  If the parent is an standard CCNode, then CCSprite behaves like any other CCNode:
 *    - It supports blending functions
 *    - It supports aliasing / antialiasing
 *    - But the rendering will be slower: 1 draw per children.
 *
 * The default anchorPoint in CCSprite is (0.5, 0.5).
 */

@interface CCShapePrimitive : CCNode <CCRGBAProtocol, CCBlendProtocol, CCTextureProtocol>
{
	
	//
	// Data used when the sprite is rendered using a CCSpriteBatchNode
	//
	CCTextureAtlas			*textureAtlas_;			// Sprite Sheet texture atlas (weak reference)
	NSUInteger				atlasIndex_;			// Absolute (real) Index on the batch node
	CCShapeBatchNode		*batchNode_;			// Used batch node (weak reference)
	ccHonorParentTransform	honorParentTransform_;	// whether or not to transform according to its parent transformations
	BOOL					dirty_:1;				// Sprite needs to be updated
	BOOL					recursiveDirty_:1;		// Subchildren needs to be updated
	BOOL					hasChildren_:1;			// optimization to check if it contain children
	
	//
	// Data used when the sprite is self-rendered
	//
	ccV3F_C4B_T2F			*vertices_;
	uint					numVertices_;
	
	//
	// Shared data
	//
	GLubyte					opacity_;
	ccColor3UB				color_;
	
	ccBlendFunc				blendFunc_;
	
	CCTexture2D				*texture_;
	BOOL					opacityModifyRGB_;
	
	// texture
	CGRect					rect_;
	CGRect					rectInPixels_;
	BOOL					rectRotated_:1;
	
	// whether or not it's parent is a CCSpriteBatchNode
	BOOL					usesBatchNode_:1;
	
	// Offset Position (used by Zwoptex)
	CGPoint					offsetPosition_;
	CGPoint					unflippedOffsetPositionFromCenter_;
	
	// image is flipped
	BOOL					flipX_:1;
	BOOL					flipY_:1;
}

/** whether or not the Sprite needs to be updated in the Atlas */
@property (nonatomic,readwrite) BOOL dirty;
/** The index used on the TextureAtlas. Don't modify this value unless you know what you are doing */
@property (nonatomic,readwrite) NSUInteger atlasIndex;
/** returns the rect of the CCSprite in points */
@property (nonatomic,readonly) CGRect textureRect;
/** returns whether or not the texture rectangle is rotated */
@property (nonatomic,readonly) BOOL textureRectRotated;

-(void) updateColor;
-(void) updateVertices;

/** updates the texture rect of the CCSprite in points.
 */
-(void) setTextureRect:(CGRect) rect;

@property (nonatomic, assign) ccV3F_C4B_T2F *vertices;

@property (nonatomic, readonly) uint numVertices;

/** Opacity: conforms to CCRGBAProtocol protocol */
@property (nonatomic,readonly) GLubyte opacity;
/** Opacity: conforms to CCRGBAProtocol protocol */
@property (nonatomic,readonly) ccColor3UB color;
/** BlendFunction. Conforms to CCBlendProtocol protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;
/** whether or not the Sprite is rendered using a CCSpriteBatchNode */
@property (nonatomic,readwrite) BOOL usesBatchNode;
/** weak reference of the CCTextureAtlas used when the sprite is rendered using a CCSpriteBatchNode */
@property (nonatomic,readwrite,assign) CCTextureAtlas *textureAtlas;
/** weak reference to the CCSpriteBatchNode that renders the CCSprite */
@property (nonatomic,readwrite,assign) CCSpriteBatchNode *batchNode;
/** whether or not to transform according to its parent transfomrations.
 Useful for health bars. eg: Don't rotate the health bar, even if the parent rotates.
 IMPORTANT: Only valid if it is rendered using an CCSpriteBatchNode.
 @since v0.99.0
 */
@property (nonatomic,readwrite) ccHonorParentTransform honorParentTransform;
/** offset position in pixels of the sprite in points. Calculated automatically by editors like Zwoptex.
 @since v0.99.0
 */
@property (nonatomic,readonly) CGPoint	offsetPosition;

/** whether or not the sprite is flipped horizontally. 
 It only flips the texture of the sprite, and not the texture of the sprite's children.
 Also, flipping the texture doesn't alter the anchorPoint.
 If you want to flip the anchorPoint too, and/or to flip the children too use:
 
 sprite.scaleX *= -1;
 */
@property (nonatomic,readwrite) BOOL flipX;
/** whether or not the sprite is flipped vertically.
 It only flips the texture of the sprite, and not the texture of the sprite's children.
 Also, flipping the texture doesn't alter the anchorPoint.
 If you want to flip the anchorPoint too, and/or to flip the children too use:
 
 sprite.scaleY *= -1;
 */
@property (nonatomic,readwrite) BOOL flipY;

/** tell the sprite to use self-render.
 */
-(void) useSelfRender;

/** tell the sprite to use sprite batch node
 */
-(void) useBatchNode:(CCSpriteBatchNode*)batchNode;

#pragma mark CCSprite - Frames

/** sets a new display frame to the CCSprite. */
-(void) setDisplayFrame:(CCSpriteFrame*)newFrame;

/** returns whether or not a CCSpriteFrame is being displayed */
-(BOOL) isFrameDisplayed:(CCSpriteFrame*)frame;

/** returns the current displayed frame. */
-(CCSpriteFrame*) displayedFrame;

#pragma mark CCSprite - Animation

/** changes the display frame with animation name and index.
 The animation name will be get from the CCAnimationCache
 @since v0.99.5
 */
-(void) setDisplayFrameWithAnimationName:(NSString*)animationName index:(int) frameIndex;

@end
