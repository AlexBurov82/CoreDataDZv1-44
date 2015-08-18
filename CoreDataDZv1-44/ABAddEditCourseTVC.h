//
//  ABAddEditCourseTVC.h
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ABCoreDataTVC.h"

@class ABCoursesTVC;
@class ABCourse;



@interface ABAddEditCourseTVC : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *mFetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *mManagedObjectContext;

@property (strong, nonatomic) ABCoursesTVC *parentController;
@property (strong, nonatomic) ABCourse *course;



- (void)initWithParentController:(ABCoursesTVC *)parentController course:(ABCourse *)course;

- (void)reloadData;

@end


