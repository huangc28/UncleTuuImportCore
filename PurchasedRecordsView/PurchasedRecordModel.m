#import "PurchasedRecordModel.h"

@implementation PurchasedRecordModel

- (instancetype) initWith:(NSString *)uuid
  prodName:(NSString *)prodName
  transactionID:(NSString *)transactionID
  transactionTime:(NSString *)transactionTime
{
  PurchasedRecordModel *pr = [[PurchasedRecordModel alloc] init];
  pr.uuid = uuid;
  pr.prodName = prodName;
  pr.transactionID = transactionID;
  pr.transactionTime = transactionTime;

  return pr;
}
@end

