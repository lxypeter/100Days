//
//  TargetCalendarDay.h
//  100Days
//
//  Created by Peter Lee on 16/9/7.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TargetSign;
@interface TargetCalendarDay : NSObject

@property (nonatomic, assign) NSInteger day;
@property (nonatomic, strong) TargetSign *targetSign;
@property (nonatomic, assign, getter=isNeedSign) BOOL needSign;
@property (nonatomic, assign, getter=isToday) BOOL today;

@end
