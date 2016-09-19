//
//  TargetMonthlyListCell.m
//  100Days
//
//  Created by Peter Lee on 16/9/8.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TargetMonthlyListCell.h"
#import "TargetMonthlySign.h"
#import "UIColor+HexString.h"

@interface TargetMonthlyListCell ()

@property (weak, nonatomic) IBOutlet UIView *monthBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *signDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *signRateLabel;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *coverView;


@property (nonatomic, strong) NSDictionary *colorDict;

@end

@implementation TargetMonthlyListCell

- (NSDictionary *)colorDict{
    if (!_colorDict) {
        _colorDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"CalendarColorDict" ofType:@"plist"]];
    }
    return _colorDict;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setTargetMonthlySign:(TargetMonthlySign *)targetMonthlySign{
    _targetMonthlySign = targetMonthlySign;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger month = [calendar components:NSUIntegerMax fromDate:targetMonthlySign.month].month;
    NSString *monthKey = [NSString stringWithFormat:@"%@",@(month)];
    
    self.monthLabel.text = monthKey;
    self.signDayLabel.text = [NSString stringWithFormat:@"%@",@(targetMonthlySign.signDay)];
    NSString *colorHex = self.colorDict[monthKey];
    self.monthBackgroundView.backgroundColor = UICOLOR(colorHex);
    self.signRateLabel.text = [NSString stringWithFormat:@"%.f%%",targetMonthlySign.signDay*1.0/targetMonthlySign.signTotalDay*100];
    self.coverView.hidden = targetMonthlySign.isBegin;
}

@end
