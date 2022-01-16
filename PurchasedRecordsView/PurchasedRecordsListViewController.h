#import "Foundation/Foundation.h"

#import "PurchasedRecordModel.h"

@interface PurchasedRecordsListViewController: UIViewController {
  NSArray<PurchasedRecordModel *> *_purchasedRecords;

  UIScrollView *_scrollView;
  UIStackView *_purchasedRecordStackView;
  UIView *_contentView;
}

- (void)render;

@property(retain, nonatomic, readwrite) NSArray<PurchasedRecordModel *> *purchaseRecords; //@synthesize purchasedRecords=_purchasedRecords
@property(retain, nonatomic) UIScrollView *scrollView; //@synthesize scrollView=_scrollView
@property(retain, nonatomic) UIStackView *purchasedRecordStackView; //@synthesize purchasedRecordStackView=_purchasedRecordStackView

@property(retain, nonatomic) UIView *contentView; //@synthesize contentView=_contentView

@end
