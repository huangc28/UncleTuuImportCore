#import "SharedLibraries/Alert.h"
#import "SharedLibraries/HttpUtil.h"

#import "../Constants.h"
#import "../Util.h"
#import "FailedItem.h"
#import "ImportFailedContainerViewController.h"

@implementation ImportFailedContainerViewController
- (void) viewDidLoad {
	[super viewDidLoad];

	[self _registerUploadFailedListEvent];
	[self _registerUploadFiledItemEvent];

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

	self.topbar = [[ImportFailedTopBarViewController alloc] init];
	[self.view addSubview:self.topbar.view];
	[self addChildViewController:self.topbar];
	[self.topbar didMoveToParentViewController:self];

	self.itemListVC = [[ImportFailedItemListViewController alloc] init];
	[self.view addSubview:self.itemListVC.view];
	[self addChildViewController:self.itemListVC];
	[self.itemListVC didMoveToParentViewController:self];

	// Load list of import failed item from local file system.
	self.itemListVC.failedItems = [self _readFromImportFailedList];

	// render itemListVC renders failedItems
	[self.itemListVC render];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	// Load list of import failed item from local file system.
	self.itemListVC.failedItems = [self _readFromImportFailedList];

	// render itemListVC renders failedItems
	[self.itemListVC render];
}

- (void)_registerUploadFailedListEvent {
	[
		[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(_uploadFailedListObserver:)
			name:@"notifyUploadFailedList"
			object:nil
	];
}

- (void)_registerUploadFiledItemEvent {
	[
		[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(_uploadFailedItemObserver:)
			name:@"notifyUploadFailedItem"
			object:nil
	];
}

- (void)_uploadFailedListObserver:(NSNotification *)notification {
	__block NSString *dataPath = [self _getImportFailedListFilename];
	if (![self _fileExistsAndHasContent:dataPath]) {
		[
			Alert
				show   :^(){}
				title  :@"入庫都沒失敗"
				message:@"目前入庫都成功"
		];

		return;
	}

	// Read file to NSData
	NSData * fileData = [[NSFileManager defaultManager] contentsAtPath:dataPath];

	// TODO add dialog to notify user that the upload is completed.
	// TODO remove file from dataPath.
	[
		[HttpUtil sharedInstance]
			uploadFailedList:fileData
			completedHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {

				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

				NSError *parseError = nil;
				NSDictionary *responseDictionary = [
					NSJSONSerialization
						JSONObjectWithData:data
						options:0
						error:&parseError
				];

				if (httpResponse.statusCode == 200) {
					// Clear file content
					[[NSFileManager defaultManager] createFileAtPath:dataPath contents:[NSData data] attributes:nil];

					// Reset failed item list
					self.itemListVC.failedItems = [[NSMutableArray<FailedItem *> alloc] init];
					// Rerender item list
					[self.itemListVC render];

					// Display success alert.
					[
						Alert
							show:^(){}
							title: @"上傳成功"
							message: @"商品上傳成功"
					];
				} else {
					[
						Alert
							show:^(){}
							title: @"上傳失敗"
							message: responseDictionary[@"err"]
					];
				}
			}
	];
}

- (void)_uploadFailedItemObserver:(NSNotification *)notification {
	if ([[notification name] isEqualToString:@"notifyUploadFailedItem"]) {
		NSDictionary *userInfo = notification.userInfo;
		__block FailedItem *failedItem = [userInfo objectForKey:@"failedItem"];
		ImportFailedContainerViewController * __weak weakSelf = self;

		// Upload item to remote server
		HttpUtil *httpUtil = [HttpUtil sharedInstance];
		[
			httpUtil
				addItemToInventory:failedItem.prodID
				transactionID     :failedItem.transactionID
				receipt           :failedItem.receipt
				tempReceipt       :failedItem.tempReceipt
				transactionTime   :[Util convertISO8601ToNSDate:failedItem.transactionDate]
				completedHandler  :^(NSData *data, NSURLResponse *response, NSError *error) {
					NSLog(@"DEBUG* done uploading");

					NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

					NSError *parseError = nil;
					NSDictionary *responseDictionary = [
						NSJSONSerialization
							JSONObjectWithData:data
							options:0
							error:&parseError
					];

					if (httpResponse.statusCode == 200) {
						// Remove uploaded item from the item list
						[weakSelf _removeFailedItemFromListByTransactionID:failedItem.transactionID];

						// Refresh import_failed_items list again.
						[weakSelf _refreshFailedItems];

						// Rerender the list
						[weakSelf.itemListVC render];

						// Display success alert.
						[
							Alert
								show:^(){}
								title: @"上傳成功"
								message: @"商品上傳成功"
						];
					} else {
						[
							Alert
								show:^(){}
								title: @"上傳失敗"
								message: responseDictionary[@"err"]
						];
					}
				}
		];
	}
}

- (void)_removeFailedItemFromListByTransactionID:(NSString *)transactionID {
	@try {
		NSInteger index = 0;
		NSMutableArray *failedItems = [self.itemListVC.failedItems mutableCopy];

		for (FailedItem *failedItem in failedItems) {
			if ([failedItem.transactionID isEqualToString:transactionID]) {
				[failedItems removeObjectAtIndex:index];

				break;
			}

			index++;
		}

		self.itemListVC.failedItems = [failedItems copy];
	} @catch (NSException *exception) {
		NSLog(@"DEBUG* exception %@", exception);
	}
}

- (void)_refreshFailedItems {

	@try {
		NSMutableData *contentData = [[NSMutableData alloc] init];

		NSLog(@"DEBUG* failedItems length %lu", (unsigned long)[self.itemListVC.failedItems count]);

		for (FailedItem *failedItem in self.itemListVC.failedItems) {
			NSLog(@"DEBUG* inloop %@", failedItem);

			// Convert FailedItem to NSDictionary
			NSMutableDictionary *itemDic = [[NSMutableDictionary alloc] init];
			[itemDic setObject:failedItem.prodID forKey:@"prod_id"];
			[itemDic setObject:failedItem.receipt forKey:@"receipt"];
			[itemDic setObject:failedItem.tempReceipt forKey:@"temp_receipt"];
			[itemDic setObject:failedItem.transactionID forKey:@"transaction_id"];
			[itemDic setObject:failedItem.transactionDate forKey:@"transaction_date"];

			// Convert NSDictionary to json string
			NSError *error;
			NSMutableData *jsonData = [[
				NSJSONSerialization
					dataWithJSONObject:itemDic
  	      options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
  	      error:&error
			] mutableCopy];


			if (error) {
				[
					NSException
						raise:@"FailedToSerializeFailedItemException"
					 format:@"failed to serialize failed item: %@", [error localizedDescription]
				];
			}

			[jsonData appendData:[@"\n\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[contentData appendData:jsonData];
		}

		NSString *dataPath = [self _getImportFailedListFilename];

		// Overwrite the original content.
		[contentData writeToFile:dataPath atomically:YES];
	} @catch (NSException *exception) {
		NSLog(@"DEBUG* failed to refresh failed items %@", exception);
	}

}

- (NSString *)_getImportFailedListFilename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *dataPath = [
		documentsDirectory stringByAppendingPathComponent:ImportFailedListFilename
	];

	return dataPath;
}

- (BOOL)_fileExistsAndHasContent:(NSString *)dataPath {
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if (![fileManager fileExistsAtPath:dataPath]){
		NSLog(@"DEBUG* imported failed items file does not exists. No item failed to import");

		return NO;
	}

	NSDictionary *attributes = [fileManager attributesOfItemAtPath:dataPath error:nil];
	unsigned long long size = [attributes fileSize];
	if (attributes && size == 0) {
		NSLog(@"DEBUG* imported failed items file has no content");

		return NO;
	}

	return YES;
}

// TODO toggle loading spinner
- (NSMutableArray<FailedItem *> *)_readFromImportFailedList {
	NSString *dataPath = [self _getImportFailedListFilename];

	NSMutableArray<FailedItem *> *items = [[NSMutableArray<FailedItem *> alloc] init];

	if (![self _fileExistsAndHasContent:dataPath]) {
		return items;
	}

	@try {
		NSError *error = nil;
		NSString* fileContents =
			[
				NSString
					stringWithContentsOfFile:dataPath
					encoding                :NSUTF8StringEncoding
					error                   :&error
			];

		if (error) {
			 NSException *e = [
				 NSException
			        exceptionWithName:@"ReadFileContentException"
			        reason:[error localizedDescription]
			        userInfo:nil
			 ];

			@throw e;
		}

		NSArray* allLinedStrings =
			[
				fileContents
					componentsSeparatedByString:@"\n\n"
			];


		for (NSString *itemJsonStr in allLinedStrings) {
			if ([itemJsonStr length] == 0) {
				continue;
			}

			NSError *parseItemError = nil;
			NSDictionary *failedItemDic = [
				NSJSONSerialization
					JSONObjectWithData:[itemJsonStr dataUsingEncoding:NSUTF8StringEncoding]
					options:0
					error:&parseItemError
			];

			if (parseItemError) {
				NSException *e = [
				  NSException
				       exceptionWithName:@"ParseFailedItemException"
				       reason:[parseItemError localizedDescription]
				       userInfo:nil
				];

				@throw e;
			}

			FailedItem *item = [
				[FailedItem alloc]
					initWithProdID   :failedItemDic[@"prod_id"]
						receipt        :failedItemDic[@"receipt"]
						tempReceipt    :failedItemDic[@"temp_receipt"]
						transactionID  :failedItemDic[@"transaction_id"]
						transactionDate:failedItemDic[@"transaction_date"]
			];

			// Push items in array
			[items addObject:item];
		}

		return items;
	} @catch (NSException *exception) {
		NSLog(@"DEBUG* readFromImportFailedList exception: %@", exception);
	}
}

@end
