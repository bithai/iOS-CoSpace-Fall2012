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

@interface HCSViewController ()

@end

@implementation HCSViewController

@synthesize responseData = _responseData;
@synthesize items = _items;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"viewDidLoad");
  
  
  self.checkReachability;
  
  
  
  self.responseData = [NSMutableData data];
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://getfitchimp.aws.af.cm/api/v1/categories"]];
  
  [[NSURLConnection alloc] initWithRequest:request delegate:self];
  
}


- (void)checkReachability
{
  // allocate a reachability object
  Reachability* reach = [Reachability reachabilityWithHostname:@"http://getfitchimp.aws.af.cm"];
  
  // set the blocks
  reach.reachableBlock = ^(Reachability*reach)
  {
    NSLog(@"REACHABLE!");
  };
  
  reach.unreachableBlock = ^(Reachability*reach)
  {
    NSLog(@"UNREACHABLE!");
  };
  
  if(reach.isReachable) {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Alert"
                                                   message: @"You're connected to the server"
                                                  delegate: nil
                                         cancelButtonTitle: @"OK"
                                         otherButtonTitles:nil];
    
    //Show Alert On The View
    [alert show];
    
    
  }
  else {
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
  NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
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
    
    [self.tableView reloadData];
    
  }
  
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  NSLog(@"Returning num sections");
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSLog(@"rows = %d", self.items.count);
  return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSLog(@"cellForRowAtIndexPath");
  
  // Identifier for retrieving reusable cells.
  static NSString *cellIdentifier = @"CellId";
  
  // Attempt to request the reusable cell.
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  // No cell available - create one.
  if(cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIdentifier];
  }
 
  NSDictionary *item = [self.items objectAtIndex:indexPath.row];
  cell.textLabel.text = [item objectForKey:@"title"];
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

@end
