#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TDThemeStyle) {
    TDThemeStyleSystem = 0,
    TDThemeStyleDark = 1,
    TDThemeStyleLight = 2
};

@interface TDThemeManager : NSObject

+ (instancetype)sharedManager;
- (void)applyThemeToWindow:(UIWindow *)window;
- (UIColor *)backgroundColor;
- (UIColor *)secondaryBackgroundColor;
- (UIColor *)primaryTextColor;
- (UIColor *)secondaryTextColor;
- (UIColor *)borderColor;

@end
