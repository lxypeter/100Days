//
//  TimeReminderViewController.m
//  100Days
//
//  Created by Peter Lee on 16/9/26.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TimeReminderViewController.h"
#import "CYPicker.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

static NSString *kTimeReminderActived = @"TimeReminderActived";
static NSString *kNotificationDate = @"NotificationDate";
const static NSString *kTitleKey = @"title";
const static NSString *kDetailKey = @"detail";
const static NSString *kType = @"cellType";

typedef NS_ENUM(NSInteger,TRCellType) {
    TRCellTypeSwitch,
    TRCellTypeAccessory
};

@interface TimeReminderViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign, getter=isTimeReminderActived) BOOL timeReminderActived;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) CYDatePicker *datePicker;
@property (nonatomic, strong) NSDate *notificationDate;

@end

@implementation TimeReminderViewController

#pragma mark - lazy load
- (NSArray *)dataArray{
    if (!_dataArray) {
        _dataArray = @[];
    }
    return _dataArray;
}

- (CYDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [CYDatePicker datePickerWithDateSelectedBlock:^(NSDate *selectedDate) {
            
        }];
        _datePicker.datePickerMode = UIDatePickerModeTime;
    }
    return _datePicker;
}

- (NSDate *)notificationDate{
    if (!_notificationDate) {
        NSTimeInterval timeInterval = [[NSUserDefaults standardUserDefaults]integerForKey:kNotificationDate];
        if (timeInterval<=0) {
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            dateComponents.hour = 20;
            dateComponents.minute = 30;
            _notificationDate = [dateComponents date];
        }else{
            _notificationDate = [[NSDate alloc]initWithTimeIntervalSinceReferenceDate:timeInterval];
        }
    }
    return _notificationDate;
}

#pragma mark - life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    [self dealWithData];
    [self configureSubViews];
}

- (void)configureSubViews{
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.rowHeight = 44;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView = tableView;
}

- (void)dealWithData{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.timeReminderActived = [userDefaults boolForKey:kTimeReminderActived];
    
    NSDictionary *openModel = @{kTitleKey:NSLocalizedString(@"Active Time Reminder", nil),kDetailKey:@"",kType:@(TRCellTypeSwitch)};
    NSDictionary *timeDetailModel = @{kTitleKey:NSLocalizedString(@"Remind me at", nil),kDetailKey:@"7:00",kType:@(TRCellTypeAccessory)};
    
    self.dataArray = @[
                       @[openModel],
                       @[timeDetailModel]
                       ];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.isTimeReminderActived) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *sectionArray = self.dataArray[section];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellId = @"TimeReminderCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *model = self.dataArray[indexPath.section][indexPath.row];
    
    cell.textLabel.text = model[kTitleKey];
    cell.detailTextLabel.text = model[kDetailKey];
    
    switch ([model[kType] integerValue]) {
        case TRCellTypeSwitch:{
            UISwitch *mainSwitch = [[UISwitch alloc]init];
            [mainSwitch addTarget:self action:@selector(mainSwitchChange:) forControlEvents:UIControlEventValueChanged];
            [mainSwitch setOn:self.isTimeReminderActived animated:NO];
            cell.accessoryView = mainSwitch;
            break;
        }
        case TRCellTypeAccessory:{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1:{
            UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
            UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, ScreenWidth - 30, 20)];
            headerLabel.font = [UIFont systemFontOfSize:15];
            headerLabel.textColor = [UIColor lightGrayColor];
            headerLabel.text = NSLocalizedString(@"Daily Reminder", nil);
            [headerView addSubview:headerLabel];
            return headerView;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1&&indexPath.row==0) {
        [self.datePicker showPickerByDate:self.notificationDate];
    }
}

#pragma mark - event method
- (void)mainSwitchChange:(UISwitch *)sw{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:sw.on forKey:kTimeReminderActived];
    [userDefaults synchronize];
    
    self.timeReminderActived = sw.on;
    
    if (sw.on) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
    }else{
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
    }
    
}

#pragma mark - notification method
- (void)createNotification{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        //            //Deliver the notification at 08:30 everyday
        //            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        //            dateComponents.hour = 8;
        //            dateComponents.minute = 30;
        //            UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"Elon said:" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:@"Hello Tom！Get up, let's play with Jerry!"
                                                             arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        
        /// 4. update application icon badge number
        content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        // Deliver the notification in five seconds.
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
                                                      triggerWithTimeInterval:5.f repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                                                              content:content trigger:trigger];
        /// 3. schedule localNotification
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"add NotificationRequest succeeded!");
            }
        }];
#endif
    }else{
        // 1.创建本地通知
        UILocalNotification *localNote = [[UILocalNotification alloc] init];
        
        // 1.1.设置什么时间弹出
        localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        
        // 1.2.设置弹出的内容
        localNote.alertBody = @"吃饭了吗?";
        
        // 1.3.设置锁屏状态下,显示的一个文字
        localNote.alertAction = @"快点打开";
        
        // 1.4.显示启动图片
        localNote.alertLaunchImage = @"123";
        
        // 1.5.是否显示alertAction的文字(默认是YES)
        localNote.hasAction = YES;
        
        // 1.6.设置音效
        localNote.soundName = UILocalNotificationDefaultSoundName;
        
        // 1.7.应用图标右上角的提醒数字
        localNote.applicationIconBadgeNumber = 999;
        
        // 1.8.设置UserInfo来传递信息
        localNote.userInfo = @{@"alertBody" : localNote.alertBody, @"applicationIconBadgeNumber" : @(localNote.applicationIconBadgeNumber)};
        
        // 2.调度通知
        [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
    }
}

- (void)stopNotification{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
#endif
    } else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

@end
