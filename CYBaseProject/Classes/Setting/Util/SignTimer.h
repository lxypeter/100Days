//
//  SignTimer.h
//  100Days
//
//  Created by Peter Lee on 2016/10/12.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TimerProgress)(NSInteger passSecond);
typedef void(^TimerEnd)();

@interface SignTimer : NSObject

+ (SignTimer *)shareSignTimer;

@end
