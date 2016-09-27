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

@interface TimeReminderViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign, getter=isTimeReminderActived) BOOL timeReminderActived;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) CYDatePicker *timePicker;
@property (nonatomic, strong) NSString *notificationDateString;

@end

@implementation TimeReminderViewController

#pragma mark - lazy load
- (NSArray *)dataArray{
    if (!_dataArray) {
        _dataArray = @[];
    }
    return _dataArray;
}

- (CYDatePicker *)timePicker{
    if (!_timePicker) {
        __weak typeof(self) weakSelf = self;
        _timePicker = [CYDatePicker datePickerWithDateSelectedBlock:^(NSDate *selectedDate) {
            
            NSDateComponents *dateComponents = [[NSCalendar currentCalendar]components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:selectedDate];
            NSString *minute = [[NSString stringWithFormat:@"%2ld",dateComponents.minute]stringByReplacingOccurrencesOfString:@" " withString:@"0"];
            NSString *notificationDateString = [NSString stringWithFormat:@"%@:%@",@(dateComponents.hour),minute];
            
            weakSelf.notificationDateString = notificationDateString;
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:notificationDateString forKey:kNotificationDate];
            [userDefault synchronize];
            
            //update notification
            [weakSelf stopNotification];
            [weakSelf createNotification];
            
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            
        }];
        _timePicker.datePickerMode = UIDatePickerModeTime;
    }
    return _timePicker;
}

- (NSString *)notificationDateString{
    if (!_notificationDateString) {
        NSString *notificationDateString = [[NSUserDefaults standardUserDefaults]stringForKey:kNotificationDate];
        if (notificationDateString) {
            _notificationDateString = notificationDateString;
        }else{
            _notificationDateString = @"20:00";
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:_notificationDateString forKey:kNotificationDate];
            [userDefault synchronize];
        }
    }
    return _notificationDateString;
}

#pragma mark - life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    [self configureSubViews];
    [self dealWithData];
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
    
    NSDictionary *openModel = @{kTitleKey:NSLocalizedString(@"Active Time Reminder", nil)};
    NSDictionary *timeDetailModel = @{kTitleKey:NSLocalizedString(@"Remind me at", nil)};
    
    self.dataArray = @[
                       @[openModel],
                       @[timeDetailModel]
                       ];
    
    [self.tableView reloadData];
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
    
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:{
                    UISwitch *mainSwitch = [[UISwitch alloc]init];
                    [mainSwitch addTarget:self action:@selector(mainSwitchChange:) forControlEvents:UIControlEventValueChanged];
                    [mainSwitch setOn:self.isTimeReminderActived animated:NO];
                    cell.accessoryView = mainSwitch;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:{
            switch (indexPath.row) {
                case 0:{
                    cell.detailTextLabel.text = self.notificationDateString;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
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
        NSArray *dateStringArray = [self.notificationDateString componentsSeparatedByString:@":"];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.hour = [dateStringArray[0] integerValue];
        dateComponents.minute = [dateStringArray[1] integerValue];
        [self.timePicker showPickerByDate:[[NSCalendar currentCalendar]dateFromComponents:dateComponents]];
    }
}

#pragma mark - event method
- (void)mainSwitchChange:(UISwitch *)sw{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:sw.on forKey:kTimeReminderActived];
    [userDefaults synchronize];
    
    self.timeReminderActived = sw.on;
    
    [self stopNotification];
    if (sw.on) {
        [self createNotification];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
    }else{
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
    }
    
}

#pragma mark - notification method
- (void)createNotification{
    
    NSArray *dateStringArray = [self.notificationDateString componentsSeparatedByString:@":"];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.hour = [dateStringArray[0] integerValue];
    dateComponents.minute = [dateStringArray[1] integerValue];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:@"Hello Tom！Get up, let's play with Jerry!" arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        
        content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        
        UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
        
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"TimeReminder" content:content trigger:trigger];
        
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
        localNote.fireDate = [[NSCalendar currentCalendar]dateFromComponents:dateComponents];
        localNote.repeatInterval = NSCalendarUnitDay;
        
        // 1.2.设置弹出的内容
        localNote.alertBody = @"吃饭了吗?";
        
        // 1.6.设置音效
        localNote.soundName = UILocalNotificationDefaultSoundName;
        
        // 1.7.应用图标右上角的提醒数字
        localNote.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        
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
