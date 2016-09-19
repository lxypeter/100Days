//
//  CoreDataUtil.m
//  100Days
//
//  Created by Peter Lee on 16/8/31.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import "CoreDataUtil.h"

@implementation CoreDataUtil

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

@end
