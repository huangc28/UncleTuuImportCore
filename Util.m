#import "Util.h"

@implementation Util : NSObject
+ (NSDate *)convertISO8601ToNSDate:(NSString *)dateTimeStr {
	NSString *transactionTime = dateTimeStr;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
	// Always use this locale when parsing fixed format date strings
	NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	[formatter setLocale:posix];
	NSDate *transactionTimeDate = [formatter dateFromString:transactionTime];

	return transactionTimeDate;
}
@end

