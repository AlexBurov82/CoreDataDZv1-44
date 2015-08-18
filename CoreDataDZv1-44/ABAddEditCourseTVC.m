//
//  ABAddEditCourseTVC.m
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import "ABAddEditCourseTVC.h"
#import "ABCoursesTVC.h"
#import "ABCourseCell.h"
#import "ABAddStudentsOnCourseTVC.h"
#import "ABAddTeacherOnCourseTVC.h"
#import "ABStudent.h"
#import "ABCourse.h"
#import "ABTeacher.h"
#import "ABAddEditTeacherTVC.h"
#import "ABAddEditStudentTVC.h"

@interface ABAddEditCourseTVC ()  <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSString *courseName;
@property (strong, nonatomic) NSString *branch;
@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSArray *students;


@end

@implementation ABAddEditCourseTVC

@synthesize mFetchedResultsController = _mFetchedResultsController;

- (void)initWithParentController:(ABCoursesTVC *)parentController course:(ABCourse *)course {
    
    self.parentController = parentController;
    self.course = course;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    
    UIBarButtonItem *addButtonStudent = [[UIBarButtonItem  alloc] initWithImage:[UIImage imageNamed:@"students.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addActionStudent)];
    
    UIBarButtonItem *addButtonTeacher = [[UIBarButtonItem  alloc] initWithImage:[UIImage imageNamed:@"teacher.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addActionTeacher)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    if (self.parentController) {
        self.navigationItem.rightBarButtonItems = @[saveButton, addButtonStudent, addButtonTeacher];
    }
    
    
    if (self.course) {
        self.courseName = [self.course valueForKey:@"courseName"];
        self.branch = [self.course valueForKey:@"branch"];
        self.subject = [self.course valueForKey:@"subject"];
        
    } else {
        self.courseName = @"";
        self.branch = @"";
        self.subject = @"";
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
    
    NSManagedObject *tempCourse = nil;
    NSString *tempCourseName = nil;
    NSString *tempeSubject = nil;
    NSString *tempBranch = nil;
    
    if (self.parentController) {
        
        if (self.course) {
            
            tempCourseName = [NSString stringWithString:(NSString *)[self.course valueForKey:@"courseName"]];
            tempeSubject = [NSString stringWithString:(NSString *)[self.course valueForKey:@"branch"]];
            tempBranch = [NSString stringWithString:(NSString *)[self.course valueForKey:@"subject"]];
            
            [self.course setValue:self.courseName forKey:@"courseName"];
            [self.course setValue:self.branch forKey:@"branch"];
            [self.course setValue:self.subject forKey:@"subject"];
            
           // [self.parentController saveContext];
            
        } else {
            
            tempCourse = [self.parentController insertStudentWithCourseName:self.courseName branch:self.branch subject:self.subject];
        }
        errorText = [self.parentController saveContext];
    }
    if (errorText) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"  message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        if (tempCourse) {
            [[self.parentController.fetchedResultsController managedObjectContext] deleteObject:tempCourse];
        } else {
            [self.course setValue:tempCourseName forKey:@"courseName"];
            [self.course setValue:tempeSubject forKey:@"branch"];
            [self.course setValue:tempBranch forKey:@"subject"];
        }
    } else {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

- (void)cancelAction {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)addActionStudent {
    
    ABAddStudentsOnCourseTVC *addStudentsOnCourseTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddStudentsOnCourseTVC"];
    
    [addStudentsOnCourseTVC initWithController:self course:self.course];
    
    [self.navigationController pushViewController:addStudentsOnCourseTVC animated:YES];
}

- (void)addActionTeacher {
    
    ABAddTeacherOnCourseTVC *addTeacherOnCourseTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddTeacherOnCourseTVC"];
    
    [addTeacherOnCourseTVC initWithController:self course:self.course];
    
    [self.navigationController pushViewController:addTeacherOnCourseTVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return @"Course";
        
    } else if (section == 2) {
        if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
            return nil;
        } else {
            
            return @"Students";
        }
        
    } else if (section == 1) {
        if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
            return nil;
        } else {
            return @"Teacher";
        }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 3;
        
    } else if (section == 2) {
        
        return [self.course.students count];
        
    } else if (section == 1) {
        ABTeacher *teacher = self.course.teacher;
        
        if (!teacher) {
            return 0;
        } else {
            return 1;
        }
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifierCours = @"ABCourseCell";
    static NSString *identifierStudent = @"ABStudentCell";
    static NSString *identifierTeacher = @"ABTeacherCell";
    
    if (indexPath.section == 0) {
        
        ABCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCours];
    
        cell.textField.tag = indexPath.row;
        cell.textField.returnKeyType = UIReturnKeyNext;
        cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        if (self.course) {
            if (cell.textField.tag == 0) {
                cell.textField.text = self.course.courseName;
                cell.label.text = @"Course Name:";
                
            } else if (cell.textField.tag == 1) {
                cell.textField.text = self.course.branch;
                cell.label.text = @"Branch:";
                
            } else if (cell.textField.tag == 2) {
                cell.textField.text = self.course.subject;
                cell.label.text = @"Subject:";
            }
            
        } else {
            
            if (cell.textField.tag == 0) {
                cell.textField.placeholder = @"Enter course name";
                cell.label.text = @"Course Name:";
                
            } else if (cell.textField.tag == 1) {
                cell.textField.placeholder = @"Enter branch";
                cell.label.text = @"Branch:";
                
            } else if (cell.textField.tag == 2) {
                cell.textField.placeholder = @"Enter subject";
                cell.label.text = @"Subject:";
            }
        }
        
        return cell;
        
    } else if (indexPath.section == 2) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStudent];
        
        ABStudent *student = [[self sortStudents] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.lastName, student.firstName];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierTeacher];
        
        ABTeacher *teacher = self.course.teacher;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", teacher.lastName, teacher.firstName];

        return cell;
        
    }
    return nil;
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
        self.courseName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
    } else if (textField.tag == 2) {
        self.branch = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
    } else if (textField.tag == 1) {
        self.subject = [textField.text stringByReplacingCharactersInRange:range withString:string];
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



- (NSArray *)sortStudents {
    NSSortDescriptor *sortLastNameDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSSortDescriptor *sortFirstNameDescriptor =  [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortLastNameDescriptor, sortFirstNameDescriptor, nil];
    return [[self.course.students allObjects] sortedArrayUsingDescriptors:sortDescriptors];
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
        if (indexPath.section == 2) {
           
            ABStudent *student = [[self sortStudents] objectAtIndex:indexPath.row];
            
            if (student) {
   
                [self.course removeStudentsObject:student];
                
                [self.parentController saveContext];
            }
            
        } else if (indexPath.section == 1) {
           
             ABTeacher *teacher = self.course.teacher;
            
            if (teacher) {
                
                [teacher removeCoursesObject:self.course];
                
                [self.parentController saveContext];
            }
        }
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [tableView endUpdates];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        ABTeacher *teacher = self.course.teacher;
        
        ABAddEditTeacherTVC *addEditTeacherTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddEditTeacherTVC"];
        [addEditTeacherTVC initWithParentController:nil teacher:teacher];
        
        [self.navigationController pushViewController:addEditTeacherTVC animated:YES];
    } else if (indexPath.section == 2) {
        ABStudent *student = [[self sortStudents] objectAtIndex:indexPath.row];
        
        ABAddEditStudentTVC *addEditStudentTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ABAddEditStudentTVC"];
        [addEditStudentTVC initWithParentController:nil student:student];
        
        [self.navigationController pushViewController:addEditStudentTVC animated:YES];
    }
    

}


- (void)reloadData {
    [self.tableView reloadData];
}


@end
