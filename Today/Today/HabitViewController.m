#import "HabitViewController.h"
#import "TDTaskStore.h"
#import "TDTaskCell.h"
#import "AddTaskViewController.h"
#import "TDThemeManager.h"

static NSString * const TDHabitCellIdentifier = @"TDHabitCellIdentifier";

@interface HabitViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<TDTaskTemplate *> *templates;

@end

@implementation HabitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"habit_title", nil);
    self.view.backgroundColor = [[TDThemeManager sharedManager] backgroundColor];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[TDTaskCell class] forCellReuseIdentifier:TDHabitCellIdentifier];
    [self.view addSubview:tableView];

    [NSLayoutConstraint activateConstraints:@[
        [tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8],
        [tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    self.tableView = tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.templates = [[TDTaskStore sharedStore] allTemplates];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.templates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TDTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:TDHabitCellIdentifier forIndexPath:indexPath];
    TDTaskTemplate *template = self.templates[indexPath.row];
    [cell configureWithEmoji:template.emoji title:template.title completed:NO showsStatus:NO];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TDTaskTemplate *template = self.templates[indexPath.row];
    AddTaskViewController *addTask = [[AddTaskViewController alloc] initWithTemplate:template];
    [self.navigationController pushViewController:addTask animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TDTaskTemplate *template = self.templates[indexPath.row];
        [[TDTaskStore sharedStore] removeTemplateWithId:template.identifier];
        NSMutableArray *mutable = [self.templates mutableCopy];
        [mutable removeObjectAtIndex:indexPath.row];
        self.templates = [mutable copy];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
