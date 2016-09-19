//
//  NSDate+CYCompare.m
//  100Days
//
//  Created by Peter Lee on 16/9/1.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "NSDate+CYCompare.h"

@implementation NSDate (CYCompare)

- (NSInteger)dayIntervalSinceDate:(NSDate *)date{
    NSDate *dateOne = [self zeroOfDate];
    NSDate *dateTwo = [date zeroOfDate];
    NSTimeInterval timeInterval = [dateOne timeIntervalSinceDate:dateTwo];
    return timeInterval/(60 * 60 * 24);
}

- (NSDate *)zeroOfDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar startOfDayForDate:self];
}

@end
