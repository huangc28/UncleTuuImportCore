#import "ProductViewController.h"

#import "SharedLibraries/ProductViewElementCreator.h"

@interface ProductViewController ()<UIGestureRecognizerDelegate>
@end

@implementation ProductViewController

- (instancetype)initWithData:(Product *)product {
	self = [super init];

	if (self) {
		self.data = product;
	}

	return self;
}

- (void) viewDidLoad {
	[super viewDidLoad];

	@try {
		self.view = self.createProdRow;

		UITapGestureRecognizer *singleFingerTap = [
			[UITapGestureRecognizer alloc]
				initWithTarget:self
								action:@selector(handleTap:)
		];

		[self.view addGestureRecognizer:singleFingerTap];
		singleFingerTap.delegate = self;
	} @catch (NSException *exception) {
	   NSLog(@"DEBUG* exception %@", exception.reason);
	}
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
	// Emit productName to listener to perform pay operation.
	NSDictionary *nProdID = [NSDictionary dictionaryWithObject:self.data.prodID forKey:@"prodID"];

	dispatch_async(dispatch_get_main_queue(), ^{
		[
			[NSNotificationCenter defaultCenter]
				postNotificationName:@"notifyInappPayment"
											object:nil
										userInfo:nProdID
		];
	});
}

// TODO remove gesture recognizer.
- (void) dealloc {
  self.data = nil;
  self.prodView = nil;
}

- (UIStackView *) createProdRow {
	UIStackView *row = [ProductViewElementCreator createRow];

	// Product name.
	UILabel *nameLabel = [ProductViewElementCreator createLabel:self.data.prodName];

	// Price.
	UILabel *priceLabel = [
		ProductViewElementCreator
			createLabel:[[NSString alloc]initWithFormat: @"%@", self.data.price]
	];

	// Quantity.
	UILabel *quantityLabel = [
		ProductViewElementCreator
			createLabel:[[NSString alloc]initWithFormat: @"%@", self.data.quantity]
	];

	[row addArrangedSubview:nameLabel];
	[row addArrangedSubview:priceLabel];
	[row addArrangedSubview:quantityLabel];

	return row;
}

@end
