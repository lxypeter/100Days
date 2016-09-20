//
//  SetTargetViewController.m
//  100Days
//
//  Created by Peter Lee on 16/8/31.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "SetTargetViewController.h"
#import "UIPlaceHolderTextView.h"
#import "UIView+Toast.h"
#import "CoreDataUtil.h"
#import "Target.h"

@interface SetTargetViewController () <UITextViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *targetView;
@property (weak, nonatomic) IBOutlet UITextField *dayTextField;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *targetTextView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *inputNumLabel;
@property (weak, nonatomic) IBOutlet UITextField *flexibleTimesTextField;

@end

@implementation SetTargetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)configureSubViews{
    self.targetTextView.placeholder = NSLocalizedString(@"A simple target in 50 characters", nil);
    
    self.targetView.layer.cornerRadius = 8;
    self.targetView.layer.masksToBounds = YES;
    
    self.confirmButton.layer.cornerRadius = 5;
    self.confirmButton.layer.masksToBounds = YES;
}

#pragma mark - event method
- (IBAction)clickCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickConfirmButton:(id)sender {
    //validate target
    NSString *targetContent = self.targetTextView.text;
    if(targetContent.length==0){
        [[UIApplication sharedApplication].keyWindow makeToast:NSLocalizedString(@"Please input your target!", nil)];
        return;
    }
    
    //save target
    NSManagedObjectContext *context = [CoreDataUtil shareContext];
    Target *target = [NSEntityDescription insertNewObjectForEntityForName:@"Target" inManagedObjectContext:context];
    target.totalDays = @([self.dayTextField.text intValue]);
    target.content = targetContent;
    NSDate *startDate = [NSDate date];
    target.startDate = startDate;
    NSInteger timeInterval = ([self.dayTextField.text intValue]-1) * 60 * 60 * 24;
    NSDate *endDate = [startDate dateByAddingTimeInterval:timeInterval];
    target.endDate = endDate;
    target.day = @1;
    target.flexibleTimes = @([self.flexibleTimesTextField.text intValue]);
    target.result = @(TargetResultProgressing);
    
    if ([context hasChanges]) {
        [context save:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - delegate method
#pragma mark textView
- (void)textViewDidChange:(UITextView *)textView{
    if (textView == self.targetTextView) {
        if (textView.text.length>50) {
            textView.text = [textView.text substringToIndex:50];
        }
        self.inputNumLabel.text = [NSString stringWithFormat:@"%@",@(textView.text.length)];
    }
}

#pragma mark textField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.dayTextField||textField == self.flexibleTimesTextField) {
        if (![NSString isInt:string]&&![NSString isBlankString:string]) return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.dayTextField) {
        if([textField.text intValue]>100){
            textField.text = @"100";
            [[UIApplication sharedApplication].keyWindow makeToast:NSLocalizedString(@"A reasonable time range makes the target easy to achieve. Please control the days between 7 and 100.", nil)];
        }
        if([textField.text intValue]<7){
            textField.text = @"7";
            [[UIApplication sharedApplication].keyWindow makeToast:NSLocalizedString(@"A reasonable time range makes the target easy to achieve. Please control the days between 7 and 100.", nil)];
        }
        self.flexibleTimesTextField.text = [NSString stringWithFormat:@"%@",@([textField.text intValue]/10)];
    }else if (textField == self.flexibleTimesTextField){
        if ([textField.text intValue]/[self.dayTextField.text intValue]>0.2) {
            textField.text = [NSString stringWithFormat:@"%.f",[self.dayTextField.text intValue] * 0.2];
            [[UIApplication sharedApplication].keyWindow makeToast:NSLocalizedString(@"Leave times are up to one fifth of the total days", nil)];
        }
    }
}

#pragma mark - keybroad method
- (void)keyboardWillShow:(NSNotification *)notifi{
    
    CGRect beginUserInfo = [[notifi.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]   CGRectValue];
    if (beginUserInfo.size.height <=44) return;
    
    UIControl *textInput = [self firstResponder];
    CGRect parentRect = [textInput.superview convertRect:textInput.frame toView:nil];
    CGFloat maxY = CGRectGetMaxY(parentRect);
    
    CGRect kbEndFrm = [notifi.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbY = kbEndFrm.origin.y;
    
    CGFloat delta = kbY - maxY;
    if(delta < 0){
        [UIView animateWithDuration:0.25 animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, delta);
        }];
    }
}

- (void)keyboardWillHide{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (UIControl *)firstResponder{
    NSArray *inputArray = @[self.flexibleTimesTextField,self.dayTextField,self.targetTextView];
    for (UIControl *ctrl in inputArray) {
        if ([ctrl isFirstResponder]) {
            return ctrl;
        }
    }
    return nil;
}

@end
