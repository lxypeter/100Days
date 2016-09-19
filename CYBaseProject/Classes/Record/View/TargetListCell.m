//
//  TargetListCell.m
//  100Days
//
//  Created by Peter Lee on 16/9/3.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "TargetListCell.h"
#import "Target.h"
#import "DescriptionUtil.h"
#import "UIColor+HexString.h"

@interface TargetListCell ()

@property (weak, nonatomic) IBOutlet UILabel *targetContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *startMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *endMonthLabel;

@end

@implementation TargetListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.statusLabel.layer.masksToBounds = YES;
    self.statusLabel.layer.cornerRadius = 3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setTarget:(Target *)target{
    self.targetContentLabel.text = target.content;
    self.totalDaysLabel.text = [NSString stringWithFormat:@"%@",target.totalDays];
    self.startMonthLabel.text = [DescriptionUtil monthDescriptionOfDate:target.startDate];
    self.startDayLabel.text = [DescriptionUtil dayDescriptionOfDate:target.startDate];
    self.endMonthLabel.text = [DescriptionUtil monthDescriptionOfDate:target.endDate];
    self.endDayLabel.text = [DescriptionUtil dayDescriptionOfDate:target.endDate];
    self.statusLabel.text = [DescriptionUtil resultDescriptionOfResult:[target.result integerValue]];
    
    switch ([target.result integerValue]) {
        case TargetResultProgressing:
            self.statusLabel.backgroundColor = UICOLOR(@"#A2DED0");
            break;
        case TargetResultComplete:
            self.statusLabel.backgroundColor = UICOLOR(@"#D2D7D3");
            break;
        case TargetResultFail:
            self.statusLabel.backgroundColor = UICOLOR(@"#F64747");
            break;
        case TargetResultStop:
            self.statusLabel.backgroundColor = UICOLOR(@"#4ECDC4");
            break;
        default:
            break;
    }
}

@end
