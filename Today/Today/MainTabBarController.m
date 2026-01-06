#import "MainTabBarController.h"
#import "TodayViewController.h"
#import "AddTaskViewController.h"
#import "SettingsViewController.h"

@interface MainTabBarController () <UITabBarControllerDelegate>

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;

    TodayViewController *today = [[TodayViewController alloc] init];
    UINavigationController *todayNav = [[UINavigationController alloc] initWithRootViewController:today];
    todayNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tab_today", nil)
                                                        image:[UIImage systemImageNamed:@"list.bullet"]
                                                selectedImage:[UIImage systemImageNamed:@"list.bullet"]];

    UIViewController *addPlaceholder = [[UIViewController alloc] init];
    addPlaceholder.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tab_add", nil)
                                                              image:[UIImage systemImageNamed:@"plus.circle.fill"]
                                                      selectedImage:[UIImage systemImageNamed:@"plus.circle.fill"]];

    SettingsViewController *settings = [[SettingsViewController alloc] init];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settings];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tab_settings", nil)
                                                           image:[UIImage systemImageNamed:@"gearshape"]
                                                   selectedImage:[UIImage systemImageNamed:@"gearshape.fill"]];

    self.viewControllers = @[todayNav, addPlaceholder, settingsNav];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSUInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index == 1) {
        AddTaskViewController *addTask = [[AddTaskViewController alloc] initWithTemplate:nil];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addTask];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
        return NO;
    }

    if (tabBarController.selectedViewController == viewController && index == 0) {
        [self selectTodayTabAndReset];
    }
    return YES;
}

- (void)selectTodayTabAndReset {
    UINavigationController *nav = (UINavigationController *)self.viewControllers.firstObject;
    if ([nav.topViewController isKindOfClass:[TodayViewController class]]) {
        TodayViewController *today = (TodayViewController *)nav.topViewController;
        [today resetToToday];
    }
}

@end
