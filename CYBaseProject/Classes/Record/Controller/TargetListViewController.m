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
@property (nonatomic, strong) UIView *emptyView;
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

- (UIView *)emptyView{
    if (!_emptyView) {
        _emptyView = [[UIView alloc]init];
        [self.view addSubview:_emptyView];
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        UIImageView *emptyImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty"]];
        [_emptyView addSubview:emptyImageView];
        [emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyView.mas_centerX);
            make.centerY.equalTo(_emptyView.mas_centerY).multipliedBy(0.9);
            make.width.mas_equalTo(120);
            make.height.mas_equalTo(120);
        }];
        UILabel *emptyLabel = [[UILabel alloc]init];
        emptyLabel.textColor = [UIColor grayColor];
        emptyLabel.font = [UIFont systemFontOfSize:25];
        emptyLabel.text = NSLocalizedString(@"No Record", nil);
        [_emptyView addSubview:emptyLabel];
        [emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_emptyView.mas_centerX);
            make.top.equalTo(emptyImageView.mas_bottom).offset(10);
        }];
    }
    return _emptyView;
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
    if (self.targetDatas.count==0) {
        self.emptyView.hidden = NO;
    }else{
        self.emptyView.hidden = YES;
    }
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
    return NSLocalizedString(@"Delete", nil);
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
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Are you sure to delete the target record?", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *datas = self.targetDatas[indexPath.section][@"datas"];
        Target *target = datas[indexPath.row];
        [datas removeObjectAtIndex:indexPath.row];
        [target.managedObjectContext deleteObject:target];
        [target.managedObjectContext save:nil];
        
        if(datas.count==0){
            [self.targetDatas removeObjectAtIndex:indexPath.section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationRight];
        }else{
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
    }];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - coreData method
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
