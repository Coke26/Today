#import "DonationViewController.h"
#import "TDThemeManager.h"

@interface DonationViewController ()

@property (nonatomic, strong) UISegmentedControl *amountControl;

@end

@implementation DonationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[TDThemeManager sharedManager] backgroundColor];
    self.title = NSLocalizedString(@"donation_title", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose
                                                                                           target:self
                                                                                           action:@selector(close)];

    UILabel *title = [[UILabel alloc] init];
    title.text = NSLocalizedString(@"donation_subtitle", nil);
    title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    title.textColor = [[TDThemeManager sharedManager] primaryTextColor];
    title.translatesAutoresizingMaskIntoConstraints = NO;

    UISegmentedControl *amount = [[UISegmentedControl alloc] initWithItems:@[@"6", @"30", @"68"]];
    amount.selectedSegmentIndex = 0;
    amount.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *confirm = [UIButton buttonWithType:UIButtonTypeSystem];
    confirm.layer.cornerRadius = 14;
    confirm.layer.masksToBounds = YES;
    confirm.backgroundColor = [[TDThemeManager sharedManager] borderColor];
    [confirm setTitle:NSLocalizedString(@"donation_confirm", nil) forState:UIControlStateNormal];
    [confirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirm.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    confirm.translatesAutoresizingMaskIntoConstraints = NO;
    [confirm addTarget:self action:@selector(confirmDonation) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:title];
    [self.view addSubview:amount];
    [self.view addSubview:confirm];

    [NSLayoutConstraint activateConstraints:@[
        [title.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:40],
        [title.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],

        [amount.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:20],
        [amount.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [amount.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40],

        [confirm.topAnchor constraintEqualToAnchor:amount.bottomAnchor constant:30],
        [confirm.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [confirm.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40],
        [confirm.heightAnchor constraintEqualToConstant:50]
    ]];

    self.amountControl = amount;
}

- (void)confirmDonation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"donation_confirm", nil)
                                                                   message:NSLocalizedString(@"donation_placeholder", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
