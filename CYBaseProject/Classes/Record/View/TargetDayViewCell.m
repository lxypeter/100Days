//
//  TargetDayViewCell.m
//  100Days
//
//  Created by Peter Lee on 16/9/6.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TargetDayViewCell.h"
#import "TargetSign.h"
#import "DescriptionUtil.h"
#import "UIColor+HexString.h"
#import "TargetCalendarDay.h"

@interface TargetDayViewCell ()

@end

@implementation TargetDayViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setTargetCalendarDay:(TargetCalendarDay *)targetCalendarDay{
    _targetCalendarDay = targetCalendarDay;
    
    NSString *dayString = [NSString stringWithFormat:@"%@",@(targetCalendarDay.day)];
    if (targetCalendarDay.day>0) {
        self.dayLabel.text = dayString;
    }else{
        self.dayLabel.text = @"";
    }
    
    if (targetCalendarDay.targetSign) {
        self.stateLabel.text = [DescriptionUtil signTypeDescriptionOfType:[targetCalendarDay.targetSign.signType integerValue]];
    }else{
        self.stateLabel.text = @"";
    }
    
    switch ([targetCalendarDay.targetSign.signType integerValue]) {
        case TargetSignTypeSign:
            self.stateLabel.backgroundColor = UICOLOR(@"#A2DED0");
            break;
        case TargetSignTypeLeave:
            self.stateLabel.backgroundColor = UICOLOR(@"#D2D7D3");
            break;
    }
    
    if (!targetCalendarDay.isNeedSign&&targetCalendarDay.day>0) {
        self.dayLabel.textColor = UICOLOR(@"#F1F1F1");
    }else{
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.dayLabel.textColor = [UIColor blackColor];
    }
    
    self.todayLineView.hidden = !targetCalendarDay.isToday;
    
}

@end
