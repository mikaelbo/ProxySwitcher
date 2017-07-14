@interface UIStatusBarItem : NSObject 
@property (nonatomic, readonly) NSString *indicatorName;
@end

@interface UIStatusBarItemView : UIView
@property (nonatomic, strong, readonly) UIStatusBarItem *item;
@end


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
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), 
                                         CFSTR("com.mikaelbo.proxyswitcheruikit/didTapOnStatusBar"),  
                                        NULL, 
                                        NULL, 
                                        YES);
}

%end
