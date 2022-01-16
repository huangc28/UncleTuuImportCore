#import "PurchasedRecordViewController.h"

@interface PurchasedRecordViewController : UIViewController {
  PurchasedRecordModel *_data;
  UIStackView *_purchasedRecordView;
}

- (instancetype)initWithData:(PurchasedRecordModel*)purchasedRecord;

@property(strong, nonatomic) PurchasedRecordModel *data; // @synthesize _data=data
@property(strong, nonatomic) UIStackView *purchasedRecordView; // @synthesize _purchasedRecordView=purchasedRecordView

@end
