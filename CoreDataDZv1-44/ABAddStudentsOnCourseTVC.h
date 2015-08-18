//
//  ABStudentsOnCourse.h
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ABCoreDataTVC.h"

@class ABAddEditCourseTVC;
@class ABCourse;

@interface ABAddStudentsOnCourseTVC :  ABCoreDataTVC <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) ABAddEditCourseTVC *parentController;
@property (strong, nonatomic) ABCourse *course;


- (void)initWithController:(ABAddEditCourseTVC *)parentController course:(ABCourse *)course;


- (IBAction)save:(id)sender;

- (IBAction)cancel:(id)sender;


@end
