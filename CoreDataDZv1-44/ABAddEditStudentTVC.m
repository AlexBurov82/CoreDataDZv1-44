//
//  ABAddEditStudentTVC.m
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import "ABAddEditStudentTVC.h"
#import "ABStudentsTVC.h"
#import "ABStudentCell.h"
#import "ABCourse.h"
#import "ABStudent.h"
#import "ABAddCourseForStudentTVC.h"
#import "ABAddEditCourseTVC.h"

@interface ABAddEditStudentTVC () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *eMail;

@end

@implementation ABAddEditStudentTVC


- (void)initWithParentController:(ABStudentsTVC *)parentController student:(ABStudent *)student {
    
    self.parentController = parentController;
    self.student = student;
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
    
    if (self.student) {
        self.lastName = [self.student valueForKey:@"lastName"];
        self.firstName = [self.student valueForKey:@"firstName"];
        self.eMail = [self.student valueForKey:@"eMail"];
        
    } else {
        self.firstName = @"";
        self.lastName = @"";
        self.eMail = @"";
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
    
    NSManagedObject *tempStudent = nil;
    NSString *tempLastName = nil;
    NSString *tempFirstName = nil;
    NSString *tempeMail = nil;
    
    if (self.parentController) {
        
        if (self.student) {
            
            tempLastName = [NSString stringWithString:(NSString *)[self.student valueForKey:@"lastName"]];
            tempFirstName = [NSString stringWithString:(NSString *)[self.student valueForKey:@"firstName"]];
            tempeMail = [NSString stringWithString:(NSString *)[self.student valueForKey:@"eMail"]];
            
            [self.student setValue:self.lastName forKey:@"lastName"];
            [self.student setValue:self.firstName forKey:@"firstName"];
            [self.student setValue:self.eMail forKey:@"eMail"];
            
            //[self.parentController saveContext];
            
        } else {
            
            tempStudent = [self.parentController insertStudentWithLastName:self.lastName firstName:self.firstName eMail:self.eMail];
        }
        errorText = [self.parentController saveContext];
        
    }
    
    if (errorText) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"  message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        if (tempStudent) {
            [[self.parentController.fetchedResultsController managedObjectContext] deleteObject:tempStudent];
        } else {
            [self.student setValue:tempLastName forKey:@"lastName"];
            [self.student setValue:tempFirstName forKey:@"firstName"];
            [self.student setValue:tempeMail forKey:@"eMail"];
        }
    } else {
    [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

- (void)cancelAction {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)addActionCourse {
    
    ABAddCourseForStudentTVC *addCourseForStudentTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddCourseForStudentTVC"];
    
    [addCourseForStudentTVC initWithController:self studnet:self.student];
    
    [self.navigationController pushViewController:addCourseForStudentTVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"Student";
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
        return 3;
    } else if (section == 1) {
        return [self.student.courses count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifierStudent = @"ABStudentCell";
    static NSString *identifierCourse = @"ABCoursCell";
    
    if (indexPath.section == 0) {
        
        ABStudentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStudent];
        
        cell.textField.tag = indexPath.row;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        if (self.student) {
            if (cell.textField.tag == 0) {
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                cell.textField.text = self.student.lastName;
                cell.label.text = @"Last Name:";
                
            } else if (cell.textField.tag == 1) {
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                cell.textField.text = self.student.firstName;
                cell.label.text = @"First Name:";
                
            } else if (cell.textField.tag == 2) {
                cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                cell.textField.text = self.student.eMail;
                cell.label.text = @"e-mail:";
            }
            
        } else {
            
            if (cell.textField.tag == 0) {
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                cell.textField.placeholder = @"Enter last name";
                cell.label.text = @"Last Name:";
                
            } else if (cell.textField.tag == 1) {
                cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                cell.textField.placeholder = @"Enter first name";
                cell.label.text = @"First Name:";
                
            } else if (cell.textField.tag == 2) {
                cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
                cell.textField.placeholder = @"Enter e-mail";
                cell.label.text = @"e-mail:";
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
    
    return [[self.student.courses allObjects] sortedArrayUsingDescriptors:sortDescriptors];
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
        
    } else if (textField.tag == 2) {
        self.eMail = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (self.parentController) {
        return YES;
    } else {
        return NO;
    }
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (indexPath.section == 1) {
            
            ABCourse *course = [[self sortCourse] objectAtIndex:indexPath.row];
            
            if (course) {
                
                [self.student removeCoursesObject:course];
                
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
