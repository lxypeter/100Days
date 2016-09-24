//
//  DescriptionUtil.h
//  100Days
//
//  Created by Peter Lee on 16/9/4.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Target.h"

@interface DescriptionUtil : NSObject

+ (NSString *)monthDescriptionOfDate:(NSDate *)date;
+ (NSString *)dayDescriptionOfDay:(NSInteger)day;
+ (NSString *)dayDescriptionOfDate:(NSDate *)date;
+ (NSString *)dateDescriptionOfDate:(NSDate *)date;
+ (NSString *)ordinalNumberSuffixWithNumber:(NSInteger)num;
+ (NSString *)resultDescriptionOfResult:(TargetResult)result;
+ (NSString *)signTypeDescriptionOfType:(TargetSignType)type;

@end
