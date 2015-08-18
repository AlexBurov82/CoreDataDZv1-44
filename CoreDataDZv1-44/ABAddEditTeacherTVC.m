//
//  ABAddEditTeacherTVC.m
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import "ABAddEditTeacherTVC.h"
#import "ABTeacherTVC.h"
#import "ABTeacherCell.h"
#import "ABTeacher.h"
#import "ABAddCourseForTeacher.h"
#import "ABCourse.h"
#import "ABAddEditCourseTVC.h"

@interface ABAddEditTeacherTVC () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *courseName;

@end

@implementation ABAddEditTeacherTVC

- (void)initWithParentController:(ABTeacherTVC *)parentController teacher:(ABTeacher *)teacher {
    
    self.parentController = parentController;
    self.teacher = teacher;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    
    UIBarButtonItem *addButtonCourse = [[UIBarButtonItem  alloc] initWithImage:[UIImage imageNamed:@"cours.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addActionCourse)];
    
    if (self.parentController) {
        self.navigationItem.rightBarButtonItems = @[saveButton, addButtonCourse];
    }
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    if (self.teacher) {
        self.lastName = [self.teacher valueForKey:@"lastName"];
        self.firstName = [self.teacher valueForKey:@"firstName"];
        
    } else {
        self.firstName = @"";
        self.lastName = @"";
    }
}

- (void)dealloc {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)saveAction {
    
    NSString *errorText = nil;
    
    NSManagedObject *tempTeacher = nil;
    NSString *tempLastName = nil;
    NSString *tempFirstName = nil;
    
    if (self.parentController) {
        
        if (self.teacher) {
            
            tempLastName = [NSString stringWithString:(NSString *)[self.teacher valueForKey:@"lastName"]];
            tempFirstName = [NSString stringWithString:(NSString *)[self.teacher valueForKey:@"firstName"]];
            
            [self.teacher setValue:self.lastName forKey:@"lastName"];
            [self.teacher setValue:self.firstName forKey:@"firstName"];
            
            [self.parentController saveContext];
            
        } else {
            
            tempTeacher = [self.parentController insertTeacherWithLastName:self.lastName firstName:self.firstName];
        }
        errorText = [self.parentController saveContext];
    }
    
    if (errorText) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"  message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        if (tempTeacher) {
            [[self.parentController.fetchedResultsController managedObjectContext] deleteObject:tempTeacher];
        } else {
            [self.teacher setValue:tempLastName forKey:@"lastName"];
            [self.teacher setValue:tempFirstName forKey:@"firstName"];
        }
    } else {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

- (void)cancelAction {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)addActionCourse {
    
    ABAddCourseForTeacher *addCourseForTeacher = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddCourseForTeacher"];
    
    [addCourseForTeacher initWithController:self teacher:self.teacher];
    
    [self.navigationController pushViewController:addCourseForTeacher animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"Teacher";
    } else if (section == 1) {
        if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
            return nil;
        } else {
            return @"Courses";
        }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return [(NSSet *)[self.teacher valueForKey:@"courses"] count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"ABTeacherCell";
    static NSString *identifierCourse = @"ABCoursCell";
    
    if (indexPath.section == 0) {
        
        ABTeacherCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        cell.textField.tag = indexPath.row;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        
        if (self.teacher) {
            if (cell.textField.tag == 0) {
                cell.textField.text = [self.teacher valueForKey:@"lastName"];
                cell.label.text = @"Last Name:";
                
            } else if (cell.textField.tag == 1) {
                cell.textField.text = [self.teacher valueForKey:@"firstName"];
                cell.label.text = @"First Name:";
            }
            
        } else {
            
            if (cell.textField.tag == 0) {
                cell.textField.placeholder = @"Enter last name";
                cell.label.text = @"Last Name:";
                
            } else if (cell.textField.tag == 1) {
                cell.textField.placeholder = @"Enter first name";
                cell.label.text = @"First Name:";
            }
        }
        
        return cell;
    } else if (indexPath.section == 1) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCourse];
        
        ABCourse *course = [[self sortCourse] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = course.courseName;
        
        return cell;
    }
    
    return nil;

}

- (NSArray *)sortCourse {
    NSSortDescriptor *sortDescriptorNameCourse = [[NSSortDescriptor alloc] initWithKey:@"courseName" ascending:YES];
    NSSortDescriptor *sortDescriptorBranch = [[NSSortDescriptor alloc] initWithKey:@"branch" ascending:YES];
    NSSortDescriptor *sortDescriptorSubject = [[NSSortDescriptor alloc] initWithKey:@"subject" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorNameCourse, sortDescriptorBranch, sortDescriptorSubject, nil];
    
    return [[self.teacher.courses allObjects] sortedArrayUsingDescriptors:sortDescriptors];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSInteger nextTag = textField.tag + 1;
    
    UIResponder* nextResponder = [self.tableView viewWithTag:nextTag];
    
    if (nextResponder) {
        
        [nextResponder becomeFirstResponder];
        
    } else {
        
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == 0) {
        self.lastName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
    } else if (textField.tag == 1) {
        self.firstName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.parentController) {
        if (indexPath.section == 0) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (self.parentController) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (indexPath.section == 1) {
            
            ABCourse *course = [[self sortCourse] objectAtIndex:indexPath.row];
            
            if (course) {
                
                [self.teacher removeCoursesObject:course];
                
                [self.parentController saveContext];;
            }
        }
        
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [tableView endUpdates];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ABCourse *course = [[self sortCourse] objectAtIndex:indexPath.row];
    
    ABAddEditCourseTVC *addEditCourseTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddEditCourseTVC"];
    [addEditCourseTVC initWithParentController:nil course:course];
    
    [self.navigationController pushViewController:addEditCourseTVC animated:YES];
}


- (void)reloadData {
    [self.tableView reloadData];
}


@end
