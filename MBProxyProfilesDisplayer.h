#import <Foundation/Foundation.h>
#import "MBProxyProfilesTableViewController.h"

@interface MBProxyProfilesDisplayer : NSObject

@property (nonatomic, copy) void (^indexChangedCompletion)(NSUInteger index);

+ (instancetype)sharedDisplayer;

- (void)showProxyProfiles:(NSArray<MBProxyProfile *> *)profiles fromFrame:(CGRect)frame selectedIndex:(NSUInteger)index;
- (void)hideProxyProfilesIfNeeded;

@end
