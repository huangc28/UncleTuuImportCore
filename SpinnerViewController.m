#import "SpinnerViewController.h"

@implementation SpinnerViewController

- (void) viewDidLoad {
	self.view = [[UIView alloc] init];
	self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
  self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
UIActivityIndicatorViewStyleLarge];
  	self.spinnerView.translatesAutoresizingMaskIntoConstraints = false;

  	[self.spinnerView startAnimating];

	[self.view addSubview:self.spinnerView];

	[self.spinnerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;

	[self.spinnerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

- (void) hide {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.view removeFromSuperview];
	});
}

- (void) dealloc {
	self.spinnerView = nil;
}

@end
