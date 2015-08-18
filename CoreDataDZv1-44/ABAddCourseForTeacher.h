//
//  ABAddCourseForTeacher.h
//  CoreDataDZv1-44
//
//  Created by Александр on 17.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ABCoreDataTVC.h"

@class ABAddEditTeacherTVC;
@class ABTeacher;

@interface ABAddCourseForTeacher : ABCoreDataTVC <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) ABAddEditTeacherTVC *parentController;
@property (strong, nonatomic) ABTeacher *teacher;


- (void)initWithController:(ABAddEditTeacherTVC *)parentController teacher:(ABTeacher *)teacher;


- (IBAction)save:(id)sender;

- (IBAction)cancel:(id)sender;

@end
