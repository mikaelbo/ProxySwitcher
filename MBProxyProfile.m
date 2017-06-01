#import "MBProxyProfile.h"

@implementation MBProxyProfile

+ (instancetype)profileWithName:(NSString *)name imageName:(NSString *)imageName {
    return [[self alloc] initWithName:name imageName:imageName];
}

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName {
    if (self = [super init]) {
        _name = name;
        _imageName = imageName;
    }
    return self;
}

@end