#import "TDThemeManager.h"
#import "TDTaskStore.h"

@implementation TDThemeManager

+ (instancetype)sharedManager {
    static TDThemeManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TDThemeManager alloc] init];
    });
    return manager;
}

- (void)applyThemeToWindow:(UIWindow *)window {
    NSInteger theme = [[TDTaskStore sharedStore] themePreference];
    if (theme == TDThemeStyleDark) {
        window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    } else if (theme == TDThemeStyleLight) {
        window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    } else {
        window.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
    }
}

- (UIColor *)backgroundColor {
    if ([self isDarkMode]) {
        return [UIColor colorWithWhite:0.07 alpha:1.0];
    }
    return [UIColor whiteColor];
}

- (UIColor *)secondaryBackgroundColor {
    if ([self isDarkMode]) {
        return [UIColor colorWithWhite:0.14 alpha:1.0];
    }
    return [UIColor colorWithWhite:0.98 alpha:1.0];
}

- (UIColor *)primaryTextColor {
    if ([self isDarkMode]) {
        return [UIColor whiteColor];
    }
    return [UIColor colorWithRed:0.07 green:0.13 blue:0.2 alpha:1.0];
}

- (UIColor *)secondaryTextColor {
    if ([self isDarkMode]) {
        return [UIColor colorWithWhite:0.8 alpha:1.0];
    }
    return [UIColor colorWithWhite:0.5 alpha:1.0];
}

- (UIColor *)borderColor {
    return [UIColor colorWithRed:0.07 green:0.13 blue:0.2 alpha:1.0];
}

- (BOOL)isDarkMode {
    NSInteger theme = [[TDTaskStore sharedStore] themePreference];
    if (theme == TDThemeStyleDark) {
        return YES;
    }
    if (theme == TDThemeStyleLight) {
        return NO;
    }
    return UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
}

@end
