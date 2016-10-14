//
//  CoreDataUtil.m
//  100Days
//
//  Created by Peter Lee on 16/8/31.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "CoreDataUtil.h"
#import "NSDate+CYCompare.h"
#import "DescriptionUtil.h"

@implementation CoreDataUtil

#pragma mark - get context
+ (NSManagedObjectContext *)shareContext{
    
    static NSManagedObjectContext *context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        // 创建一个模型对象
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        // 持久化存储调度器
        NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // 存储数据库的名字
        NSError *error = nil;
        
        // 获取docment目录
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        // 数据库保存的路径
        NSString *sqlitePath = [doc stringByAppendingFormat:@"/100DaysTargetModel.slqite"];
        DDLogInfo(@"path =====> %@",sqlitePath);
        
        [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlitePath] options:nil error:&error];
        
        context.persistentStoreCoordinator = store;
        
    });
    
    return context;
}

/**
 *  Get progressing target
 */
+ (Target *)queryCurrentTarget{
    NSManagedObjectContext *context = [CoreDataUtil shareContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Target"];
    request.predicate = [NSPredicate predicateWithFormat:@"result == %@",@(TargetResultProgressing)];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
    request.sortDescriptors = @[sort];
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (!error&&array.count>0) {
        Target *target = array[0];
        return target;
    }
    return nil;
}

/**
 *  Get last sign of target
 */
+ (TargetSign *)queryLastTargetSign:(Target *)target{
    if (!target) return nil;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"signTime" ascending:NO];
    NSArray *targetSigns = [target.targetSigns sortedArrayUsingDescriptors:@[sort]];
    if(targetSigns&&targetSigns.count>0){
        return targetSigns[0];
    }
    return nil;
}

/**
 *  Get sign of target in a date
 */
+ (TargetSign *)queryTargetSign:(Target *)target date:(NSDate *)date{
    
    NSMutableArray<TargetSign *> *targetSigns = [NSMutableArray array];
    [target.targetSigns enumerateObjectsUsingBlock:^(TargetSign * _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj.signTime dayIntervalSinceDate:date]==0){
            [targetSigns addObject:obj];
        }
    }];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"signTime" ascending:NO];
    [targetSigns sortUsingDescriptors:@[sort]];
    
    if(targetSigns&&targetSigns.count>0){
        return targetSigns[0];
    }
    return nil;
}

/**
 *  Update target to current time
 */
+ (void)updateTarget:(Target *)target complete:(void(^)())complete fail:(void(^)())fail{
    
    NSManagedObjectContext *context = [CoreDataUtil shareContext];
    //update target day
    NSDate *lastValidDate = [NSDate date];
    if ([lastValidDate compare:target.endDate]==NSOrderedDescending) {
        lastValidDate = [target.endDate dateByAddingTimeInterval:60 * 60 * 24];
    }
    NSInteger dayInterval = [lastValidDate dayIntervalSinceDate:target.startDate];
    
    //update sign
    TargetSign *lastTargetSign = [CoreDataUtil queryLastTargetSign:target];
    NSDate *lastSignTime;
    if(lastTargetSign){
        lastSignTime = lastTargetSign.signTime;
    }else{
        lastSignTime = [target.startDate dateByAddingTimeInterval:-(60 * 60 * 24)];
    }
    NSInteger signDayInterval = [lastValidDate dayIntervalSinceDate:lastSignTime];
    if (signDayInterval>1) {
        for (int index = 1; index<signDayInterval; index++) {
            
            NSInteger flexibleTimes = [target.flexibleTimes integerValue];
            if (flexibleTimes>0) {
                flexibleTimes--;
                target.flexibleTimes = @(flexibleTimes);
            }else{
                [CoreDataUtil terminateTarget:target WithResult:TargetResultFail complete:^{
                    if (fail) {
                        fail();
                    }
                }];
                break;
            }
            
            TargetSign *targetSigh = [NSEntityDescription insertNewObjectForEntityForName:@"TargetSign" inManagedObjectContext:context];
            targetSigh.signType = @(TargetSignTypeLeave);
            targetSigh.note = NSLocalizedString(@"No Sign", nil);
            targetSigh.signTime = [[lastSignTime zeroOfDate] dateByAddingTimeInterval:(60 * 60 * 24 * index)];
            [target addTargetSignsObject:targetSigh];
        }
    }
    
    //update current day
    if ([lastValidDate compare:target.endDate]==NSOrderedDescending) {
        target.day = @(dayInterval);
        [CoreDataUtil terminateTarget:target WithResult:TargetResultComplete complete:^{
            if (complete) {
                complete();
            }
        }];
    }else{
        target.day = @(dayInterval+1);
    }
    
    if ([context hasChanges]) {
        [context save:nil];
    }
}

/**
 *  Target Sign
 */
+ (void)signTarget:(Target *)target signType:(TargetSignType)type  complete:(void(^)(TargetSign *targetSign))complete{
    
    NSDate *now = [NSDate date];
    TargetSign *targetSignInOneDay = [CoreDataUtil queryTargetSign:target date:now];
    TargetSignType lastSignType = [targetSignInOneDay.signType integerValue];
    
    NSString *defaultSignNote;
    switch (type) {
        case TargetSignTypeSign:
            defaultSignNote = NSLocalizedString(@"Daliy sign", nil);
            break;
        case TargetSignTypeLeave:
            defaultSignNote = NSLocalizedString(@"Take a leave", nil);
            break;
    }
    
    if (targetSignInOneDay) {//if signed
        
        if (lastSignType!=type) {
            if(lastSignType == TargetSignTypeLeave){
                target.flexibleTimes = @([target.flexibleTimes integerValue]+1);
            }else if (lastSignType == TargetSignTypeSign){
                target.flexibleTimes = @([target.flexibleTimes integerValue]-1);
            }
        }
    }
    
    //clear old sign data
    [target.targetSigns enumerateObjectsUsingBlock:^(TargetSign * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.signTime dayIntervalSinceDate:now]==0) {
            [target removeTargetSignsObject:obj];
        }
    }];
    
    //create new sign data
    TargetSign *targetSign = [NSEntityDescription insertNewObjectForEntityForName:@"TargetSign" inManagedObjectContext:target.managedObjectContext];
    targetSign.signType = @(type);
    targetSign.note = defaultSignNote;
    targetSign.signTime = now;
    [target addTargetSignsObject:targetSign];
    
    if ([target.managedObjectContext hasChanges]) {
        [target.managedObjectContext save:nil];
    }
    
    if (complete) {
        complete(targetSign);
    }
}

/**
 *  Terminate target
 */
+ (void)terminateTarget:(Target *)target WithResult:(TargetResult)result complete:(void(^)())complete{
    NSManagedObjectContext *context = target.managedObjectContext;
    target.result = @(result);
    if ([context hasChanges]) {
        [context save:nil];
    }
    if (complete) {
        complete();
    }
}

@end
