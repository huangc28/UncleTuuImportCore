#import "Foundation/Foundation.h"

@interface AuthModel : NSObject {
	NSString *_username;
	NSString *_password;
}
	@property (retain, nonatomic) NSString *username; //@synthesize username=_username
	@property (retain, nonatomic) NSString *password; //@synthesize password=_password
@end
