//
//  ABAddCourseForStudentTVC.m
//  CoreDataDZv1-44
//
//  Created by Александр on 17.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import "ABAddCourseForStudentTVC.h"
#import "ABStudent.h"
#import "ABCourse.h"
#import "ABAddEditStudentTVC.h"

@interface ABAddCourseForStudentTVC ()

@property (strong, nonatomic) NSMutableArray *cellSelected;

@end

@implementation ABAddCourseForStudentTVC

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)initWithController:(ABAddEditStudentTVC *)parentController studnet:(ABStudent *)student {
    
    self.parentController = parentController;
    self.student = student;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cellSelected = [NSMutableArray array];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.cellSelected containsObject:indexPath]) {
        
        [self.cellSelected removeObject:indexPath];
        
    } else {
        
        [self.cellSelected addObject:indexPath];
    }
    
    [tableView reloadData];
}

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
    
    if([self.cellSelected containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}


- (void)saveContext {
    
    NSError *error = nil;
    if (![[self.fetchedResultsController managedObjectContext] save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Actions

- (IBAction)save:(id)sender {
    
    if (self.parentController) {
        
        if (self.student) {
            
            for (NSIndexPath *indexPath in self.cellSelected) {
                
                ABCourse *course = [[self fetchedResultsController] objectAtIndexPath:indexPath];
                
                [self.student addCoursesObject:course];
                
            }
            [self saveContext];
        }
    }
    [self.parentController reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
