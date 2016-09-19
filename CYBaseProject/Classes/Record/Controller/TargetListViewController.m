//
//  TargetListViewController.m
//  100Days
//
//  Created by Peter Lee on 16/9/2.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TargetListViewController.h"
#import "TargetListCell.h"
#import "CoreDataUtil.h"
#import "Target.h"
#import "TargetMonthlyListController.h"

@interface TargetListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *targetDatas;

@end

@implementation TargetListViewController

#pragma mark - lazy load
- (NSMutableArray *)targetDatas{
    if (!_targetDatas) {
        _targetDatas = [NSMutableArray array];
    }
    return _targetDatas;
}

#pragma mark - life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    [self configureSubViews];
    [self queryData];
}

- (void)configureSubViews{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.rowHeight = 80;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.tableView = tableView;
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.targetDatas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *datas = self.targetDatas[section][@"datas"];
    return datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"targetListCell";
    TargetListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"TargetListCell" owner:nil options:nil]lastObject];
    }
    NSArray *datas = self.targetDatas[indexPath.section][@"datas"];
    Target *target = datas[indexPath.row];
    cell.target = target;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 32)];
    NSString *year = self.targetDatas[section][@"year"];
    UILabel *yearLabel = [[UILabel alloc]init];
    yearLabel.text = year;
    yearLabel.textColor = [UIColor darkGrayColor];
    [headerView addSubview:yearLabel];
    [yearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 32;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *datas = self.targetDatas[indexPath.section][@"datas"];
    Target *target = datas[indexPath.row];
    
    TargetMonthlyListController *ctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TargetMonthlyListController"];
    ctrl.target = target;
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"是否确认删除目标？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *datas = self.targetDatas[indexPath.section][@"datas"];
        Target *target = datas[indexPath.row];
        [datas removeObjectAtIndex:indexPath.row];
        [target.managedObjectContext deleteObject:target];
        [target.managedObjectContext save:nil];
        [self.tableView reloadData];
    }];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 
- (void)queryData{
    NSManagedObjectContext *context = [CoreDataUtil shareContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Target"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
    request.sortDescriptors = @[sort];
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error||array.count<=0) return;
    
    //deal with data
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy";
    NSString *year = @"";
    
    NSMutableDictionary *yearGroupDict;
    NSMutableArray *yearTargetArray;
    
    for (Target *target in array) {
        NSString *currentYear = [formatter stringFromDate:target.startDate];
        if (![year isEqualToString:currentYear]) {
            
            if (yearGroupDict) {
                yearGroupDict[@"datas"] = yearTargetArray;
                [self.targetDatas addObject:yearGroupDict];
            }
            
            yearGroupDict = [NSMutableDictionary dictionary];
            yearTargetArray = [NSMutableArray array];
            yearGroupDict[@"year"] = currentYear;
            year = currentYear;
        }
        
        [yearTargetArray addObject:target];
    }
    
    if (yearGroupDict) {
        yearGroupDict[@"datas"] = yearTargetArray;
        [self.targetDatas addObject:yearGroupDict];
    }
    
    [self.tableView reloadData];
}

@end
