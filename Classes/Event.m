//
//  Events.m
//  Calagator
//
//  Created by Audrey Eschright on 12/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@implementation Event

@synthesize title;
@synthesize description;
@synthesize link;
@synthesize date;
@synthesize venueTitle;
@synthesize venueAddress;
@synthesize latitude;
@synthesize longitude;

- (NSString *) cleanDescription {
	NSScanner *scanner = [NSScanner scannerWithString:self.description];
	NSString *tag = @"";
	NSString *cleaned = self.description;

	while ([scanner isAtEnd] == NO) {
		[scanner scanUpToString:@"<" intoString:NULL];
		[scanner scanUpToString:@">" intoString:&tag];
		cleaned = [cleaned stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", tag] withString:@""];
	}
	return cleaned;
}

-(void) dealloc {
	[title release];
	[description release];
	[link release];
	[venueTitle release];
	[venueAddress release];
	[super dealloc];
}
	

@end
