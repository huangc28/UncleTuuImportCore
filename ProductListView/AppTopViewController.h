#import "UIKit/UIKit.h"

#import "../AuthModel.h"

@interface AppTopViewController : UIViewController <UITextFieldDelegate> {
	AuthModel *_authModel;
}

- (UIButton *)createSubmitButton;
- (void) dismissKeyboard;

@property (strong, nonatomic) UIStackView *topBarStackView;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) AuthModel *authModel; // @synthesize authModel=_authModel;

@end
