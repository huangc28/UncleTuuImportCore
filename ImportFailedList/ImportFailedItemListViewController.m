#import "ImportFailedItemListViewController.h"
#import "FailedItemViewController.h"

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
		[self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor].active = YES;
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

- (void)render {
	NSLog(@"DEBUG* trigger render !!!");
	// Remove old list before rendering anything.
	[
		self.itemsStackView.subviews
			makeObjectsPerformSelector: @selector(removeFromSuperview)
	];

	NSLog(@"DEBUG* render faileditems %lu", (unsigned long)[self.failedItems count]);

	for (FailedItem *failedItem in self.failedItems) {
		FailedItemViewController *fivc = [
			[FailedItemViewController alloc]
				initWithFailedItem:failedItem
		];

		[self.itemsStackView addArrangedSubview:fivc.view];
		[self addChildViewController:fivc];
	}
}

@end
