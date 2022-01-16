#import "Foundation/Foundation.h"

#import "SharedLibraries/Product.h"

@interface ProductViewController : UIViewController {
	Product *_data;
	UIStackView *_prodView;
}

- (instancetype)initWithData:(Product *)product;

@property(retain, nonatomic) Product *data; // @synthesize data=_data
@property(retain, nonatomic) UIStackView *prodView; // @synthesize prodView=_prodView

@end
