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

- (NSDate *)firstDateOfCurrentMonth{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *oldComponents = [calendar components:NSUIntegerMax fromDate:self];
    
    NSDateComponents *components = [[NSDateComponents alloc]init];
    components.year = oldComponents.year;
    components.month = oldComponents.month;
    components.day = 1;
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)lastDateOfCurrentMonth{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *oldComponents = [calendar components:NSUIntegerMax fromDate:self];
    
    NSDateComponents *lastDayComponents = [[NSDateComponents alloc]init];
    lastDayComponents.year = oldComponents.year;
    lastDayComponents.month = oldComponents.month+1;
    lastDayComponents.day = 0;
    
    return [calendar dateFromComponents:lastDayComponents];
}

@end
