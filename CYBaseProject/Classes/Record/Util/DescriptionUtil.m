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
            return NSLocalizedString(@"Jan", nil);
        case 2:
            return NSLocalizedString(@"Feb", nil);
        case 3:
            return NSLocalizedString(@"Mar", nil);
        case 4:
            return NSLocalizedString(@"Apr", nil);
        case 5:
            return NSLocalizedString(@"Mar", nil);
        case 6:
            return NSLocalizedString(@"Jun", nil);
        case 7:
            return NSLocalizedString(@"Jul", nil);
        case 8:
            return NSLocalizedString(@"Aug", nil);
        case 9:
            return NSLocalizedString(@"Sep", nil);
        case 10:
            return NSLocalizedString(@"Oct", nil);
        case 11:
            return NSLocalizedString(@"Nov", nil);
        case 12:
            return NSLocalizedString(@"Dec", nil);
        default:
            return @"";
    }
}

+ (NSString *)dayDescriptionOfDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"dd";
    NSUInteger day = [[formatter stringFromDate:date]integerValue];
    return [NSString stringWithFormat:@"%@%@",@(day),NSLocalizedString(@"CalanderDay", nil)];
}

+ (NSString *)resultDescriptionOfResult:(TargetResult)result{
    switch (result) {
        case TargetResultProgressing:
            return NSLocalizedString(@"Progressing", nil);
        case TargetResultComplete:
            return NSLocalizedString(@"Completed", nil);
        case TargetResultFail:
            return NSLocalizedString(@"Fail", nil);
        case TargetResultStop:
            return NSLocalizedString(@"End", nil);
    }
}

+ (NSString *)signTypeDescriptionOfType:(TargetSignType)type{
    switch (type) {
        case TargetSignTypeSign:
            return NSLocalizedString(@"Signed", nil);
        case TargetSignTypeLeave:
            return NSLocalizedString(@"Leave", nil);
    }
}

@end
