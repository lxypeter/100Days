//
//  TargetSign.h
//  100Days
//
//  Created by Peter Lee on 16/8/31.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, TargetSignType){
    TargetSignTypeSign,
    TargetSignTypeLeave
};

@class Target;

NS_ASSUME_NONNULL_BEGIN

@interface TargetSign : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "TargetSign+CoreDataProperties.h"
