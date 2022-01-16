#import "Foundation/Foundation.h"

@interface AuthManager :NSObject {
	NSString *_jwt;
}

+ (instancetype) sharedInstance;
- (_Bool) isLoggedIn;

@property(strong, nonatomic) NSString *jwt; // @synthesize jwt=_jwt

@end

