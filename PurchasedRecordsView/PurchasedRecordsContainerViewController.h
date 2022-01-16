#import "Foundation/Foundation.h"
#import "UIKit/UIKit.h"

#import "TopBarViewController.h"
#import "PurchasedRecordsListViewController.h"

@interface PurchasedRecordsContainerViewController : UIViewController {
  TopBarViewController *_topBarViewController;

  PurchasedRecordsListViewController *_purchaseRecordsListViewController;
}

@property(strong, nonatomic) TopBarViewController *topBarViewController; // @synthesize topBarViewController=_topBarViewController

@property(strong, nonatomic) PurchasedRecordsListViewController *purchaseRecordsListViewController; // @synthesize purchaseRecordsListViewController=_purchaseRecordsListViewController

@end
