//
//  NSDate+CYCompare.h
//  100Days
//
//  Created by Peter Lee on 16/9/1.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CYCompare)

/**
 *  @author CY.Lee, 16-09-01 15:09:37
 *
 *  天数差
 */
- (NSInteger)dayIntervalSinceDate:(NSDate *)date;

/**
 *  @author CY.Lee, 16-09-01 15:09:11
 *
 *  当天零点
 */
- (NSDate *)zeroOfDate;

@end
