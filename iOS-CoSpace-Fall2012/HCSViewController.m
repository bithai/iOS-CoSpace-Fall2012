//
//  HCSViewController.m
//  iOS-CoSpace-Fall2012
//
//  Created by Carl Brown on 10/22/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import "HCSViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "Exercise.h"

#define kbExerciseCategoriesAPIURL @"http://getfitchimp.aws.af.cm/api/v1/categories"

@interface HCSViewController ()

@end

@implementation HCSViewController

@synthesize responseData = _responseData; // the result from network call
@synthesize items = _items; // the list of items to display in tableView

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  NSLog(@"viewDidLoad");
  
  // check if connection to server can be reached, if not display Alert
  [self checkReachability];
  
  self.responseData = [NSMutableData data];
  
  // create instance of NSURLRequest with api endpoint
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kbExerciseCategoriesAPIURL]];
  
  // display the network activity indicator
  // NOTE from stackoverflow: The UI won't be updated unless your code returns control to the runloop. So if you enable and disable the network indicator in the same method, it will never actually show.
  // so we hide the indicator in the connectDidFinishLoading method
  [UIApplication sharedApplication].networkActivityIndicatorVisible = true;
  
  // initialize request and make network call
  [[NSURLConnection alloc] initWithRequest:request delegate:self];

  
}

// checks for connection to server, sends Alert if not successful
- (void)checkReachability
{
  // allocate a reachability object
  Reachability* reach = [Reachability reachabilityWithHostname:[[NSURL URLWithString:kbExerciseCategoriesAPIURL] host]];
  
  // set the blocks
  reach.reachableBlock = ^(Reachability*reach)
  {
    NSLog(@"REACHABLE!");
  };
  
  reach.unreachableBlock = ^(Reachability*reach)
  {
    NSLog(@"UNREACHABLE!");
  };
  
  if(!reach.isReachable) {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Alert"
                                                   message: @"You're not connected to the server"
                                                  delegate: nil
                                         cancelButtonTitle: @"OK"
                                         otherButtonTitles:nil];
    [alert show];
  }

  
  // start the notifier which will cause the reachability object to retain itself!
  [reach startNotifier];
}

- (void)viewDidUnload
{
  [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.

}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  // A delegate method called by the NSURLConnection when the request/response
  // exchange is complete.
	NSLog(@"didReceiveResponse");
  [self.responseData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  // A delegate method called by the NSURLConnection as data arrives.
	[self.responseData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  // A delegate method called by the NSURLConnection if the connection fails.
  // We shut down the connection and display the failure.  Production quality code
  // would either display or log the actual error.
	NSLog(@"didFailWithError");
  NSLog(@"Connection failed: %@", [error description]);
  
  // hide network activity indicator after error
  [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
  
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {

  // A delegate method called by the NSURLConnection when the connection has been
  // done successfully.  We shut down the connection with a nil status, which
  // causes the image to be displayed.
  NSLog(@"connectionDidFinishLoading");
  NSLog(@"Success! Received %d bytes of data", [self.responseData length]);
  
  // convert to JSON
  NSError *myError = nil;
  NSDictionary *result = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&myError];

  NSLog(@"data: %@", [NSString stringWithFormat:@"HTTP response data%@", result]);
  
  self.items = [result objectForKey:@"results"];
  
  for(NSDictionary *d in self.items) {
    NSString *title = [d objectForKey:@"title"];
    
    NSLog(@"title: %@", title);
    
    
    
    
  }

  
  
  for (NSDictionary *repoDict in self.items) {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[repoDict valueForKeyPath:@"title"] forKey:@"title"];
    [newManagedObject setValue:[repoDict valueForKeyPath:@"slug"] forKey:@"slug"];

    
//nslog(@"title: %@", repoDict valueForKey)
    
  }
  // Save the context.
  NSError *error = nil;
  if (![self.managedObjectContext save:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
  
  

      [self.tableView reloadData];
  
  if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
  
  // hide network activity indicator after loading of data
  [UIApplication sharedApplication].networkActivityIndicatorVisible = false;
  
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  NSLog(@"Returning num sections");
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSLog(@"rows = %d", self.items.count);
  //return [self.items count];
  return [[self.fetchedResultsController fetchedObjects] count];
  
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
  // Identifier for retrieving reusable cells.
  static NSString *cellIdentifier = @"CellId";
  
  // Attempt to request the reusable cell.
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  // No cell available - create one.
  if(cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIdentifier];
  }
 
 
  // the single item row
  //NSDictionary *item = [self.items objectAtIndex:indexPath.row];
  
  // exercise slug value (e.g. ab-exercises,chest-exercises)
  //NSString *slug = [item objectForKey:@"slug"];

  // this loads the image from Resources
  //cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",slug]];
  
  //Alternative way to load image from url
  //NSString *urlString = [NSString stringWithFormat:@"%@%@%@", @"http://www.site.com/pathtoimage/",slug,@".jpg"];
  //NSURL *imageUrl = [NSURL URLWithString:urlString];
  //NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
  //cell.imageView.image = [UIImage imageWithData:imageData];
  
  
  //cell.textLabel.text = [item objectForKey:@"title"];
  
  NSString *slug =  [[self.fetchedResultsController objectAtIndexPath:indexPath] slug];
  NSString *title = [[self.fetchedResultsController objectAtIndexPath:indexPath] title];
  
  cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",slug]];
  cell.textLabel.text = title;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Spit out some pretty JSON for the tweet that was tapped. Neato.
	NSString *formattedJSON = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self.items objectAtIndex:indexPath.row] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
	NSLog(@"item:\n%@", formattedJSON);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  // Edit the entity name as appropriate.
  NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Exercise class]) inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  
  // Set the batch size to a suitable number.
  [fetchRequest setFetchBatchSize:30];
  
  // Edit the sort key as appropriate.
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
  NSArray *sortDescriptors = @[sortDescriptor];
  
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
  //aFetchedResultsController.delegate = self;
  self.fetchedResultsController = aFetchedResultsController;
  
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
	}
  
  return _fetchedResultsController;
}



@end
