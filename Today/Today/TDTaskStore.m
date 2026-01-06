#import "TDTaskStore.h"

NSString * const TDThemePreferenceKey = @"TDThemePreference";
NSString * const TDLanguagePreferenceKey = @"TDLanguagePreference";

static NSString * const TDTemplatesKey = @"TDTemplatesKey";
static NSString * const TDInstancesKeyPrefix = @"TDInstances_";
static NSString * const TDAppGroupSuiteName = @"group.com.today.app";

@interface TDTaskStore ()

@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation TDTaskStore

+ (instancetype)sharedStore {
    static TDTaskStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[TDTaskStore alloc] initPrivate];
    });
    return store;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        NSUserDefaults *groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:TDAppGroupSuiteName];
        _defaults = groupDefaults ?: [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (NSArray<TDTaskTemplate *> *)allTemplates {
    NSArray *stored = [self.defaults arrayForKey:TDTemplatesKey] ?: @[];
    NSMutableArray<TDTaskTemplate *> *templates = [NSMutableArray array];
    for (NSDictionary *item in stored) {
        TDTaskTemplate *template = [[TDTaskTemplate alloc] initWithDictionary:item];
        [templates addObject:template];
    }
    return templates;
}

- (void)saveTemplates:(NSArray<TDTaskTemplate *> *)templates {
    NSMutableArray *payload = [NSMutableArray array];
    for (TDTaskTemplate *template in templates) {
        [payload addObject:[template dictionaryRepresentation]];
    }
    [self.defaults setObject:payload forKey:TDTemplatesKey];
}

- (NSArray<TDTaskInstance *> *)instancesForDateKey:(NSString *)dateKey {
    NSString *key = [TDInstancesKeyPrefix stringByAppendingString:dateKey ?: @""];
    NSArray *stored = [self.defaults arrayForKey:key] ?: @[];
    NSMutableArray<TDTaskInstance *> *instances = [NSMutableArray array];
    for (NSDictionary *item in stored) {
        TDTaskInstance *instance = [[TDTaskInstance alloc] initWithDictionary:item];
        [instances addObject:instance];
    }
    return instances;
}

- (void)saveInstances:(NSArray<TDTaskInstance *> *)instances forDateKey:(NSString *)dateKey {
    NSString *key = [TDInstancesKeyPrefix stringByAppendingString:dateKey ?: @""];
    NSMutableArray *payload = [NSMutableArray array];
    for (TDTaskInstance *instance in instances) {
        [payload addObject:[instance dictionaryRepresentation]];
    }
    [self.defaults setObject:payload forKey:key];
}

- (void)removeTemplateWithId:(NSString *)templateId {
    if (templateId.length == 0) {
        return;
    }
    NSArray<TDTaskTemplate *> *templates = [self allTemplates];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(TDTaskTemplate *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ![evaluatedObject.identifier isEqualToString:templateId];
    }];
    NSArray<TDTaskTemplate *> *filtered = [templates filteredArrayUsingPredicate:predicate];
    [self saveTemplates:filtered];

    NSDictionary *storedKeys = [self.defaults dictionaryRepresentation];
    for (NSString *key in storedKeys) {
        if ([key hasPrefix:TDInstancesKeyPrefix]) {
            NSArray *instances = [self.defaults arrayForKey:key] ?: @[];
            NSMutableArray *filteredInstances = [NSMutableArray array];
            for (NSDictionary *item in instances) {
                if (![item[@"templateId"] isEqualToString:templateId]) {
                    [filteredInstances addObject:item];
                }
            }
            [self.defaults setObject:filteredInstances forKey:key];
        }
    }
}

- (void)clearAllData {
    NSDictionary *storedKeys = [self.defaults dictionaryRepresentation];
    for (NSString *key in storedKeys) {
        if ([key hasPrefix:TDInstancesKeyPrefix] || [key isEqualToString:TDTemplatesKey]) {
            [self.defaults removeObjectForKey:key];
        }
    }
}

- (void)setThemePreference:(NSInteger)theme {
    [self.defaults setInteger:theme forKey:TDThemePreferenceKey];
}

- (NSInteger)themePreference {
    return [self.defaults integerForKey:TDThemePreferenceKey];
}

- (void)setLanguagePreference:(NSString *)language {
    [self.defaults setObject:language forKey:TDLanguagePreferenceKey];
}

- (NSString *)languagePreference {
    NSString *value = [self.defaults stringForKey:TDLanguagePreferenceKey];
    return value.length > 0 ? value : @"system";
}

@end
