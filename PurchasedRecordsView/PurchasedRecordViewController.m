#import "Foundation/Foundation.h"


#import "SharedLibraries/ProductViewElementCreator.h"
#import "PurchasedRecordModel.h"
#import "PurchasedRecordViewController.h"

@implementation PurchasedRecordViewController

- (instancetype)initWithData:(PurchasedRecordModel*)purchasedRecord {
  self = [super init];

  if (self) {
  	self.data = purchasedRecord;
  }

  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];

  @try {
  	self.view = self.createPRRow;
  } @catch (NSException *exception) {
     NSLog(@"DEBUG* exception %@", exception.reason);
  }
}

- (UIStackView *) createPRRow {
  UIStackView *row = [ProductViewElementCreator createRow];

  // Product name.
  UILabel *prodNameLabel = [ProductViewElementCreator createLabel:self.data.prodName];

  // transaction ID.
  UILabel *transactionIDLabel = [
  	ProductViewElementCreator
  		createLabel:[[NSString alloc]initWithFormat: @"%@", self.data.transactionID]
  ];

  // Transaction time.
  UILabel *transactionTimeLabel = [
  	ProductViewElementCreator
  		createLabel:[[NSString alloc]initWithFormat: @"%@", self.data.transactionTime]
  ];

  [row addArrangedSubview:prodNameLabel];
  [row addArrangedSubview:transactionIDLabel];
  [row addArrangedSubview:transactionTimeLabel];

  return row;
}

@end
