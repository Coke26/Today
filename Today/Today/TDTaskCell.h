#import <UIKit/UIKit.h>

@interface TDTaskCell : UITableViewCell

- (void)configureWithEmoji:(NSString *)emoji title:(NSString *)title completed:(BOOL)completed showsStatus:(BOOL)showsStatus;

@end
