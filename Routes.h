#import "Foundation/Foundation.h"
#import "UIKit/UIKit.h"

@interface Routes : NSObject {
	// Store view controller for toggling purpose.
	NSMutableDictionary<NSString*, UIViewController*> *_routes;
}

+ (instancetype) sharedInstance;
+ (NSString*) productListView;
+ (NSString*) purchasedRecordsView;
+ (NSString*) importFailedView;
- (id)GetRouteUIViewController:(NSString *)routeName;

@property(strong, nonatomic) NSMutableDictionary<NSString*, UIViewController*> *routes; // @synthesize routes=_routes

@end
