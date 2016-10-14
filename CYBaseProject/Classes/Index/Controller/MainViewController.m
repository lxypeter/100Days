//
//  MainViewController.m
//  100Days
//
//  Created by Peter Lee on 16/8/30.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "MainViewController.h"
#import "NoTargetView.h"
#import "SetTargetViewController.h"
#import "CoreDataUtil.h"
#import "Target.h"
#import "NSDate+CYCompare.h"
#import "UIView+Toast.h"
#import "TargetMonthlyListController.h"
#import "DescriptionUtil.h"
#import "SignShareViewController.h"
#import "TargetSucceedViewController.h"


typedef NS_ENUM(NSInteger,MainViewAnimationType){
    MainViewAnimationTypeIn,
    MainViewAnimationTypeOut
};

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *calendarButton;

@property (weak, nonatomic) IBOutlet UIView *signView;
@property (weak, nonatomic) IBOutlet UILabel *lastSignTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *endView;

@property (weak, nonatomic) IBOutlet UIView *leaveView;
@property (weak, nonatomic) IBOutlet UILabel *leaveNoteLabel;

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *dayTimesLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayTimesSuffixLabel;

@property (nonatomic, strong) NoTargetView *noTargetView;
@property (nonatomic, strong) Target *currentTarget;

@end

@implementation MainViewController

#pragma mark - get/set method
- (NoTargetView *)noTargetView{
    if (!_noTargetView) {
        NoTargetView *noTargetView = [[NoTargetView alloc]init];
        noTargetView.settingBlock = ^{
            SetTargetViewController *ctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"SetTargetViewController"];
            [self presentViewController:ctrl animated:YES completion:nil];
        };
        [self.view addSubview:noTargetView];
        [noTargetView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.infoView.mas_bottom).offset(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        [self.view updateConstraintsIfNeeded];
        _noTargetView = noTargetView;
    }
    return _noTargetView;
}

- (void)setCurrentTarget:(Target *)currentTarget{
    _currentTarget = currentTarget;
    [self refreshData];
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData) name:SignNotificationKey object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    [self viewAnimation:MainViewAnimationTypeIn];
    [self queryCurrentTarget];
    if (self.viewWillAppearEvent) {
        self.viewWillAppearEvent();
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    [self viewAnimation:MainViewAnimationTypeOut];
}

#pragma mark - subViews setting method
- (void)refreshData{
    
    NSString *day = @"0";
    NSString *daySuffix = NSLocalizedString(@"day", nil);
    NSString *totalDay = @"0";
    NSString *targetContent = @"-";
    NSString *leaveNote = [NSString stringWithFormat:NSLocalizedString(@"LeaveTimeLeft", nil),0];
    NSString *lastSignTime = @"-";
    
    if (self.currentTarget) {
        self.noTargetView.hidden = YES;
        self.calendarButton.enabled = YES;
        
        //chinese
        if (![[NSBundle currentLanguage] hasPrefix:@"zh-Hans"]){
            NSString *suffix = [DescriptionUtil ordinalNumberSuffixWithNumber:[self.currentTarget.day integerValue]];
            daySuffix = [NSString stringWithFormat:@"%@ %@",suffix, NSLocalizedString(@"day", nil)];
        }
        
        day = [NSString stringWithFormat:@"%@",self.currentTarget.day];
        
        totalDay = [NSString stringWithFormat:@"%@",self.currentTarget.totalDays];
        targetContent = self.currentTarget.content;
        leaveNote = [NSString stringWithFormat:NSLocalizedString(@"LeaveTimeLeft", nil),self.currentTarget.flexibleTimes];
        TargetSign *lastTargetSign = [CoreDataUtil queryLastTargetSign:self.currentTarget];
        if (lastTargetSign) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
            lastSignTime = [formatter stringFromDate:lastTargetSign.signTime];
        }
    }else{
        self.noTargetView.hidden = NO;
        self.calendarButton.enabled = NO;
    }
    
    self.dayTimesLabel.text = day;
    self.dayTimesSuffixLabel.text = daySuffix;
    self.totalDayLabel.text = totalDay;
    self.targetLabel.text = targetContent;
    self.leaveNoteLabel.text = leaveNote;
    self.lastSignTimeLabel.text = lastSignTime;
}

- (void)viewAnimation:(MainViewAnimationType)type{
    CGFloat duration;
    switch (type) {
        case MainViewAnimationTypeIn:{
            duration = 0.25;
            break;
        }
        default:{
            duration = 0.35;
            break;
        }
    }
    
    CABasicAnimation *infoViewAnimation = [CABasicAnimation animation];
    [infoViewAnimation setDuration:duration];
    infoViewAnimation.keyPath = @"position.y";
    NSNumber *infoViewFromValue;
    NSNumber *infoViewToValue;
    switch (type) {
        case MainViewAnimationTypeIn:{
            infoViewFromValue = @(-self.infoView.bounds.size.height/2);
            infoViewToValue = @(self.infoView.bounds.size.height/2);
            break;
        }
        default:{
            infoViewFromValue = @(+self.infoView.bounds.size.height/2);
            infoViewToValue = @(-self.infoView.bounds.size.height/2);
            break;
        }
    }
    infoViewAnimation.fromValue = infoViewFromValue;
    infoViewAnimation.toValue = infoViewToValue;
    [self.infoView.layer addAnimation:infoViewAnimation forKey:nil];
    
    CABasicAnimation *signViewAnimation = [CABasicAnimation animation];
    [signViewAnimation setDuration:duration];
    signViewAnimation.keyPath = @"position.x";
    NSNumber *signViewFromValue;
    NSNumber *signViewToValue;
    switch (type) {
        case MainViewAnimationTypeIn:{
            signViewFromValue = @(ScreenWidth+self.signView.bounds.size.width/2);
            signViewToValue = @(ScreenWidth-self.signView.bounds.size.width/2);
            break;
        }
        default:{
            signViewFromValue = @(ScreenWidth-self.signView.bounds.size.width/2);
            signViewToValue = @(ScreenWidth+self.signView.bounds.size.width/2);
            break;
        }
    }
    signViewAnimation.fromValue = signViewFromValue;
    signViewAnimation.toValue = signViewToValue;
    [self.signView.layer addAnimation:signViewAnimation forKey:nil];
    
    CABasicAnimation *endViewAnimation = [CABasicAnimation animation];
    [endViewAnimation setDuration:duration];
    endViewAnimation.keyPath = @"position.x";
    NSNumber *endViewFromValue;
    NSNumber *endViewToValue;
    switch (type) {
        case MainViewAnimationTypeIn:{
            endViewFromValue = @(-self.endView.bounds.size.width/2);
            endViewToValue = @(self.endView.bounds.size.width/2);
            break;
        }
        default:{
            endViewFromValue = @(self.endView.bounds.size.width/2);
            endViewToValue = @(-self.endView.bounds.size.width/2);
            break;
        }
    }
    endViewAnimation.fromValue = endViewFromValue;
    endViewAnimation.toValue = endViewToValue;
    [self.endView.layer addAnimation:endViewAnimation forKey:nil];
    
    CABasicAnimation *leaveViewAnimation = [CABasicAnimation animation];
    [leaveViewAnimation setDuration:duration];
    leaveViewAnimation.keyPath = @"position.x";
    NSNumber *leaveViewFromValue;
    NSNumber *leaveViewToValue;
    switch (type) {
        case MainViewAnimationTypeIn:{
            leaveViewFromValue = @(-self.leaveView.bounds.size.width/2);
            leaveViewToValue = @(self.leaveView.bounds.size.width/2);
            break;
        }
        default:{
            leaveViewFromValue = @(self.leaveView.bounds.size.width/2);
            leaveViewToValue = @(-self.leaveView.bounds.size.width/2);
            break;
        }
    }
    leaveViewAnimation.fromValue = leaveViewFromValue;
    leaveViewAnimation.toValue = leaveViewToValue;
    [self.leaveView.layer addAnimation:leaveViewAnimation forKey:nil];
}

#pragma mark - events method
- (IBAction)clickSettingButton:(id)sender {
    if(self.settingButtonEvent){
        self.settingButtonEvent();
    }
}

- (IBAction)clickSignButton:(id)sender {
    [self signWithType:TargetSignTypeSign];
}

- (IBAction)clickEndButton:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"Are you sure to terminate the target?", nil)] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __weak typeof(self) weakSelf = self;
        [CoreDataUtil terminateTarget:self.currentTarget WithResult:TargetResultStop complete:^{
            [weakSelf targetStop];
        }];
    }];
    
    [alertController addAction:yesAction];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No,let me reconsider it.", nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:noAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)clickLeaveButton:(id)sender {
    if (self.currentTarget.flexibleTimes<=0) {
        [self.view makeToast:NSLocalizedString(@"Sorry, you have no leave times!", nil)];
    }
    [self signWithType:TargetSignTypeLeave];
}

- (IBAction)clickCalendarButton:(id)sender {
    TargetMonthlyListController *ctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TargetMonthlyListController"];
    ctrl.target = self.currentTarget;
    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark - coreData method
- (void)queryCurrentTarget{
    Target *target =[CoreDataUtil queryCurrentTarget];
    if (target) {
        __weak typeof(self) weakSelf = self;
        [CoreDataUtil updateTarget:target complete:^{
            [weakSelf targetComplete];
        } fail:^{
            [weakSelf targetFail];
        }];
    }
    self.currentTarget = target;
}

- (void)signTarget:(Target *)target signType:(TargetSignType)type{
    __weak typeof(self) weakSelf = self;
    [CoreDataUtil signTarget:target signType:type complete:^(TargetSign *targetSign) {
        [weakSelf refreshData];
        
        //to share view
        SignShareViewController *ctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"SignShareViewController"];
        ctrl.targetSign = targetSign;
        [weakSelf presentViewController:ctrl animated:YES completion:nil];
        
        //check whether target has been completed
        if ([target.day integerValue] == [target.totalDays integerValue]) {
            [CoreDataUtil terminateTarget:target WithResult:TargetResultComplete complete:^{
                [weakSelf targetComplete];
            }];
        }
    }];
    
}

- (void)signWithType:(TargetSignType)type{
    NSDate *now = [NSDate date];
    TargetSign *targetSignInOneDay = [CoreDataUtil queryTargetSign:self.currentTarget date:now];
    TargetSignType lastSignType = [targetSignInOneDay.signType integerValue];
    
    if (targetSignInOneDay) {// signed
        NSString *typeName = [DescriptionUtil signTypeDescriptionOfType:lastSignType];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"SignAlready", nil),typeName] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *resignAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Sign again", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self signTarget:self.currentTarget signType:type];
        }];
        [alertController addAction:resignAction];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }else{
        [self signTarget:self.currentTarget signType:type];
    }
}

#pragma mark - Target complete Method
- (void)targetComplete{
    TargetSucceedViewController *ctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TargetSucceedViewController"];
    ctrl.target = self.currentTarget;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ctrl animated:NO completion:nil];
    self.currentTarget = nil;
}

- (void)targetFail{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"Sorry, your target failed...", nil)  delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles: nil];
    [alertView show];
    self.currentTarget = nil;
}

- (void)targetStop{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"You have terminated the target, a new tour is waiting for you！", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Confirm", nil) otherButtonTitles: nil];
    [alertView show];
    self.currentTarget = nil;
}

@end
