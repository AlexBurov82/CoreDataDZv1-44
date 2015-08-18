//
//  ABCourse.h
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ABStudent, ABTeacher;

@interface ABCourse : NSManagedObject

@property (nonatomic, retain) NSString * branch;
@property (nonatomic, retain) NSString * courseName;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) ABTeacher *teacher;
@property (nonatomic, retain) NSSet *students;
@end

@interface ABCourse (CoreDataGeneratedAccessors)

- (void)addStudentsObject:(ABStudent *)value;
- (void)removeStudentsObject:(ABStudent *)value;
- (void)addStudents:(NSSet *)values;
- (void)removeStudents:(NSSet *)values;

@end
