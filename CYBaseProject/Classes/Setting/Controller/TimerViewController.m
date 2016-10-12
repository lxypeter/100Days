//
//  TimerViewController.m
//  100Days
//
//  Created by Peter Lee on 2016/10/11.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TimerViewController.h"
#import "SignTimer.h"

@interface TimerViewController ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *startBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIView *resetBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *editTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *autoSignButton;

@property (weak, nonatomic) IBOutlet UIView *timeDetailView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TimerViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubviews];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    [self startAnimation];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - view method
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
}

- (void)startAnimation{
    
    __weak typeof(self) weakSelf = self;
    
    //pic opacity animation
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animation];
    fadeInAnimation.duration = 1;
    fadeInAnimation.keyPath = @"opacity";
    fadeInAnimation.fromValue = @(0);
    fadeInAnimation.toValue = @(1);
    [self.coverView.layer addAnimation:fadeInAnimation forKey:nil];
    
    //pic mask animation
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    self.coverView.layer.mask = maskLayer;
    CAKeyframeAnimation *coverAnimation = [CAKeyframeAnimation animation];
    coverAnimation.duration = 1;
    coverAnimation.keyPath = @"path";
    UIBezierPath *pathOne = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth/2, ScreenHeight/2) radius:ScreenHeight startAngle:-M_PI_2 endAngle:-M_PI_2+M_PI_2*0.1 clockwise:YES];
    [pathOne addLineToPoint:CGPointMake(ScreenWidth/2, ScreenHeight/2)];
    [pathOne closePath];
    UIBezierPath *pathOneLeft = [UIBezierPath bezierPathWithArcCenter:CGPointMake(ScreenWidth/2, ScreenHeight/2) radius:ScreenHeight startAngle:-M_PI_2 endAngle:-M_PI_2-M_PI_2*0.1 clockwise:NO];
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
    coverAnimation.keyTimes = @[@(0),@(0.4),@(1)];
    coverAnimation.removedOnCompletion = NO;
    coverAnimation.fillMode = kCAFillModeForwards;
    [maskLayer addAnimation:coverAnimation forKey:nil];
    
    //start button backgroundView
    CABasicAnimation *startBgAnimation = [CABasicAnimation animation];
    startBgAnimation.keyPath = @"position.y";
    startBgAnimation.duration = 0.6;
    startBgAnimation.fromValue = @(ScreenHeight/2);
    startBgAnimation.toValue = @(ScreenHeight/2*0.65);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.startBackgroundView.hidden = NO;
        [weakSelf.startBackgroundView.layer addAnimation:startBgAnimation forKey:nil];
    });
    
    //start button
    CABasicAnimation *startBtnAnimation = [CABasicAnimation animation];
    startBtnAnimation.keyPath = @"transform.scale";
    startBtnAnimation.duration = 0.25;
    startBtnAnimation.fromValue = @(0);
    startBtnAnimation.toValue = @(1);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.startButton.hidden = NO;
        [weakSelf.startButton.layer addAnimation:startBtnAnimation forKey:nil];
    });
    
    //time detail view
    CABasicAnimation *timeDetailAnimation = [CABasicAnimation animation];
    timeDetailAnimation.keyPath = @"opacity";
    timeDetailAnimation.duration = 0.5;
    timeDetailAnimation.fromValue = @(0);
    timeDetailAnimation.toValue = @(1);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
    
}

- (IBAction)clickEditTimeButton:(id)sender {
}

- (IBAction)clickAutoSignButton:(UIButton *)sender {
    sender.selected = !sender.selected;
}

@end
