#import "SettingsViewController.h"
#import "DonationViewController.h"
#import "TDTaskStore.h"
#import "TDThemeManager.h"

typedef NS_ENUM(NSInteger, TDSettingsSection) {
    TDSettingsSectionDonation = 0,
    TDSettingsSectionPreferences = 1,
    TDSettingsSectionInfo = 2,
    TDSettingsSectionDanger = 3
};

@interface SettingsViewController ()

@property (nonatomic, strong) NSArray<NSString *> *languages;
@property (nonatomic, strong) NSArray<NSString *> *themes;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"settings_title", nil);
    self.tableView.backgroundColor = [[TDThemeManager sharedManager] backgroundColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.languages = @[NSLocalizedString(@"lang_zh_hans", nil), NSLocalizedString(@"lang_zh_hant", nil), NSLocalizedString(@"lang_en", nil)];
    self.themes = @[NSLocalizedString(@"theme_auto", nil), NSLocalizedString(@"theme_dark", nil), NSLocalizedString(@"theme_light", nil)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case TDSettingsSectionDonation:
            return 1;
        case TDSettingsSectionPreferences:
            return 2;
        case TDSettingsSectionInfo:
            return 2;
        case TDSettingsSectionDanger:
            return 1;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TDSettingsSectionDonation:
            return NSLocalizedString(@"settings_section_donation", nil);
        case TDSettingsSectionPreferences:
            return NSLocalizedString(@"settings_section_preferences", nil);
        case TDSettingsSectionInfo:
            return NSLocalizedString(@"settings_section_info", nil);
        case TDSettingsSectionDanger:
            return NSLocalizedString(@"settings_section_danger", nil);
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SettingsCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [[TDThemeManager sharedManager] primaryTextColor];
        cell.detailTextLabel.textColor = [[TDThemeManager sharedManager] secondaryTextColor];
        cell.backgroundColor = [[TDThemeManager sharedManager] secondaryBackgroundColor];
        cell.layer.cornerRadius = 12;
        cell.layer.masksToBounds = YES;
    }

    switch (indexPath.section) {
        case TDSettingsSectionDonation:
            cell.textLabel.text = NSLocalizedString(@"settings_donation", nil);
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case TDSettingsSectionPreferences:
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"settings_language", nil);
                cell.detailTextLabel.text = [self currentLanguageLabel];
            } else {
                cell.textLabel.text = NSLocalizedString(@"settings_theme", nil);
                cell.detailTextLabel.text = [self currentThemeLabel];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case TDSettingsSectionInfo:
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"settings_version", nil);
                cell.detailTextLabel.text = [self appVersion];
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                cell.textLabel.text = NSLocalizedString(@"settings_tips", nil);
                cell.detailTextLabel.text = @"";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        case TDSettingsSectionDanger:
            cell.textLabel.text = NSLocalizedString(@"settings_reset", nil);
            cell.textLabel.textColor = [UIColor systemRedColor];
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case TDSettingsSectionDonation:
            [self openDonation];
            break;
        case TDSettingsSectionPreferences:
            if (indexPath.row == 0) {
                [self showLanguagePicker];
            } else {
                [self showThemePicker];
            }
            break;
        case TDSettingsSectionInfo:
            if (indexPath.row == 1) {
                UIViewController *tips = [[UIViewController alloc] init];
                tips.view.backgroundColor = [[TDThemeManager sharedManager] backgroundColor];
                tips.title = NSLocalizedString(@"settings_tips", nil);
                [self.navigationController pushViewController:tips animated:YES];
            }
            break;
        case TDSettingsSectionDanger:
            [self confirmReset];
            break;
        default:
            break;
    }
}

- (void)openDonation {
    DonationViewController *donation = [[DonationViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:donation];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showLanguagePicker {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"settings_language", nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *values = @[@"zh-Hans", @"zh-Hant", @"en"];
    [values enumerateObjectsUsingBlock:^(NSString *value, NSUInteger idx, BOOL *stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:self.languages[idx]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
            [[TDTaskStore sharedStore] setLanguagePreference:value];
            [self.tableView reloadData];
        }];
        [alert addAction:action];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showThemePicker {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"settings_theme", nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *values = @[@(TDThemeStyleSystem), @(TDThemeStyleDark), @(TDThemeStyleLight)];
    [values enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:self.themes[idx]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
            [[TDTaskStore sharedStore] setThemePreference:value.integerValue];
            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            [[TDThemeManager sharedManager] applyThemeToWindow:window];
            [self.tableView reloadData];
        }];
        [alert addAction:action];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirmReset {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"settings_reset", nil)
                                                                   message:NSLocalizedString(@"settings_reset_warning", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil)
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction * _Nonnull action) {
        [[TDTaskStore sharedStore] clearAllData];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:confirm];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)appVersion {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @"";
    return [NSString stringWithFormat:@"%@ (%@)", version, build];
}

- (NSString *)currentLanguageLabel {
    NSString *lang = [[TDTaskStore sharedStore] languagePreference];
    if ([lang isEqualToString:@"zh-Hans"]) {
        return self.languages[0];
    }
    if ([lang isEqualToString:@"zh-Hant"]) {
        return self.languages[1];
    }
    return self.languages[2];
}

- (NSString *)currentThemeLabel {
    NSInteger theme = [[TDTaskStore sharedStore] themePreference];
    if (theme == TDThemeStyleDark) {
        return self.themes[1];
    }
    if (theme == TDThemeStyleLight) {
        return self.themes[2];
    }
    return self.themes[0];
}

@end
