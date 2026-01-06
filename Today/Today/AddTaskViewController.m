#import "AddTaskViewController.h"
#import "TDTaskStore.h"
#import "TDTaskTemplate.h"
#import "TDTaskInstance.h"
#import "TDThemeManager.h"

@interface AddTaskViewController ()

@property (nonatomic, strong) TDTaskTemplate *templateModel;
@property (nonatomic, strong) UISegmentedControl *priorityControl;
@property (nonatomic, strong) UISegmentedControl *repeatControl;
@property (nonatomic, strong) UIButton *emojiButton;
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation AddTaskViewController

- (instancetype)initWithTemplate:(TDTaskTemplate *)template {
    self = [super init];
    if (self) {
        _templateModel = template ?: [[TDTaskTemplate alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[TDThemeManager sharedManager] backgroundColor];
    self.title = NSLocalizedString(@"add_title", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                                                                           target:self
                                                                                           action:@selector(close)];

    [self setupForm];
    [self populateForm];
}

- (void)setupForm {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 20;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *priorityLabel = [self labelWithText:NSLocalizedString(@"add_priority", nil)];
    UISegmentedControl *priority = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"priority_high", nil),
        NSLocalizedString(@"priority_medium", nil),
        NSLocalizedString(@"priority_low", nil)
    ]];
    priority.selectedSegmentIndex = 1;
    [priority addTarget:self action:@selector(priorityChanged:) forControlEvents:UIControlEventValueChanged];

    UILabel *emojiLabel = [self labelWithText:NSLocalizedString(@"add_emoji", nil)];
    UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeSystem];
    emojiButton.layer.cornerRadius = 12;
    emojiButton.layer.masksToBounds = YES;
    emojiButton.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightSemibold];
    [emojiButton addTarget:self action:@selector(selectEmoji) forControlEvents:UIControlEventTouchUpInside];
    emojiButton.backgroundColor = [[TDThemeManager sharedManager] secondaryBackgroundColor];

    UILabel *titleLabel = [self labelWithText:NSLocalizedString(@"add_title_label", nil)];
    UITextField *titleField = [[UITextField alloc] init];
    titleField.borderStyle = UITextBorderStyleRoundedRect;
    titleField.backgroundColor = [[TDThemeManager sharedManager] secondaryBackgroundColor];
    titleField.textColor = [[TDThemeManager sharedManager] primaryTextColor];
    titleField.placeholder = NSLocalizedString(@"add_title_placeholder", nil);

    UILabel *repeatLabel = [self labelWithText:NSLocalizedString(@"add_repeat", nil)];
    UISegmentedControl *repeat = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"repeat_none", nil),
        NSLocalizedString(@"repeat_daily", nil),
        NSLocalizedString(@"repeat_weekday", nil),
        NSLocalizedString(@"repeat_monthly", nil)
    ]];
    repeat.selectedSegmentIndex = 0;

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    saveButton.layer.cornerRadius = 14;
    saveButton.layer.masksToBounds = YES;
    saveButton.backgroundColor = [[TDThemeManager sharedManager] borderColor];
    [saveButton setTitle:NSLocalizedString(@"add_save", nil) forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    [saveButton addTarget:self action:@selector(saveTask) forControlEvents:UIControlEventTouchUpInside];

    UIView *priorityContainer = [self containerWithView:priority];
    UIView *emojiContainer = [self containerWithView:emojiButton];
    UIView *titleContainer = [self containerWithView:titleField];
    UIView *repeatContainer = [self containerWithView:repeat];

    [stack addArrangedSubview:priorityLabel];
    [stack addArrangedSubview:priorityContainer];
    [stack addArrangedSubview:emojiLabel];
    [stack addArrangedSubview:emojiContainer];
    [stack addArrangedSubview:titleLabel];
    [stack addArrangedSubview:titleContainer];
    [stack addArrangedSubview:repeatLabel];
    [stack addArrangedSubview:repeatContainer];
    [stack addArrangedSubview:saveButton];

    [self.view addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:24],
        [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];

    self.priorityControl = priority;
    self.repeatControl = repeat;
    self.emojiButton = emojiButton;
    self.titleField = titleField;
    self.saveButton = saveButton;
}

- (UILabel *)labelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    label.textColor = [[TDThemeManager sharedManager] primaryTextColor];
    return label;
}

- (UIView *)containerWithView:(UIView *)view {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor clearColor];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:view];
    [NSLayoutConstraint activateConstraints:@[
        [view.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [view.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [view.topAnchor constraintEqualToAnchor:container.topAnchor],
        [view.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],
        [view.heightAnchor constraintGreaterThanOrEqualToConstant:44]
    ]];
    return container;
}

- (void)populateForm {
    if (self.templateModel.priority == TDPriorityHigh) {
        self.priorityControl.selectedSegmentIndex = 0;
    } else if (self.templateModel.priority == TDPriorityMedium) {
        self.priorityControl.selectedSegmentIndex = 1;
    } else {
        self.priorityControl.selectedSegmentIndex = 2;
    }
    self.repeatControl.selectedSegmentIndex = self.templateModel.repeatRule;
    [self.emojiButton setTitle:self.templateModel.emoji forState:UIControlStateNormal];
    self.titleField.text = self.templateModel.title;
}

- (void)priorityChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.templateModel.priority = TDPriorityHigh;
    } else if (sender.selectedSegmentIndex == 1) {
        self.templateModel.priority = TDPriorityMedium;
    } else {
        self.templateModel.priority = TDPriorityLow;
    }
}

- (void)selectEmoji {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"add_emoji", nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *emojis = @[ @"📌", @"📚", @"💪", @"🧘", @"🧠", @"🎯", @"🧹" ];
    for (NSString *emoji in emojis) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:emoji style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.templateModel.emoji = emoji;
            [self.emojiButton setTitle:emoji forState:UIControlStateNormal];
        }];
        [alert addAction:action];
    }
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveTask {
    self.templateModel.title = self.titleField.text ?: @"";
    self.templateModel.repeatRule = self.repeatControl.selectedSegmentIndex;
    [self priorityChanged:self.priorityControl];

    NSMutableArray *templates = [[[TDTaskStore sharedStore] allTemplates] mutableCopy];
    NSUInteger index = [templates indexOfObjectPassingTest:^BOOL(TDTaskTemplate *obj, NSUInteger idx, BOOL *stop) {
        return [obj.identifier isEqualToString:self.templateModel.identifier];
    }];
    if (index != NSNotFound) {
        templates[index] = self.templateModel;
    } else {
        [templates addObject:self.templateModel];
    }
    [[TDTaskStore sharedStore] saveTemplates:templates];

    if (self.templateModel.repeatRule != TDRepeatRuleNone) {
        NSString *dateKey = [self dateKeyFromDate:[NSDate date]];
        NSMutableArray<TDTaskInstance *> *instances = [[[TDTaskStore sharedStore] instancesForDateKey:dateKey] mutableCopy];
        BOOL exists = NO;
        for (TDTaskInstance *instance in instances) {
            if ([instance.templateId isEqualToString:self.templateModel.identifier]) {
                exists = YES;
                break;
            }
        }
        if (!exists) {
            TDTaskInstance *instance = [[TDTaskInstance alloc] init];
            instance.templateId = self.templateModel.identifier;
            instance.dateKey = dateKey;
            instance.sortOrder = instances.count;
            [instances addObject:instance];
            [[TDTaskStore sharedStore] saveInstances:instances forDateKey:dateKey];
        }
    }

    if (self.navigationController.presentingViewController && self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)dateKeyFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:date];
}

- (void)close {
    if (self.navigationController.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
