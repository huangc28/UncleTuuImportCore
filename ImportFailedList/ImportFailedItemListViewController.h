#import "UIKit/UIKit.h"
#import "FailedItem.h"

@interface ImportFailedItemListViewController : UIViewController

- (void)render;

@property(strong, nonatomic) NSArray<FailedItem *> *failedItems;
@property(retain, nonatomic) UIView *contentView;
@property(retain, nonatomic) UIScrollView *scrollView;
@property(retain, nonatomic) UIStackView *itemsStackView;

@end
