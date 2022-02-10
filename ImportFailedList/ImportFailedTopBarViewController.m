#import "ImportFailedTopBarViewController.h"
#import "../Routes.h"
#import "../ColorHashGenerator.h"

@implementation ImportFailedTopBarViewController
- (void)viewDidLoad {
	[super viewDidLoad];

	UIView *topBar = [
		[UIView alloc] initWithFrame:CGRectMake(
			0,
			0,
			[[UIScreen mainScreen] bounds].size.width,
			80
		)
	];

	topBar.userInteractionEnabled = YES;
	topBar.backgroundColor = UIColorFromRGB(0x4A76F0);
	self.view = topBar;

	// Create back button
	UIButton *backButton = [self createButton:@"返回"];
	[
		backButton
			addTarget: self
				 action: @selector(handleBack:)
				forControlEvents:UIControlEventTouchUpInside
	];

	// Create upload button
	UIButton *uploadButton =[self createButton:@"上傳"];
	[
		uploadButton
			addTarget: self
			action: @selector(handleUpload:)
			forControlEvents:UIControlEventTouchUpInside
	];

	self.topbarContent = [self _createTopBarContent];
	[self.view addSubview:self.topbarContent];
	[self _configureTopBarContent];

	[self.topbarContent addArrangedSubview:backButton];
	[self.topbarContent addArrangedSubview:uploadButton];
}

- (UIStackView *)_createTopBarContent {
	UIStackView *topBarContent = [[UIStackView alloc] init];
	topBarContent.axis = UILayoutConstraintAxisHorizontal;
	topBarContent.distribution = UIStackViewDistributionFillEqually;
	topBarContent.translatesAutoresizingMaskIntoConstraints = NO;

	return topBarContent;
}


- (void)_configureTopBarContent {
		[self.topbarContent.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
		[self.topbarContent.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
		[self.topbarContent.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
		[self.topbarContent.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
}

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

- (void)handleBack:(UIButton *)sender {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSDictionary *routeName = [
			NSDictionary dictionaryWithObject:Routes.productListView
			forKey:@"routeName"
		];

		[
			[NSNotificationCenter defaultCenter]
				postNotificationName:@"notifyRouteChange"
				object              :nil
				userInfo            :routeName
		];
	});
}

- (void)handleUpload:(UIButton *)sender {
	[
		[NSNotificationCenter defaultCenter]
			postNotificationName:@"notifyUploadFailedList"
			object              :nil
			userInfo            :nil
	];
}

@end
