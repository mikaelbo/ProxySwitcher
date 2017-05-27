#import "MBRootListController.h"
#import <Preferences/PSTableCell.h>
#import <Preferences/PSEditableTableCell.h>

static CFStringRef settingsChangedNotification = CFSTR("com.mikaelbo.proxyswitcher/settingschanged");

@interface MBRootListController()

@property (nonatomic, strong) PSSpecifier *usernameSpecifier;
@property (nonatomic, strong) PSSpecifier *passwordSpecifier;

@end


@implementation MBRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        self.usernameSpecifier = _specifiers[6];
        self.passwordSpecifier = _specifiers[7];
	}
	return _specifiers;
}

- (void)contactMe {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:mbo@mbo42.com"]];
}

- (void)sendFeedback {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:mbo@mbo42.com?subject=ProxySwitcher"]];
}

- (void)viewSourceCode {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/mikaelbo/ProxySwitcher"]];
}

- (void)dealloc {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         settingsChangedNotification,
                                         NULL,
                                         NULL,
                                         true);
}

@end


@interface MBTextFieldCell : PSEditableTableCell

@end

@implementation MBTextFieldCell

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            textField.textAlignment = NSTextAlignmentRight;
        }
    }
}

@end


@interface MBPasswordTextFieldCell : PSEditableTableCell

@end

@implementation MBPasswordTextFieldCell

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            textField.textAlignment = NSTextAlignmentRight;
            textField.returnKeyType = UIReturnKeyDone;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
