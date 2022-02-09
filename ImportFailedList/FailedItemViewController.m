#import "SharedLibraries/ProductViewElementCreator.h"

#import "FailedItemViewController.h"
#import "FailedItem.h"

@implementation FailedItemViewController
- (instancetype)initWithFailedItem:(FailedItem *)failedItem {
	self = [super init];

	if (self) {
		self.failedItem = failedItem;
	}

	return self;
}

- (void) viewDidLoad{
	[super viewDidLoad];

	self.view = [self _createItemRow];
}

- (UIStackView *)_createItemRow {
	UIStackView *row = [ProductViewElementCreator createRow];

	NSLog(@"DEBUG* prodID %@", self.failedItem.prodID);
	NSLog(@"DEBUG* prodID %@", self.failedItem.transactionID);
	// Product ID
	UILabel *prodIDLabel = [ProductViewElementCreator createLabel:self.failedItem.prodID];
	prodIDLabel.textColor = [UIColor blackColor];

	// transaction ID
	UILabel *transactionIDLabel = [
		ProductViewElementCreator
			createLabel:[[NSString alloc]initWithFormat: @"%@", self.failedItem.transactionID]
	];
	transactionIDLabel.textColor = [UIColor blackColor];

	// transaction date
	UILabel *transactionDate = [ProductViewElementCreator createLabel:self.failedItem.transactionDate];
	transactionDate.textColor = [UIColor blackColor];

	[row addArrangedSubview:prodIDLabel];
	[row addArrangedSubview:transactionIDLabel];
	[row addArrangedSubview:transactionDate];

	return row;
}

@end
