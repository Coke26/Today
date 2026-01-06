#import "TodayViewController.h"
#import "HabitViewController.h"
#import "TDTaskCell.h"
#import "TDTaskStore.h"
#import "TDThemeManager.h"
#import "TDTaskTemplate.h"
#import "TDTaskInstance.h"

static NSString * const TDTaskCellIdentifier = @"TDTaskCellIdentifier";

@interface TodayViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *dateTitleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIStackView *dateStrip;
@property (nonatomic, strong) NSArray<NSDate *> *visibleDates;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSArray<TDTaskInstance *> *instances;
@property (nonatomic, strong) NSDictionary<NSString *, TDTaskTemplate *> *templateMap;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[TDThemeManager sharedManager] backgroundColor];
    self.navigationItem.titleView = [self buildTitleView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"checklist"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(openHabits)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"calendar"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(resetToToday)];

    [self setupDateStrip];
    [self setupTableView];
    [self loadTemplates];
    [self resetToToday];

    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadTemplates];
    [self reloadInstances];
}

- (UIView *)buildTitleView {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    label.textColor = [[TDThemeManager sharedManager] primaryTextColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:label];
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:container.centerYAnchor]
    ]];
    self.dateTitleLabel = label;
    return container;
}

- (void)setupDateStrip {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.distribution = UIStackViewDistributionFillEqually;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 8;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *stripContainer = [[UIView alloc] init];
    stripContainer.translatesAutoresizingMaskIntoConstraints = NO;
    stripContainer.backgroundColor = [[TDThemeManager sharedManager] secondaryBackgroundColor];
    stripContainer.layer.cornerRadius = 12;
    stripContainer.layer.masksToBounds = YES;

    [stripContainer addSubview:stack];
    [self.view addSubview:stripContainer];

    [NSLayoutConstraint activateConstraints:@[
        [stripContainer.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [stripContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [stripContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [stripContainer.heightAnchor constraintEqualToConstant:40],

        [stack.leadingAnchor constraintEqualToAnchor:stripContainer.leadingAnchor constant:12],
        [stack.trailingAnchor constraintEqualToAnchor:stripContainer.trailingAnchor constant:-12],
        [stack.topAnchor constraintEqualToAnchor:stripContainer.topAnchor],
        [stack.bottomAnchor constraintEqualToAnchor:stripContainer.bottomAnchor]
    ]];

    self.dateStrip = stack;
}

- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[TDTaskCell class] forCellReuseIdentifier:TDTaskCellIdentifier];

    [self.view addSubview:tableView];

    [NSLayoutConstraint activateConstraints:@[
        [tableView.topAnchor constraintEqualToAnchor:self.dateStrip.superview.bottomAnchor constant:12],
        [tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [tableView addGestureRecognizer:longPress];

    self.tableView = tableView;
}

- (void)loadTemplates {
    NSArray<TDTaskTemplate *> *templates = [[TDTaskStore sharedStore] allTemplates];
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    for (TDTaskTemplate *template in templates) {
        map[template.identifier] = template;
    }
    self.templateMap = map;
}

- (void)resetToToday {
    self.selectedDate = [NSDate date];
    [self updateVisibleDates];
    [self refreshTitle];
    [self reloadInstances];
}

- (void)updateVisibleDates {
    NSMutableArray *dates = [NSMutableArray array];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *baseDate = self.selectedDate ?: [NSDate date];
    for (NSInteger offset = -2; offset <= 2; offset++) {
        NSDate *date = [calendar dateByAddingUnit:NSCalendarUnitDay value:offset toDate:baseDate options:0];
        [dates addObject:date];
    }
    self.visibleDates = dates;
    [self configureDateStrip];
}

- (void)configureDateStrip {
    for (UIView *view in self.dateStrip.arrangedSubviews) {
        [self.dateStrip removeArrangedSubview:view];
        [view removeFromSuperview];
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE · d";

    for (NSDate *date in self.visibleDates) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.layer.cornerRadius = 10;
        button.layer.masksToBounds = YES;
        button.contentEdgeInsets = UIEdgeInsetsMake(6, 8, 6, 8);
        button.tag = [self.visibleDates indexOfObject:date];
        NSString *title = [formatter stringFromDate:date];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
        [self applyDateButtonStyle:button date:date];
        [self.dateStrip addArrangedSubview:button];
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger delta = gesture.direction == UISwipeGestureRecognizerDirectionLeft ? 1 : -1;
    self.selectedDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:delta toDate:self.selectedDate options:0];
    [self refreshTitle];
    [self reloadInstances];
    [self updateVisibleDates];
}

- (void)applyDateButtonStyle:(UIButton *)button date:(NSDate *)date {
    TDThemeManager *theme = [TDThemeManager sharedManager];
    BOOL isSelected = [self isSameDay:date other:self.selectedDate];
    button.backgroundColor = isSelected ? [theme borderColor] : [UIColor clearColor];
    UIColor *titleColor = isSelected ? [UIColor whiteColor] : [theme secondaryTextColor];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
}

- (void)selectDate:(UIButton *)sender {
    if (sender.tag < self.visibleDates.count) {
        self.selectedDate = self.visibleDates[sender.tag];
        [self refreshTitle];
        [self reloadInstances];
        for (UIButton *button in self.dateStrip.arrangedSubviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                NSDate *date = self.visibleDates[button.tag];
                [self applyDateButtonStyle:button date:date];
            }
        }
    }
}

- (void)refreshTitle {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM d";
    self.dateTitleLabel.text = [formatter stringFromDate:self.selectedDate];
}

- (void)reloadInstances {
    NSString *dateKey = [self dateKeyFromDate:self.selectedDate];
    NSArray<TDTaskInstance *> *instances = [[TDTaskStore sharedStore] instancesForDateKey:dateKey];
    self.instances = [self sortInstances:instances];
    [self.tableView reloadData];
}

- (NSArray<TDTaskInstance *> *)sortInstances:(NSArray<TDTaskInstance *> *)instances {
    NSArray *templates = [[TDTaskStore sharedStore] allTemplates];
    NSMutableDictionary *priorityMap = [NSMutableDictionary dictionary];
    for (TDTaskTemplate *template in templates) {
        priorityMap[template.identifier] = @(template.priority);
    }
    return [instances sortedArrayUsingComparator:^NSComparisonResult(TDTaskInstance *a, TDTaskInstance *b) {
        NSNumber *priorityA = priorityMap[a.templateId] ?: @(TDPriorityMedium);
        NSNumber *priorityB = priorityMap[b.templateId] ?: @(TDPriorityMedium);
        if (priorityA.integerValue != priorityB.integerValue) {
            return priorityA.integerValue < priorityB.integerValue ? NSOrderedDescending : NSOrderedAscending;
        }
        if (a.sortOrder == b.sortOrder) {
            return NSOrderedSame;
        }
        return a.sortOrder < b.sortOrder ? NSOrderedAscending : NSOrderedDescending;
    }];
}

- (NSString *)dateKeyFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:date];
}

- (BOOL)isSameDay:(NSDate *)date other:(NSDate *)other {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar isDate:date inSameDayAsDate:other];
}

- (void)openHabits {
    HabitViewController *habit = [[HabitViewController alloc] init];
    [self.navigationController pushViewController:habit animated:YES];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.instances.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TDTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:TDTaskCellIdentifier forIndexPath:indexPath];
    TDTaskInstance *instance = self.instances[indexPath.row];
    TDTaskTemplate *template = self.templateMap[instance.templateId];
    [cell configureWithEmoji:template.emoji title:template.title completed:instance.completed showsStatus:YES];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TDTaskInstance *instance = self.instances[indexPath.row];
    instance.completed = !instance.completed;
    [self persistInstances];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *mutable = [self.instances mutableCopy];
        [mutable removeObjectAtIndex:indexPath.row];
        self.instances = [mutable copy];
        [self persistInstances];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            if (indexPath) {
                [self.tableView beginUpdates];
                [self.tableView beginInteractiveMovementForRowAtIndexPath:indexPath];
            }
            break;
        case UIGestureRecognizerStateChanged:
            [self.tableView updateInteractiveMovementTargetPosition:location];
            break;
        case UIGestureRecognizerStateEnded:
            [self.tableView endInteractiveMovement];
            [self.tableView endUpdates];
            [self persistInstances];
            break;
        default:
            [self.tableView cancelInteractiveMovement];
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *mutable = [self.instances mutableCopy];
    TDTaskInstance *instance = mutable[sourceIndexPath.row];
    [mutable removeObjectAtIndex:sourceIndexPath.row];
    [mutable insertObject:instance atIndex:destinationIndexPath.row];
    self.instances = [mutable copy];
    [self persistInstances];
}

- (void)persistInstances {
    NSMutableArray<TDTaskInstance *> *mutable = [self.instances mutableCopy];
    [mutable enumerateObjectsUsingBlock:^(TDTaskInstance * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.sortOrder = idx;
    }];
    self.instances = [mutable copy];
    NSString *dateKey = [self dateKeyFromDate:self.selectedDate];
    [[TDTaskStore sharedStore] saveInstances:self.instances forDateKey:dateKey];
}

@end
