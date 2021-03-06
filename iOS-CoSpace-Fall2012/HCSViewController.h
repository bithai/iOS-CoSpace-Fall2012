//
//  HCSViewController.h
//  iOS-CoSpace-Fall2012
//
//  Created by Carl Brown on 10/22/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface HCSViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSArray *items;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
