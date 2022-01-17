#import "StoreKit/StoreKit.h"

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
			[[UIScreen mainScreen] applicationFrame].size.width,
			[[UIScreen mainScreen] applicationFrame].size.height
		)
	];

	appView.userInteractionEnabled = YES;
	appView.backgroundColor = [UIColor whiteColor];

	[self registerRouteChangeEvent];

	// Retrieve UIViewController from routes.
	[self changeRoute:Routes.productListView];
	//self.currentRouteViewController = [self.routes GetRouteUIViewController:Routes.productListView];

	//[self addChildViewController: self.currentRouteViewController];
	//[self.view addSubview: self.currentRouteViewController.view];
	//[self.currentRouteViewController didMoveToParentViewController:self];
}

- (void) renderImportApp:(UIApplication *)app {
	UIWindow *window = ([UIApplication sharedApplication].delegate).window;
	// We need to store the original app view controller reference inorder
	// to restore game UI after closing importer app.
	self.gameRootViewController = window.rootViewController;

	// Override the app view.
	self.view.center = window.center;

	// Override the app controller.
	window.rootViewController = self;

	[window addSubview:self.view];
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
		UIWindow *window = ([UIApplication sharedApplication].delegate).window;
		window.rootViewController = self.gameRootViewController;

		[self.view removeFromSuperview];
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
