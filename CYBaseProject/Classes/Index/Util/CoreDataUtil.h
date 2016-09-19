//
//  CoreDataUtil.h
//  100Days
//
//  Created by Peter Lee on 16/8/31.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataUtil : NSObject

+ (NSManagedObjectContext *)shareContext;

@end
