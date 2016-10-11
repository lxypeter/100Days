//
//  TimerViewController.m
//  100Days
//
//  Created by Peter Lee on 2016/10/11.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TimerViewController.h"

@interface TimerViewController ()

@property (weak, nonatomic) IBOutlet UIView *coverView;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubviews];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)configureSubviews{
    
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
}

@end
