#import "SharedLibraries/ProductViewElementCreator.h"

#import "FailedItemViewController.h"
#import "FailedItem.h"

@interface FailedItemViewController ()<UIGestureRecognizerDelegate>
@end

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

	UITapGestureRecognizer *singleFingerTap = [
		[UITapGestureRecognizer alloc]
			initWithTarget:self
			action        :@selector(_handleTap:)
	];

	[self.view addGestureRecognizer:singleFingerTap];
	singleFingerTap.delegate = self;
}

- (void)_handleTap:(UITapGestureRecognizer *)recognizer {
	__block NSDictionary *dicFailedItem = [
		NSDictionary
			dictionaryWithObject:self.failedItem
			forKey              :@"failedItem"
	];

	// Dispatch filed event to ImportFailedContainerViewController
	dispatch_async(dispatch_get_main_queue(), ^{
		[
			[NSNotificationCenter defaultCenter]
				postNotificationName:@"notifyUploadFailedItem"
				object              :nil
				userInfo            :dicFailedItem
		];
	});
}

- (UIStackView *)_createItemRow {
	UIStackView *row = [ProductViewElementCreator createRow];

	// transaction date
	UILabel *transactionDate = [ProductViewElementCreator createLabel:self.failedItem.transactionDate];
	transactionDate.textColor = [UIColor blackColor];

	// Product ID
	UILabel *prodIDLabel = [ProductViewElementCreator createLabel:self.failedItem.prodID];
	prodIDLabel.textColor = [UIColor blackColor];

	// transaction ID
	UILabel *transactionIDLabel = [
		ProductViewElementCreator
			createLabel:self.failedItem.transactionID
	];
	transactionIDLabel.textColor = [UIColor blackColor];


	[row addArrangedSubview:transactionDate];
	[row addArrangedSubview:transactionIDLabel];
	[row addArrangedSubview:prodIDLabel];

	return row;
}

@end
