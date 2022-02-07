#import "Foundation/Foundation.h"
#import "UIKit/UIKit.h"

@interface SpinnerViewController : UIViewController {
	UIActivityIndicatorView *_spinnerView;
}

- (void) hide;

@property(strong, nonatomic) UIActivityIndicatorView *spinnerView; // @synthesize spinnerView=spinnerView;
@end
