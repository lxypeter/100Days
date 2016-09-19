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
+ (NSString *)dayDescriptionOfDate:(NSDate *)date;
+ (NSString *)resultDescriptionOfResult:(TargetResult)result;
+ (NSString *)signTypeDescriptionOfType:(TargetSignType)type;

@end
