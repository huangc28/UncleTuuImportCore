#import "AuthManager.h"

@implementation AuthManager

static AuthManager *_sharedInstance = nil;

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		_sharedInstance = [[AuthManager alloc] init];
	});

	return _sharedInstance;
}

- (_Bool) isLoggedIn {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	return [prefs valueForKey:@"atuu_jwt"] != nil && [[prefs stringForKey:@"atuu_jwt"] length] > 0;
}

@end
