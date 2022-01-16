#import "Foundation/Foundation.h"

@interface PurchasedRecordModel : NSObject {
  NSString* _uuid;
  NSString* _prodName;
  NSString* _transactionID;
  NSString* _transactionTime;
}

- (instancetype) initWith:(NSString *)uuid
  prodName:(NSString *)prodName
  transactionID:(NSString *)transactionID
  transactionTime:(NSString *)transactionTime;

@property(strong, nonatomic) NSString* uuid; // @synthesize _uuid=uuid
@property(strong, nonatomic) NSString* prodName; // @synthesize _prodName=prodName
@property(strong, nonatomic) NSString* transactionID; // @synthesize _transactionID=transactionID
@property(strong, nonatomic) NSString* transactionTime; // @synthesize _transactionTime=transactionTime

@end
