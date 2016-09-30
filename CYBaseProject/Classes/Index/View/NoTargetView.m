//
//  NoTargetView.m
//  100Days
//
//  Created by Peter Lee on 16/8/31.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "NoTargetView.h"

@interface NoTargetSettingButton : UIButton

@end

@implementation NoTargetSettingButton

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setTitle:NSLocalizedString(@"Setting", nil) forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"target_right_arrow"] forState:UIControlStateNormal];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2;
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(contentRect.size.width-contentRect.size.height, 0, contentRect.size.height, contentRect.size.height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, 0, contentRect.size.width-contentRect.size.height, contentRect.size.height);
}

@end

@interface NoTargetView ()

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *settingButton;

@end

@implementation NoTargetView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSubviews];
    }
    return self;
}

- (void)configureSubviews{
    
    UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UILabel *tipsLabel = [[UILabel alloc]init];
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.font = [UIFont systemFontOfSize:30];
    tipsLabel.text = NSLocalizedString(@"You need a target", nil);
    [self addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY).multipliedBy(0.8);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    NoTargetSettingButton *settingButton = [[NoTargetSettingButton alloc]init];
    [settingButton addTarget:self action:@selector(clickSettingButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingButton];
    [settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLabel.mas_bottom).offset(15);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];
}

- (IBAction)clickSettingButton:(id)sender {
    if (self.settingBlock) {
        self.settingBlock();
    }
}


@end
