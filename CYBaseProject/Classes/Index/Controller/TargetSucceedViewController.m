//
//  TargetSucceedViewController.m
//  100Days
//
//  Created by Peter Lee on 16/9/22.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TargetSucceedViewController.h"

@interface TargetSucceedViewController () <CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *signDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *signRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetNameLabel;

@end

@implementation TargetSucceedViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubViews];
}

- (void)viewDidAppear:(BOOL)animated{
    [self viewAnimation];
}

- (void)configureSubViews{
    self.shareButton.layer.masksToBounds = YES;
    self.shareButton.layer.cornerRadius = 5;
    self.shareButton.layer.borderWidth = 2;
    self.shareButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    //customer info
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults stringForKey:kUserNameKey];
    if (![NSString isBlankString:userName]) {
        self.nameLabel.text = userName;
    }
    NSData *userHeaderData = [userDefaults dataForKey:kUserHeaderKey];
    if (userHeaderData) {
        self.headerImageView.image = [UIImage imageWithData:userHeaderData];
    }
    
    //target info
    if (!self.target) return;
    self.targetNameLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TargetDayType", nil),self.target.totalDays];;
    
    __block NSInteger signDay = 0;
    [self.target.targetSigns enumerateObjectsUsingBlock:^(TargetSign * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.signType integerValue] == TargetSignTypeSign) {
            signDay++;
        }
    }];
    self.signDayLabel.text = [NSString stringWithFormat:@"%@",@(signDay)];
    CGFloat signRate = signDay *100.0/[self.target.totalDays integerValue];
    self.signRateLabel.text =[NSString stringWithFormat:@"%.1f%%",signRate];
}

- (void)viewAnimation{
    
    CGFloat animateDuration = 0.5;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    self.view.layer.mask = maskLayer;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.delegate = self;
    animation.duration = animateDuration;
    animation.keyPath = @"path";
    
    UIBezierPath *pathOne = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 1, ScreenHeight/4)];
    UIBezierPath *pathTwo = [UIBezierPath bezierPathWithRect:CGRectMake(ScreenWidth-1, ScreenHeight/4, 1, ScreenHeight/4)];
    [pathOne appendPath:pathTwo];
    UIBezierPath *pathThree = [UIBezierPath bezierPathWithRect:CGRectMake(0, ScreenHeight/4*2, 1, ScreenHeight/4)];
    [pathOne appendPath:pathThree];
    UIBezierPath *pathFour = [UIBezierPath bezierPathWithRect:CGRectMake(ScreenWidth-1, ScreenHeight/4*3, 1, ScreenHeight/4)];
    [pathOne appendPath:pathFour];
    
    UIBezierPath *pathOneEnd = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, ScreenWidth, ScreenHeight/4)];
    UIBezierPath *pathTwoEnd = [UIBezierPath bezierPathWithRect:CGRectMake(0, ScreenHeight/4, ScreenWidth, ScreenHeight/4)];
    [pathOneEnd appendPath:pathTwoEnd];
    UIBezierPath *pathThreeEnd = [UIBezierPath bezierPathWithRect:CGRectMake(0, ScreenHeight/4*2, ScreenWidth, ScreenHeight/4)];
    [pathOneEnd appendPath:pathThreeEnd];
    UIBezierPath *pathFourEnd = [UIBezierPath bezierPathWithRect:CGRectMake(0, ScreenHeight/4*3, ScreenWidth, ScreenHeight/4)];
    [pathOneEnd appendPath:pathFourEnd];
    
    animation.fromValue = (__bridge id)(pathOne.CGPath);
    animation.toValue = (__bridge id)(pathOneEnd.CGPath);
    [maskLayer addAnimation:animation forKey:nil];

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    //move out the mask
    self.view.layer.mask = nil;
    
    //begin the animation of imageView;
    NSArray *imgArray = @[[UIImage imageNamed:@"cheers_1"],[UIImage imageNamed:@"cheers_2"],[UIImage imageNamed:@"cheers_3"]];
    self.contentImageView.animationImages=imgArray;
    self.contentImageView.animationDuration=1;
    [self.contentImageView startAnimating];
}

#pragma mark - event method
- (IBAction)clickCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickShareButton:(id)sender {
}

@end
