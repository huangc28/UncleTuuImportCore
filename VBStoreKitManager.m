#import "Storekit/Storekit.h"

#import "SharedLibraries/HttpUtil.h"
#import "SharedLibraries/Alert.h"

#import "ImportFailedList/FailedItem.h"
#import "VBStoreKitManager.h"
#import "Util.h"

@interface SKPaymentQueue()
@property (nonatomic, copy) NSArray* transactions;
@end

@implementation VBStoreKitManager

- (void)_handlePurchased:(NSArray *)transactions {
	NSLog(@"DEBUG* transaction success");

	for (SKPaymentTransaction *transaction in transactions) {
		NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
		NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
		if (!receipt) {
			NSLog(@"DEBUG* VBStoreKitManager no receipt");
		    /* No local receipt -- handle the error. */
		} else {
			#pragma clang diagnostic push
			#pragma clang diagnostic ignored "-Wdeprecated-declarations"
				NSData *tempReceipt = transaction.transactionReceipt;
			#pragma clang diagnostic pop

			// NSData *tempReceipt = transaction.transactionReceipt;
			NSString *encodedTempReceipt = [tempReceipt base64EncodedStringWithOptions:0];
			NSLog(@"DEBUG* encodedTempReceipt %@", encodedTempReceipt);

		  /* Get the receipt in encoded format */
			NSString *encodedReceipt = [receipt base64EncodedStringWithOptions:0];
			NSLog(@"DEBUG* encodedReceipt %@", encodedReceipt);

			NSString *productID = transaction.payment.productIdentifier;

			// Let's prepare failed item in case http failed. Write failed item to local filesystem if http request failed.
			__block FailedItem *item = [
				[FailedItem alloc]
					initWithProdID :productID
					receipt        :encodedReceipt
					tempReceipt    :encodedTempReceipt
					transactionID  :transaction.transactionIdentifier
					transactionDate:[Util convertNSDateToISO8601:transaction.transactionDate]
			];

			HttpUtil *httpUtil = [HttpUtil sharedInstance];
			[
				httpUtil
					addItemToInventory:productID
						transactionID   :transaction.transactionIdentifier
						receipt         :encodedReceipt
						tempReceipt     :encodedTempReceipt
						transactionTime :transaction.transactionDate
						completedHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
							if (error) {
								[
									Alert show:^(){
										NSLog(@"failed to add game item to inventory %@", [error localizedDescription]);
									}
									title: @"Error"
									message: [error localizedDescription]
								];

								[
									item writeDataToFailedItemLog: ^(NSError * writeError){
										if (writeError) {
											[
												Alert
													show:^(){}
													title: @"寫入入庫失敗列表錯誤"
													message: [writeError localizedDescription]
											];

											return;
										}
									}
								];

								return;
							}

							NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
							NSError *parseError = nil;
							NSDictionary *responseDictionary = [
								NSJSONSerialization
									JSONObjectWithData:data
									options:0
									error:&parseError
							];

							if (parseError) {

								[
									Alert show:^(){
										NSLog(@"failed to add game item to inventory %@", [
												parseError localizedDescription
										]);
									}
									title: @"Error"
									message: [parseError localizedDescription]
								];

								[
									item writeDataToFailedItemLog: ^(NSError * writeError){
										if (writeError) {
											[
												Alert
													show:^(){}
													title: @"寫入入庫失敗列表錯誤"
													message: [writeError localizedDescription]
											];

											return;
										}
									}
								];

								return;
							}

							if (httpResponse.statusCode == 200) {
								@try {
									[[SKPaymentQueue defaultQueue] finishTransaction: transaction];

									[
										Alert
											show:^(){
												// Dispatch event to "ProductListViewController" to rerender product list
												NSLog(@"DEBUG* import completed");
											}
											title: @"Success"
											message: @"import complete"
									];

									dispatch_async(dispatch_get_main_queue(), ^{
										[
											[NSNotificationCenter defaultCenter]
												postNotificationName:@"notifyRefreshProducts"
												object:self
										];
									});
								} @catch (NSException *exception) {
									NSLog(@"DEBUG* exception after import request %@", exception);
								}
							} else {
								[
									Alert
										show:^(){}
										title: @"入庫失敗, 已寫入失敗列表"
										message: responseDictionary[@"err"]
								];

								// Write failed item data into local file.
								[
									item writeDataToFailedItemLog: ^(NSError * writeError){
										if (writeError) {
											[
												Alert
													show:^(){}
													title: @"寫入入庫失敗列表錯誤"
													message: [writeError localizedDescription]
											];

											return;
										}
									}
								];
							}
						}
				];
		}
	}
}

// TODO
//   1. Intercept transaction receipt and transaction ID. The above 2 data should be send to BE.
//   2. Should we invoke "finishTransaction"? Will this effect the result to item delivery?
//			- If we don't invoke "finishTransaction" method, We can not proceed to next purchase. It seems like
//			  we need to invoke this method.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	for (SKPaymentTransaction *transaction in transactions) {
			switch (transaction.transactionState) {
				case SKPaymentTransactionStatePurchased: {
					[self _handlePurchased:transactions];

					break;
				}
				case SKPaymentTransactionStatePurchasing: {
					break;
				}
      	case SKPaymentTransactionStateFailed: {
					NSLog(@"DEBUG* VBStoreKitManager Transaction Failed");
      		break;
				}
      	default: {
					break;
				}
      }
    }
}

@end


