//
//  CalagatorAppDelegate.h
//  Calagator
//
//  Created by Audrey Eschright on 12/3/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@class Event, EventsViewController;

@interface CalagatorAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
	
	EventsViewController *eventsViewController;
	NSMutableArray *eventList;
	NSMutableDictionary *events;

    // for downloading the xml data
    NSURLConnection *eventFeedConnection;
    NSMutableData *eventData;
	
    // these variables are used during parsing
    Event *currentEventObject;
    NSMutableArray *currentParseBatch;
    NSUInteger parsedEventsCounter;
    NSMutableString *currentParsedCharacterData;
    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
	BOOL inVenue;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet EventsViewController *eventsViewController;
@property (nonatomic, retain) NSMutableArray *eventList;
@property (nonatomic, retain) NSMutableDictionary *events;

@property (nonatomic, retain) NSURLConnection *eventFeedConnection;
@property (nonatomic, retain) NSMutableData *eventData;

@property (nonatomic, retain) Event *currentEventObject;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;

- (void)addEventsToList:(NSArray *)events;
- (void)handleError:(NSError *)error;

@end

