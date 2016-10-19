//
//  SignTimer.m
//  100Days
//
//  Created by Peter Lee on 2016/10/12.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "SignTimer.h"
#import "CoreDataUtil.h"
#import "SignShareViewController.h"
#import "TargetSucceedViewController.h"

@interface SignTimer ()

@property (nonatomic, copy) TimerProgress timerProgress;
@property (nonatomic, copy) TimerEnd timerEnd;
@property (nonatomic, assign) NSInteger totalSecond;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign, getter=isCounting) BOOL counting;

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

- (void)startTimerWithTotalSecond:(NSInteger)second autoSign:(BOOL)autoSign timerProgress:(TimerProgress)timerProgress timeEnd:(TimerEnd)timeEnd{
    
    self.timerProgress = timerProgress;
    self.timerEnd = timeEnd;
    
    if (!self.counting) {
        if (second<=0){
            if (timeEnd) {
                timeEnd();
            }
            return;
        }
        self.counting = YES;
        self.totalSecond = second;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerProgressing:) userInfo:@(autoSign) repeats:YES];
    }
}

- (void)pauseTimer{
    [self.timer invalidate];
    self.timer = nil;
    self.counting = NO;
}

- (void)resetTimer{
    [self pauseTimer];
    self.totalSecond = 0;
}

- (void)timerProgressing:(NSTimer *)timer{
    if (self.totalSecond) {
        self.totalSecond--;
    }
    if (self.totalSecond) {
        if (self.timerProgress) {
            self.timerProgress(self.totalSecond);
        }
    }else{
        BOOL autoSign = [timer.userInfo boolValue];
        
        [self pauseTimer];
        self.counting = NO;
        
        if (self.timerProgress) {
            self.timerProgress(0);
        }
        
        if (self.timerEnd) {
            self.timerEnd();
        }
        
        if (autoSign) {
            Target *target = [CoreDataUtil queryCurrentTarget];
            if (target) {
                __weak typeof(self) weakSelf = self;
                [CoreDataUtil signTarget:target signType:TargetSignTypeSign complete:^(TargetSign *targetSign) {
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:SignNotificationKey object:weakSelf userInfo:nil];
                    
                    //to share view
                    SignShareViewController *ctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"SignShareViewController"];
                    ctrl.targetSign = targetSign;
                    [[weakSelf getCurrentViewController] presentViewController:ctrl animated:YES completion:nil];
                    
                    //check whether target has been completed
                    if ([target.day integerValue] == [target.totalDays integerValue]) {
                        [CoreDataUtil terminateTarget:target WithResult:TargetResultComplete complete:^{
                            TargetSucceedViewController *ctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TargetSucceedViewController"];
                            ctrl.target = target;
                            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ctrl animated:NO completion:nil];
                        }];
                    }
                }];
            }
        }
    }
}

- (UIViewController *)getCurrentViewController{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]){
        result = nextResponder;
    }else{
        result = window.rootViewController;
    }
    return result;
}

@end
