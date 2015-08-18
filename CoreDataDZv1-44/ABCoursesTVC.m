//
//  ABCoursesTVC.m
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import "ABCoursesTVC.h"
#import "ABCourse.h"
#import "ABAddEditCourseTVC.h"


@interface ABCoursesTVC ()

@end

@implementation ABCoursesTVC

@synthesize fetchedResultsController = _fetchedResultsController;


#pragma mark Fetched results controller


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ABCourse" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptorNameCourse = [[NSSortDescriptor alloc] initWithKey:@"courseName" ascending:YES];
    NSSortDescriptor *sortDescriptorBranch = [[NSSortDescriptor alloc] initWithKey:@"branch" ascending:YES];
    NSSortDescriptor *sortDescriptorSubject = [[NSSortDescriptor alloc] initWithKey:@"subject" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorNameCourse, sortDescriptorBranch, sortDescriptorSubject, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"ABCourse"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    [NSFetchedResultsController deleteCacheWithName:@"ABCourse"];
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ABCourseCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ABCourse *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = course.courseName;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ABCourse *course = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    ABAddEditCourseTVC *addEditCourseTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddEditCourseTVC"];
    [addEditCourseTVC initWithParentController:self course:course];
    addEditCourseTVC.mFetchedResultsController = self.fetchedResultsController;
    
    [self.navigationController pushViewController:addEditCourseTVC animated:YES];
}


- (NSManagedObject *)insertStudentWithCourseName:(NSString *)courseName branch:(NSString *)branch subject:(NSString *)subject {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newCourse= [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newCourse setValue:courseName forKey:@"courseName"];
    [newCourse setValue:branch forKey:@"branch"];
    [newCourse setValue:subject forKey:@"subject"];
    
    [self saveContext];
    
    return newCourse;
}

- (NSString *)saveContext {
    
    NSString *errorText = nil;
    NSError *error = nil;
    if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
        errorText = [self validationErrorText:error];
    }
    return errorText;
}

#pragma mark - Actions

- (IBAction)addAction:(id)sender {
    
    ABAddEditCourseTVC *addEditCourseTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddEditCourseTVC"];
    
    [addEditCourseTVC initWithParentController:self course:nil];
    
    [self.navigationController pushViewController:addEditCourseTVC animated:YES];
    
}

- (NSString *)validationErrorText:(NSError *)error {
    
    NSMutableString *errorText = [NSMutableString stringWithCapacity:100];
    
    NSArray *errors = [error code] == NSValidationMultipleErrorsError ? [[error userInfo] objectForKey:NSDetailedErrorsKey] : [NSArray arrayWithObject:error];
    
    for (NSError *err in errors) {
        NSString *propName = [[err userInfo] objectForKey:@"NSValidationErrorKey"];
        NSString *message;
        
        switch ([err code]) {
            case NSValidationMultipleErrorsError:
                message = [NSString stringWithFormat:@"%@ required", propName];
                break;
                
            case NSValidationStringTooShortError:
                message = [NSString stringWithFormat:@"%@ must be at least %d characters", propName, 3];
                break;
            case NSValidationStringPatternMatchingError:
                message = [NSString stringWithFormat:@"%@ can contain only letters and numbers", propName];
                
            default:
                message =  @"Unknown error. Press Home button to halt.";
                break;
        }
        
        if ([errorText length] > 0) {
            [errorText appendString:@"\n"];
        }
        [errorText appendString:message];
    }
    return errorText;
}




@end
