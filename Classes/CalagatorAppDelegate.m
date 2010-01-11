//
//  CalagatorAppDelegate.m
//  Calagator
//
//  Created by Audrey Eschright on 12/3/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "CalagatorAppDelegate.h"
#import "EventsViewController.h"
#import "Event.h"

@implementation CalagatorAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize eventsViewController;
@synthesize eventList;
@synthesize eventFeedConnection;
@synthesize eventData;
@synthesize currentEventObject;
@synthesize currentParsedCharacterData;
@synthesize currentParseBatch;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:.51 green:.77 blue:.33 alpha:1];
	
    // Override point for customization after app launch
	self.eventList = [NSMutableArray array];
	eventsViewController.eventList = eventList;

	[window addSubview:[navigationController view]];

//	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
//	NSDate *date = [NSDate date];
//	NSString *today = [dateFormatter stringFromDate:date];

	NSString *feedURLString = @"http://calagator.org/events.xml";
//	NSString *feedURLString = [NSString stringWithFormat:@"http://calagator.org/events.xml?date[start]=%@&date[end]=%@", today, today];
	NSURLRequest *eventURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.eventFeedConnection = [[[NSURLConnection alloc] initWithRequest:eventURLRequest delegate:self] autorelease];
	
	NSAssert(self.eventFeedConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}

#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.eventData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [eventData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
	[self handleError:error];
    self.eventFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.eventFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
    // Spawn a thread to fetch the data so that the UI is not blocked while the application parses the XML data.
    //
    // IMPORTANT! - Don't access UIKit objects on secondary threads.
    //
    [NSThread detachNewThreadSelector:@selector(parseEventData:) toTarget:self withObject:eventData];
	
    // eventData will be retained by the thread until parseEventData: has finished executing, so we no longer need
    // a reference to it in the main thread.
    self.eventData = nil;
}

- (void)parseEventData:(NSData *)data {
    // You must create a autorelease pool for all secondary threads.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not desirable
    // because it gives less control over the network, particularly in responding to connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
	
    // depending on the total number of earthquakes parsed, the last batch might not have been a "full" batch, and thus
    // not been part of the regular batch transfer. So, we check the count of the array and, if necessary, send it to the main thread.
    if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(addEventsToList:) withObject:self.currentParseBatch waitUntilDone:NO];
    }
    self.currentParseBatch = nil;
    self.currentEventObject = nil;
    self.currentParsedCharacterData = nil;
    [parser release];        
    [pool release];
}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Title", @"Title for alert displayed when download or parse error occurs.") message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)addEventsToList:(NSArray *)events {
    [self.eventList addObjectsFromArray:events];
    // The table needs to be reloaded to reflect the new content of the list.
	[eventsViewController.tableView reloadData];
}

#pragma mark Parser constants

static const const NSUInteger kMaximumNumberOfEventsToParse = 50;
static NSUInteger const kSizeOfEventBatch = 10;

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kEntryElementName = @"event";
static NSString * const kTitleElementName = @"title";
static NSString * const kDescriptionElementName = @"description";
static NSString * const kURLElementName = @"url";
static NSString * const kDateElementName = @"start-time";
static NSString * const kVenueElementName = @"venue";
static NSString * const	kVenueAddressName = @"address";
static NSString * const kLatitude = @"latitude";
static NSString * const kLongitude = @"longitude";

#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (parsedEventsCounter >= kMaximumNumberOfEventsToParse) {
        // Use the flag didAbortParsing to distinguish between this deliberate stop and other parser errors.
        didAbortParsing = YES;
        [parser abortParsing];
    }
	
    if ([elementName isEqualToString:kEntryElementName]) {
        Event *event = [[Event alloc] init];
        self.currentEventObject = event;
		inVenue = NO;
        [event release];
	} else if ([elementName isEqualToString:kVenueElementName]) {
		// Handle venue attributes
		inVenue = YES;
    } else if ([elementName isEqualToString:kTitleElementName] || 
			   [elementName isEqualToString:kDescriptionElementName] || 
			   [elementName isEqualToString:kURLElementName] ||
			   [elementName isEqualToString:kDateElementName] ||
			   [elementName isEqualToString:kVenueAddressName] || 
			   [elementName isEqualToString:kLatitude] ||
			   [elementName isEqualToString:kLongitude]) {
        // Begin accumulating parsed character data.
        // The contents are collected in parser:foundCharacters:.
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [currentParsedCharacterData setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
    if ([elementName isEqualToString:kEntryElementName]) {
        [self.currentParseBatch addObject:self.currentEventObject];
        parsedEventsCounter++;
        if (parsedEventsCounter % kSizeOfEventBatch == 0) {
            [self performSelectorOnMainThread:@selector(addEventsToList:) withObject:self.currentParseBatch waitUntilDone:NO];
            self.currentParseBatch = [NSMutableArray array];
        }
    } else if (inVenue == NO) {
		NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
		if ([elementName isEqualToString:kTitleElementName]) {
			self.currentEventObject.title = scanner.string;
		} else if ([elementName isEqualToString:kDescriptionElementName]) {
			self.currentEventObject.description = scanner.string;
		} else if ([elementName isEqualToString:kURLElementName]) {
			self.currentEventObject.link = scanner.string;
		} else if ([elementName isEqualToString:kDateElementName]) {
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
			self.currentEventObject.date = [dateFormatter dateFromString:self.currentParsedCharacterData];
		}
	} else if (inVenue == YES) {
		NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
		if ([elementName isEqualToString:kTitleElementName]) {
			self.currentEventObject.venueTitle = scanner.string;
		} else if ([elementName isEqualToString:kVenueAddressName]) {
			self.currentEventObject.venueAddress = scanner.string;
		} else if ([elementName isEqualToString:kLatitude]) {
			double latitude;
			[scanner scanDouble:&latitude];
			self.currentEventObject.latitude = latitude;
		} else if ([elementName isEqualToString:kLongitude]) {
			double longitude;
			[scanner scanDouble:&longitude];
			self.currentEventObject.longitude = longitude;
		}
	}
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element. The parser is not
// guaranteed to deliver all of the parsed character data for an element in a single invocation, so it is necessary to
// accumulate character data until the end of the element is reached.
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {	
    if (accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.currentParsedCharacterData appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // If the number of earthquake records received is greater than kMaximumNumberOfEarthquakesToParse, we abort parsing.
    // The parser will report this as an error, but we don't want to treat it as an error. The flag didAbortParsing is
    // how we distinguish real errors encountered by the parser.
    if (didAbortParsing == NO) {
        // Pass the error to the main thread for handling.
        [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[eventFeedConnection release];
	[eventData release];
	[navigationController release];
	[window release];
	[eventList release];
	[currentEventObject release];
    [currentParsedCharacterData release];
    [currentParseBatch release];
	[super dealloc];
}


@end

