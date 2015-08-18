//
//  ABAddTeacherOnCourseTVC.m
//  CoreDataDZv1-44
//
//  Created by Александр on 16.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import "ABAddTeacherOnCourseTVC.h"
#import "ABTeacher.h"
#import "ABCourse.h"
#import "ABAddEditCourseTVC.h"

@interface ABAddTeacherOnCourseTVC ()

@property (strong, nonatomic) NSIndexPath *cellSelected;

@end

@implementation ABAddTeacherOnCourseTVC

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)initWithController:(ABAddEditCourseTVC *)parentController course:(ABCourse *)course {
    
    self.parentController = parentController;
    self.course = course;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.cellSelected == indexPath) {
        
        self.cellSelected = nil;
        
    } else {
        
        self.cellSelected = indexPath;
    }
    
    [tableView reloadData];
}

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
    [NSFetchedResultsController deleteCacheWithName:@"ABTeacher"];
    
    NSError *error = nil;
    
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ABAddTeacherCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ABTeacher *teacher = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.lastName, teacher.firstName];
    
    if (self.cellSelected == indexPath) {
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
        
        if (self.course) {
            
            ABTeacher *teacher = [[self fetchedResultsController] objectAtIndexPath:self.cellSelected];
            
            [teacher addCoursesObject:self.course];
            
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
