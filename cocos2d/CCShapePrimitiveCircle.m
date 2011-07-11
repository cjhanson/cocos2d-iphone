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

#import "CCShapePrimitiveCircle.h"

@implementation CCShapePrimitiveCircle

+ (id) nodeWithRadius:(float)radius numberOfSegments:(NSUInteger)segments
{
	return [[[self alloc] initWithRadius:radius numberOfSegments:segments] autorelease];
}

- (id) initWithRadius:(float)radius numberOfSegments:(NSUInteger)segments
{
	self = [super init];
	if(self != nil){
		radius_				= radius;
		numberOfSegments_	= segments;
		
		numVertices_		= numberOfSegments_ * 3;
		
		vertices_			= (ccV3F_C4B_T2F *)calloc(numVertices_, sizeof(ccV3F_C4B_T2F));

		if(!vertices_){
			[self release];
			return nil;
		}		
		
		color_				= ccWHITE;
		opacity_			= 255;
		[self updateColor];
		
		[self updateVertices];
	}
	return self;
}

- (id) init
{
	return [self initWithRadius:50.0f numberOfSegments:36];
}

-(void) updateVertices
{
	if(!vertices_)
		return;
	
	const float diam		= radius_ * 2.0f;
	
	[self setContentSize:CGSizeMake(diam, diam)];
	
	const float texW		= texture_.maxS * texture_.pixelsWide;
	const float texH		= texture_.maxT * texture_.pixelsHigh;
	const CGPoint texOffset	= CGPointMake(-texW/2, 0);
	
	const float theta_inc	= 2.0f * (float)M_PI/numberOfSegments_;
	const float theta_inc_2	= theta_inc / 2.0f;
	float theta				= 0.0f;
	
	CGPoint posBefore		= position_;
	position_				= CGPointZero;
	
	for(uint i=0, offset=0; i<numberOfSegments_; i++,offset=i*3){
		float g = position_.x;
		float h = position_.y;
		float j = radius_ * cosf(theta-theta_inc_2) + position_.x;
		float k = radius_ * sinf(theta-theta_inc_2) + position_.y;
		float l = radius_ * cosf(theta+theta_inc_2) + position_.x;
		float m = radius_ * sinf(theta+theta_inc_2) + position_.y;
		
		//center of circle
		vertices_[offset].vertices.x	= g;
		vertices_[offset].vertices.y	= h;
		vertices_[offset].texCoords.u	= (g - texOffset.x)/texW;
		vertices_[offset].texCoords.v	= (contentSize_.height - h - texOffset.y)/texH;
		if(flipX_)
			vertices_[offset].texCoords.u = contentSize_.width - vertices_[offset].texCoords.u;
		offset++;
		//outer point A
		vertices_[offset].vertices.x	= j;
		vertices_[offset].vertices.y	= k;
		vertices_[offset].texCoords.u	= (j - texOffset.x)/texW;
		vertices_[offset].texCoords.v	= (contentSize_.height - k - texOffset.y)/texH;
		if(flipX_)
			vertices_[offset].texCoords.u = contentSize_.width - vertices_[offset].texCoords.u;
		offset++;
		//outer point B
		vertices_[offset].vertices.x	= l;
		vertices_[offset].vertices.y	= m;
		vertices_[offset].texCoords.u	= (l - texOffset.x)/texW;
		vertices_[offset].texCoords.v	= (contentSize_.height - m - texOffset.y)/texH;
		if(flipX_)
			vertices_[offset].texCoords.u = contentSize_.width - vertices_[offset].texCoords.u;
		
		theta += theta_inc;
	}
	
	position_ = posBefore;
}

@end
