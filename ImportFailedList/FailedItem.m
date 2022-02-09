#import "FailedItem.h"

@implementation FailedItem

- (instancetype)initWithProdID:(NSString *)prodID
	receipt:(NSString *)receipt
	tempReceipt:(NSString *)tempReceipt
	transactionID:(NSString *)transactionID
	transactionDate:(NSString *)transactionDate {
		self = [super init];

		if (self) {
			self.prodID = prodID;
			self.receipt = receipt;
			self.tempReceipt = tempReceipt;
			self.transactionID = transactionID;
			self.transactionDate = transactionDate;
		}

		return self;
}
@end
