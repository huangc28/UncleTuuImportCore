#import "UIKit/UIKit.h"

#import "../AuthModel.h"

@interface AppTopViewController : UIViewController <UITextFieldDelegate> {
	AuthModel *_authModel;
}

- (UIButton *)createSubmitButton;
- (void) dismissKeyboard;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) AuthModel *authModel; // @synthesize authModel=_authModel;

@end
