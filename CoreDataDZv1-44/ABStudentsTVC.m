//
//  ABStudentsTVC.m
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import "ABStudentsTVC.h"
#import "ABAddEditStudentTVC.h"
#import "ABStudent.h"

@implementation ABStudentsTVC

@synthesize fetchedResultsController = _fetchedResultsController;


#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ABStudent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptorLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSSortDescriptor *sortDescriptorFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorLastName, sortDescriptorFirstName, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"ABStudent"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ABStudetCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ABStudent *student = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.lastName, student.firstName];
    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%ld", [student.courses count]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ABStudent *student = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    ABAddEditStudentTVC *addEditStudentTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddEditStudentTVC"];
    [addEditStudentTVC initWithParentController:self student:student];
    
    [self.navigationController pushViewController:addEditStudentTVC animated:YES];
}

- (IBAction)addAction:(id)sender {
    
    ABAddEditStudentTVC *addEditStudentTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddEditStudentTVC"];
    
    [addEditStudentTVC initWithParentController:self student:nil];
    
    [self.navigationController pushViewController:addEditStudentTVC animated:YES];
    
}

- (NSManagedObject *)insertStudentWithLastName:(NSString *)lastName firstName:(NSString *)firstName eMail:(NSString *)eMail {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newStudent = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newStudent setValue:lastName forKey:@"lastName"];
    [newStudent setValue:firstName forKey:@"firstName"];
    [newStudent setValue:eMail forKey:@"eMail"];
    
    [self saveContext];
    
    return newStudent;
}

- (NSString *)saveContext {
    
    NSString *errorText = nil;
    NSError *error = nil;
    if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
        errorText = [self validationErrorText:error];
    }
    return errorText;
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
