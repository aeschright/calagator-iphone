//
//  RootViewController.h
//  Calagator
//
//  Created by Audrey Eschright on 12/3/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@interface EventsViewController : UITableViewController {
	NSArray *eventList;
	NSDictionary *events;
}

@property (nonatomic, retain) NSArray *eventList;
@property (nonatomic, retain) NSDictionary *events;

@end
