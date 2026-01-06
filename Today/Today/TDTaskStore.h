#import <Foundation/Foundation.h>
#import "TDTaskTemplate.h"
#import "TDTaskInstance.h"

extern NSString * const TDThemePreferenceKey;
extern NSString * const TDLanguagePreferenceKey;

@interface TDTaskStore : NSObject

+ (instancetype)sharedStore;

- (NSArray<TDTaskTemplate *> *)allTemplates;
- (void)saveTemplates:(NSArray<TDTaskTemplate *> *)templates;

- (NSArray<TDTaskInstance *> *)instancesForDateKey:(NSString *)dateKey;
- (void)saveInstances:(NSArray<TDTaskInstance *> *)instances forDateKey:(NSString *)dateKey;

- (void)removeTemplateWithId:(NSString *)templateId;

- (void)clearAllData;

- (void)setThemePreference:(NSInteger)theme;
- (NSInteger)themePreference;

- (void)setLanguagePreference:(NSString *)language;
- (NSString *)languagePreference;

@end
