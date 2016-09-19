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

@property (nonatomic, strong) NoTargetView *noTargetView;
@property (nonatomic, strong) Target *currentTarget;

@end

@implementation MainViewController

#pragma mark - get/set method
- (NoTargetView *)noTargetView{
    if (!_noTargetView) {
        NoTargetView *noTargetView = [[[NSBundle mainBundle]loadNibNamed:@"NoTargetView" owner:nil options:nil]lastObject];
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
    NSString *totalDay = @"0";
    NSString *targetContent = @"-";
    NSString *leaveNote = @"您剩下0次机会";
    NSString *lastSignTime = @"-";
    
    if (self.currentTarget) {
        self.noTargetView.hidden = YES;
        self.calendarButton.enabled = YES;
        
        day = [NSString stringWithFormat:@"%@",self.currentTarget.day];
        totalDay = [NSString stringWithFormat:@"%@",self.currentTarget.totalDays];
        targetContent = self.currentTarget.content;
        leaveNote = [NSString stringWithFormat:@"您剩下%@次机会",self.currentTarget.flexibleTimes];
        TargetSign *lastTargetSign = [self queryLastTargetSign:self.currentTarget];
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
    [self signWithTarget:self.currentTarget type:TargetSignTypeSign];
}

- (IBAction)clickEndButton:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"目标一旦结束就不可重新激活，是否确定终止？"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self terminateTarget:self.currentTarget WithResult:TargetResultStop];
        
    }];
    [alertController addAction:yesAction];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"否，让我再想想" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:noAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)clickLeaveButton:(id)sender {
    if (self.currentTarget.flexibleTimes<=0) {
        [self.view makeToast:@"抱歉，您已没有请假的机会了！"];
    }
    [self signWithTarget:self.currentTarget type:TargetSignTypeLeave];
}

- (IBAction)clickCalendarButton:(id)sender {
    TargetMonthlyListController *ctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TargetMonthlyListController"];
    ctrl.target = self.currentTarget;
    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark - coreData method
- (void)queryCurrentTarget{
    NSManagedObjectContext *context = [CoreDataUtil shareContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Target"];
    request.predicate = [NSPredicate predicateWithFormat:@"result == %@",@(TargetResultProgressing)];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
    request.sortDescriptors = @[sort];
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (!error&&array.count>0) {
        Target *target = array[0];
        [self updateTarget:target];
        self.currentTarget = target;
    }else{
        [self refreshData];
    }
}

- (TargetSign *)queryLastTargetSign:(Target *)target{
    if (!target) return nil;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"signTime" ascending:NO];
    NSArray *targetSigns = [target.targetSigns sortedArrayUsingDescriptors:@[sort]];
    if(targetSigns&&targetSigns.count>0){
        return targetSigns[0];
    }
    return nil;
}

- (TargetSign *)queryTargetSign:(Target *)target date:(NSDate *)date{

    NSMutableArray<TargetSign *> *targetSigns = [NSMutableArray array];
    [target.targetSigns enumerateObjectsUsingBlock:^(TargetSign * _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj.signTime dayIntervalSinceDate:date]==0){
            [targetSigns addObject:obj];
        }
    }];

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"signTime" ascending:NO];
    [targetSigns sortUsingDescriptors:@[sort]];
    
    if(targetSigns&&targetSigns.count>0){
        return targetSigns[0];
    }
    return nil;
}

- (void)updateTarget:(Target *)target{
    
    NSManagedObjectContext *context = [CoreDataUtil shareContext];
    //update target day
    NSDate *now = [NSDate date];
    NSInteger dayInterval = [now dayIntervalSinceDate:target.startDate];
    target.day = @(dayInterval+1);
    
    //update sign
    TargetSign *lastTargetSign = [self queryLastTargetSign:target];
    NSDate *lastSignTime;
    if(lastTargetSign){
        lastSignTime = lastTargetSign.signTime;
    }else{
        lastSignTime = [target.startDate dateByAddingTimeInterval:-(60 * 60 * 24)];
    }
    NSInteger signDayInterval = [now dayIntervalSinceDate:lastSignTime];
    if (signDayInterval>1) {
        for (int index = 1; index<signDayInterval; index++) {
            
            NSInteger flexibleTimes = [target.flexibleTimes integerValue];
            if (flexibleTimes>0) {
                flexibleTimes--;
                target.flexibleTimes = @(flexibleTimes);
            }else{
                [self terminateTarget:target WithResult:TargetResultFail];
                break;
            }
            
            TargetSign *targetSigh = [NSEntityDescription insertNewObjectForEntityForName:@"TargetSign" inManagedObjectContext:context];
            targetSigh.signType = @(TargetSignTypeLeave);
            targetSigh.note = @"未签到";
            targetSigh.signTime = [[lastSignTime zeroOfDate] dateByAddingTimeInterval:(60 * 60 * 24 * index)];
            [target addTargetSignsObject:targetSigh];
        }
    }
    
    if ([context hasChanges]) {
        [context save:nil];
    }
}

- (void)signTarget:(Target *)target signType:(TargetSignType)type note:(NSString *)note time:(NSDate *)time{
    //clear sign data
    [target.targetSigns enumerateObjectsUsingBlock:^(TargetSign * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.signTime dayIntervalSinceDate:time]==0) {
            [target removeTargetSignsObject:obj];
        }
    }];
    
    //create new sign data
    TargetSign *targetSigh = [NSEntityDescription insertNewObjectForEntityForName:@"TargetSign" inManagedObjectContext:target.managedObjectContext];
    targetSigh.signType = @(type);
    targetSigh.note = note;
    targetSigh.signTime = time;
    [target addTargetSignsObject:targetSigh];
    
    if ([target.managedObjectContext hasChanges]) {
        [target.managedObjectContext save:nil];
    }
    
    [self refreshData];
    
    if (type == TargetSignTypeSign) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"签到成功！"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.view makeToast:@"下个版本吧╮(╯_╰)╭"];
        }];
        [alertController addAction:shareAction];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (void)signWithTarget:(Target *)target type:(TargetSignType)type{
    NSDate *now = [NSDate date];
    TargetSign *targetSignInOneDay = [self queryTargetSign:self.currentTarget date:now];
    TargetSignType lastSignType = [targetSignInOneDay.signType integerValue];
    if (targetSignInOneDay) {// signed
        NSString *typeName = [DescriptionUtil signTypeDescriptionOfType:lastSignType];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"您今天已签到，状态为【%@】",typeName] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *resignAction = [UIAlertAction actionWithTitle:@"重新签到" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if (lastSignType!=type) {
                if(lastSignType == TargetSignTypeLeave){
                    target.flexibleTimes = @([target.flexibleTimes integerValue]+1);
                }else if (lastSignType == TargetSignTypeSign){
                    target.flexibleTimes = @([target.flexibleTimes integerValue]-1);
                }
            }
            
            [self signTarget:target signType:type note:@"" time:[NSDate date]];
        }];
        [alertController addAction:resignAction];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    //unsigned
    [self signTarget:target signType:type note:@"" time:now];
}

- (void)terminateTarget:(Target *)target WithResult:(TargetResult)result{
    NSManagedObjectContext *context = target.managedObjectContext;
    target.result = @(result);
    if ([context hasChanges]) {
        [context save:nil];
    }
    
    switch (result) {
        case TargetResultComplete:{
            
            break;
        }
        case TargetResultFail:{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"很遗憾，您的目标失败了……" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            break;
        }
        case TargetResultStop:{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"您的目标已终止，快开始新的征程吧！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            break;
        }
        default:
            break;
    }
    
    self.currentTarget = nil;
}

@end
