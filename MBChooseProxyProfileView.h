#import <UIKit/UIKit.h>
#import "MBProxyProfilesTableViewController.h"

@interface MBChooseProxyProfileView : UIView

@property (nonatomic, strong, readonly) NSArray<MBProxyProfile *> *profiles;
@property (nonatomic, readonly) NSUInteger selectedIndex;
@property (nonatomic, copy) void (^dismissCompletion)();

+ (instancetype)viewWithProfiles:(NSArray<MBProxyProfile *> *)profiles selectedIndex:(NSUInteger)selectedIndex;
- (instancetype)initWithProfiles:(NSArray<MBProxyProfile *> *)profiles selectedIndex:(NSUInteger)selectedIndex;

- (void)addToView:(UIView *)view withTargetCenter:(CGPoint)targetCenter;

@end
