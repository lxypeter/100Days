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

@interface SignShareViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDaysLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *signNoteLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIView *signInfoView;

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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults stringForKey:kUserNameKey];
    if (![NSString isBlankString:userName]) {
        self.nameLabel.text = userName;
    }
    NSData *userHeaderData = [userDefaults dataForKey:kUserHeaderKey];
    if (userHeaderData) {
        self.headerImageView.image = [UIImage imageWithData:userHeaderData];
    }
    
    if (!self.targetSign) return;
    
    self.totalDaysLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TargetDayType", nil),self.targetSign.target.totalDays];
    self.currentDayLabel.text = [NSString stringWithFormat:NSLocalizedString(@"CurrentDay", nil),self.targetSign.target.day];
    
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
    
    [self.view bringSubviewToFront:self.signInfoView];
    [self.view bringSubviewToFront:self.confirmButton];
    [self.view bringSubviewToFront:self.shareButton];
}

#pragma mark - event method
- (IBAction)clickBackgroundButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickEditButton:(id)sender {
}

- (IBAction)clickConfrimButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickShareButton:(id)sender {
}
@end
