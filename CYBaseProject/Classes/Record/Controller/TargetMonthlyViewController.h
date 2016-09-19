//
//  TargetMonthlyViewController.h
//  100Days
//
//  Created by Peter Lee on 16/9/4.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "CYBaseViewController.h"

@class Target,TargetMonthlySign;
@interface TargetMonthlyViewController : CYBaseViewController

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) Target *target;
@property (nonatomic, strong) NSArray<TargetMonthlySign *> *targetMonthlySigns;

@end
