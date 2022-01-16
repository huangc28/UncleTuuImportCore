#import "../Util.h"
#import "../Routes.h"
#import "TopBarViewController.h"

@implementation TopBarViewController

- (void) viewDidLoad {
	[super viewDidLoad];

	UIView *topBar = [
		[UIView alloc] initWithFrame:CGRectMake(
			0,
			0,
			[[UIScreen mainScreen] applicationFrame].size.width,
			80
		)
	];

	topBar.userInteractionEnabled = YES;
	topBar.backgroundColor = UIColorFromRGB(0x4A76F0);
	self.view = topBar;
	UIButton *backButton = [self createButton:@"返回"];
	[
		backButton
			addTarget: self
				 action: @selector(handleBack:)
				forControlEvents:UIControlEventTouchUpInside
	];

	UIButton *clearButton = [self createButton:@"清除"];
	[
		clearButton
			addTarget: self
				 action: @selector(handleClear:)
				forControlEvents:UIControlEventTouchUpInside
	];

	UIStackView *topBarContent = [self createTopBarContent];
	[self.view addSubview:topBarContent];
	[self configureTopBarContent:topBarContent];

	[topBarContent addArrangedSubview:backButton];
	[topBarContent addArrangedSubview:clearButton];
}

- (void)configureTopBarContent:(UIStackView *)topBarContent {
		[topBarContent.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
		[topBarContent.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
		[topBarContent.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
		[topBarContent.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
}

- (UIStackView *)createTopBarContent {
	UIStackView *topBarContent = [[UIStackView alloc] init];
	topBarContent.axis = UILayoutConstraintAxisHorizontal;
	topBarContent.distribution = UIStackViewDistributionFillEqually;
	topBarContent.translatesAutoresizingMaskIntoConstraints = NO;

	return topBarContent;
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
											object:nil
										userInfo:routeName
		];
	});
}

- (void)handleClear:(UIButton *)sender {
	NSLog(@"DEBUG* handleClear");
}

@end
