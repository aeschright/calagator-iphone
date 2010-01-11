//
//  EventViewController.h
//  Calagator
//
//  Created by Audrey Eschright on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Event;

@interface EventViewController : UIViewController {
	Event *event;

	UILabel *eventName;
	UITextView *eventDescription;
	UIButton *eventURLButton;
	UILabel *eventDate;
	UILabel *venueName;
	UILabel *venueAddress;

    NSDateFormatter *dateFormatter;
}

@property (nonatomic, retain) IBOutlet Event *event;

@property (nonatomic, retain) IBOutlet UILabel *eventName;
@property (nonatomic, retain) IBOutlet UITextView *eventDescription;
@property (nonatomic, retain) IBOutlet UIButton	*eventURLButton;
@property (nonatomic, retain) IBOutlet UILabel *eventDate;
@property (nonatomic, retain) IBOutlet UILabel *venueName;
@property (nonatomic, retain) IBOutlet UILabel *venueAddress;

@property (nonatomic, retain, readonly) NSDateFormatter *dateFormatter;

- (IBAction) goToEventSite;
- (IBAction) goToMap;

@end
