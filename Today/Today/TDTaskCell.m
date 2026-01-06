#import "TDTaskCell.h"
#import "TDThemeManager.h"

@interface TDTaskCell ()

@property (nonatomic, strong) UILabel *emojiLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation TDTaskCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _emojiLabel = [[UILabel alloc] init];
        _emojiLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
        _emojiLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        _statusLabel.textAlignment = NSTextAlignmentRight;
        _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;

        UIView *cardView = [[UIView alloc] init];
        cardView.translatesAutoresizingMaskIntoConstraints = NO;
        cardView.layer.cornerRadius = 12;
        cardView.layer.masksToBounds = YES;
        cardView.tag = 1001;

        [self.contentView addSubview:cardView];
        [cardView addSubview:_emojiLabel];
        [cardView addSubview:_titleLabel];
        [cardView addSubview:_statusLabel];

        [NSLayoutConstraint activateConstraints:@[
            [cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:6],
            [cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-6],

            [_emojiLabel.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:12],
            [_emojiLabel.centerYAnchor constraintEqualToAnchor:cardView.centerYAnchor],

            [_titleLabel.leadingAnchor constraintEqualToAnchor:_emojiLabel.trailingAnchor constant:12],
            [_titleLabel.centerYAnchor constraintEqualToAnchor:cardView.centerYAnchor],
            [_titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_statusLabel.leadingAnchor constant:-12],

            [_statusLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-12],
            [_statusLabel.centerYAnchor constraintEqualToAnchor:cardView.centerYAnchor]
        ]];
    }
    return self;
}

- (void)configureWithEmoji:(NSString *)emoji title:(NSString *)title completed:(BOOL)completed showsStatus:(BOOL)showsStatus {
    UIView *cardView = [self.contentView viewWithTag:1001];
    TDThemeManager *theme = [TDThemeManager sharedManager];
    cardView.backgroundColor = [theme secondaryBackgroundColor];
    BOOL isDark = UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    cardView.layer.borderWidth = isDark ? 0 : 1;
    cardView.layer.borderColor = [theme borderColor].CGColor;

    self.emojiLabel.text = emoji ?: @"";
    self.titleLabel.text = title ?: @"";
    self.titleLabel.textColor = [theme primaryTextColor];
    self.statusLabel.textColor = completed ? [UIColor systemGreenColor] : [theme secondaryTextColor];
    self.statusLabel.text = completed ? NSLocalizedString(@"status_done", nil) : NSLocalizedString(@"status_todo", nil);
    self.statusLabel.hidden = !showsStatus;
}

@end
