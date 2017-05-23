#import "MBRootListController.h"

static CFStringRef settingsChangedNotification = CFSTR("com.mikaelbo.proxyswitcher/settingschanged");

@implementation MBRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

- (void)dealloc {
    NSLog(@"DEALLOC");
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         settingsChangedNotification,
                                         NULL,
                                         NULL,
                                         true);
}

@end
