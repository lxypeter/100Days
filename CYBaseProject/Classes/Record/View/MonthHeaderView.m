//
//  MonthHeaderView.m
//  100Days
//
//  Created by Peter Lee on 16/9/7.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "MonthHeaderView.h"
#import "DescriptionUtil.h"

@interface MonthHeaderView ()

@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UIView *seperateLine;
@property (nonatomic, strong) UIView *spaceView;

@end

@implementation MonthHeaderView

- (instancetype)init{
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _spaceView = [[UIView alloc]init];
        [self addSubview:_spaceView];
        [_spaceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(0);
        }];
        _monthLabel = [[UILabel alloc]init];
        _monthLabel.font = [UIFont systemFontOfSize:15];
        _monthLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_monthLabel];
        [_monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.left.equalTo(_spaceView.mas_right).offset(0);
            make.width.mas_equalTo(ScreenWidth/7);
        }];
        _seperateLine = [[UIView alloc]init];
        _seperateLine.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_seperateLine];
        [_seperateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.left.equalTo(_spaceView.mas_right).offset(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

- (void)setStartWeakDay:(NSInteger)startWeakDay{
    _startWeakDay = startWeakDay;
    
    CGFloat width = startWeakDay * ScreenWidth/7;
    [self.spaceView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
}

- (void)setMonth:(NSDate *)month{
    _month = month;
    NSString *monthDescription = [DescriptionUtil monthDescriptionOfDate:month];
    self.monthLabel.text = monthDescription;
}

@end
