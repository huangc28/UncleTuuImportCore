#import "SharedLibraries/Alert.h"
#import "SharedLibraries/HttpUtil.h"
#import "../Constants.h"
#import "FailedItem.h"
#import "ImportFailedContainerViewController.h"

@implementation ImportFailedContainerViewController
- (void) viewDidLoad {
	[super viewDidLoad];
	[self _registerUploadFailedListEvent];

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
	//NSLog(@"DEBUG* failed item %@", items);

	//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
	//	// We will check if cache file of import failed items exists.
	//	// Store a fake receipt in import_failed_items.txt first.
	//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  //	NSString *documentsDirectory = [paths objectAtIndex:0];
  //	NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"import_failed_items.txt"];

	//	NSLog(@"DEBUG* dataPath %@", dataPath);
	//	NSDictionary *cacheDic = @{
	//		@"prod_id":@"exampleid",
	//		@"receipt":@"somereceipt",
	//		@"temp_receipt":@"sometempreceipt",
	//		@"transaction_id":@"sometransid",
	//		@"transaction_date":@"sometransdate"
	//	};

	//	NSError *error;
	//	NSMutableData *jsonData = [[
	//		NSJSONSerialization
	//			dataWithJSONObject:cacheDic
  //      options:NSJSONWritingPrettyPrinted
  //      error:&error
	//	] copy];

	//	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:dataPath];

	//	if (fileHandle == nil) {
  //    [
	//			[NSFileManager defaultManager]
	//				createFileAtPath:dataPath
	//				contents:nil
	//				attributes:nil
	//		];

  //    fileHandle = [NSFileHandle fileHandleForWritingAtPath:dataPath];
	//	}

	//	[fileHandle seekToEndOfFile];
	//	[fileHandle writeData:jsonData];
	//	[fileHandle writeData:[@"\n\n" dataUsingEncoding:NSUTF8StringEncoding]];
	//	[fileHandle closeFile];

	//	NSLog(@"DEBUG* closeFile~~");
	//});
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

- (void)_uploadFailedListObserver:(NSNotification *)notification {
	NSLog(@"DEBUG* trigger _uploadFailedListObserver");

	NSString *dataPath = [self _getImportFailedListFilename];
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

	NSLog(@"DEBUG* fileData %@", fileData);

	[
		[HttpUtil sharedInstance]
			uploadFailedList:fileData
	];
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

			NSLog(@"DEBUG* itemJsonStr %@", itemJsonStr);

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
