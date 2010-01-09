//
//  Events.h
//  Calagator
//
//  Created by Audrey Eschright on 12/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Event : NSObject {
	NSString *title;
	NSString *description;
	NSString *link;
	NSDate *date;
	NSString *venueTitle;
	NSString *venueAddress;
	double latitude;
	double longitude;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *venueTitle;
@property (nonatomic, retain) NSString *venueAddress;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

- (NSString *) cleanDescription;

@end
