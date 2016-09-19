//
//  NoTargetView.h
//  100Days
//
//  Created by Peter Lee on 16/8/31.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SettingBlock)();

@interface NoTargetView : UIView

@property (nonatomic, copy) SettingBlock settingBlock;

@end
