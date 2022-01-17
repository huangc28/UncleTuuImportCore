#import "Foundation/Foundation.h"

#import "ProductModel.h"

@interface ProductListViewController : UIViewController {
	NSArray<ProductModel *> *_products;
	UIScrollView *_scrollView;
	UIStackView *_prodsStackView;
	UIView *_contentView;
}

@property(retain, nonatomic, readwrite) NSArray<ProductModel *> *products; //@synthesize products=_products
@property(retain, nonatomic) UIScrollView *scrollView; //@synthesize scrollView=_scrollView
@property(retain, nonatomic) UIStackView *prodsStackView; //@synthesize prodsStackView=_prodsStackView

@property(retain, nonatomic) UIView *contentView; //@synthesize contentView=_contentView

@end
