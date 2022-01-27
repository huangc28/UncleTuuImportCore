#import "Storekit/Storekit.h"

#import "VBStoreKitManager.h"

#import "SharedLibraries/HttpUtil.h"
#import "SharedLibraries/Alert.h"

@interface SKPaymentQueue()
@property (nonatomic, copy) NSArray* transactions;
@end

@implementation VBStoreKitManager

// TODO
//   1. Intercept transaction receipt and transaction ID. The above 2 data should be send to BE.
//   2. Should we invoke "finishTransaction"? Will this effect the result to item delivery?
//			- If we don't invoke "finishTransaction" method, We can not proceed to next purchase. It seems like
//			  we need to invoke this method.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased: {
							// Observe SKPaymentTransaction:
              NSLog(@"DEBUG* transaction success");

							NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
							NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
							if (!receipt) {
							    NSLog(@"DEBUG* VBStoreKitManager no receipt");
							    /* No local receipt -- handle the error. */
							} else {
							    /* Get the receipt in encoded format */
							    NSString *encodedReceipt = [receipt base64EncodedStringWithOptions:0];

									NSLog(@"DEBUG* %@", encodedReceipt);


									NSString *productID = transaction.payment.productIdentifier;

									HttpUtil *httpUtil = [HttpUtil sharedInstance];
									[
										httpUtil
											addItemToInventory:productID
													 transactionID:transaction.transactionIdentifier
																 receipt:encodedReceipt
												 transactionTime:transaction.transactionDate
												completedHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
													if (error) {
														[
															Alert show:^(){
																NSLog(@"failed to add game item to inventory %@", [error localizedDescription]);
															}
															title: @"Error"
															message: [error localizedDescription]
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
																show:^(){
																	NSLog(@"DEBUG* item import failed");
																}
																title: @"Error"
																message: responseDictionary[@"err"]
														];
													}
												}
									];
							}

							break;
						}

						case SKPaymentTransactionStatePurchasing: {
							@try {
								NSLog(@"DEBUG* trigger SKPaymentTransactionStatePurchasing");

								NSMutableArray *trans = [[NSMutableArray alloc] init];
								[trans addObject:transaction];

								[
									self
										paymentQueue:queue
										removedTransactions:trans
								];
							} @catch (NSException* exception) {
								NSLog(@"DEBUG* trigger SKPaymentTransactionStatePurchasing exception %@", exception);
							}

							break;
						}


            case SKPaymentTransactionStateFailed: {
                NSLog(@"DEBUG* VBStoreKitManager Transaction Failed");
                // [[SKPaymentQueue defaultQueue]
                //      finishTransaction:transaction];
                break;
						}

            default: {
							break;
						}
        }
    }
}


@end


