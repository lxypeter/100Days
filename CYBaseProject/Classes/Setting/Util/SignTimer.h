//
//  SignTimer.h
//  100Days
//
//  Created by Peter Lee on 2016/10/12.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TimerProgress)(NSInteger remainingSecond);
typedef void(^TimerEnd)();

@interface SignTimer : NSObject

@property (nonatomic, readonly, assign, getter=isCounting) BOOL counting;
@property (nonatomic, readonly, assign) NSInteger totalSecond;

+ (SignTimer *)shareSignTimer;

- (void)startTimerWithTotalSecond:(NSInteger)second autoSign:(BOOL)autoSign timerProgress:(TimerProgress)timerProgress timeEnd:(TimerEnd)timeEnd;
- (void)pauseTimer;
- (void)resetTimer;

@end
