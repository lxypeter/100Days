//
//  TargetMonthlySign.m
//  100Days
//
//  Created by Peter Lee on 16/9/5.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TargetMonthlySign.h"
#import "NSDate+CYCompare.h"

@interface TargetMonthlySign ()

@property (nonatomic, assign) NSInteger monthTotalDay;
@property (nonatomic, assign) NSInteger startWeakDay;
@property (nonatomic, strong) NSDate *firstDay;
@property (nonatomic, strong) NSDate *lastDay;

@end

@implementation TargetMonthlySign

- (void)setMonth:(NSDate *)month{
    _month = month;
    _lastDay = nil;
    _firstDay = nil;
    _monthTotalDay = -1000;
    _startWeakDay = -1000;
}

- (NSDate *)lastDay{
    if (!_lastDay) {
        if (!_month) return nil;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger year = [calendar components:NSUIntegerMax fromDate:self.month].year;
        NSInteger month = [calendar components:NSUIntegerMax fromDate:self.month].month;
        
        NSDateComponents *lastDayComponents = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
        lastDayComponents.year = year;
        lastDayComponents.month = month+1;
        lastDayComponents.day = 0;
        NSDate *lastDay = [calendar dateFromComponents:lastDayComponents];
        _lastDay = lastDay;
    }
    return _lastDay;
}

- (NSDate *)firstDay{
    if (!_firstDay) {
        if (!_month) return nil;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger year = [calendar components:NSUIntegerMax fromDate:self.month].year;
        NSInteger month = [calendar components:NSUIntegerMax fromDate:self.month].month;
        
        NSDateComponents *firstDayComponents = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
        firstDayComponents.year = year;
        firstDayComponents.month = month;
        firstDayComponents.day = 1;
        NSDate *firstDay = [calendar dateFromComponents:firstDayComponents];
        _firstDay = firstDay;
    }
    return _firstDay;
}

- (NSInteger)monthTotalDay{
    if (_monthTotalDay == -1000) {
        _monthTotalDay = [self.lastDay dayIntervalSinceDate:self.firstDay]+1;
    }
    return _monthTotalDay;
}

- (NSInteger)startWeakDay{
    if (_startWeakDay == -1000) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        _startWeakDay = [calendar components:NSUIntegerMax fromDate:self.firstDay].weekday-1;
    }
    return _startWeakDay;
}

@end
