//
//  TargetMonthlyViewController.m
//  100Days
//
//  Created by Peter Lee on 16/9/4.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TargetMonthlyViewController.h"
#import "TargetDayViewCell.h"
#import "NSDate+CYCompare.h"
#import "WeekDayHeaderView.h"
#import "TargetMonthlySign.h"
#import "TargetSign.h"
#import "DescriptionUtil.h"
#import "MonthHeaderView.h"
#import "TargetCalendarDay.h"
#import "SignShareViewController.h"

#define kCollectionCellId @"TargetDayViewCell"
#define kCollectionMonthHeaderId @"MonthHeaderView"

@interface TargetMonthlyViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation TargetMonthlyViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubViews];
    
}

- (void)configureSubViews{
    
    self.title = NSLocalizedString(@"Calander", nil);
    
    WeekDayHeaderView *headerView = [[[NSBundle currentBundle]loadNibNamed:@"WeekDayHeaderView" owner:nil options:nil]lastObject];
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(30);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsVerticalScrollIndicator = NO;
    
    [collectionView registerClass:[MonthHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionMonthHeaderId];
    
    [collectionView registerNib:[UINib nibWithNibName:@"TargetDayViewCell" bundle:nil] forCellWithReuseIdentifier:kCollectionCellId];
    [self.view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    self.collectionView = collectionView;
    
    [self.collectionView performBatchUpdates:^{} completion:^(BOOL finished) {
        if(self.selectedIndex!=0){
            
            TargetMonthlySign *targetMonthlySign = self.targetMonthlySigns[self.selectedIndex-1];
            NSInteger lastDayOfLastMonth = targetMonthlySign.startWeakDay+targetMonthlySign.monthTotalDay-1;
            
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:lastDayOfLastMonth inSection:self.selectedIndex-1] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }
    }];
    
}

#pragma mark - collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.targetMonthlySigns.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    TargetMonthlySign *targetMonthlySign = self.targetMonthlySigns[section];
    return targetMonthlySign.startWeakDay+targetMonthlySign.monthTotalDay;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    MonthHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionMonthHeaderId forIndexPath:indexPath];
    
    TargetMonthlySign *targetMonthlySign = self.targetMonthlySigns[indexPath.section];
    headerView.month = targetMonthlySign.month;
    headerView.startWeakDay = targetMonthlySign.startWeakDay;
    
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat screenWidth = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    return CGSizeMake(screenWidth, 30);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TargetDayViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionCellId forIndexPath:indexPath];
    
    TargetMonthlySign *targetMonthlySign = self.targetMonthlySigns[indexPath.section];
    TargetCalendarDay *dayModel = [self targetCalendarDayWithTargetMonthlySign:targetMonthlySign index:indexPath.row];
    cell.targetCalendarDay = dayModel;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    CGFloat cellWidth = (screenWidth)/7;
    return CGSizeMake(cellWidth,cellWidth*1.2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TargetMonthlySign *targetMonthlySign = self.targetMonthlySigns[indexPath.section];
    TargetCalendarDay *dayModel = [self targetCalendarDayWithTargetMonthlySign:targetMonthlySign index:indexPath.row];
    
    if (dayModel.targetSign) {
        SignShareViewController *ctrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"SignShareViewController"];
        ctrl.targetSign = dayModel.targetSign;
        [self presentViewController:ctrl animated:YES completion:nil];
    }
    
}

//generate cell model
- (TargetCalendarDay *)targetCalendarDayWithTargetMonthlySign:(TargetMonthlySign *)targetMonthlySign index:(NSInteger)index{
    
    TargetCalendarDay *dayModel = [[TargetCalendarDay alloc]init];
    NSInteger day = index-targetMonthlySign.startWeakDay+1;
    dayModel.day = day;
    dayModel.targetSign = targetMonthlySign.signDictionary[[NSString stringWithFormat:@"%@",@(day)]];
    
    if (day>0) {
        NSDate *startDate = [self.target.startDate zeroOfDate];
        NSDate *endDate = [self.target.endDate zeroOfDate];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dayComponents = [calendar components:NSUIntegerMax fromDate:targetMonthlySign.month];
        dayComponents.day = day;
        NSDate *currentDay = [[calendar dateFromComponents:dayComponents]zeroOfDate];
        if ([currentDay compare:startDate]!=NSOrderedAscending&&[currentDay compare:endDate]!=NSOrderedDescending) {
            dayModel.needSign = YES;
        }
        
        if ([currentDay dayIntervalSinceDate:[NSDate date]]==0) {
            dayModel.today = YES;
        }
    }
    
    return dayModel;
}

@end
