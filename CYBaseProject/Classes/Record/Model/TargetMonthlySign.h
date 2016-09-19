//
//  TargetMonthlySign.h
//  100Days
//
//  Created by Peter Lee on 16/9/5.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TargetMonthlySign : NSObject

@property (nonatomic, strong) NSDate *month;
@property (nonatomic, assign) NSInteger signTotalDay;
@property (nonatomic, assign) NSInteger signDay;
@property (nonatomic, strong) NSMutableDictionary *signDictionary;
@property (nonatomic, assign, getter=isBegin) BOOL begin;
@property (nonatomic, assign, readonly) NSInteger monthTotalDay;
@property (nonatomic, assign, readonly) NSInteger startWeakDay;

@end
