#import "MBWiFiProxyHandler.h"
#import "SCNetworkHeader.h"

@interface NSDictionary<KeyType, ObjectType> (Getters)

- (nullable NSString*)stringForKeySafely:(nullable KeyType)key;
- (nullable NSNumber*)numberForKeySafely:(nullable KeyType)key;

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

- (NSNumber*)numberFromString:(NSString*)string {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

@end

@implementation MBWiFiProxyHandler

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MBWiFiProxyHandler *handler;
    dispatch_once(&onceToken, ^{
        handler = [[MBWiFiProxyHandler alloc] init];
    });
    return handler;
}

- (void)refreshPreferences { 
    _preferences = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.mbo42.proxyswitcher.plist"];
}

- (void)enableProxy {
    [self updateProxy:YES];
}

- (void)disableProxy {
    [self updateProxy:NO];
}

- (void)updateProxy:(BOOL)enabled {
    SCPreferencesRef prefRef = SCPreferencesCreate(NULL, CFSTR("proxy_switcher"), NULL);
    SCPreferencesLock(prefRef, true);
    CFStringRef currentSetPath = SCPreferencesGetValue(prefRef, kSCPrefCurrentSet);

    NSDictionary *currentSet = (__bridge NSDictionary *)SCPreferencesPathGetValue(prefRef, currentSetPath);

    if (currentSet) {
        NSDictionary *currentSetServices = currentSet[cfs2nss(kSCCompNetwork)][cfs2nss(kSCCompService)];
        NSDictionary *services = (__bridge NSDictionary *)SCPreferencesGetValue(prefRef, kSCPrefNetworkServices);

        NSString *wifiServiceKey = nil;
        for (NSString *key in currentSetServices) {
            NSDictionary *service = services[key];
            NSString *name = service[cfs2nss(kSCPropUserDefinedName)];
            if (service && [@"Wi-Fi" isEqualToString:name]) {
                wifiServiceKey = key;
                break;
            }
        }

        if (wifiServiceKey) {
            NSData *data = [NSPropertyListSerialization dataWithPropertyList:services
                                                                      format:NSPropertyListBinaryFormat_v1_0
                                                                     options:0
                                                                       error:nil];
            NSMutableDictionary *nservices = [NSPropertyListSerialization propertyListWithData:data
                                                                                       options:NSPropertyListMutableContainersAndLeaves
                                                                                        format:NULL
                                                                                         error:nil];
            NSMutableDictionary *proxies = nservices[wifiServiceKey][(__bridge NSString *)kSCEntNetProxies];
            BOOL didChange = NO;
            if (enabled) {
                if (!self.preferences) { [self refreshPreferences]; }
                NSString *server = [self.preferences stringForKeySafely:@"server"];
                NSNumber *port = [self.preferences numberForKeySafely:@"port"];
                if (server && port) {
                    BOOL shouldChange = [self shouldChangeProxyDict:proxies withServer:server port:port];
                    NSLog(@"Should change proxy: %d", shouldChange);
                   if (shouldChange) {
                        [proxies setObject:@(1) forKey:cfs2nss(kSCPropNetProxiesHTTPEnable)];
                        [proxies setObject:server forKey:cfs2nss(kSCPropNetProxiesHTTPProxy)];
                        [proxies setObject:port forKey:cfs2nss(kSCPropNetProxiesHTTPPort)];
                        [proxies setObject:@(1) forKey:cfs2nss(kSCPropNetProxiesHTTPSEnable)];
                        [proxies setObject:server forKey:cfs2nss(kSCPropNetProxiesHTTPSProxy)];
                        [proxies setObject:port forKey:cfs2nss(kSCPropNetProxiesHTTPSPort)];
                        didChange = YES;
                   }
                    //TODO: Save credentials to keychain
                }
            } else {
                if (proxies.count) {
                    NSLog(@"Remove proxy settings");
                    [proxies removeAllObjects];
                    didChange = YES;
                }
            }
            if (didChange) {
                NSLog(@"DID CHANGE");
                SCPreferencesSetValue(prefRef, kSCPrefNetworkServices, (__bridge CFPropertyListRef)nservices);
                SCPreferencesCommitChanges(prefRef);
                SCPreferencesApplyChanges(prefRef);
            }
        }
    }
    SCPreferencesUnlock(prefRef);
    CFRelease(prefRef);
}

- (BOOL)shouldChangeProxyDict:(NSDictionary *)proxyDict withServer:(NSString *)server port:(NSNumber *)port {
   return
   ![[proxyDict objectForKey:cfs2nss(kSCPropNetProxiesHTTPEnable)] isEqualToNumber:@1]        ||
   ![[proxyDict objectForKey:cfs2nss(kSCPropNetProxiesHTTPProxy)] isEqualToString:server]     ||
   ![[proxyDict objectForKey:cfs2nss(kSCPropNetProxiesHTTPPort)] isEqualToNumber:port]        ||
   ![[proxyDict objectForKey:cfs2nss(kSCPropNetProxiesHTTPSEnable)] isEqualToNumber:@1]       ||
   ![[proxyDict objectForKey:cfs2nss(kSCPropNetProxiesHTTPSProxy)] isEqualToString:server]    ||
   ![[proxyDict objectForKey:cfs2nss(kSCPropNetProxiesHTTPSPort)] isEqualToNumber:port];
}

@end
