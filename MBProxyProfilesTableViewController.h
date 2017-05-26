#import <UIKit/UIKit.h>

@interface MBProxyProfile : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *imageName;

+ (instancetype)profileWithName:(NSString *)name imageName:(NSString *)imageName;
- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName;

@end


@interface MBProxyProfilesTableViewController : UITableViewController

@property (nonatomic, strong, readonly) NSArray<MBProxyProfile *> *profiles;
@property (nonatomic, readonly) NSUInteger selectedIndex;
@property (nonatomic, copy) void (^dismissCompletion)();

+ (instancetype)controllerWithProfiles:(NSArray<MBProxyProfile *> *)profiles selectedIndex:(NSUInteger)selectedIndex;
- (instancetype)initWithProfiles:(NSArray<MBProxyProfile *> *)profiles selectedIndex:(NSUInteger)selectedIndex;

@end
