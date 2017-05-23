@interface MBWiFiProxyInfo : NSObject

@property (nonatomic, copy, readonly) NSString *server;
@property (nonatomic, strong, readonly) NSNumber *port;
@property (nonatomic, copy, readonly) NSString *username;
@property (nonatomic, copy, readonly) NSString *password;

+ (instancetype)infoWithServer:(NSString *)server
                          port:(NSNumber *)port
                      username:(NSString *)username
                      password:(NSString *)password;

+ (instancetype)infoFromDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithServer:(NSString *)server
                          port:(NSNumber *)port
                      username:(NSString *)username
                      password:(NSString *)password;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;

@end
