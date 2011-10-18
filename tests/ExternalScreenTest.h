
#define CC_ROOT_VIEW_CONTROLLER_CLASS DualScreenRootViewController
#import "cocos2d.h"

@class CC_ROOT_VIEW_CONTROLLER_CLASS;

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow	*window_;
	CC_ROOT_VIEW_CONTROLLER_CLASS *viewController_;
	
	BOOL isApplicationActive_;
	BOOL isInBackground_;
	BOOL directorWasPausedWhenResigned_;
}
@end

@interface ExternalScreenTest: CCLayer
{
}
-(NSString*) title;
-(NSString*) subtitle;

@end

