//
//  RootViewController.m
//  Calagator
//
//  Created by Audrey Eschright on 12/3/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "EventsViewController.h"
#import "EventViewController.h"
#import "Event.h"

@implementation EventsViewController

@synthesize eventList;
@synthesize events;

- (void)dealloc {
    [eventList release];
	[events release];
	[super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Events on Calagator";
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

- (NSArray *)sortedEventKeys {
	return [[events allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [events count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *dateKey = [[self sortedEventKeys] objectAtIndex:section];
    return [[events objectForKey:dateKey] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *dateKey = [[self sortedEventKeys] objectAtIndex:section];

	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSDate *sectionDate = [dateFormatter dateFromString:dateKey];
	
	[dateFormatter setDateFormat:@"EEEE, MMMM d"];	
	return [dateFormatter stringFromDate:sectionDate];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// Configure the cell.
//	Event *event = [eventList objectAtIndex:indexPath.row];
	NSString *sectionName = [[self sortedEventKeys] objectAtIndex:indexPath.section];
	Event *event = [[events objectForKey:sectionName] objectAtIndex:indexPath.row];
	cell.textLabel.text = event.title;
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"h:mm a"];
	cell.detailTextLabel.text = [[dateFormatter stringFromDate:event.date] stringByAppendingFormat:@", %@", event.venueTitle];
	
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Navigation logic may go here -- for example, create and push another view controller.
	EventViewController *eventViewController = [[EventViewController alloc] initWithNibName:@"EventViewController" bundle:nil];
	NSString *sectionName = [[self sortedEventKeys] objectAtIndex:indexPath.section];
	eventViewController.event = [[events objectForKey:sectionName] objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:eventViewController animated:YES];
	[eventViewController release];
}

@end

