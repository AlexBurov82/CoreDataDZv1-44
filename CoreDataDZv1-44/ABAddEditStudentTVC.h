//
//  ABAddEditStudentTVC.h
//  CoreDataDZv1-44
//
//  Created by Александр on 14.08.15.
//  Copyright (c) 2015 Alex Bukharov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class ABStudentsTVC;
@class ABStudent;


@interface ABAddEditStudentTVC : UITableViewController


@property (strong, nonatomic) ABStudentsTVC *parentController;
@property (strong, nonatomic) ABStudent *student;




- (void)initWithParentController:(ABStudentsTVC *)parentController student:(ABStudent *)student;

- (void)reloadData;


@end
