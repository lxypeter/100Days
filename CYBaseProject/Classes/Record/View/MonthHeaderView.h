//
//  MonthHeaderView.h
//  100Days
//
//  Created by Peter Lee on 16/9/7.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonthHeaderView : UICollectionReusableView

@property (nonatomic, assign) NSInteger startWeakDay;
@property (nonatomic, strong) NSDate *month;

@end
