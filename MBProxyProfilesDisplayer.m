#import "MBProxyProfilesDisplayer.h"
#import "MBChooseProxyProfileView.h"

#define IS_IOS8 UIDevice.currentDevice.systemVersion.integerValue < 9

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

@interface MBProxyProfilesDisplayer () <UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate>

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
    
    rootVC.dismissCompletion = ^void() {
        [self hideContainerWindow];
    };
    
    if (IS_IOS8) {
        MBChooseProxyProfileView *view = [MBChooseProxyProfileView viewWithProfiles:profiles selectedIndex:index];
        [view addToView:rootVC.view withTargetCenter:CGPointMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height)];
        __weak __typeof(view) weakView = view;
        view.dismissCompletion = ^{
            if (index != weakView.selectedIndex && self.indexChangedCompletion) {
                self.indexChangedCompletion(weakView.selectedIndex);
            }
            [self dismissiOS8Overlay:YES];
        };
        self.containerWindow.rootViewController = rootVC;
        [self.containerWindow makeKeyAndVisible];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOverlayBackground)];
        tapRecognizer.delegate = self;
        [self.containerWindow addGestureRecognizer:tapRecognizer];
        return;
    }
    
    MBProxyProfilesTableViewController *profilesVC = [MBProxyProfilesTableViewController controllerWithProfiles:profiles
                                                                                                  selectedIndex:index];
    
    
    
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

#pragma mark - Tap gesture

- (void)didTapOverlayBackground {
    if (self.containerWindow) {
        [self dismissiOS8Overlay:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (!self.containerWindow) { return NO; }
    UIView *overlay;
    for (UIView *view in self.containerWindow.rootViewController.view.subviews) {
        if ([view isKindOfClass:[MBChooseProxyProfileView class]]) {
            overlay = view;
            break;
        }
    }
    if (overlay && [touch.view isDescendantOfView:overlay]) {
        return NO;
    }
    return YES;
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

#pragma mark - ContainerWindow

- (void)hideProxyProfilesIfNeeded {
    if (self.containerWindow) {
        if (IS_IOS8) {
            [self dismissiOS8Overlay:NO];
        } else {
            [self.containerWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
        }
    }
}

- (void)dismissiOS8Overlay:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.25 : 0 animations:^{
        self.containerWindow.alpha = 0;
    } completion:^(BOOL finished) {
        [self hideContainerWindow];
    }];
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
