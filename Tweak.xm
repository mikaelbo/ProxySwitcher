#include <notify.h>
#import "MBWiFiProxyInfo.h"
#import "LSStatusBarItem.h"
#import "MBProxyProfilesDisplayer.h"

static BOOL enabled = NO;
static BOOL alwaysShow = YES;
static NSUInteger type = 0;
static MBWiFiProxyInfo *proxyInfo;
static LSStatusBarItem *statusBarItem;

@interface SBWiFiManager : NSObject
+ (instancetype)sharedInstance;
- (void)_powerStateDidChange;
- (NSString *)currentNetworkName;
- (BOOL)wiFiEnabled;
@end

@interface RadiosPreferences : NSObject
@property (nonatomic) BOOL airplaneMode;
@end

@interface UIStatusBarItem : NSObject 
@property (nonatomic, readonly) NSString *indicatorName;
@end

@interface UIStatusBarItemView : UIView
@property (nonatomic, strong, readonly) UIStatusBarItem *item;
@end

static BOOL canShowStatusBarIcon() {
    return alwaysShow ? YES : [[%c(SBWiFiManager) sharedInstance] wiFiEnabled] && [[%c(SBWiFiManager) sharedInstance] currentNetworkName];
}

static void updateStatusBarImage() {
    statusBarItem.imageName = type > 0 ? @"ProxySwitcher" : @"ProxySwitcherUnselected";
}

static void setStatusBarVisible(BOOL visible) {
    statusBarItem.visible = enabled && canShowStatusBarIcon() ? visible : NO; 
}

static void networkChanged() {
    if (!enabled) { return; }
    setStatusBarVisible(![[[%c(RadiosPreferences) alloc] init] airplaneMode]);
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
        alwaysShow = [preferences objectForKey:@"alwaysShow"] ? [[preferences objectForKey:@"alwaysShow"] boolValue] : YES;
        proxyInfo = [MBWiFiProxyInfo infoFromDictionary:preferences];
        type = [preferences objectForKey:@"type"] ? [[preferences objectForKey:@"type"] integerValue] : 0;
        notify_post("com.mikaelbo.proxyswitcherd.refreshPreferences");
        setStatusBarVisible(![[[%c(RadiosPreferences) alloc] init] airplaneMode]);
        updateStatusBarImage();
        networkChanged();
    }
}

static void saveNewType() {
    CFPreferencesSetAppValue(CFSTR("type"),
                            CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt16Type, &type),
                            CFSTR("com.mikaelbo.proxyswitcher"));
    networkChanged();
    updateStatusBarImage();
}

static void hideProfilesOverlayIfNeeded() {
    [[MBProxyProfilesDisplayer sharedDisplayer] hideProxyProfilesIfNeeded];
}

static void toggleProxy() {
    type = !type ? 1 : 0;
    saveNewType();
}


%hook SBUIController

- (BOOL)handleMenuDoubleTap {
    hideProfilesOverlayIfNeeded();
    return %orig;
}

- (BOOL)isHandlingHomeButtonPress {
    hideProfilesOverlayIfNeeded();
    return %orig;
}

- (_Bool)clickedMenuButton {
    hideProfilesOverlayIfNeeded();
    return %orig;
}

%end


%hook SBHomeHardwareButton

- (void)doubleTapUp:(id)arg1 {
    hideProfilesOverlayIfNeeded();
    %orig;
}

- (void)doublePressUp:(id)arg1 {
    hideProfilesOverlayIfNeeded();
    %orig;
}

- (void)singlePressUp:(id)arg1 {
    hideProfilesOverlayIfNeeded();
    %orig;
}

%end


%hook SBBulletinRootViewController // NotificationCenter

- (void)viewWillAppear:(BOOL)animated {
    hideProfilesOverlayIfNeeded();
    %orig;
}

%end


%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    statusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"com.mikaelbo.proxyswitcher" alignment:StatusBarAlignmentRight];
    statusBarItem.imageName = @"ProxySwitcher";
    loadPreferences();
}

- (void)frontDisplayDidChange:(id)arg1 { // App launch, screen lock, etc
    hideProfilesOverlayIfNeeded();
    %orig;
}

%end


%hook RadiosPreferences

- (void)setAirplaneMode:(BOOL)airplaneMode {
    %orig;
    setStatusBarVisible(!airplaneMode);
}

%end


%hook UIStatusBarItemView

- (id)initWithItem:(id)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4 {
    self = %orig;
    if ([self.item.indicatorName isEqualToString:@"ProxySwitcher"] || [self.item.indicatorName isEqualToString:@"ProxySwitcherUnselected"]) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MB_didTapOnView:)]];
    }
    return self;
}

- (void)setUserInteractionEnabled:(BOOL)enabled { 
    NSString *indicatorName = self.item.indicatorName;
    BOOL hasProxySwitcherItem = [indicatorName isEqualToString:@"ProxySwitcher"] || [indicatorName isEqualToString:@"ProxySwitcherUnselected"];
    hasProxySwitcherItem ? %orig(YES) : %orig;
}

%new
- (void)MB_didTapOnView:(UITapGestureRecognizer *)recognizer {
    toggleProxy();
    // NSArray<MBProxyProfile *> *profiles = @[[MBProxyProfile profileWithName:@"Direct" imageName:@"arrow"],
    //                                         [MBProxyProfile profileWithName:@"Proxy" imageName:@"globe"]];
    // [[MBProxyProfilesDisplayer sharedDisplayer] showProxyProfiles:profiles fromFrame:self.frame selectedIndex:type];
    // [MBProxyProfilesDisplayer sharedDisplayer].indexChangedCompletion = ^void(NSUInteger index) {
    //     type = index;
    //     saveNewType();
    // };
}

%end

// %hook UIStatusBarItem

// - (int)leftOrder {
//     %log;
//     NSLog(@"%d", %orig);
//     return [self.indicatorName isEqualToString:@"ProxySwitcher"] ? 3 : %orig;
// }

// - (int)priorty {
//     %log;
//     return %orig;
// }

// %end

static void showMenu(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    toggleProxy();
}


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
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
                                    NULL, 
                                    (CFNotificationCallback)showMenu, 
                                    CFSTR("com.mikaelbo.proxyswitcheruikit/didTapOnStatusBar"), 
                                    NULL, 
                                    CFNotificationSuspensionBehaviorCoalesce);
}
