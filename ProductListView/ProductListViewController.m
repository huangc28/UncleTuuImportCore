#import "SharedLibraries/HttpUtil.h"
#import "SharedLibraries/ProductViewElementCreator.h"
#import "SharedLibraries/SpinnerViewController.h"

#import "ProductListViewController.h"
#import "ProductViewController.h"

@interface ProductListViewController ()
@end

@implementation ProductListViewController

- (void) viewDidLoad {
	[super viewDidLoad];

	self.view = [
		[UIView alloc] initWithFrame: CGRectMake(
			0,
			80,
			[[UIScreen mainScreen] bounds].size.width,
			[[UIScreen mainScreen] bounds].size.height - 50
		)
	];

	self.contentView = [[UIView alloc] init];
	self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

	[self setupScrollView];
	[self setupProductStackView];

	[self.view addSubview:self.scrollView];
	[self.scrollView addSubview:self.contentView];
	[self.contentView addSubview:self.prodsStackView];

	[self setupLayout];

	// An event handler that reacts to refresh product list. For example, when vendor
	// finished adding stock to inventory, 'ProductListViewController' needs to refresh
	// product list again to rerender product list view.
	[
		[NSNotificationCenter defaultCenter]
			addObserver:self
			selector   :@selector(refreshProductsObserver:)
			name       :@"notifyRefreshProducts"
			object     :nil
	];


	// We need to observe changes of product list. If product list changes,
	// we should rerender product list in view.
	[
		[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(fetchProductsObserver:)
			name    :@"notifyProductsUpdate"
			object  :self
	];

	// Fetch inventory status by bundleID
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	[self fetchInventoryAndReact: bundleIdentifier];
}

- (void) refreshProductsObserver:(NSNotification *)notification {
	if ([[notification name] isEqualToString:@"notifyRefreshProducts"]) {
		NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
		[self fetchInventoryAndReact: bundleIdentifier];
	}
}

// @TODO Uiscroll view can not be scrolled.
//   - Try setup layout again.
//   - Try set constraint height foreach product view.
- (void) fetchProductsObserver:(NSNotification *)notification {
	if ([[notification name] isEqualToString:@"notifyProductsUpdate"]) {
		NSDictionary *userInfo = notification.userInfo;
		NSArray * nProds = [userInfo objectForKey:@"products"];

		[self renderProductList: nProds];
	}
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void) fetchInventoryAndReact:(NSString *)bundleID {
	// Enable spinner.
	UIWindow *window = ([UIApplication sharedApplication].delegate).window ;
	__block SpinnerViewController *spinnerViewCtrl = [[SpinnerViewController alloc] init];
	spinnerViewCtrl.view.frame = window.frame;
	[window addSubview:spinnerViewCtrl.view];

	[
		[HttpUtil sharedInstance]
			fetchInventory: bundleID

		completedHandler: ^(NSData *data, NSURLResponse *response, NSError *error){
			@try {
				// Hide spinner
				[spinnerViewCtrl hide];

				if (error) {
					NSLog(@"DEBUG* error %@", error);
				}

				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

				NSError *parseError = nil;
				NSDictionary *responseDictionary = [
					NSJSONSerialization
						JSONObjectWithData:data
						options:0
						error:&parseError
				];

				if (httpResponse.statusCode == 200) {
					// @TODO: handle the case where no inventory in response.
					// Normalize
					NSMutableArray<ProductModel *> *prods = [[NSMutableArray alloc] init];
					NSArray *inventory = responseDictionary[@"inventory"];

					for (NSDictionary *prod in inventory) {
						// Initialize Product class.
						NSString *prodName = (NSString *)prod[@"prod_name"];
						NSString *prodID = (NSString *)prod[@"prod_id"];
						NSNumber *price = (NSNumber *)prod[@"price"];
						NSNumber *quantity = (NSNumber *)prod[@"quantity"];

						ProductModel *prod = [
							[ProductModel alloc]
								initWithProdName: prodName
									prodID: prodID
									price: price
									quantity: quantity
						];


						[prods addObject: prod];
					}


					// Add products to controller property "products".
					self.products = [[NSArray alloc] initWithArray: prods];

					// Notify observer to update products views.
					NSDictionary *nProds = [NSDictionary dictionaryWithObject:self.products forKey:@"products"];

					dispatch_async(dispatch_get_main_queue(), ^{
						[
							[NSNotificationCenter defaultCenter]
								postNotificationName:@"notifyProductsUpdate"
								object              :self
								userInfo            :nProds
						];
					});
				}
			} @catch (NSException *exception) {
				NSLog(@"DEBUG* fetchInventoryAndReact exception %@", exception.reason);
			}
		}
	];
}

// Responsible for rendering product view.
- (void) renderProductList:(NSArray *)productList {
	[self setupLayout];

	// Remove all subviews from prodsStackView first before refreshing
	// product list view.
	[
		self.prodsStackView.subviews
			makeObjectsPerformSelector: @selector(removeFromSuperview)
	];

	UIStackView *headerRow = [self createHeaderRow];

	[self.prodsStackView addArrangedSubview:headerRow];

	for (ProductModel *prod in productList) {
		// Initialize ProductViewController for each product model.
		ProductViewController *prodViewController =	[
			[ProductViewController alloc]initWithData: prod
		];

		[self.prodsStackView addArrangedSubview:prodViewController.view];
		[self addChildViewController:prodViewController];
	}
}

- (void) setupScrollView {
	self.scrollView = [[UIScrollView alloc]init];
	self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	self.scrollView.contentSize = CGSizeMake(
		[[UIScreen mainScreen] bounds].size.width,
		[[UIScreen mainScreen] bounds].size.height
	);
}

// Setup a stack view container where product status will be listed row by row
// inside the scroll view. We use UIStackView to auto adjust the vertical layout
// of product list.
// [
//   prod info 1
//   prod info 2
//   prod info 3
// ]
- (void) setupProductStackView {
  self.prodsStackView = [[UIStackView alloc] init];
  self.prodsStackView.axis = UILayoutConstraintAxisVertical;
  self.prodsStackView.distribution = UIStackViewDistributionEqualSpacing;
  self.prodsStackView.spacing = 30;
  self.prodsStackView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupLayout {
	@try {
		[self.scrollView.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:20.0].active = YES;
  	[self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor].active = YES;
		[self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor].active = YES;
  	[self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor].active = YES;


		// Content view layout.
		[self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor].active = YES;
		[self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor].active = YES;
		[self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor].active = YES;
		[self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant: -40].active = YES;
		[self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor].active = YES;


		// Products stack view layout.
		[self.prodsStackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
		[self.prodsStackView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
		[self.prodsStackView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
		[self.prodsStackView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
	} @catch (NSException *exception) {
	   NSLog(@"DEBUG* exception %@", exception.reason);
	}
}

- (UIStackView *) createHeaderRow {
	UIStackView *row = [ProductViewElementCreator createRow];

	UILabel *prodNameLabel = [ProductViewElementCreator createLabel:@"名稱"];
	prodNameLabel.textColor = [UIColor blackColor];

	UILabel *priceLabel = [ProductViewElementCreator createLabel:@"價格"];
	priceLabel.textColor = [UIColor blackColor];

	UILabel *quantityLabel = [ProductViewElementCreator createLabel:@"數量"];
	quantityLabel.textColor = [UIColor blackColor];

	[row addArrangedSubview:prodNameLabel];
	[row addArrangedSubview:priceLabel];
	[row addArrangedSubview:quantityLabel];

	return row;
}

@end
