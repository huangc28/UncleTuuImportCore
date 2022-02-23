#import "UIKit/UIKit.h"

#import "SharedLibraries/HttpUtil.h"
#import "SharedLibraries/Product.h"
#import "SharedLibraries/Alert.h"

#import "../SpinnerViewController.h"
#import "../ColorHashGenerator.h"
#import "../Auth/AuthManager.h"
#import "../AuthModel.h"
#import "AppTopViewController.h"

@interface AppTopViewController ()<UITextFieldDelegate>
@end

@implementation AppTopViewController

@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize authModel;

- (id) init {
	authModel = [[AuthModel alloc] init];

	return [super init];
}

- (void) viewDidLoad {
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

	// setup product stack view
	[self _setupTopBarStackView];
	[self.view addSubview:self.topBarStackView];
	[self _configureTopBarStackView];


	// Create username text field
	self.usernameTextField = [self _createUsernameTextField];
	self.usernameTextField.delegate = self;


	// Create password text field
	self.passwordTextField = [self _createPasswordTextField];
	self.passwordTextField.delegate = self;


	// Create a button to submit auth credential
	UIButton *submitButton = [self createSubmitButton];

	[self.topBarStackView addArrangedSubview: self.usernameTextField];
	[self.topBarStackView addArrangedSubview: self.passwordTextField];
	[self.topBarStackView addArrangedSubview: submitButton];
}

- (void) _setupTopBarStackView {
  self.topBarStackView = [[UIStackView alloc] init];
  self.topBarStackView.axis = UILayoutConstraintAxisHorizontal;
  self.topBarStackView.alignment = UIStackViewAlignmentCenter;
  self.topBarStackView.distribution = UIStackViewDistributionFillEqually;
  self.topBarStackView.translatesAutoresizingMaskIntoConstraints = NO;
  self.topBarStackView.spacing = 3;
}

- (void)_configureTopBarStackView {
	[self.topBarStackView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
  [self.topBarStackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
	[self.topBarStackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
  [self.topBarStackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
}

- (UITextField *)_createUsernameTextField {
	UITextField *utf = [[UITextField alloc] init];
	[
		utf
			setContentHuggingPriority:250
			forAxis                  :UILayoutConstraintAxisHorizontal
	];


	[utf setTextColor:[UIColor blackColor]];
	utf.backgroundColor = [UIColor whiteColor];

	utf.attributedPlaceholder = [
		[NSAttributedString alloc]
			initWithString:@"用戶名"
			attributes:@{
				NSForegroundColorAttributeName:[UIColor lightGrayColor]
			}
	];
	[
		utf
			addTarget          :self
				 action          :@selector(usernameDidChange:)
				 forControlEvents:UIControlEventAllEditingEvents
	];

	NSLayoutConstraint * height = [
		NSLayoutConstraint
			constraintWithItem:utf
			attribute:NSLayoutAttributeHeight
			relatedBy:NSLayoutRelationEqual
			toItem:nil
			attribute:NSLayoutAttributeHeight
			multiplier:1.0
			constant:70
	];

	[utf addConstraints:@[height]];

	return utf;
}

- (UITextField *)_createPasswordTextField {
	UITextField *ptf = [[UITextField alloc] init];
	[
		ptf
			setContentHuggingPriority:250
			forAxis                  :UILayoutConstraintAxisHorizontal
	];

	[ptf setTextColor:[UIColor blackColor]];
	ptf.backgroundColor = [UIColor whiteColor];

	ptf.attributedPlaceholder = [
		[NSAttributedString alloc]
			initWithString:@"密碼"
			attributes:@{
				NSForegroundColorAttributeName:[UIColor lightGrayColor]
			}
	];

	[
		ptf
			addTarget: self
				 action: @selector(passwordDidChange:)
				 forControlEvents: UIControlEventAllEditingEvents
	];

	NSLayoutConstraint * height = [
		NSLayoutConstraint
			constraintWithItem:ptf
			attribute:NSLayoutAttributeHeight
			relatedBy:NSLayoutRelationEqual
			toItem:nil
			attribute:NSLayoutAttributeHeight
			multiplier:1.0
			constant:70
	];

	[ptf addConstraints:@[height]];

	return ptf;
}

- (UIButton *)createSubmitButton {
	UIButton *but = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[
		but
			addTarget: self
				 action: @selector(_handleSubmit:)
				forControlEvents:UIControlEventTouchUpInside
	];

	[
		but
			setContentHuggingPriority:UILayoutPriorityDefaultHigh
			forAxis                  :UILayoutConstraintAxisHorizontal
	];

	[but setTitle: @"登入" forState: UIControlStateNormal];
	[but setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
	[but setExclusiveTouch: YES];

	return but;
}

- (void)usernameDidChange:(UITextField *)arg {
	authModel.username = arg.text;
}

- (void)passwordDidChange:(UITextField *)arg {
	authModel.password = arg.text;
}

- (void)_handleSubmit:(UIButton *)arg1 {
	NSString *username = authModel.username;
	NSString *password = authModel.password;

	// Dismiss keyboard
	[self dismissKeyboard];

	// Check non-empty username / password.
	if ([username length] == 0 || [password length] == 0) {
		[
			Alert
				show:^(){
					NSLog(@"DEBUG* username or password is empty value");
				}
				title: @"[請登入]"
				message: @"帳號或密碼不可為空"
		];

		return;
	}

	// TODO: extract this to AppViewController
	// Start animating spinner.
	UIWindow *window = ([UIApplication sharedApplication].delegate).window ;
	__block SpinnerViewController *spinnerViewCtrl = [[SpinnerViewController alloc] init];
	spinnerViewCtrl.view.frame = window.frame;
	[window addSubview:spinnerViewCtrl.view];

	// Perform login.
	HttpUtil *httpUtil = [HttpUtil sharedInstance];

	[
		httpUtil
			login:username
			password:password
			completedHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
				// Hide spinner.
				[spinnerViewCtrl hide];

				NSError *parseError = nil;
				NSDictionary *responseDictionary = [
					NSJSONSerialization
						JSONObjectWithData:data
						options:0
						error:&parseError
				];

				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

				// Store jwt in AuthManager
				if (httpResponse.statusCode == 200) {
					NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

					[
						prefs
							setObject:responseDictionary[@"jwt"]
							forKey   :@"atuu_jwt"
					];

					return;
				} else {
					// Display error
					[
						Alert
							show:^(){
								NSLog(@"DEBUG* item import failed");
							}
							title: @"[登入失敗]"
							message: responseDictionary[@"err"]
					];
				}
			}
	];
}

- (void) dismissKeyboard {
	[self.usernameTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
}

@end


