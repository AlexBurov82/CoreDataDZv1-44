//
//  ABAddCourseForStudentTVC.h
//  CoreDataDZv1-44
//
//  Created by Александр on 17.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ABCoreDataTVC.h"

@class ABAddEditStudentTVC;
@class ABStudent;

@interface ABAddCourseForStudentTVC : ABCoreDataTVC <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) ABAddEditStudentTVC *parentController;
@property (strong, nonatomic) ABStudent *student;


- (void)initWithController:(ABAddEditStudentTVC *)parentController studnet:(ABStudent *)student;


- (IBAction)save:(id)sender;

- (IBAction)cancel:(id)sender;

@end
