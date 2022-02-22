#import "SharedLibraries/ProductViewElementCreator.h"
#import "ImportFailedItemListViewController.h"
#import "FailedItemViewController.h"

static UIStackView *headerRow = nil;

@implementation ImportFailedItemListViewController
- (void)viewDidLoad {
    [super viewDidLoad];

		self.view = [
  	  [UIView alloc] initWithFrame: CGRectMake(
		  0,
		  80, // reserve for the height of the topbar.
		  [[UIScreen mainScreen] bounds].size.width,
		  [[UIScreen mainScreen] bounds].size.height
  	  )
  	];

		[self _setupContentView];
		[self _setupScrollView];
		[self _setupImportFailedItemsStackView];

		[self.view addSubview:self.scrollView];
		[self.scrollView addSubview:self.contentView];
		[self.contentView addSubview:self.itemsStackView];

		[self _setupLayout];
}

- (void)_setupContentView {
  self.contentView = [[UIView alloc] init];
  self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)_setupScrollView {
  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  self.scrollView.contentSize = CGSizeMake(
		[[UIScreen mainScreen] bounds].size.width,
		[[UIScreen mainScreen] bounds].size.height
  );
}

- (void)_setupImportFailedItemsStackView {
	self.itemsStackView = [[UIStackView alloc] init];
  self.itemsStackView.axis = UILayoutConstraintAxisVertical;
  self.itemsStackView.distribution = UIStackViewDistributionEqualSpacing;
  self.itemsStackView.spacing = 30;
  self.itemsStackView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)_setupLayout {
		[self.scrollView.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:20.0].active = YES;
  	[self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor].active = YES;
	[self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor constant:-100.0].active = YES;
  	[self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor].active = YES;

		// Content view layout.
		[self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor].active = YES;
		[self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor].active = YES;
		[self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor].active = YES;
		[self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor].active = YES;
		[self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor].active = YES;

		// Products stack view layout.
		[self.itemsStackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
		[self.itemsStackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
		[self.itemsStackView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
		[self.itemsStackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
}

+ (UIStackView *)getHeaderRow {
	if (!headerRow) {
		UIStackView *row = [ProductViewElementCreator createRow];

		UILabel *dateLabel = [ProductViewElementCreator createLabel:@"日期"];
		dateLabel.textColor = [UIColor blackColor];

		UILabel *transactionIDLabel = [ProductViewElementCreator createLabel:@"憑證單號"];
		transactionIDLabel.textColor = [UIColor blackColor];

		UILabel *prodIDLabel = [ProductViewElementCreator createLabel:@"商品ID"];
		prodIDLabel.textColor = [UIColor blackColor];

		[row addArrangedSubview:dateLabel];
		[row addArrangedSubview:transactionIDLabel];
		[row addArrangedSubview:prodIDLabel];

		headerRow = row;
	}

	return headerRow;
}

- (void)render {
	// Remove old list before rendering anything.
	@try {
		dispatch_async(dispatch_get_main_queue(), ^{
			[
				self.itemsStackView.subviews
					makeObjectsPerformSelector: @selector(removeFromSuperview)
			];

			// Render header view.
			UIStackView *headerRow = [ImportFailedItemListViewController getHeaderRow];
			[self.itemsStackView addArrangedSubview:headerRow];

			for (FailedItem *failedItem in self.failedItems) {
				FailedItemViewController *fivc = [
					[FailedItemViewController alloc]
						initWithFailedItem:failedItem
				];

				[self.itemsStackView addArrangedSubview:fivc.view];
				[self addChildViewController:fivc];
			}
		});
	} @catch (NSException *exception) {
		NSLog(@"DEBUG* exception %@", exception);
	}
}

@end
