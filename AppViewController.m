#import "StoreKit/StoreKit.h"
#import "QuartzCore/QuartzCore.h"

#import "SharedLibraries/HttpUtil.h"
#import "SharedLibraries/Alert.h"

#import "AppViewController.h"
#import "Routes.h"

@interface AppViewController ()<UIGestureRecognizerDelegate>
@end

@implementation AppViewController

- (id) init {
	self = [super init];

	self.routes = [Routes sharedInstance];

	return self;
}


- (void) viewDidLoad {
	[super viewDidLoad];

	// Initialize AppView here.
	UIView *appView = [
		[UIView alloc] initWithFrame:CGRectMake(
			0,
			0,
			[[UIScreen mainScreen] bounds].size.width,
			[[UIScreen mainScreen] bounds].size.height
		)
	];

	appView.userInteractionEnabled = YES;
	appView.backgroundColor = [UIColor whiteColor];

	[self registerRouteChangeEvent];
	[self registerCloseImporterEvent];

	// Retrieve UIViewController from routes.
	[self changeRoute:Routes.productListView];
}

- (void) renderImportApp:(UIApplication *)app {
	UIWindow *window = ([UIApplication sharedApplication].delegate).window;
	[window addSubview:self.view];
	[window.rootViewController addChildViewController:self];
	[self didMoveToParentViewController:window.rootViewController];
}

// Deprecate renderImportApp: progressively
- (void) renderImportApp {
	UIWindow *window = ([UIApplication sharedApplication].delegate).window;
	[window addSubview:self.view];
	[window.rootViewController addChildViewController:self];
	[self didMoveToParentViewController:window.rootViewController];
}

- (void) dealloc {
	self.routes = nil;
}

// Register event to close importer APP.
- (void)registerCloseImporterEvent {
	[
		[NSNotificationCenter defaultCenter]
			addObserver:self
				 selector:@selector(closeImporterObserver:)
						 name:@"notifyCloseImporter"
					 object:nil
	];
}

- (void)closeImporterObserver:(NSNotification *)notification {
	if ([[notification name] isEqualToString:@"notifyCloseImporter"]) {
		[self willMoveToParentViewController:nil];
		[self.view removeFromSuperview];
		[self removeFromParentViewController];
	}
}

- (void)registerRouteChangeEvent {
	[
		[NSNotificationCenter defaultCenter]
			addObserver:self
				 selector:@selector(routeChangeObserver:)
						 name:@"notifyRouteChange"
					 object:nil
	];
}

- (void)routeChangeObserver:(NSNotification *)notification {
	if ([[notification name] isEqualToString:@"notifyRouteChange"]) {
		NSDictionary *userInfo = notification.userInfo;
		NSString *routeName = [userInfo objectForKey:@"routeName"];

		NSLog(@"DEBUG* routeName %@", routeName);

		[self changeRoute:routeName];
	}
}

- (void)changeRoute:(NSString *)routeName {
	@try {
	  UIViewController *nextViewController = [
	  	self.routes GetRouteUIViewController:routeName
	  ];

	  // Remove current view controller from parent view controller
	  if (self.currentRouteViewController != nil) {
	  	[self.currentRouteViewController willMoveToParentViewController:nil];
	  	[self.currentRouteViewController.view removeFromSuperview];
	  	[self.currentRouteViewController removeFromParentViewController];
	  }

	  // Assign current view
	  self.currentRouteViewController = nextViewController;

	  [self addChildViewController:self.currentRouteViewController];
	  [self.view addSubview:self.currentRouteViewController.view];
	  [self.currentRouteViewController didMoveToParentViewController:self];
	} @catch (NSException *exception) {
	  NSLog(@"DEBUG* changeRoute exception %@", exception);
	}
}

// Handle close event
- (void) didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
