#import "Foundation/Foundation.h"
#import "UIKit/UIKit.h"

#import "AppTopViewController.h"
#import "ProductListViewController.h"
#import "AppBottomViewController.h"
#import "../VBStoreKitManager.h"

@interface ProductListViewContainerViewController : UIViewController {
	AppTopViewController *_appTopViewController;

	ProductListViewController *_productListViewController;

	AppBottomViewController *_appBottomViewController;

	VBStoreKitManager *_vbStoreKitManager;
}

@property(strong, nonatomic) AppTopViewController *appTopViewController; // @synthesize appTopViewController=_appTopViewController
@property(strong, nonatomic) ProductListViewController *productListViewController; // @synthesize productListViewController=_productListViewController
@property(strong, nonatomic) AppBottomViewController *appBottomViewController; // @synthesize appBottomViewController=_appBottomViewController
@property(strong, nonatomic) VBStoreKitManager *vbStoreKitManager; // @synthesize vbStoreKitManager=_vbStoreKitManager

@end
