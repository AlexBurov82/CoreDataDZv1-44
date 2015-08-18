//
//  ABStudentsTVC.h
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ABCoreDataTVC.h"

@interface ABStudentsTVC : ABCoreDataTVC <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSString *)saveContext;

- (NSManagedObject *)insertStudentWithLastName:(NSString *)lastName firstName:(NSString *)firstName eMail:(NSString *)eMail;

- (IBAction)addAction:(id)sender;

- (NSString *)validationErrorText:(NSError *)error;

@end
