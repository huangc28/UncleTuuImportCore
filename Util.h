#import "Foundation/Foundation.h"

@interface Util : NSObject
+ (NSDate *)convertISO8601ToNSDate:(NSString *)dateTimeStr;
+ (NSString *)convertNSDateToISO8601:(NSDate *)nsdate;
+ (NSString *)getImportFailedListFilename;
@end
