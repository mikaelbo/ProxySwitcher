#import "MBChooseProxyProfileView.h"

#define TOP_HEIGHT 12

@interface MBChooseProxyProfileView() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) CAShapeLayer *outlineLayer;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;

@property (nonatomic) CGPoint currentCenter;
@property (nonatomic) CGRect previousBounds;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation MBChooseProxyProfileView

+ (instancetype)viewWithProfiles:(NSArray<MBProxyProfile *> *)profiles selectedIndex:(NSUInteger)selectedIndex {
    return [[self alloc] initWithProfiles:profiles selectedIndex:selectedIndex];
}

- (instancetype)initWithProfiles:(NSArray<MBProxyProfile *> *)profiles selectedIndex:(NSUInteger)selectedIndex {
    if (self = [super init]) {
        _profiles = profiles;
        _selectedIndex = selectedIndex;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureView];
    }
    return self;
}

- (void)configureView {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView * visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.backgroundView.bounds;
    visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.backgroundView addSubview:visualEffectView];
    
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.backgroundView];
    [self addSubview:self.contentView];
    [self createTableView];
}

- (void)createTableView {
    self.tableView = [[UITableView alloc] init];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.rowHeight = 54;
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.contentInset = UIEdgeInsetsMake(TOP_HEIGHT, 0, 0, 0);
    [self.contentView addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

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
    if (indexPath.row != self.profiles.count - 1) {
        CGFloat height = 1 / [UIScreen mainScreen].scale;
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                         tableView.rowHeight - height,
                                                                         tableView.bounds.size.width,
                                                                         height)];
        separatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [cell.contentView addSubview:separatorView];
    }
    if (indexPath.row == self.selectedIndex) {
        UIImage *image = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"Checkmark" ofType:@"png"]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        cell.accessoryView = imageView;
    } else {
        cell.accessoryView = nil;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath.row;
    if (self.dismissCompletion) {
        self.dismissCompletion();
    }
}

#pragma mark - Mask

- (void)addToView:(UIView *)view withTargetCenter:(CGPoint)targetCenter {
    if ((CGPointEqualToPoint(targetCenter, self.currentCenter) &&
        CGRectEqualToRect(self.bounds, self.previousBounds)) ||
        !self.profiles.count) {
        return;
    }
    [view addSubview:self];
    
    CGFloat wantedHeight = self.tableView.rowHeight * self.profiles.count + TOP_HEIGHT;
    CGFloat wantedWidth = view.frame.size.width * 0.6;
    
    CGFloat wantedX = targetCenter.x - wantedWidth / 2;
    CGFloat padding = 8;
    
    if (wantedX <= padding) {
        wantedX = padding;
    } else if (wantedX >= view.bounds.size.width - wantedWidth - padding) {
        wantedX = view.bounds.size.width - wantedWidth - padding;
    }
    
    self.frame = CGRectMake(wantedX, targetCenter.y, wantedWidth, wantedHeight);
    UIBezierPath *path = [self pathForBounds:self.bounds targetCenter:targetCenter.x - wantedX];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    
    self.layer.mask = mask;
    self.outlineLayer.path = path.CGPath;
    self.backgroundLayer.frame = self.backgroundView.layer.bounds;
    self.currentCenter = targetCenter;
    self.previousBounds = self.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (UIBezierPath *)pathForBounds:(CGRect)bounds targetCenter:(CGFloat)targetCenter {
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = CGRectGetHeight(bounds);
    CGFloat arcRadius = 14;
    CGFloat topHeight = TOP_HEIGHT;
    CGFloat triagleWidth = 12;
    CGFloat minimumCenterInset = arcRadius + triagleWidth + 5;
    
    if (targetCenter > width - minimumCenterInset) {
        targetCenter = width - minimumCenterInset;
    } else if (targetCenter < minimumCenterInset) {
        targetCenter = minimumCenterInset;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];

    // left bottom corner
    [path moveToPoint:CGPointMake(arcRadius, height)];
    [path addArcWithCenter:CGPointMake(arcRadius, height - arcRadius) radius:arcRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    
    // left top corner
    [path addArcWithCenter:CGPointMake(arcRadius, arcRadius + topHeight) radius:arcRadius startAngle:M_PI endAngle:M_PI + M_PI_2 clockwise:YES];
    
    // triangle
    [path addLineToPoint:CGPointMake(targetCenter - triagleWidth , topHeight)];
    [path addLineToPoint:CGPointMake(targetCenter, 0)];
    [path addLineToPoint:CGPointMake(targetCenter + triagleWidth, topHeight)];
    
    // right top corner
    [path addArcWithCenter:CGPointMake(width - arcRadius, arcRadius + topHeight) radius:arcRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [path addLineToPoint:CGPointMake(width, height - arcRadius)];
    
    // right bottom corner
    [path addArcWithCenter:CGPointMake(width - arcRadius, height - arcRadius) radius:arcRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(arcRadius, height)];
    
    [path closePath];
    return path.copy;
}

#pragma mark - Getters

- (CAShapeLayer *)outlineLayer {
    if (!_outlineLayer) {
        _outlineLayer = [CAShapeLayer layer];
        _outlineLayer.lineWidth = 1 / [UIScreen mainScreen].scale;
        _outlineLayer.fillColor = [UIColor clearColor].CGColor;
        _outlineLayer.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
        [self.layer addSublayer:_outlineLayer];
    }
    return _outlineLayer;
}

- (CAShapeLayer *)backgroundLayer {
    if (!_backgroundLayer) {
        _backgroundLayer = [CAShapeLayer layer];
        [self.backgroundView.layer addSublayer:_backgroundLayer];
    }
    return _backgroundLayer;
}

- (NSBundle *)bundle {
    if (!_bundle) {
        _bundle = [[NSBundle alloc] initWithPath:@"/Library/Application Support/ProxySwitcher/ProxySwitcherBundle.bundle"];
    }
    return _bundle;
}


@end
