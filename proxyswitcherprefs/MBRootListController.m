#import "MBRootListController.h"
#import <Preferences/PSTableCell.h>
#import <Preferences/PSEditableTableCell.h>
#import <Preferences/PSControlTableCell.h>

static CFStringRef settingsChangedNotification = CFSTR("com.mikaelbo.proxyswitcher/settingschanged");

@interface MBRootListController()

@property (nonatomic) BOOL authenticationEnabled;
@property (nonatomic, strong) PSSpecifier *usernameSpecifier;
@property (nonatomic, strong) PSSpecifier *passwordSpecifier;

@end


@implementation MBRootListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self toggleAuthenticationCells:NO];
    [self addFooterView];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(MB_applicationWillEnterForeground) 
                                                 name:UIApplicationWillEnterForegroundNotification 
                                               object:nil];
}

- (void)addFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 144)];
    NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/ProxySwitcher.bundle"];
    UIImage *image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"FooterIcon" ofType:@"png"]];
    CGSize size = image.size;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - size.width) / 2,
                                                                           20,
                                                                           size.width,
                                                                           size.height)];
    imageView.image = image;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [footerView addSubview:imageView];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               imageView.frame.origin.y + imageView.frame.size.height + 4,
                                                               self.view.frame.size.width,
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

    [footerView addSubview:label];
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                      label.frame.origin.y + label.frame.size.height,
                                                                      self.view.frame.size.width,
                                                                      18)];
    versionLabel.font = [UIFont systemFontOfSize:14];
    versionLabel.textColor = [UIColor colorWithRed:204 / 255.0 green:204 / 255.0 blue:204 / 255.0 alpha:1];
    versionLabel.text = @"Version 1.0";
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [footerView addSubview:versionLabel];
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)view;
            tableView.tableFooterView = footerView;
            tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        }
    }
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        self.usernameSpecifier = _specifiers[7];
        self.passwordSpecifier = _specifiers[8];
        [self loadPreferences];
    }
    return _specifiers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:NSClassFromString(@"PSSwitchTableCell")] && indexPath.section == 1 && indexPath.row == 2) {
        if ([cell respondsToSelector:@selector(control)]) {
            UISwitch *theSwitch = [cell performSelector:@selector(control)];
            if ([theSwitch isKindOfClass:[UISwitch class]]) {
                [theSwitch addTarget:self action:@selector(MB_authenticationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            }
        }
    }
    return cell;
}

- (void)MB_applicationWillEnterForeground {
    [self toggleAuthenticationCells:NO];
}

- (void)MB_authenticationSwitchChanged:(UISwitch *)theSwitch {
    self.authenticationEnabled = theSwitch.isOn;
    [self toggleAuthenticationCells:YES];
}

- (void)loadPreferences {
    CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.mikaelbo.proxyswitcher"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSDictionary *preferences;
    if (keyList) {
        preferences = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList,
                                                                         CFSTR("com.mikaelbo.proxyswitcher"),
                                                                         kCFPreferencesCurrentUser,
                                                                         kCFPreferencesAnyHost);
        if (!preferences) { preferences = [NSDictionary dictionary]; }
        CFRelease(keyList);
        self.authenticationEnabled = [preferences objectForKey:@"authentication"] ? [[preferences objectForKey:@"authentication"] boolValue] : NO;
    }
}

- (void)toggleAuthenticationCells:(BOOL)animated {
    if (self.authenticationEnabled) {
        [self insertAuthenticationCellsIfNeeded:animated];
    } else {
        [self removeAuthenticationCellsIfNeeded:animated];
    }
}

- (void)insertAuthenticationCellsIfNeeded:(BOOL)animated {
    NSMutableArray<PSSpecifier *> *insertionArray = [NSMutableArray array];
    if (![self.specifiers containsObject:self.usernameSpecifier]) { [insertionArray addObject:self.usernameSpecifier]; }
    if (![self.specifiers containsObject:self.passwordSpecifier]) { [insertionArray addObject:self.passwordSpecifier]; }
    if (insertionArray.count) {
        [self insertContiguousSpecifiers:insertionArray atEndOfGroup:1 animated:animated];
    }
}

- (void)removeAuthenticationCellsIfNeeded:(BOOL)animated {
    NSMutableArray<PSSpecifier *> *deletionArray = [NSMutableArray array];
    if ([self.specifiers containsObject:self.usernameSpecifier]) { [deletionArray addObject:self.usernameSpecifier]; }
    if ([self.specifiers containsObject:self.passwordSpecifier]) { [deletionArray addObject:self.passwordSpecifier]; }
    if (deletionArray.count) {
        [self removeContiguousSpecifiers:deletionArray animated:animated];
    }
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
            textField.returnKeyType = UIReturnKeyNext;
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
