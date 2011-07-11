/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 CJ Hanson
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

#import "CCShapePrimitive.h"
#import <Availability.h>

#import "ccConfig.h"
#import "CCSpriteBatchNode.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"
#import "CCSpriteFrameCache.h"
#import "CCAnimation.h"
#import "CCAnimationCache.h"
#import "CCTextureCache.h"
#import "CCDrawingPrimitives.h"
#import "CCShaderCache.h"
#import "ccGLState.h"
#import "GLProgram.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
#import "Support/TransformUtils.h"

// external
#import "kazmath/GL/matrix.h"

@implementation CCShapePrimitive

@synthesize vertices=vertices_, numVertices=numVertices_, opacity=opacity_, color=color_, blendFunc=blendFunc_;

- (void) dealloc
{
	[texture_ release];
	if(vertices_)
		free(vertices_);
	[super dealloc];
}

- (id) init
{
	self = [super init];
	if(self != nil){
		// shader program
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
		
		[self setTexture:[[CCTextureCache sharedTextureCache] addImage:@"white_square_16.png"]];
		
		vertices_		= NULL;
		numVertices_	= 0;
		opacityModifyRGB_ = YES;
		color_			= ccWHITE;
		opacity_		= 255;
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		
		flipY_ = flipX_ = NO;
		
		[self updateVertices];
		[self updateColor];
	}
	return self;
}

-(void) updateVertices
{
	
}

-(void) draw
{	
	if(!vertices_){
		return;
	}
	
	// Default Attribs & States: GL_TEXTURE0, k,CCAttribVertex, kCCAttribColor, kCCAttribTexCoords
	// Needed states: GL_TEXTURE0, k,CCAttribVertex, kCCAttribColor, kCCAttribTexCoords
	// Unneeded states: -
	
	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );
	
	ccGLUseProgram( shaderProgram_->program_ );
	ccGLUniformProjectionMatrix( shaderProgram_ );
	ccGLUniformModelViewMatrix( shaderProgram_ );
	
	glBindTexture( GL_TEXTURE_2D, [texture_ name] );
	
	int offset		= (int)vertices_;
	int vertexSize	= sizeof(vertices_[0]);
	
	// vertex
	int diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCAttribPosition, 3, GL_FLOAT, GL_FALSE, vertexSize, (void*) (offset + diff) );
	
	// tex coords
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCAttribTexCoords, 2, GL_FLOAT, GL_FALSE, vertexSize, (void*)(offset + diff));
	
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, vertexSize, (void*)(offset + diff));
	
	glDrawArrays(GL_TRIANGLES, 0, numVertices_);
	
#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CGSize s = self.contentSize;
	CGPoint vertices[4] = {
		ccp(0,0), ccp(s.width,0),
		ccp(s.width,s.height), ccp(0,s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CGSize s = self.textureRect.size;
	CGPoint offsetPix = self.offsetPosition;
	CGPoint vertices[4] = {
		ccp(offsetPix.x,offsetPix.y), ccp(offsetPix.x+s.width,offsetPix.y),
		ccp(offsetPix.x+s.width,offsetPix.y+s.height), ccp(offsetPix.x,offsetPix.y+s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW
}

#pragma mark Protocols
// Color Protocol

- (void) updateColor
{
	if(vertices_){
		for(uint i=0; i<numVertices_; i++){
			if(opacityModifyRGB_){
				float opacityF		= opacity_/255.0f;
				vertices_[i].colors	= ccc4(color_.r * opacityF, color_.g * opacityF, color_.b * opacityF, opacity_);
			}else{
				vertices_[i].colors	= ccc4(color_.r, color_.g, color_.b, opacity_);
			}
		}
	}
}

-(void) setColor:(ccColor3UB)color
{
	color_ = color;
	[self updateColor];
}

-(void) setOpacity: (GLubyte) o
{
	opacity_ = o;
	[self updateColor];
}

-(void) updateBlendFunc
{
	// it's possible to have an untextured sprite
	if( !texture_ || ! [texture_ hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
		[self setOpacityModifyRGB:NO];
	} else {
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		[self setOpacityModifyRGB:YES];
	}
}

-(void) setTexture:(CCTexture2D*)texture
{
	// accept texture==nil as argument
	NSAssert( !texture || [texture isKindOfClass:[CCTexture2D class]], @"setTexture expects a CCTexture2D. Invalid argument");
	
	[texture_ release];
	texture_ = [texture retain];
	
	[self updateBlendFunc];
	[self updateVertices];
}

-(CCTexture2D*) texture
{
	return texture_;
}

-(void) setOpacityModifyRGB:(BOOL)modify
{
	opacityModifyRGB_	= modify;
	
	[self updateColor];
	
	for(id<CCRGBAProtocol>aChild in children_){
		[aChild setOpacityModifyRGB:opacityModifyRGB_];
	}
}

-(BOOL) doesOpacityModifyRGB
{
	return opacityModifyRGB_;
}

-(void)setFlipX:(BOOL)b
{
	if( flipX_ != b ) {
		flipX_ = b;
        [self updateVertices];
	}
}
-(BOOL) flipX
{
	return flipX_;
}

-(void) setFlipY:(BOOL)b
{
	if( flipY_ != b ) {
		flipY_ = b;
		[self updateVertices];
	}	
}
-(BOOL) flipY
{
	return flipY_;
}

@end
