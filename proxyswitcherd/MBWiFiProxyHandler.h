@interface MBWiFiProxyHandler : NSObject

@property (nonatomic, strong, readonly) NSDictionary *preferences;

+ (instancetype)sharedInstance;

- (void)enableProxy;
- (void)disableProxy;
- (void)refreshPreferences;

@end
