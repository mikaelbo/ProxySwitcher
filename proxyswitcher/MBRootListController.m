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


@interface MBFooterCell : PSTableCell

@end

@implementation MBFooterCell

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FooterCell" specifier:specifier]) {
        NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/ProxySwitcher.bundle"];
        UIImage *image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"FooterIcon" ofType:@"png"]];
        CGSize size = image.size;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - size.width) / 2,
                                                                               40,
                                                                               size.width,
                                                                               size.height)];
        imageView.image = image;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:imageView];
    
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   imageView.frame.origin.y + imageView.frame.size.height + 4,
                                                                   self.frame.size.width,
                                                                   24)];
        label.text = @"ProxySwitcher";

        if ([UIFont instancesRespondToSelector:@selector(systemFontOfSize:weight:)]) {
            label.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
        } else {
            label.font = [UIFont boldSystemFontOfSize:20];
        }

        label.textColor = [UIColor colorWithRed:204 / 255.0 green:204 / 255.0 blue:204 / 255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [self.contentView addSubview:label];
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          label.frame.origin.y + label.frame.size.height,
                                                                          self.frame.size.width,
                                                                          18)];
        versionLabel.font = [UIFont systemFontOfSize:14];
        versionLabel.textColor = [UIColor colorWithRed:204 / 255.0 green:204 / 255.0 blue:204 / 255.0 alpha:1];
        versionLabel.text = @"Version 0.0.1";
        versionLabel.textAlignment = NSTextAlignmentCenter;
        versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:versionLabel];

    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    return 144;
}

@end


