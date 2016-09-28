//
//  NSBundle+Language.m
//  100Days
//
//  Created by Peter Lee on 16/9/28.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "NSBundle+Language.h"
#import <objc/runtime.h>

static const char _bundle = 0;

@interface BundleEx : NSBundle

@end

@implementation BundleEx

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *bundle = objc_getAssociatedObject(self, &_bundle);
    return bundle ? [bundle localizedStringForKey:key value:value table:tableName] : [super localizedStringForKey:key value:value table:tableName];
}

@end

@implementation NSBundle (Language)

+ (NSBundle *)currentBundle{
    NSBundle *bundle = objc_getAssociatedObject([NSBundle mainBundle], &_bundle);
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    return bundle;
}

+ (NSString *)currentLanguage{
    
    NSString *language = [[NSUserDefaults standardUserDefaults]stringForKey:@"myLanguage"];
    
    if ([NSString isBlankString:language]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *allLanguage = [defaults objectForKey:@"AppleLanguages"];
        language = [allLanguage objectAtIndex:0];
        
        NSString *path=[[NSBundle mainBundle] pathForResource:@"Language" ofType:@"plist"];
        NSArray *validLanguageArray = [NSArray arrayWithContentsOfFile:path];
        BOOL validLanguage = NO;
        for (NSDictionary *languageDict in validLanguageArray) {
            if ([language hasPrefix:languageDict[@"code"]]) {
                validLanguage = YES;
                language = languageDict[@"code"];
                break;
            }
        }
        if (!validLanguage) {
            language = @"Base";
        }
    }
    
    return language;
}

+ (void)setLanguage:(NSString *)language {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [BundleEx class]);
    });
    
    objc_setAssociatedObject([NSBundle mainBundle], &_bundle, language ? [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:language ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"myLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
