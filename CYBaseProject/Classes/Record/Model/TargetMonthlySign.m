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
    _lastDay = [month lastDateOfCurrentMonth];
    _firstDay = [month firstDateOfCurrentMonth];;
    _monthTotalDay = [_lastDay dayIntervalSinceDate:_firstDay]+1;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    _startWeakDay = [calendar components:NSUIntegerMax fromDate:_firstDay].weekday-1;
}

@end
