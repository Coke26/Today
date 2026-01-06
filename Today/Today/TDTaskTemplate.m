#import "TDTaskTemplate.h"

@implementation TDTaskTemplate

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = [[NSUUID UUID] UUIDString];
        _emoji = @"✅";
        _title = @"";
        _priority = TDPriorityMedium;
        _repeatRule = TDRepeatRuleNone;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self) {
        NSString *identifier = dictionary[@"id"];
        if (identifier.length > 0) {
            _identifier = [identifier copy];
        }
        NSString *title = dictionary[@"title"];
        if (title.length > 0) {
            _title = [title copy];
        }
        NSString *emoji = dictionary[@"emoji"];
        if (emoji.length > 0) {
            _emoji = [emoji copy];
        }
        NSNumber *priority = dictionary[@"priority"];
        if (priority != nil) {
            _priority = priority.integerValue;
        }
        NSNumber *repeatRule = dictionary[@"repeat"];
        if (repeatRule != nil) {
            _repeatRule = repeatRule.integerValue;
        }
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
        @"id": self.identifier ?: @"",
        @"title": self.title ?: @"",
        @"emoji": self.emoji ?: @"",
        @"priority": @(self.priority),
        @"repeat": @(self.repeatRule)
    };
}

@end
