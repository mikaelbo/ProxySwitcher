#import "MBWiFiProxyInfo.h"

@interface NSDictionary<KeyType, ObjectType> (Getters)

- (nullable NSString *)stringForKeySafely:(nullable KeyType)key;
- (nullable NSNumber *)numberForKeySafely:(nullable KeyType)key;

@end

@implementation NSDictionary (Getters)

- (NSString *)stringForKeySafely:(id)key {
    id string = [self objectForKey:key];
    if ([string isKindOfClass:[NSString class]]) { return string; }
    if ([string isKindOfClass:[NSNumber class]]) { return [NSString stringWithFormat:@"%@", string]; }
    return nil;
}

- (NSNumber *)numberForKeySafely:(id)key {
    id number = [self objectForKey:key];
    if ([number isKindOfClass:[NSNumber class]]) { return number; }
    if ([number isKindOfClass:[NSString class]]) { return [self numberFromString:(NSString *)number]; }
    return nil;
}

- (NSNumber *)numberFromString:(NSString *)string {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

@end

@implementation MBWiFiProxyInfo

+ (instancetype)infoWithServer:(NSString *)server port:(NSNumber *)port username:(nullable NSString *)username password:(nullable NSString *)password {
    return [[self alloc] initWithServer:server port:port username:username password:password];
}

+ (instancetype)infoFromDictionary:(NSDictionary *)dictionary {
    return [[self alloc] initFromDictionary:dictionary];
}

- (instancetype)initWithServer:(NSString *)server port:(NSNumber *)port username:(nullable NSString *)username password:(nullable NSString *)password {
    if (self = [super init]) {
        _server = server;
        _port = port;
        _username = username;
        _password = password;
    }
    return self;
}

- (instancetype)initFromDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _server = [dictionary stringForKeySafely:@"server"];
        _port = [dictionary numberForKeySafely:@"port"];
        _username = [dictionary stringForKeySafely:@"username"];
        _password = [dictionary stringForKeySafely:@"password"];
    }
    return self;
}

@end
