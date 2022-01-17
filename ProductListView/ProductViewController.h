#import "Foundation/Foundation.h"

#import "ProductModel.h"

@interface ProductViewController : UIViewController {
	ProductModel *_data;
	UIStackView *_prodView;
}

- (instancetype)initWithData:(ProductModel *)product;

@property(retain, nonatomic) ProductModel *data; // @synthesize data=_data
@property(retain, nonatomic) UIStackView *prodView; // @synthesize prodView=_prodView

@end
