//
//  Target+CoreDataProperties.h
//  100Days
//
//  Created by Peter Lee on 16/9/2.
//  Copyright © 2016年 CY.Lee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Target.h"

NS_ASSUME_NONNULL_BEGIN

@interface Target (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSNumber *day;
@property (nullable, nonatomic, retain) NSDate *endDate;
@property (nullable, nonatomic, retain) NSNumber *flexibleTimes;
@property (nullable, nonatomic, retain) NSNumber *result;
@property (nullable, nonatomic, retain) NSDate *startDate;
@property (nullable, nonatomic, retain) NSNumber *totalDays;
@property (nullable, nonatomic, retain) NSSet<TargetSign *> *targetSigns;

@end

@interface Target (CoreDataGeneratedAccessors)

- (void)addTargetSignsObject:(TargetSign *)value;
- (void)removeTargetSignsObject:(TargetSign *)value;
- (void)addTargetSigns:(NSSet<TargetSign *> *)values;
- (void)removeTargetSigns:(NSSet<TargetSign *> *)values;

@end

NS_ASSUME_NONNULL_END
