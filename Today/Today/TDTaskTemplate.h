#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TDPriority) {
    TDPriorityLow = 0,
    TDPriorityMedium = 1,
    TDPriorityHigh = 2
};

typedef NS_ENUM(NSInteger, TDRepeatRule) {
    TDRepeatRuleNone = 0,
    TDRepeatRuleDaily = 1,
    TDRepeatRuleWeekday = 2,
    TDRepeatRuleMonthly = 3
};

@interface TDTaskTemplate : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *emoji;
@property (nonatomic, assign) TDPriority priority;
@property (nonatomic, assign) TDRepeatRule repeatRule;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;

@end
