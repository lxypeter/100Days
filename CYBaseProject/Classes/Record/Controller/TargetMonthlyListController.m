//
//  TargetMonthlyListController.m
//  100Days
//
//  Created by Peter Lee on 16/9/8.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TargetMonthlyListController.h"
#import "Target.h"
#import "NSDate+CYCompare.h"
#import "TargetMonthlySign.h"
#import "TargetMonthlyListCell.h"
#import "TargetMonthlyViewController.h"
#import "UIColor+HexString.h"
#import "DescriptionUtil.h"

@interface TargetMonthlyListController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *totalDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *passDaysLabel;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation TargetMonthlyListController

#pragma mark - lazy load
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubViews];
    [self dealWithData];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)configureSubViews{
    
    self.title = NSLocalizedString(@"Target", nil);
    self.tableView.backgroundColor = UICOLOR(@"#EBEBF1");
    self.tableView.rowHeight = 68.0;
    self.totalDaysLabel.text = [NSString stringWithFormat:@"%@",self.target.totalDays];
    self.passDaysLabel.text = [NSString stringWithFormat:NSLocalizedString(@"DaysPassed", nil),self.target.day];
    self.contentLabel.text = self.target.content;
    self.stateLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.stateLabel.layer.borderWidth = 2;
    self.stateLabel.text = [DescriptionUtil resultDescriptionOfResult:[self.target.result integerValue]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd";
    self.startDateLabel.text = [formatter stringFromDate:self.target.startDate];
    self.endDateLabel.text = [formatter stringFromDate:self.target.endDate];
    
}

#pragma mark - deal data method
- (void)dealWithData{
    if(!self.target) return;
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.locale = [NSLocale currentLocale];
    
    //create TargetMonthlySign object
    NSArray *monthsArray = [self monthsArrayFromDate:self.target.startDate toDate:self.target.endDate];
    for (NSDate *month in monthsArray) {
        TargetMonthlySign *monthlySign = [[TargetMonthlySign alloc]init];
        
        monthlySign.signTotalDay = [self calculateValidateSignDayInMonth:month];
        monthlySign.month = month;
        monthlySign.begin = !([month earlierDate:now]==now);
        monthlySign.signDay = 0;
        monthlySign.signDictionary = [NSMutableDictionary dictionary];
        
        [self.dataArray addObject:monthlySign];
    }
    
    //dispatch TargetSign to each TargetMonthlySign object
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"signTime" ascending:NO];
    NSArray *signArray = [self.target.targetSigns sortedArrayUsingDescriptors:@[descriptor]];
    
    for (TargetMonthlySign *monthlySign in self.dataArray) {
        for (TargetSign *targetSign in signArray) {
            NSInteger month = [calendar components:NSUIntegerMax fromDate:targetSign.signTime].month;
            NSInteger day = [calendar components:NSUIntegerMax fromDate:targetSign.signTime].day;
            NSInteger signMonth = [calendar components:NSUIntegerMax fromDate:monthlySign.month].month;
            if (signMonth==month) {
                NSString *dayString = [NSString stringWithFormat:@"%@",@(day)];
                [monthlySign.signDictionary setObject:targetSign forKey:dayString];
                if ([targetSign.signType integerValue]==TargetSignTypeSign) {
                    monthlySign.signDay++;
                }
            }
        }
    }
    
    [self.tableView reloadData];
}

- (NSInteger)calculateValidateSignDayInMonth:(NSDate *)monthDate{
    
    NSDate *startDate = self.target.startDate;
    NSDate *endDate = self.target.endDate;
    
    NSDate *firstDay = [monthDate firstDateOfCurrentMonth];
    NSDate *lastDay = [monthDate lastDateOfCurrentMonth];
    
    if ([firstDay compare:startDate]!=NSOrderedDescending&&[lastDay compare:endDate]!=NSOrderedDescending) {
        return [lastDay dayIntervalSinceDate:startDate]+1;
    }else if ([firstDay compare:startDate]!=NSOrderedAscending&&[lastDay compare:endDate]!=NSOrderedDescending){
        return [lastDay dayIntervalSinceDate:firstDay]+1;
    }else if ([firstDay compare:startDate]!=NSOrderedAscending&&[lastDay compare:endDate]!=NSOrderedAscending){
        return [endDate dayIntervalSinceDate:firstDay]+1;
    }else if ([firstDay compare:startDate]!=NSOrderedDescending&&[lastDay compare:endDate]!=NSOrderedAscending){
        return [endDate dayIntervalSinceDate:startDate]+1;
    }
    
    return 0;
}

- (NSArray *)monthsArrayFromDate:(NSDate *)startDate toDate:(NSDate *)endDate{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.locale = [NSLocale currentLocale];
    
    NSDateComponents *startDateComponents = [calendar components:NSUIntegerMax fromDate:startDate];
    NSDateComponents *endDateComponents = [calendar components:NSUIntegerMax fromDate:endDate];
    
    if (startDateComponents.year==endDateComponents.year&&startDateComponents.month==endDateComponents.month) {
        startDateComponents.day = 1;
        return @[[startDate firstDateOfCurrentMonth]];
    }
    
    NSInteger yearInterval = endDateComponents.year-startDateComponents.year;
    NSInteger monthInterval = endDateComponents.month-startDateComponents.month;
    
    NSMutableArray *monthsArray = [NSMutableArray array];
    
    
    for (int i = 0; i<=yearInterval * 12 + monthInterval; i++) {
        
        NSInteger month = startDateComponents.month + i;
        NSInteger year = startDateComponents.year;
        if (month>12) {
            month = month - 12;
            year++;
        }
        
        NSDateComponents *resultComponents = [[NSDateComponents alloc]init];
        resultComponents.year = year;
        resultComponents.month = month;
        resultComponents.day = 1;
        NSDate *resultDate = [[calendar dateFromComponents:resultComponents]zeroOfDate];
        [monthsArray addObject:resultDate];
    }
    
    return [monthsArray copy];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"TargetMonthlyListCell";
    TargetMonthlyListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[NSBundle currentBundle]loadNibNamed:@"TargetMonthlyListCell" owner:nil options:nil]lastObject];
    }
    TargetMonthlySign *monthlySign = self.dataArray[indexPath.row];
    cell.targetMonthlySign = monthlySign;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    TargetMonthlyViewController *ctrl = [[TargetMonthlyViewController alloc]init];
    ctrl.selectedIndex = indexPath.row;
    ctrl.targetMonthlySigns = self.dataArray;
    ctrl.target = self.target;
    [self.navigationController pushViewController:ctrl animated:YES];
}

@end
