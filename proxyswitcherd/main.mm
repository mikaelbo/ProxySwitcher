#import "MBWiFiProxyHandler.h"

static void enable(CFNotificationCenterRef center,
                   void *observer,
                   CFStringRef name,
                   const void *object,
                   CFDictionaryRef userInfo) {
    NSLog(@"ProxySwitcherd: Enable proxy");
    [[MBWiFiProxyHandler sharedInstance] enableProxy];
}

static void disable(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    NSLog(@"ProxySwitcherd: Disable proxy");
    [[MBWiFiProxyHandler sharedInstance] disableProxy];
}

static void refreshPreferences(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    NSLog(@"ProxySwitcherd: Refresh preferences");
    [[MBWiFiProxyHandler sharedInstance] refreshPreferences];
}

int main(int argc, char **argv, char **envp) {
    NSLog(@"ProxySwitcherd: ProxySwitcherd is launched!");
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    enable,
                                    CFSTR("com.mbo42.proxyswitcherd.enable"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    disable,
                                    CFSTR("com.mbo42.proxyswitcherd.disable"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    refreshPreferences,
                                    CFSTR("com.mbo42.proxyswitcherd.refreshPreferences"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);
    CFRunLoopRun();
    return 0;
}
