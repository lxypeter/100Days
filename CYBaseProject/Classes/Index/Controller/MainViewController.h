//
//  MainViewController.h
//  100Days
//
//  Created by Peter Lee on 16/8/30.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SettingButtonEvent)();
typedef void(^ViewWillAppearEvent)();

@interface MainViewController : UIViewController

@property (nonatomic, copy) SettingButtonEvent settingButtonEvent;
@property (nonatomic, copy) ViewWillAppearEvent viewWillAppearEvent;

@end
