//
//  TimerViewController.m
//  100Days
//
//  Created by Peter Lee on 2016/10/11.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TimerViewController.h"
#import "SignTimer.h"
#import "CYPicker.h"
#import "CoreDataUtil.h"
#import "TimerProgressView.h"

@interface TimerViewController () <CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *startBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIView *resetBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *editTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *autoSignButton;

@property (weak, nonatomic) IBOutlet UIView *timeDetailView;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UILabel *minuteLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet TimerProgressView *progressView;

@property (nonatomic, strong) CYDatePicker *timePicker;
@property (nonatomic, assign) BOOL hasTarget;

@end

@implementation TimerViewController

#pragma mark - lazy load
- (CYDatePicker *)timePicker{
    if (!_timePicker) {
        _timePicker = [CYDatePicker datePickerWithDatePickerMode:UIDatePickerModeCountDownTimer selectedBlock:^(id selectedValue) {
            
            NSInteger totalSecond = [selectedValue integerValue];
            NSArray *timeComponent = [self calculateTimeComponentFromSecond:totalSecond];
            
            [self refreshTimeStringFromTimeComponent:timeComponent];
            
            NSString *countDownStirng = [[NSString stringWithFormat:@"%2li:%2li:%2li",[timeComponent[0]integerValue],[timeComponent[1]integerValue],[timeComponent[2]integerValue]]stringByReplacingOccurrencesOfString:@" " withString:@"0"];
            self.totalTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TotalTime", nil),countDownStirng];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:countDownStirng forKey:kDefaultCountDown];
            [userDefaults synchronize];
        }];
        _timePicker.datePickerMode = UIDatePickerModeCountDownTimer;
    }
    return _timePicker;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubviews];
    [self queryCountDownRecord];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    [self startAnimation];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - initial method
- (void)configureSubviews{
    self.startBackgroundView.layer.cornerRadius = 100;
    self.startBackgroundView.hidden = YES;
    
    self.startButton.layer.cornerRadius = 70;
    self.startButton.hidden = YES;
    
    self.resetBackgroundView.layer.cornerRadius = 50;
    self.resetBackgroundView.hidden = YES;
    
    self.resetButton.layer.cornerRadius = 35;
    self.resetButton.hidden = YES;
    
    //time detail view
    self.timeDetailView.hidden = YES;
    
    //auto sign button
    [self.autoSignButton setBackgroundImage:[UIImage imageNamed:@"checkbox_check_disable"] forState:UIControlStateDisabled|UIControlStateSelected];
    [self.autoSignButton setBackgroundImage:[UIImage imageNamed:@"checkbox_uncheck_disable"] forState:UIControlStateDisabled];
    
    if ([CoreDataUtil queryCurrentTarget]) {
        self.hasTarget = YES;
    }else{
        self.hasTarget = NO;
        self.autoSignButton.enabled = NO;
    }
    
    //progressView
    self.progressView.hidden = YES;
    self.progressView.radius = 85;
}

- (void)queryCountDownRecord{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //default countdown
    NSString *defaultCountDown = [userDefaults stringForKey:kDefaultCountDown];
    if([NSString isBlankString:defaultCountDown]){
        defaultCountDown = @"01:00:00";
    }
    self.totalTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TotalTime", nil),defaultCountDown];
    
    //auto sign
    BOOL autoSign = self.hasTarget?[userDefaults boolForKey:kCountDownAutoSign]:NO;
    self.autoSignButton.selected = autoSign;
    
    if ([SignTimer shareSignTimer].totalSecond!=0) {
        [self refreshTimeStringFromTimeComponent:[self calculateTimeComponentFromSecond:[SignTimer shareSignTimer].totalSecond]];
        
        NSInteger totalSecond = [self getTotalSecond];
        self.progressView.progress = (totalSecond -[SignTimer shareSignTimer].totalSecond)*1.0/totalSecond;
    }else{
        [self clickResetButton:self.resetButton];
    }
    if ([SignTimer shareSignTimer].isCounting) {
        [self clickStartButton:self.startButton];
    }
    
}

- (void)startAnimation{
    
    CGFloat totalTime = 0.6;
    CGFloat openAnimationPercent = 0.7;
    
    __weak typeof(self) weakSelf = self;
    
    //pic opacity animation
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animation];
    fadeInAnimation.duration = totalTime;
    fadeInAnimation.keyPath = @"opacity";
    fadeInAnimation.fromValue = @(0);
    fadeInAnimation.toValue = @(1);
    [self.coverView.layer addAnimation:fadeInAnimation forKey:nil];
    
    //pic mask animation
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    self.coverView.layer.mask = maskLayer;
    CAKeyframeAnimation *coverAnimation = [CAKeyframeAnimation animation];
    coverAnimation.duration = totalTime;
    coverAnimation.keyPath = @"path";
    UIBezierPath *pathOne = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth/2, ScreenHeight/2) radius:ScreenHeight startAngle:-M_PI_2 endAngle:-M_PI_2+M_PI_2*0.01 clockwise:YES];
    [pathOne addLineToPoint:CGPointMake(ScreenWidth/2, ScreenHeight/2)];
    [pathOne closePath];
    UIBezierPath *pathOneLeft = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth/2, ScreenHeight/2) radius:ScreenHeight startAngle:-M_PI_2 endAngle:-M_PI_2-M_PI_2*0.01 clockwise:NO];
    [pathOneLeft addLineToPoint:CGPointMake(ScreenWidth/2, ScreenHeight/2)];
    [pathOneLeft closePath];
    [pathOne appendPath:pathOneLeft];
    
    UIBezierPath *pathTwo = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth/2, ScreenHeight/2) radius:ScreenHeight startAngle:-M_PI_2 endAngle:-M_PI_2*0.3 clockwise:YES];
    [pathTwo addLineToPoint:CGPointMake(ScreenWidth/2, ScreenHeight/2)];
    [pathTwo closePath];
    UIBezierPath *pathTwoLeft = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth/2, ScreenHeight/2) radius:ScreenHeight startAngle:-M_PI_2 endAngle:-M_PI+M_PI_2*0.3 clockwise:NO];
    [pathTwoLeft addLineToPoint:CGPointMake(ScreenWidth/2, ScreenHeight/2)];
    [pathTwoLeft closePath];
    [pathTwo appendPath:pathTwoLeft];
    
    UIBezierPath *pathThree = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth/2, ScreenHeight/2*0.8) radius:ScreenHeight startAngle:-M_PI_2 endAngle:-M_PI_2*0.3 clockwise:YES];
    [pathThree addLineToPoint:CGPointMake(ScreenWidth/2, ScreenHeight/2*0.8)];
    [pathThree closePath];
    UIBezierPath *pathThreeLeft = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth/2, ScreenHeight/2*0.8) radius:ScreenHeight startAngle:-M_PI_2 endAngle:-M_PI+M_PI_2*0.3 clockwise:NO];
    [pathThreeLeft addLineToPoint:CGPointMake(ScreenWidth/2, ScreenHeight/2*0.8)];
    [pathThreeLeft closePath];
    [pathThree appendPath:pathThreeLeft];
    
    coverAnimation.values = @[(__bridge id)(pathOne.CGPath),(__bridge id)(pathTwo.CGPath),(__bridge id)(pathThree.CGPath)];
    coverAnimation.keyTimes = @[@(0),@(0.7),@(1)];
    coverAnimation.removedOnCompletion = NO;
    coverAnimation.fillMode = kCAFillModeForwards;
    [maskLayer addAnimation:coverAnimation forKey:nil];
    
    //start button backgroundView
    CABasicAnimation *startBgAnimation = [CABasicAnimation animation];
    startBgAnimation.keyPath = @"position.y";
    startBgAnimation.duration = 0.6;
    startBgAnimation.fromValue = @(ScreenHeight/2);
    startBgAnimation.toValue = @(ScreenHeight/2*0.65);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalTime*openAnimationPercent * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.startBackgroundView.hidden = NO;
        [weakSelf.startBackgroundView.layer addAnimation:startBgAnimation forKey:nil];
    });
    
    //start button
    CABasicAnimation *startBtnAnimation = [CABasicAnimation animation];
    startBtnAnimation.keyPath = @"transform.scale";
    startBtnAnimation.delegate = self;
    startBtnAnimation.duration = 0.15;
    startBtnAnimation.fromValue = @(0);
    startBtnAnimation.toValue = @(1);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((totalTime*openAnimationPercent+0.6) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.startButton.hidden = NO;
        [weakSelf.startButton.layer addAnimation:startBtnAnimation forKey:nil];
    });
    
    //time detail view
    CABasicAnimation *timeDetailAnimation = [CABasicAnimation animation];
    timeDetailAnimation.keyPath = @"opacity";
    timeDetailAnimation.duration = 0.5;
    timeDetailAnimation.fromValue = @(0);
    timeDetailAnimation.toValue = @(1);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.timeDetailView.hidden = NO;
        [weakSelf.timeDetailView.layer addAnimation:timeDetailAnimation forKey:nil];
    });
    
    //reset button
    CABasicAnimation *resetBgAnimation = [CABasicAnimation animation];
    resetBgAnimation.keyPath = @"opacity";
    resetBgAnimation.duration = 0.6;
    resetBgAnimation.fromValue = @(0);
    resetBgAnimation.toValue = @(0.5);
    
    CABasicAnimation *resetAnimation = [CABasicAnimation animation];
    resetAnimation.keyPath = @"opacity";
    resetAnimation.duration = 0.6;
    resetAnimation.fromValue = @(0);
    resetAnimation.toValue = @(1);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalTime*openAnimationPercent * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.resetBackgroundView.hidden = NO;
        weakSelf.resetButton.hidden = NO;
        [weakSelf.resetBackgroundView.layer addAnimation:resetBgAnimation forKey:nil];
        [weakSelf.resetButton.layer addAnimation:resetAnimation forKey:nil];
    });
    
}

#pragma mark - event method
- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickStartButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self switchButtons];
    if (sender.selected) {//playing
        
        BOOL autoSign = self.hasTarget?self.autoSignButton.selected:NO;
        
        __weak typeof(self) weakSelf = self;
        [[SignTimer shareSignTimer]startTimerWithTotalSecond:[self getCurrentSecond] autoSign:autoSign timerProgress:^(NSInteger remainingSecond) {
            [weakSelf refreshTimeStringFromTimeComponent:[weakSelf calculateTimeComponentFromSecond:remainingSecond]];
            
            NSInteger totalSecond = [self getTotalSecond];
            weakSelf.progressView.progress = (totalSecond -remainingSecond)*1.0/totalSecond;
            
        } timeEnd:^{
            [weakSelf switchButtons];
            sender.selected = NO;
        }];
    }else{
        [[SignTimer shareSignTimer]pauseTimer];
    }
}

- (IBAction)clickEditTimeButton:(id)sender {
    NSString *totalTimeString = [self.totalTimeLabel.text substringFromIndex:self.totalTimeLabel.text.length-8];
    NSArray *timeComponents = [totalTimeString componentsSeparatedByString:@":"];
    [self.timePicker showPickerWithCountDownDuration:[self calculateTotalSecondFormTimeComponent:timeComponents]];
}

- (IBAction)clickAutoSignButton:(UIButton *)sender {
    
    if (!self.hasTarget) return;
    
    sender.selected = !sender.selected;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:sender.selected forKey:kCountDownAutoSign];
    [userDefaults synchronize];
}

- (IBAction)clickResetButton:(id)sender {
    [[SignTimer shareSignTimer]resetTimer];
    NSString *totalTimeString = [self.totalTimeLabel.text substringFromIndex:self.totalTimeLabel.text.length-8];
    NSArray *timeComponents = [totalTimeString componentsSeparatedByString:@":"];
    self.hourLabel.text = timeComponents[0];
    self.minuteLabel.text = timeComponents[1];
    self.secondLabel.text = timeComponents[2];
    
    self.progressView.progress = 0;
}

- (void)switchButtons{
    self.resetButton.enabled = !self.resetButton.enabled;
    self.editTimeButton.enabled = !self.editTimeButton.enabled;
    if (self.hasTarget) {
        self.autoSignButton.enabled = !self.autoSignButton.enabled;
    }
}

- (NSInteger)getCurrentSecond{
    NSArray *currentTimeComponent = @[self.hourLabel.text,self.minuteLabel.text,self.secondLabel.text];
    return [self calculateTotalSecondFormTimeComponent:currentTimeComponent];
}

- (NSInteger)getTotalSecond{
    NSString *totalTimeString = [self.totalTimeLabel.text substringFromIndex:self.totalTimeLabel.text.length-8];
    NSArray *timeComponents = [totalTimeString componentsSeparatedByString:@":"];
    return [self calculateTotalSecondFormTimeComponent:timeComponents];
}

- (void)refreshTimeStringFromTimeComponent:(NSArray *)timeComponent{
    self.hourLabel.text = [[NSString stringWithFormat:@"%2li",[timeComponent[0]integerValue]]stringByReplacingOccurrencesOfString:@" " withString:@"0"];
    self.minuteLabel.text = [[NSString stringWithFormat:@"%2li",[timeComponent[1]integerValue]]stringByReplacingOccurrencesOfString:@" " withString:@"0"];
    self.secondLabel.text = [[NSString stringWithFormat:@"%2li",[timeComponent[2]integerValue]]stringByReplacingOccurrencesOfString:@" " withString:@"0"];
}

- (NSArray *)calculateTimeComponentFromSecond:(NSInteger)totalSecond{
    NSInteger hour = totalSecond/3600;
    NSInteger minute = (totalSecond-hour*3600)/60;
    NSInteger second = totalSecond-hour*3600-minute*60;
    return @[@(hour),@(minute),@(second)];
}

- (NSInteger)calculateTotalSecondFormTimeComponent:(NSArray *)timeComponent{
    return [timeComponent[0] integerValue]*3600 + [timeComponent[1] integerValue]*60 + [timeComponent[2] integerValue];
}

#pragma mark - delegate method
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    self.progressView.hidden = NO;
}

@end
