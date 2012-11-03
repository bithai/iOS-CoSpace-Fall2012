//
//  HCSViewController.m
//  iOS-CoSpace-Fall2012
//
//  Created by Carl Brown on 10/22/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import "HCSViewController.h"

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
  self.responseData = [NSMutableData data];
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/statuses/user_timeline.json?screen_name=bithai"]];
  
  [[NSURLConnection alloc] initWithRequest:request delegate:self];
  
}

- (void)viewDidUnload
{
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
  
  self.items = result; //[result objectForKey:@"results"];
  for(NSDictionary *d in self.items) {
    NSString *title = [d objectForKey:@"text"];
    NSLog(@"text: %@", title);
    
  }
  
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSLog(@"rows = %d", self.items.count);
  return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSLog(@"cellForRowAtIndexPath");
  UITableViewCell *cell = [[UITableViewCell alloc] init];
 
  NSDictionary *item = [self.items objectAtIndex:indexPath.row];
  cell.textLabel.text = [item objectForKey:@"text"];
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
