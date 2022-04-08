#import "FailedItem.h"
#import "../Util.h"

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

// TODO handle error so the app won't crash.
- (void)writeDataToFailedItemLog:(void(^)(NSError *error))completionHandler {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		NSString *dataPath = [Util getImportFailedListFilename];

		NSDictionary *cacheDic = @{
			@"prod_id"         :self.prodID,
			@"receipt"         :self.receipt,
			@"temp_receipt"    :self.tempReceipt,
			@"transaction_id"  :self.transactionID,
			@"transaction_date":self.transactionDate
		};

		NSError *error;
		NSMutableData *jsonData = [[
			NSJSONSerialization
				dataWithJSONObject:cacheDic
				options:NSJSONWritingPrettyPrinted
						error:&error
		] copy];


		if (error) {
			completionHandler(error);

			return;
		}

		NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:dataPath];

		if (fileHandle == nil) {
			[
				[NSFileManager defaultManager]
					createFileAtPath:dataPath
					contents:nil
					attributes:nil
			];

			fileHandle = [NSFileHandle fileHandleForWritingAtPath:dataPath];
		}

		[fileHandle seekToEndOfFile];
		[fileHandle writeData:jsonData];
		[fileHandle writeData:[@"\n\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[fileHandle closeFile];
	});
}

@end
