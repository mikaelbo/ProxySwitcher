@interface MBProxyProfile : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *imageName;

+ (instancetype)profileWithName:(NSString *)name imageName:(NSString *)imageName;
- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName;

@end