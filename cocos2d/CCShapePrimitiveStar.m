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

#import "CCShapePrimitiveStar.h"


@implementation CCShapePrimitiveStar

+ (id) nodeWithNumberOfPoints:(NSUInteger)numPoints innerRadius:(float)innerRadius outerRadius:(float)outerRadius
{
	return [[[self alloc] initWithNumberOfPoints:numPoints innerRadius:innerRadius outerRadius:outerRadius] autorelease];
}

- (id) initWithNumberOfPoints:(NSUInteger)numPoints innerRadius:(float)innerRadius outerRadius:(float)outerRadius
{
	if([super init]){
		innerRadius_		= innerRadius;
		outerRadius_		= outerRadius;
		
		numberOfPoints_		= numPoints;
		
		numVertices_		= numberOfPoints_ * 3 * 2;
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
	return [self initWithNumberOfPoints:7 innerRadius:40.0f outerRadius:140.0f];
}

-(void) updateVertices
{
	if(!vertices_)
		return;
	
	[self setContentSize:CGSizeMake(outerRadius_*2, outerRadius_*2)];
	
	const float texW		= texture_.maxS * texture_.pixelsWide;
	const float texH		= texture_.maxT * texture_.pixelsHigh;
	const CGPoint texOffset	= CGPointMake(-texW/2, 0);
	
	const float theta_inc	= 2.0f * (float)M_PI/numberOfPoints_;
	const float theta_inc_2	= theta_inc / 2;
	float theta				= 0.0f;
	
	CGPoint posBefore		= position_;
	position_				= CGPointZero;
	
	for(uint i=0, offset=0; i<numberOfPoints_; i++,offset=i*6){
		//star
		float a = innerRadius_ * cosf(theta-theta_inc_2) + position_.x;
		float b = innerRadius_ * sinf(theta-theta_inc_2) + position_.y;
		float c = outerRadius_ * cosf(theta) + position_.x;
		float d = outerRadius_ * sinf(theta) + position_.y;
		float e = innerRadius_ * cosf(theta+theta_inc_2) + position_.x;
		float f = innerRadius_ * sinf(theta+theta_inc_2) + position_.y;
		
		vertices_[offset].vertices.x	= a;
		vertices_[offset].vertices.y	= b;
		vertices_[offset].texCoords.u	= (a - texOffset.x)/texW;
		vertices_[offset].texCoords.v	= (contentSize_.height - b - texOffset.y)/texH;
		offset++;
		vertices_[offset].vertices.x	= c;
		vertices_[offset].vertices.y	= d;
		vertices_[offset].texCoords.u	= (c - texOffset.x)/texW;
		vertices_[offset].texCoords.v	= (contentSize_.height - d - texOffset.y)/texH;
		offset++;
		vertices_[offset].vertices.x	= e;
		vertices_[offset].vertices.y	= f;
		vertices_[offset].texCoords.u	= (e - texOffset.x)/texW;
		vertices_[offset].texCoords.v	= (contentSize_.height - f - texOffset.y)/texH;
		offset++;
		//circle
		float g = position_.x;
		float h = position_.y;
		float j = innerRadius_ * cosf(theta-theta_inc_2) + position_.x;
		float k = innerRadius_ * sinf(theta-theta_inc_2) + position_.y;
		float l = innerRadius_ * cosf(theta+theta_inc_2) + position_.x;
		float m = innerRadius_ * sinf(theta+theta_inc_2) + position_.y;
		
		vertices_[offset].vertices.x	= g;
		vertices_[offset].vertices.y	= h;
		vertices_[offset].texCoords.u	= (g - texOffset.x)/texW;
		vertices_[offset].texCoords.v	= (contentSize_.height - h - texOffset.y)/texH;
		offset++;
		vertices_[offset].vertices.x	= j;
		vertices_[offset].vertices.y	= k;
		vertices_[offset].texCoords.u	= (j - texOffset.x)/texW;
		vertices_[offset].texCoords.v	= (contentSize_.height - k - texOffset.y)/texH;
		offset++;
		vertices_[offset].vertices.x	= l;
		vertices_[offset].vertices.y	= m;
		vertices_[offset].texCoords.u	= (l - texOffset.x)/texW;
		vertices_[offset].texCoords.v	= (contentSize_.height - m - texOffset.y)/texH;
		
		theta += theta_inc;
	}
	
	position_ = posBefore;
}

@end
