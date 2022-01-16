#import "Routes.h"

#import "ProductListView/ProductListViewContainerViewController.h"
#import "PurchasedRecordsView/PurchasedRecordsContainerViewController.h"

@implementation Routes

// How to declare class level static variable:
// https://stackoverflow.com/questions/1063229/objective-c-static-class-level-variables
static NSString *productListView = @"productListView";
static NSString *purchasedRecordsView = @"purchasedRecordsView";
static NSString *uploadFailedList = @"uploadFailedListView";

+ (instancetype) sharedInstance {
	@try {
    static Routes *instance = nil;
    static dispatch_once_t onceToken;

		// If API_HOST constant is defined, assign the value to variable apiHost. Other wise, uses
		// the production as the default value.
    dispatch_once(&onceToken, ^{
        instance = [[Routes alloc]init];
    });

    return instance;
	} @catch (NSException *exception) {
		NSLog(@"DEBUG* exception %@", exception.reason);
	}
}

+ (NSString *) productListView {
	return productListView;
}

+ (NSString *)purchasedRecordsView {
	return purchasedRecordsView;
}

+ (NSString *)uploadFailedList {
	return uploadFailedList;
}

// How to assign null value to NSDictionary property:
// https://stackoverflow.com/questions/12008365/ios-why-cant-i-set-nil-to-nsdictionary-value
// http://www.takingnotes.co/blog/2012/01/06/comparing-to-nsnull/
- (id) init {
	self = [super init];

	// Configure routes.
	NSDictionary *routeConfig = @{
		productListView     :(UIViewController *)[NSNull null],
		purchasedRecordsView:(UIViewController *)[NSNull null],
		uploadFailedList    :(UIViewController *)[NSNull null]
	};

	self.routes = [routeConfig mutableCopy];

	return self;
}

//- (UIViewController *)GetRouteUIViewController:(NSString *)routeName {
- (id)GetRouteUIViewController:(NSString *)routeName {
	// Check if routeName exists.
	// If route name does not exists raised exception
	if (!self.routes[routeName]) {
		[
			NSException
				raise:@"Route does not exist"
				format:@"route %@ does not exist", routeName
		];
	}

	// If route name exists but it's paired value is [NSNull null],
	// we simply initialize that UIViewController and return it.
	if ([self.routes objectForKey:routeName] == (UIViewController *)[NSNull null]) {
		id v = [self initRouteUIViewController:routeName];

		[
			self.routes
				setObject:v
				forKey   :routeName
		];
	}

	return [self.routes objectForKey:routeName];
}

- (id)initRouteUIViewController:(NSString *)routeName {
	id v;
	NSArray *views = @[
		productListView,
		purchasedRecordsView,
		uploadFailedList
	];

	int viewIdx = [views indexOfObject:routeName];
	switch (viewIdx) {
			// ProductListViewContainerViewController
	    case 0:
				 v = [[ProductListViewContainerViewController alloc] init];
	       break;

			// PurchasedRecordsContainerViewController
	    case 1:
				 v = [[PurchasedRecordsContainerViewController alloc] init];

	       break;
			case 2:
				 break;
	    default:
				 v = [[ProductListViewContainerViewController alloc] init];
	       break;
	}

	return v;
}

@end
