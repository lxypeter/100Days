//
//  NoTargetView.m
//  100Days
//
//  Created by Peter Lee on 16/8/31.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "NoTargetView.h"

@interface NoTargetView ()

@property (weak, nonatomic) IBOutlet UIView *goToSetView;

@end

@implementation NoTargetView

- (void)awakeFromNib{
    self.goToSetView.layer.cornerRadius = 3;
    self.goToSetView.layer.borderWidth = 2;
    self.goToSetView.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (IBAction)clickSettingButton:(id)sender {
    if (self.settingBlock) {
        self.settingBlock();
    }
}


@end
