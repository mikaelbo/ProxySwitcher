#import "MBProxyProfilesDisplayer.h"

@interface MBPopoverPresentationViewController : UIViewController

@property (nonatomic, copy) void (^dismissCompletion)();

@end

@implementation MBPopoverPresentationViewController

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    __weak __typeof(self) weakSelf = self;
    [super dismissViewControllerAnimated:flag completion:^void {
        if (completion) {
            completion();
        }
        if (weakSelf.dismissCompletion) {
            weakSelf.dismissCompletion();
        }
    }];
}

@end

@interface MBProxyProfilesDisplayer () <UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) UIWindow *containerWindow;
@property (nonatomic, strong) UIWindow *previousKeyWindow;

@end


@implementation MBProxyProfilesDisplayer

+ (instancetype)sharedDisplayer {
    static dispatch_once_t onceToken;
    static MBProxyProfilesDisplayer *displayer;
    dispatch_once(&onceToken, ^{
        displayer = [[MBProxyProfilesDisplayer alloc] init];
    });
    return displayer;
}

- (void)showProxyProfiles:(NSArray<MBProxyProfile *> *)profiles fromFrame:(CGRect)frame selectedIndex:(NSUInteger)index {
    self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    MBPopoverPresentationViewController *rootVC = [[MBPopoverPresentationViewController alloc] init];
    rootVC.view.backgroundColor = [UIColor clearColor];
    
    MBProxyProfilesTableViewController *profilesVC = [MBProxyProfilesTableViewController controllerWithProfiles:profiles
                                                                                                  selectedIndex:index];
    
    rootVC.dismissCompletion = ^void() {
        [self hideContainerWindow];
    };
    
    __weak __typeof(profilesVC) weakProfilesVC = profilesVC;
    profilesVC.dismissCompletion = ^void() {
        if (index != weakProfilesVC.selectedIndex && self.indexChangedCompletion) {
            self.indexChangedCompletion(weakProfilesVC.selectedIndex);
        }
        [self hideContainerWindow];
    };
    
    profilesVC.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *presentationController = [profilesVC popoverPresentationController];

    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.sourceView = rootVC.view;
    presentationController.sourceRect = frame;
    presentationController.delegate = self;
    
    self.containerWindow.rootViewController = rootVC;
    [self.containerWindow makeKeyAndVisible];
    
    [rootVC presentViewController:profilesVC animated:YES completion: nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)hideContainerWindow {
    [self.previousKeyWindow makeKeyAndVisible];
    for (UIView *view in self.containerWindow.subviews) {
        [view removeFromSuperview];
    }
    [self.containerWindow removeFromSuperview];
    self.containerWindow = nil;
    self.previousKeyWindow = nil;
}

- (UIWindow *)containerWindow {
    if (!_containerWindow) {
        _containerWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _containerWindow.windowLevel = MAX([UIApplication sharedApplication].keyWindow.windowLevel, UIWindowLevelStatusBar) + 1;
    }
    return _containerWindow;
}

@end
