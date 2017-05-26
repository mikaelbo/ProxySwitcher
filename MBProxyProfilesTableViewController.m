#import "MBProxyProfilesTableViewController.h"

@implementation MBProxyProfile

+ (instancetype)profileWithName:(NSString *)name imageName:(NSString *)imageName {
    return [[self alloc] initWithName:name imageName:imageName];
}

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName {
    if (self = [super init]) {
        _name = name;
        _imageName = imageName;
    }
    return self;
}

@end

@interface MBProxyProfilesTableViewController ()

@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation MBProxyProfilesTableViewController

+ (instancetype)controllerWithProfiles:(NSArray<MBProxyProfile *> *)profiles selectedIndex:(NSUInteger)selectedIndex {
    return [[self alloc] initWithProfiles:profiles selectedIndex:selectedIndex];
}

- (instancetype)initWithProfiles:(NSArray<MBProxyProfile *> *)profiles  selectedIndex:(NSUInteger)selectedIndex{
    if (self = [super init]) {
        _profiles = profiles;
        _selectedIndex = selectedIndex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    CGFloat rowHeight = 54;
    self.tableView.rowHeight = rowHeight;
    self.tableView.bounces = NO;
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
//    self.tableView.separatorColor = [UIColor colorWithRed:161 / 255.0 green:209 / 255.0 blue:225 / 255.0 alpha:1];
    self.tableView.separatorColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    CGSize size = self.view.bounds.size;
    CGFloat width = size.width < size.height ? size.width : size.height;
    self.preferredContentSize = CGSizeMake(width * 0.6, rowHeight * self.profiles.count);
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.profiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    MBProxyProfile *profile = self.profiles[indexPath.row];
    cell.textLabel.text = profile.name;
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.imageView.image = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:profile.imageName ofType:@"png"]];
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.row == self.selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath.row;
    [self dismissViewControllerAnimated:YES completion:nil];
}

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

- (NSBundle *)bundle {
    if (!_bundle) {
        _bundle = [[NSBundle alloc] initWithPath:@"/Library/Application Support/ProxySwitcher/ProxySwitcherBundle.bundle"];
    }
    return _bundle;
}

@end
