#import "Foundation/Foundation.h"

#import "ProductModel.h"

@implementation ProductModel

- (instancetype) initWithProdName:(NSString *)prodName
	prodID:(NSString *)prodID
	price:(NSNumber *)price
	quantity:(NSNumber *)quantity
{
	self = [super init];
	self.prodName = prodName;
	self.prodID = prodID;
	self.price = price;
	self.quantity = quantity;

	return self;
}
@end
