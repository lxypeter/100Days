//
//  NSBundle+Language.h
//  100Days
//
//  Created by Peter Lee on 16/9/28.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (Language)

+ (NSBundle *)currentBundle;
+ (NSString *)currentLanguage;
+ (void)setLanguage:(NSString *)language;

@end
