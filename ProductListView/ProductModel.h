#import "Foundation/Foundation.h"

@interface ProductModel : NSObject {
	NSString *_prodName;
	NSString *_prodID;
	NSNumber *_price;
	NSNumber *_quantity;
}

- (instancetype) initWithProdName:(NSString *)prodName
	prodID:(NSString *)prodID
	price:(NSNumber *)price
	quantity:(NSNumber *)quantity;

@property(retain, nonatomic) NSString* prodName; // @synthesize prodName=_prodName;
@property(retain, nonatomic) NSString* prodID; // @synthesize prodID=_prodID;
@property(retain, nonatomic) NSNumber* price; // @synthesize price=_price;
@property(retain, nonatomic) NSNumber* quantity; // @synthesize quantity=_quantity

@end
