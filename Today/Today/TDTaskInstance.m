#import "TDTaskInstance.h"

@implementation TDTaskInstance

- (instancetype)init {
    self = [super init];
    if (self) {
        _templateId = @"";
        _dateKey = @"";
        _completed = NO;
        _sortOrder = 0;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self) {
        NSString *templateId = dictionary[@"templateId"];
        if (templateId.length > 0) {
            _templateId = [templateId copy];
        }
        NSString *dateKey = dictionary[@"dateKey"];
        if (dateKey.length > 0) {
            _dateKey = [dateKey copy];
        }
        NSNumber *completed = dictionary[@"completed"];
        if (completed != nil) {
            _completed = completed.boolValue;
        }
        NSNumber *sortOrder = dictionary[@"order"];
        if (sortOrder != nil) {
            _sortOrder = sortOrder.integerValue;
        }
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
        @"templateId": self.templateId ?: @"",
        @"dateKey": self.dateKey ?: @"",
        @"completed": @(self.completed),
        @"order": @(self.sortOrder)
    };
}

@end
