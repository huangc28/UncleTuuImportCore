#import "AppBottomViewController.h"

#import "../Util.h"
#import "../Routes.h"

@implementation AppBottomViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	// Create bottom view
	UIView *bottomBarView = [
		[UIView alloc] initWithFrame:CGRectMake(
			0,
			[UIScreen mainScreen].bounds.size.height - 70.0,
			[UIScreen mainScreen].bounds.size.width,
			70
		)
	];
	bottomBarView.userInteractionEnabled = YES;
	bottomBarView.backgroundColor = UIColorFromRGB(0x4A76F0);
	self.view = bottomBarView;

	// Close button
	UIButton *closeButton = [self createButton:@"關閉"];
	[
		closeButton
			addTarget: self
				 action: @selector(handleClose:)
				forControlEvents:UIControlEventTouchUpInside
	];

	// Purchase record button
	UIButton *purchaseRecordButton = [self createButton:@"購買紀錄列表"];
	[
		purchaseRecordButton
			addTarget: self
				 action: @selector(handleRedirectToPurchaseRecord:)
				forControlEvents:UIControlEventTouchUpInside
	];

	// Upload failed list button
	UIButton *uploadFailedListButton = [self createButton:@"上傳失敗列表"];
	[
		uploadFailedListButton
			addTarget: self
				 action: @selector(handleUploadFailedList:)
				forControlEvents:UIControlEventTouchUpInside
	];


	// Refresh button
	UIButton *refreshButton = [self createButton:@"更新"];
	[
		refreshButton
			addTarget: self
				 action: @selector(handleRefresh:)
				forControlEvents:UIControlEventTouchUpInside
	];


	UIStackView *bottomBarContent = [self createBottomBar];
	[self.view addSubview:bottomBarContent];
	[self configureBottomBarContent:bottomBarContent];

	// TODO configure button events.

	[bottomBarContent addArrangedSubview:closeButton];
	[bottomBarContent addArrangedSubview:purchaseRecordButton];
	[bottomBarContent addArrangedSubview:uploadFailedListButton];
	[bottomBarContent addArrangedSubview:refreshButton];
}

- (void)configureBottomBarContent:(UIStackView *)bottomBarContent {
	@try {
		[bottomBarContent.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
		[bottomBarContent.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
		[bottomBarContent.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
		[bottomBarContent.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
	} @catch (NSException *exception) {
		NSLog(@"DEBUG* configureBottomBarContent %@", exception);
	}
}

- (UIStackView *)createBottomBar {
	UIStackView *bottomBarContent = [[UIStackView alloc] init];
	bottomBarContent.axis = UILayoutConstraintAxisHorizontal;
	bottomBarContent.distribution = UIStackViewDistributionFillEqually;
	bottomBarContent.translatesAutoresizingMaskIntoConstraints = NO;

	return bottomBarContent;
}

// TODO there should be border in between each button.
- (UIButton *)createButton:(NSString*)title {
	UIButton *but = [UIButton buttonWithType:UIButtonTypeRoundedRect];


	but.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
	[but setTitle:title forState: UIControlStateNormal];
	[
		but
			setTitleColor:[
				UIColor
					colorWithRed:36/255.0
					green       :71/255.0
					blue        :113/255.0
					alpha       :1.0
			] forState:UIControlStateNormal
	];
	[but setExclusiveTouch: YES];

	return but;
}

- (void)handleClose:(UIButton *)sender {
	dispatch_async(dispatch_get_main_queue(), ^{
		[
			[NSNotificationCenter defaultCenter]
				postNotificationName:@"notifyCloseImporter"
											object:nil
										userInfo:nil
		];
	});
}

- (void)handleRedirectToPurchaseRecord:(UIButton *)sender {
	// We should toggle view from product list to purchased record view.
	dispatch_async(dispatch_get_main_queue(), ^{
		NSDictionary *routeName = [
			NSDictionary dictionaryWithObject:Routes.purchasedRecordsView
			forKey:@"routeName"
		];

		[
			[NSNotificationCenter defaultCenter]
				postNotificationName:@"notifyRouteChange"
											object:nil
										userInfo:routeName
		];
	});
}

- (void)handleUploadFailedList:(UIButton *)sender {
	NSLog(@"DEBUG* handleUploadFailedList");
}

- (void)handleRefresh:(UIButton *)sender {
	dispatch_async(dispatch_get_main_queue(), ^{
		[
			[NSNotificationCenter defaultCenter]
				postNotificationName:@"notifyRefreshProducts"
											object:nil
										userInfo:nil
		];
	});
}

@end
