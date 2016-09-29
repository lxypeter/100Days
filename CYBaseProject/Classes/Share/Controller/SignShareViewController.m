//
//  SignShareViewController.m
//  100Days
//
//  Created by Peter Lee on 16/9/20.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "SignShareViewController.h"
#import "Target.h"
#import "DescriptionUtil.h"
#import "UIColor+HexString.h"
#import "UIPlaceHolderTextView.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

@interface SignShareViewController () <CAAnimationDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDaysLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *signNoteLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIView *signInfoView;
@property (weak, nonatomic) IBOutlet UIView *editNoteView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *noteTextView;
@property (weak, nonatomic) IBOutlet UILabel *textNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic, assign, getter=isEditMode) BOOL editMode;

@end

@implementation SignShareViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    [self configureSubViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)configureSubViews{
    self.headerImageView.layer.masksToBounds = YES;
    self.headerImageView.layer.cornerRadius = 42.5;
    self.headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headerImageView.layer.borderWidth = 3;
    
    self.confirmButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.confirmButton.layer.borderWidth = 0.5;
    self.shareButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.shareButton.layer.borderWidth = 0.5;
    
    self.noteTextView.placeholder = @"";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults stringForKey:kUserNameKey];
    if (![NSString isBlankString:userName]) {
        self.nameLabel.text = userName;
    }
    NSData *userHeaderData = [userDefaults dataForKey:kUserHeaderKey];
    if (userHeaderData) {
        self.headerImageView.image = [UIImage imageWithData:userHeaderData];
    }
    
    //about targetSign data
    if (!self.targetSign) return;
    
    self.totalDaysLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TargetDayType", nil),self.targetSign.target.totalDays];
    
    NSString *dayString = [DescriptionUtil dayDescriptionOfDay:[self.targetSign.target.day integerValue]];
    self.currentDayLabel.text = [NSString stringWithFormat:NSLocalizedString(@"CurrentDay", nil),dayString];
    
    self.stateLabel.text = [DescriptionUtil signTypeDescriptionOfType:[self.targetSign.signType integerValue]];
    
    self.stateLabel.layer.masksToBounds = YES;
    self.stateLabel.layer.cornerRadius = 3;
    switch ([self.targetSign.signType integerValue]) {
        case TargetSignTypeSign:
            self.stateLabel.backgroundColor = UICOLOR(@"#A2DED0");
            break;
        case TargetSignTypeLeave:
            self.stateLabel.backgroundColor = UICOLOR(@"#D2D7D3");
            break;
    }
    
    self.signNoteLabel.text = self.targetSign.note;
    self.dateLabel.text = [DescriptionUtil dateDescriptionOfDate:self.targetSign.signTime];
    
}

#pragma mark - event method
- (IBAction)clickBackgroundButton:(id)sender {
    
    [self.view endEditing:YES];
    
    if (self.editMode) {
        [self switchEditMode];
    }else{
        [self dismissViewController];
    }
    
}

- (IBAction)clickEditButton:(id)sender {
    [self switchEditMode];
}

- (IBAction)clickConfrimButton:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewController];
}

- (IBAction)clickShareButton:(id)sender {
    //FIXME: SHARE
    NSArray* imageArray = @[];
    
    if (imageArray) {
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"分享内容"
                                         images:imageArray
                                            url:[NSURL URLWithString:@"http://mob.com"]
                                          title:@"分享标题"
                                           type:SSDKContentTypeAuto];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                       }
                   }
         ];}
}

- (IBAction)clickNoteConfrimButton:(id)sender {
    self.targetSign.note = self.noteTextView.text;
    [self switchEditMode];
}

- (void)dismissViewController{
    if ([self.targetSign.managedObjectContext hasChanges]) {
        [self.targetSign.managedObjectContext save:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchEditMode{
    self.editMode = !self.editMode;
    
    self.noteTextView.text = self.targetSign.note;
    self.signNoteLabel.text = self.targetSign.note;
    self.textNumLabel.text = [NSString stringWithFormat:@"%@",@(self.noteTextView.text.length)];
    
    CGFloat animationDuration = 0.5;
    
    CAKeyframeAnimation *signInfoAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    signInfoAnimation.delegate = self;
    signInfoAnimation.duration = animationDuration;
    
    if (self.editMode) {
        signInfoAnimation.values = @[@(ScreenHeight/2+20),@(-ScreenHeight/2)];
        signInfoAnimation.keyTimes = @[@(0.3),@(1)];
    }else{
        signInfoAnimation.values = @[@(-ScreenHeight/2),@(ScreenHeight/2+20),@(ScreenHeight/2*0.9)];
        signInfoAnimation.keyTimes = @[@(0),@(0.7),@(1)];
    }
    
    [self.signInfoView.layer addAnimation:signInfoAnimation forKey:@"signInfoView"];
    
    CAKeyframeAnimation *editNoteAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    editNoteAnimation.duration = animationDuration;
    
    if (self.editMode) {
        editNoteAnimation.values = @[@(ScreenHeight*3/2+20),@(ScreenHeight/2*0.9)];
        editNoteAnimation.keyTimes = @[@(0.3),@(1)];
    }else{
        editNoteAnimation.values = @[@(ScreenHeight/2-20),@(ScreenHeight*3/2)];
        editNoteAnimation.keyTimes = @[@(0.7),@(1)];
    }
    
    [self.editNoteView.layer addAnimation:editNoteAnimation forKey:@"editNoteView"];
}

#pragma mark - delegate
#pragma mark animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (self.editMode) {
        [self.signInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view.mas_centerY).offset(-ScreenHeight);
        }];
        [self.editNoteView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view.mas_centerY).offset(-ScreenHeight/2*0.1);
        }];
    }else{
        [self.signInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view.mas_centerY).offset(-ScreenHeight/2*0.1);
        }];
        [self.editNoteView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.view.mas_centerY).offset(ScreenHeight);
        }];
    }
}

#pragma mark textView delegate
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length>144) {
        textView.text = [textView.text substringToIndex:144];
    }
    self.textNumLabel.text = [NSString stringWithFormat:@"%@",@(textView.text.length)];
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
    NSArray *inputArray = @[self.noteTextView];
    for (UIControl *ctrl in inputArray) {
        if ([ctrl isFirstResponder]) {
            return ctrl;
        }
    }
    return nil;
}
@end
