//
//  CYDatePicker.m
//  CYPicker
//
//  Created by Peter Lee on 16/3/10.
//  Copyright © 2016年 Peter Lee. All rights reserved.
//

#import "CYDatePicker.h"

@interface CYDatePicker ()

@end

@implementation CYDatePicker

@synthesize currentDate = _currentDate;
@synthesize currentCountDownDuration = _currentCountDownDuration;

#pragma mark - initialize
+ (instancetype)datePickerWithDatePickerMode:(UIDatePickerMode)datePickerMode selectedBlock:(CYDateSelectedBlock)dateSelectedBlock{
    CYDatePicker *dataPicker = [[CYDatePicker alloc]init];
    dataPicker.dateSelectedBlock = dateSelectedBlock;
    dataPicker.datePickerMode = datePickerMode;
    return dataPicker;
}

- (void)addSubViewOfContentView{
    //UIDatePicker
    self.datePicker = [[UIDatePicker alloc]initWithFrame:self.contentView.bounds];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.contentView addSubview:self.datePicker];
}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode{
    _datePickerMode = datePickerMode;
    self.datePicker.datePickerMode = datePickerMode;
}

#pragma mark - event method
- (void)clickConfirmBtn{
    [super clickConfirmBtn];
    if (self.dateSelectedBlock) {
        switch (self.datePickerMode) {
            case UIDatePickerModeCountDownTimer:
                self.dateSelectedBlock(@(self.currentCountDownDuration));
                break;
            default:
                self.dateSelectedBlock(self.currentDate);
                break;
        }
        
    }
}

- (void)showPickerWithDate:(NSDate *)date{
    self.datePicker.date = date;
    [super showPicker];
}

- (void)showPickerWithCountDownDuration:(NSTimeInterval)duration{
    self.datePicker.countDownDuration = duration;
    [super showPicker];
}

#pragma mark - get/set time method
/**
 *  current selected time
 */
- (NSDate *)currentDate{
    return self.datePicker.date;
}

- (void)setCurrentDate:(NSDate *)currentDate{
    _currentDate = currentDate;
    self.datePicker.date = currentDate;
}

/**
 *  current countDownDuration(For UIDatePickerModeCountDownTimer)
 */
- (NSTimeInterval)currentCountDownDuration{
    return self.datePicker.countDownDuration;
}

- (void)setCurrentCountDownDuration:(NSTimeInterval)currentCountDownDuration{
    _currentCountDownDuration = currentCountDownDuration;
    self.datePicker.countDownDuration = currentCountDownDuration;
}

@end
