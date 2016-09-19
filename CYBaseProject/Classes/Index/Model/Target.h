//
//  Target.h
//  100Days
//
//  Created by Peter Lee on 16/8/31.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TargetSign.h"

typedef NS_ENUM(NSInteger, TargetResult){
    TargetResultProgressing = 0,
    TargetResultComplete,
    TargetResultFail,
    TargetResultStop
};

NS_ASSUME_NONNULL_BEGIN

@interface Target : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Target+CoreDataProperties.h"
