#import "cocos2d.h"

@class RootViewController;
@class CCLabel;

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow	*window_;
	RootViewController *viewController_;
}
@end

@interface TextLayer: CCLayerColor
{
}
@end

