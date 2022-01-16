#import "PurchasedRecordModel.h"
#import "PurchasedRecordsListViewController.h"
#import "PurchasedRecordViewController.h"

@interface PurchasedRecordsListViewController()
@end

@implementation PurchasedRecordsListViewController

- (void) viewDidLoad {
  [super viewDidLoad];

  self.view = [
    [UIView alloc] initWithFrame: CGRectMake(
	  0,
	  80, // reserve for the height of the topbar.
	  [[UIScreen mainScreen] applicationFrame].size.width,
	  [[UIScreen mainScreen] applicationFrame].size.height
    )
  ];

  self.contentView = [[UIView alloc] init];
  self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

  [self setupScrollView];
  [self setupPurchasedRecordsStackView];

  [self.view addSubview:self.scrollView];
  [self.scrollView addSubview:self.contentView];
  [self.contentView addSubview:self.purchasedRecordStackView];

  [self setupLayout];
}

- (void) setupScrollView {
  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  self.scrollView.contentSize = CGSizeMake(
		[[UIScreen mainScreen] applicationFrame].size.width,
		[[UIScreen mainScreen] applicationFrame].size.height
  );
}

- (void) setupPurchasedRecordsStackView {
  self.purchasedRecordStackView = [[UIStackView alloc] init];
  self.purchasedRecordStackView.axis = UILayoutConstraintAxisVertical;
  self.purchasedRecordStackView.distribution = UIStackViewDistributionEqualSpacing;
  self.purchasedRecordStackView.spacing = 30;
  self.purchasedRecordStackView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupLayout {
	@try {
		[self.scrollView.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:20.0].active = YES;
  	[self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor].active = YES;
		[self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor].active = YES;
  	[self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor].active = YES;


		// Content view layout.
		[self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor].active = YES;
		[self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor].active = YES;
		[self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor].active = YES;
		[self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant: -40].active = YES;
		[self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor].active = YES;


		// Products stack view layout.
		[self.purchasedRecordStackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
		[self.purchasedRecordStackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
		[self.purchasedRecordStackView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
		[self.purchasedRecordStackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
	} @catch (NSException *exception) {
	   NSLog(@"DEBUG* exception %@", exception.reason);
	}
}

- (void) render {
  [
  	self.purchasedRecordStackView.subviews
  		makeObjectsPerformSelector: @selector(removeFromSuperview)
  ];

  for (PurchasedRecordModel* purchaseRecord in self.purchaseRecords) {
	PurchasedRecordViewController *prViewCtrl = [
		[PurchasedRecordViewController alloc]initWithData:purchaseRecord];

	[self.purchasedRecordStackView addArrangedSubview:prViewCtrl.view];
	[self addChildViewController:prViewCtrl];
  }
}

@end
