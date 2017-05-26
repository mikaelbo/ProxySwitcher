#include <notify.h>
#import "MBWiFiProxyInfo.h"
#import "LSStatusBarItem.h"
#import "MBProxyProfilesDisplayer.h"

static BOOL enabled = NO;
static NSUInteger type = 0;
static MBWiFiProxyInfo *proxyInfo;

@interface SBWiFiManager : NSObject

+ (instancetype)sharedInstance;
- (void)_powerStateDidChange;
- (BOOL)wiFiEnabled;
- (id)currentNetworkName;

@end

@interface UIStatusBarItem : NSObject 
@property (nonatomic, readonly) NSString *indicatorName;
@end

@interface UIStatusBarItemView : UIView
@property (nonatomic, strong, readonly) UIStatusBarItem *item;
@end


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
        networkChanged();
    }
}

static void saveNewType() {
    CFPreferencesSetAppValue(CFSTR("type"),
                            CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt16Type, &type),
                            CFSTR("com.mikaelbo.proxyswitcher"));
    networkChanged();
}


static LSStatusBarItem *statusBarItem;

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    if (UIDevice.currentDevice.systemVersion.integerValue >= 10) {
        statusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"com.mikaelbo.proxyswitcher" alignment:StatusBarAlignmentLeft];
        statusBarItem.imageName = @"ProxySwitcher";
        statusBarItem.visible = YES;
    }
    loadPreferences();
}

%end


%hook UIStatusBarItemView

- (id)initWithItem:(id)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4 {
    self = %orig;
    if ([self.item.indicatorName isEqualToString:@"ProxySwitcher"]) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MB_didTapOnView:)]];
    }
    return self;
}

- (void)setUserInteractionEnabled:(BOOL)enabled { 
    [self.item.indicatorName isEqualToString:@"ProxySwitcher"] ? %orig(YES) : %orig;
}

%new
- (void)MB_didTapOnView:(UITapGestureRecognizer *)recognizer {
    NSArray<MBProxyProfile *> *profiles = @[[MBProxyProfile profileWithName:@"Direct" imageName:@"arrow"],
                                            [MBProxyProfile profileWithName:@"Proxy" imageName:@"globe"]];
    [[MBProxyProfilesDisplayer sharedDisplayer] showProxyProfiles:profiles fromFrame:self.frame selectedIndex:type];
    [MBProxyProfilesDisplayer sharedDisplayer].indexChangedCompletion = ^void(NSUInteger index) {
        type = index;
        saveNewType();
    };
}

%end


%hook _UIAlertControllerView

- (void)setAlertController:(id)controller {
    %orig;
    if ([controller isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alertVC = (UIAlertController *)controller;
        NSString *message = alertVC.message;
        if (!proxyInfo.server.length || !proxyInfo.port || !proxyInfo.username.length || !proxyInfo.password.length) { return; }
        if ([message rangeOfString:proxyInfo.server].location != NSNotFound && 
            [message rangeOfString:[proxyInfo.port stringValue]].location != NSNotFound) {
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


%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
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
