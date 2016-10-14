//
//  CoreDataUtil.h
//  100Days
//
//  Created by Peter Lee on 16/8/31.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Target.h"

@interface CoreDataUtil : NSObject

+ (NSManagedObjectContext *)shareContext;

+ (Target *)queryCurrentTarget;
+ (TargetSign *)queryLastTargetSign:(Target *)target;
+ (TargetSign *)queryTargetSign:(Target *)target date:(NSDate *)date;
+ (void)updateTarget:(Target *)target complete:(void(^)())complete fail:(void(^)())fail;
+ (void)signTarget:(Target *)target signType:(TargetSignType)type  complete:(void(^)(TargetSign *targetSign))complete;
+ (void)terminateTarget:(Target *)target WithResult:(TargetResult)result complete:(void(^)())complete;

@end
