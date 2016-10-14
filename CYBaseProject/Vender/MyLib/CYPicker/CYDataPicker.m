//
//  CYDataPicker.m
//  100Days
//
//  Created by Peter Lee on 16/9/27.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "CYDataPicker.h"

const static NSInteger kLoopRound = 50;

@interface CYDataPicker ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *dataPickerView;

@end

@implementation CYDataPicker

#pragma mark - 初始化
+ (instancetype)dataPickerWithType:(CYDataPickerType)dataPickerType dataSource:(NSArray *)dataSource loop:(BOOL)loop{
    CYDataPicker *picker = [[CYDataPicker alloc] init];
    picker.dataPickerType = dataPickerType;
    picker.dataSource = dataSource;
    picker.loop = loop;
    return picker;
}

- (void)addSubViewOfContentView{
    self.dataPickerView = [[UIPickerView alloc]initWithFrame:self.contentView.bounds];
    self.dataPickerView.dataSource = self;
    self.dataPickerView.delegate = self;
    [self.contentView addSubview:self.dataPickerView];
}

- (void)setDataSource:(NSArray *)dataSource{
    _dataSource = dataSource;
    if (self.dataPickerView) {
        [self.dataPickerView reloadAllComponents];
    }
}

- (void)setWidthPercent:(CGFloat)widthPercent{
    if (widthPercent>1) widthPercent = 1;
    else if(widthPercent<0) widthPercent = 0;
    _widthPercent = widthPercent;
    CGRect pickerFrame = self.dataPickerView.frame;
    pickerFrame.size.width = pickerFrame.size.width * widthPercent;
    pickerFrame.origin.x = (self.contentView.bounds.size.width - pickerFrame.size.width)/2;
    self.dataPickerView.frame = pickerFrame;
}

#pragma mark - 点击事件
- (void)clickConfirmBtn{
    [super clickConfirmBtn];
    
    switch (self.dataPickerType) {
        case CYDataPickerTypeSingleSelect:{
            
            if (self.dataSingleSelectedBlock) {
                NSInteger selectedIndex = [self.dataPickerView selectedRowInComponent:0];
                NSString *selectedValue;
                if (selectedIndex != -1) {
                    selectedValue = self.dataSource[selectedIndex];
                }
                self.dataSingleSelectedBlock(selectedValue,selectedIndex);
            }
            
            break;
        }
        case CYDataPickerTypeMultiSelect:{
            
            if (self.dataMultiSelectedBlock) {
                NSMutableArray *selectedValues = [NSMutableArray array];
                NSMutableArray *selectedIndexs = [NSMutableArray array];
                [self.dataSource enumerateObjectsUsingBlock:^(NSArray *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSInteger selectedIndex = [self.dataPickerView selectedRowInComponent:idx];
                    NSString *selectedValue = @"";
                    if (selectedIndex != -1) {
                        selectedValue = self.dataSource[idx][selectedIndex];
                    }
                    [selectedIndexs addObject:@(selectedIndex)];
                    [selectedValues addObject:selectedValue];
                }];
                
                self.dataMultiSelectedBlock([selectedValues copy],[selectedIndexs copy]);
            }
            
            break;
        }
    }
}

- (void)showPicker{
    switch (self.dataPickerType) {
        case CYDataPickerTypeSingleSelect:{
            NSInteger selectedRow = 0;
            if (self.isLoop) {
                selectedRow = kLoopRound/2*self.dataSource.count;
            }
            [self.dataPickerView selectRow:selectedRow inComponent:0 animated:YES];
            break;
        }
        case CYDataPickerTypeMultiSelect:{
            [self.dataSource enumerateObjectsUsingBlock:^(NSArray * _Nonnull componentSource, NSUInteger idx, BOOL * _Nonnull stop) {
                NSInteger selectedRow = 0;
                if (self.isLoop) {
                    selectedRow = kLoopRound/2*componentSource.count;
                }
                [self.dataPickerView selectRow:selectedRow inComponent:idx animated:YES];
            }];
            break;
        }
    }
    [super showPicker];
}

- (void)showPickerWithSelectedRow:(NSInteger)row{
    switch (self.dataPickerType) {
        case CYDataPickerTypeSingleSelect:{
            if (self.isLoop) {
                row = kLoopRound/2*self.dataSource.count+row;
            }
            [self.dataPickerView selectRow:row inComponent:0 animated:YES];
            break;
        }
        case CYDataPickerTypeMultiSelect:{
            break;
        }
    }
    [super showPicker];
}

- (void)showPickerWithSelectedRows:(NSArray *)selectedIndexs{
    switch (self.dataPickerType) {
        case CYDataPickerTypeSingleSelect:{
            NSInteger selectedRow = [selectedIndexs[0] integerValue];
            if (self.isLoop) {
                selectedRow = kLoopRound/2*self.dataSource.count+selectedRow;
            }
            [self.dataPickerView selectRow:selectedRow inComponent:0 animated:YES];
            break;
        }
        case CYDataPickerTypeMultiSelect:{
            [selectedIndexs enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSInteger selectedRow = [obj integerValue];
                if (self.isLoop) {
                    NSArray *componentSource = self.dataSource[idx];
                    selectedRow = kLoopRound/2*componentSource.count+selectedRow;
                }
                [self.dataPickerView selectRow:selectedRow inComponent:idx animated:YES];
            }];
            break;
        }
    }
    [super showPicker];
}

#pragma mark - UIPickerView 代理
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    switch (self.dataPickerType) {
        case CYDataPickerTypeSingleSelect:{
            return 1;
        }
        case CYDataPickerTypeMultiSelect:{
            return self.dataSource.count;
        }
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (self.dataPickerType) {
        case CYDataPickerTypeSingleSelect:{
            if(self.isLoop&&self.dataSource.count>1){
                return self.dataSource.count*kLoopRound;
            }
            return self.dataSource.count;
        }
        case CYDataPickerTypeMultiSelect:{
            NSArray *componentSource = self.dataSource[component];
            if(self.isLoop&&componentSource.count>1){
                return componentSource.count*kLoopRound;
            }
            return componentSource.count;
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *title;
    switch (self.dataPickerType) {
        case CYDataPickerTypeSingleSelect:{
            if (self.isLoop&&self.dataSource.count>1) {
                title = self.dataSource[row%self.dataSource.count];
            }else{
                title = self.dataSource[row];
            }
            break;
        }
        case CYDataPickerTypeMultiSelect:{
            NSArray *componentSource = self.dataSource[component];
            if (self.isLoop&&componentSource.count>1) {
                title = componentSource[row%componentSource.count];
            }else{
                title = componentSource[row];
            }
            break;
        }
    }
    
    if (title && [title isKindOfClass:[NSString class]]) {
        return title;
    }
    
    return @"";
}

@end
