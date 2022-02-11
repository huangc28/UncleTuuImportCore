#import "Util.h"
#import "Constants.h"

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

+ (NSString *)convertNSDateToISO8601:(NSDate *)nsdate {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	[dateFormatter setLocale:enUSPOSIXLocale];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
	[dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];

	return [dateFormatter stringFromDate:nsdate];
}


// TODO cache retrieved dataPath instead of performing the login everytime.
+ (NSString *)getImportFailedListFilename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
  	NSString *dataPath = [
		documentsDirectory stringByAppendingPathComponent:ImportFailedListFilename
	];

	return dataPath;
}
@end

