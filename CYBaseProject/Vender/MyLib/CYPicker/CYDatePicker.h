//
//  CYDatePicker.h
//  CYPicker
//
//  Created by Peter Lee on 16/3/10.
//  Copyright © 2016年 Peter Lee. All rights reserved.
//

#import "CYBasePicker.h"

typedef void(^CYDateSelectedBlock)(id selectedValue);

@interface CYDatePicker : CYBasePicker

@property (strong, nonatomic) NSDate *currentDate;
@property (assign, nonatomic) NSTimeInterval currentCountDownDuration;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (assign, nonatomic) UIDatePickerMode datePickerMode;
@property (copy, nonatomic) CYDateSelectedBlock dateSelectedBlock;

+ (instancetype)datePickerWithDatePickerMode:(UIDatePickerMode)datePickerMode selectedBlock:(CYDateSelectedBlock)dateSelectedBlock;

/**
 *  Show date picker with date
 */
- (void)showPickerWithDate:(NSDate *)date;

/**
 *  Show date picker with duration(for UIDatePickerModeCountDownTimer)
 */
- (void)showPickerWithCountDownDuration:(NSTimeInterval)duration;

@end
