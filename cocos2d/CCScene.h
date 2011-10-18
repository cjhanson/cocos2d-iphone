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
 *
 */


#import "CCNode.h"
#import "Platforms/CCGL.h"

/** CCScene is a subclass of CCNode that is for use as the rootNode of the display hierarchy.
 
 CCScene an CCNode are almost identical with the difference that CCScene has its
 anchor point (by default) at the center of the screen.
 
 - Only a CCScene can be the rootNode sent to a view controller for rendering.
*/
@interface CCScene : CCNode
{
	CC_GLVIEWCONTROLLER	*openGLViewController_;
	BOOL isTransition_;
}

+ (id) sceneWithViewController:(CC_GLVIEWCONTROLLER *)openGLViewController;
- (id) initWithViewController:(CC_GLVIEWCONTROLLER *)openGLViewController;

/** The OpenGLView, where everything is rendered */
@property (nonatomic,readwrite,assign) CC_GLVIEWCONTROLLER *openGLViewController;

/** some scenes are actually a transition */
@property (nonatomic, assign) BOOL isTransition;

@end
