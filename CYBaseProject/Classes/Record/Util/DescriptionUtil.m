//
//  DescriptionUtil.m
//  100Days
//
//  Created by Peter Lee on 16/9/4.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "DescriptionUtil.h"

@implementation DescriptionUtil

+ (NSString *)monthDescriptionOfDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MM";
    NSUInteger month = [[formatter stringFromDate:date]integerValue];
    switch (month) {
        case 1:
            return @"一月";
        case 2:
            return @"二月";
        case 3:
            return @"三月";
        case 4:
            return @"四月";
        case 5:
            return @"五月";
        case 6:
            return @"六月";
        case 7:
            return @"七月";
        case 8:
            return @"八月";
        case 9:
            return @"九月";
        case 10:
            return @"十月";
        case 11:
            return @"十一月";
        case 12:
            return @"十二月";
        default:
            return @"";
    }
}

+ (NSString *)dayDescriptionOfDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"dd";
    NSUInteger day = [[formatter stringFromDate:date]integerValue];
    return [NSString stringWithFormat:@"%@日",@(day)];
}

+ (NSString *)resultDescriptionOfResult:(TargetResult)result{
    switch (result) {
        case TargetResultProgressing:
            return @"进行中";
        case TargetResultComplete:
            return @"已完成";
        case TargetResultFail:
            return @"失败";
        case TargetResultStop:
            return @"结束";
    }
}

+ (NSString *)signTypeDescriptionOfType:(TargetSignType)type{
    switch (type) {
        case TargetSignTypeSign:
            return @"已签到";
        case TargetSignTypeLeave:
            return @"请假";
    }
}

@end
