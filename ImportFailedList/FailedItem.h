#import "Foundation/Foundation.h"

@interface FailedItem : NSObject

- (instancetype)initWithProdID:(NSString *)prodID
	receipt:(NSString *)receipt
	tempReceipt:(NSString *)tempReceipt
	transactionID:(NSString *)transactionID
	transactionDate:(NSString *)transactionDate;

- (void)writeDataToFailedItemLog;

@property(strong, nonatomic) NSString* prodID;
@property(strong, nonatomic) NSString* receipt;
@property(strong, nonatomic) NSString* tempReceipt;
@property(strong, nonatomic) NSString* transactionID;
@property(strong, nonatomic) NSString* transactionDate;

@end
