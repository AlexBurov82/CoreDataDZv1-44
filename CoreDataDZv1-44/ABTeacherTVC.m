//
//  ABTeacherTVC.m
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import "ABTeacherTVC.h"
#import "ABAddEditTeacherTVC.h"
#import "ABTeacher.h"

@interface ABTeacherTVC ()

@end

@implementation ABTeacherTVC

@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark Fetched results controller


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ABTeacher" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptorLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSSortDescriptor *sortDescriptorFirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
   
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorLastName, sortDescriptorFirstName, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"ABTeacher"];
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
    
    static NSString *CellIdentifier = @"ABTeacherCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ABTeacher *teacher = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.lastName, teacher.firstName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[teacher.courses count]];
    //не отображаетс detailTextLabel в tableView
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ABTeacher *teacher = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    ABAddEditTeacherTVC *addEditTeacherTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddEditTeacherTVC"];
    [addEditTeacherTVC initWithParentController:self teacher:teacher];
    
    [self.navigationController pushViewController:addEditTeacherTVC animated:YES];
}

- (IBAction)addAction:(id)sender {
    
    ABAddEditTeacherTVC *addEditTeacherTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddEditTeacherTVC"];
    
    [addEditTeacherTVC initWithParentController:self teacher:nil];
    
    [self.navigationController pushViewController:addEditTeacherTVC animated:YES];
    
}

- (NSManagedObject *)insertTeacherWithLastName:(NSString *)lastName firstName:(NSString *)firstName {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newTeacher = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newTeacher setValue:lastName forKey:@"lastName"];
    [newTeacher setValue:firstName forKey:@"firstName"];
    
    [self saveContext];
    
    return newTeacher;
}

- (NSString *)saveContext {
    
    NSString *errorText = nil;
    NSError *error = nil;
    if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
        errorText = [self validationErrorText:error];;
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
