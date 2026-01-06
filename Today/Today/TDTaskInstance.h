#import <Foundation/Foundation.h>

@interface TDTaskInstance : NSObject

@property (nonatomic, copy) NSString *templateId;
@property (nonatomic, copy) NSString *dateKey;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, assign) NSInteger sortOrder;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;

@end
