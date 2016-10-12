//
//  SignTimer.m
//  100Days
//
//  Created by Peter Lee on 2016/10/12.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "SignTimer.h"

@interface SignTimer ()

@property (nonatomic, copy) TimerProgress timerProgress;
@property (nonatomic, copy) TimerEnd timerEnd;
@property (nonatomic, assign) NSInteger totalSecond;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SignTimer

+ (SignTimer *)shareSignTimer{
    static SignTimer *signTimer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        signTimer = [[SignTimer alloc]init];
    });
    return signTimer;
}

- (void)startTimerWithTotalSecond:(NSInteger)second autoSign:(BOOL)autoSign timerProgress:(TimerProgress)timerProgress{
    self.totalSecond = second;
    self.timerProgress = timerProgress;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerProgressing:) userInfo:@(autoSign) repeats:YES];
}

- (void)pauseTimer{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerProgressing:(NSTimer *)timer{
    self.totalSecond--;
    if (self.totalSecond) {
        if (self.timerProgress) {
            self.timerProgress(self.totalSecond);
        }
    }else{
        BOOL autoSign = [timer.userInfo boolValue];
        
        [timer invalidate];
        self.timer = nil;
        
        if (self.timerEnd) {
            self.timerEnd();
        }
        
        if (autoSign) {
            
        }
    }
}

@end
