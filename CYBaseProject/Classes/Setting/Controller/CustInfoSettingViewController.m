//
//  CustInfoSettingViewController.m
//  100Days
//
//  Created by Peter Lee on 16/9/8.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "CustInfoSettingViewController.h"
#import "UIView+Toast.h"

@interface CustInfoSettingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@end

@implementation CustInfoSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureSubViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)configureSubViews{
    self.confirmButton.layer.masksToBounds = YES;
    self.confirmButton.layer.cornerRadius = 22.5;
    self.confirmButton.layer.borderWidth = 1;
    self.confirmButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.closeButton.hidden = self.banClose;
    
    NSString *userName = [[NSUserDefaults standardUserDefaults]stringForKey:kUserNameKey];
    if (![NSString isBlankString:userName]) {
        self.nameTextField.text = userName;
    }
}

- (IBAction)clickConfirmButton:(id)sender {
    
    [self.view endEditing:YES];
    
    NSString *userName = self.nameTextField.text;
    if ([NSString isBlankString:userName]) {
        [self.view makeToast:@"用户名不能为空！"];
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userName forKey:kUserNameKey];
    [userDefaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
            self.view.transform = CGAffineTransformMakeTranslation(0, delta-50);
        }];
    }
}

- (void)keyboardWillHide{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (UIControl *)firstResponder{
    NSArray *inputArray = @[self.nameTextField];
    for (UIControl *ctrl in inputArray) {
        if ([ctrl isFirstResponder]) {
            return ctrl;
        }
    }
    return nil;
}

@end
