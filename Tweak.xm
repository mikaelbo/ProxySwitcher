#include <notify.h>
#import "MBWiFiProxyInfo.h"

static BOOL enabled = NO;
static BOOL hasLoadedOnce = NO;
static NSUInteger type = 0;
static MBWiFiProxyInfo *proxyInfo;

@interface SBWiFiManager : NSObject

+ (instancetype)sharedInstance;
- (void)_powerStateDidChange;
- (BOOL)wiFiEnabled;
- (id)currentNetworkName;

@end

%hook _UIAlertControllerView

- (void)setAlertController:(id)controller {
    %orig;
    if ([controller isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alertVC = (UIAlertController *)controller;
        NSString *message = alertVC.message;
        if (!proxyInfo.server.length || !proxyInfo.port || !proxyInfo.username.length || !proxyInfo.password.length) { return; }
        if ([message rangeOfString:proxyInfo.server].location != NSNotFound && [message rangeOfString:[proxyInfo.port stringValue]].location != NSNotFound) {
            if (alertVC.textFields.count > 1) {
                UITextField *usernameField = alertVC.textFields[0];
                UITextField *passwordField = alertVC.textFields[1];
                usernameField.text = proxyInfo.username;
                passwordField.text = proxyInfo.password;
            }
        }
    }
}

%end

// %hook SBWiFiManager

// - (void)_powerStateDidChange {
//     %orig;
//     if ([self wiFiEnabled] && enabled) {
//         notify_post("com.mikaelbo.proxyswitcherd.enable"); 
//     }
// }

// %end



static void networkChanged() {
    if (!enabled) { return; }
    if ([[%c(SBWiFiManager) sharedInstance] wiFiEnabled] && [[%c(SBWiFiManager) sharedInstance] currentNetworkName]) {
        if (type == 1) {
            notify_post("com.mikaelbo.proxyswitcherd.enable"); 
        } else {
            notify_post("com.mikaelbo.proxyswitcherd.disable");
        }
    }
}

static void loadPreferences() {
    CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.mikaelbo.proxyswitcher"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSDictionary *preferences;
    if (keyList) {
        preferences = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList, 
                                                                   CFSTR("com.mikaelbo.proxyswitcher"), 
                                                                   kCFPreferencesCurrentUser, 
                                                                   kCFPreferencesAnyHost);
        if (!preferences) { preferences = [NSDictionary dictionary]; }
        CFRelease(keyList);
        enabled = [preferences objectForKey:@"enabled"] ? [[preferences objectForKey:@"enabled"] boolValue] : NO;
        proxyInfo = [MBWiFiProxyInfo infoFromDictionary:preferences];
        type = [preferences objectForKey:@"type"] ? [[preferences objectForKey:@"type"] integerValue] : 0;
        notify_post("com.mikaelbo.proxyswitcherd.refreshPreferences");
        hasLoadedOnce = YES;
        networkChanged();
    }
}

%ctor {
    // Making the daemon instantly change network settings will make the 
    // WiFi icon initially disappear for some reason
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!hasLoadedOnce) {
            loadPreferences();
        }    
    });
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),\
                                NULL,
                                (CFNotificationCallback)networkChanged,
                                CFSTR("com.apple.system.config.network_change"),
                                NULL,
                                CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
                                    NULL, 
                                    (CFNotificationCallback)loadPreferences, 
                                    CFSTR("com.mikaelbo.proxyswitcher/settingschanged"), 
                                    NULL, 
                                    CFNotificationSuspensionBehaviorCoalesce);

}
