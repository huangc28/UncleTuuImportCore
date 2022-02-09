#import "UIKit/UIKit.h"
#import "FailedItem.h"

@interface FailedItemViewController : UIViewController

- (instancetype)initWithFailedItem:(FailedItem *)failedItem;

@property(strong, nonatomic) FailedItem *failedItem;

@end
