//
//  EventViewController.m
//  Calagator
//
//  Created by Audrey Eschright on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"
#import "Event.h"


@implementation EventViewController

@synthesize event;

@synthesize eventName;
@synthesize eventDescription;
@synthesize eventURLButton;
@synthesize eventDate;
@synthesize venueName;
@synthesize venueAddress;

- (IBAction) goToEventSite {
	NSString *webLink = [event link];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:webLink]];
}

- (IBAction) goToMap {
	static NSString * const kMapsBaseURL = @"http://maps.google.com/maps?";
	NSString *mapsQuery = [NSString stringWithFormat:@"q=%@&ll=%f,%f", event.venueTitle, event.latitude, event.longitude];
	mapsQuery = [mapsQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *mapsURLString = [kMapsBaseURL stringByAppendingString:mapsQuery];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsURLString]];
}	

// On-demand initializer for read-only property.
- (NSDateFormatter *)dateFormatter {
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return dateFormatter;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.eventName.text = event.title;
	self.eventDate.text = [self.dateFormatter stringFromDate:event.date];
	self.eventDescription.text = [event cleanDescription];
	self.venueName.text = event.venueTitle;
	self.venueAddress.text = event.venueAddress;
	
	if ([event.link length] == 0) {
		[self.eventURLButton setEnabled:NO];
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
