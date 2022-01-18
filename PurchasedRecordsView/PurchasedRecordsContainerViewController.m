#import "SharedLibraries/HttpUtil.h"

#import "PurchasedRecordsContainerViewController.h"
#import "TopBarViewController.h"
#import "PurchasedRecordsListViewController.h"
#import "PurchasedRecordModel.h"

@implementation PurchasedRecordsContainerViewController
- (void) viewDidLoad {
	[super viewDidLoad];

	self.view = [
		[UIView alloc] initWithFrame: CGRectMake(
			0,
			0,
			[[UIScreen mainScreen] bounds].size.width,
			[[UIScreen mainScreen] bounds].size.height
		)
	];

	self.view.userInteractionEnabled = YES;
	self.view.backgroundColor = [UIColor whiteColor];

	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	[self fetchPurchasedRecordsAndReact:bundleIdentifier];

	self.topBarViewController = [[TopBarViewController alloc] init];
	[self addChildViewController:self.topBarViewController];
	[self.view addSubview:self.topBarViewController.view];

	self.purchaseRecordsListViewController = [[PurchasedRecordsListViewController alloc] init];
	[self.view addSubview:self.purchaseRecordsListViewController.view];
}

- (void)fetchPurchasedRecordsAndReact:(NSString*)bundleID {
	@try {
		HttpUtil *httpUtil = [HttpUtil sharedInstance];
		[
			httpUtil
				fetchPurchasedRecords:bundleID
				page                 :0
				completedHandler     : ^(NSData *data, NSURLResponse *response, NSError *error){
					@try {

						NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

						NSError *parseError = nil;
						NSDictionary *responseDictionary = [
							NSJSONSerialization
								JSONObjectWithData:data
								options:0
								error:&parseError
						];

						NSMutableArray<PurchasedRecordModel *> *purchasedRecordModels = [[NSMutableArray alloc] init] ;

						if (httpResponse.statusCode == 200) {
						  // Instantiate PurchasedRecord data model
						  for (NSDictionary *purchasedRecord in responseDictionary[@"data"]) {
						  	NSString *uuid = purchasedRecord[@"uuid"];
						  	NSString *prodName =purchasedRecord[@"prod_name"];
						  	NSString *transID =purchasedRecord[@"transaction_id"];
						  	NSString *transTime =purchasedRecord[@"transaction_time"];

						  	PurchasedRecordModel *pr = [
						  		[PurchasedRecordModel alloc]
						  			initWith:uuid
						  			prodName:prodName
						  			transactionID:transID
						  			transactionTime:transTime
						  	];

							[purchasedRecordModels addObject: pr];

						  }

						  self.purchaseRecordsListViewController.purchaseRecords = purchasedRecordModels;

						  dispatch_async(dispatch_get_main_queue(), ^{
						    [self.purchaseRecordsListViewController render];
						  });
						}
					} @catch (NSException *exception){
						NSLog(@"DEBUG* fetchPurchasedRecordsAndReact exception %@", exception);
					}
				}
		];
	} @catch (NSException *exception) {
		NSLog(@"DEBUG* fetchPurchasedRecordsAndReact exception %@", exception);
	}
}

@end
