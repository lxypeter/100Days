//
//  TargetSign+CoreDataProperties.h
//  100Days
//
//  Created by Peter Lee on 16/9/1.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TargetSign.h"

NS_ASSUME_NONNULL_BEGIN

@interface TargetSign (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *note;
@property (nullable, nonatomic, retain) NSDate *signTime;
@property (nullable, nonatomic, retain) NSNumber *signType;
@property (nullable, nonatomic, retain) Target *target;

@end

NS_ASSUME_NONNULL_END
