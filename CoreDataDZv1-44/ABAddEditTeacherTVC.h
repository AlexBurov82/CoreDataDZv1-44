//
//  ABAddEditTeacherTVC.h
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class ABTeacherTVC;
@class ABTeacher;

@interface ABAddEditTeacherTVC : UITableViewController

@property (strong, nonatomic) ABTeacherTVC *parentController;
@property (strong, nonatomic) ABTeacher *teacher;



- (void)initWithParentController:(ABTeacherTVC *)parentController teacher:(ABTeacher *)teacher;

- (void)reloadData;


@end
