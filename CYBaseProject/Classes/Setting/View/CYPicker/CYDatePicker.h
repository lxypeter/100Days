//
//  CYDatePicker.h
//  CYPicker
//
//  Created by Peter Lee on 16/3/10.
//  Copyright © 2016年 Peter Lee. All rights reserved.
//

#import "CYBasePicker.h"

typedef void(^DateSelectedBlock)(NSDate *selectedDate);

@interface CYDatePicker : CYBasePicker

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (assign, nonatomic) UIDatePickerMode datePickerMode;
@property (copy, nonatomic) DateSelectedBlock dateSelectedBlock;
@property (strong, nonatomic) NSDate *currentDate;

+ (instancetype)datePickerWithDateSelectedBlock:(DateSelectedBlock)dateSelectedBlock;

/**
 *  显示Picker并设定当前选中时间
 */
- (void)showPickerByDate:(NSDate *)date;

@end
