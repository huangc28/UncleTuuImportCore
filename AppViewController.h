#import "UIKit/UIKit.h"
#import "StoreKit/StoreKit.h"

#import "Routes.h"
#import "VBStoreKitManager.h"

@interface AppViewController : UIViewController {
	UIViewController *_currentRouteViewController;
	Routes *_routes;
	VBStoreKitManager *_vbStoreKitManager;
}

- (void) renderImportApp:(UIApplication *)app;
- (void) renderImportApp;
@property(strong, nonatomic) UIViewController *currentRouteViewController; // @synthesize currentRouteViewController=_currentRouteViewController

@property(strong, nonatomic) Routes *routes; // @synthesize routes=_routes
@property(strong, nonatomic) VBStoreKitManager *vbStoreKitManager; //@synthesize vbStoreKitManager=_vbStoreKitManager

@end
