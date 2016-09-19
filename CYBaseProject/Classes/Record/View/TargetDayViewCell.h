//
//  TargetDayViewCell.h
//  100Days
//
//  Created by Peter Lee on 16/9/6.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TargetCalendarDay;
@interface TargetDayViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UIView *todayLineView;
@property (nonatomic, strong) TargetCalendarDay *targetCalendarDay;

@end
