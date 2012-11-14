//
//  ArgusUpcomingRecording.m
//  Argus
//
//  Created by Chris Elsworth on 04/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

// an UpcomingRecording. This one differs from UpcomingProgram slightly
// in that we can get ConflictingPrograms and CardChannelAllocation

#import "ArgusUpcomingRecording.h"

@implementation ArgusUpcomingRecording

-(BOOL)populateSelfFromDictionary:(NSDictionary *)input
{
	if (! [super populateSelfFromDictionary:input])
		return NO;
	
	if ([input isKindOfClass:[NSDictionary class]])
	{
		NSDictionary *tmp;
		
		if ((tmp = [input objectForKey:kProgram]))
			self.UpcomingProgramme = [[ArgusUpcomingProgramme alloc] initWithDictionary:tmp ScheduleType:ArgusScheduleTypeRecording];
		
		if ((tmp = [input objectForKey:kCardChannelAllocation]))
			self.CardChannelAllocation = [[ArgusCardChannelAllocation alloc] initWithDictionary:tmp];
		
		// ConflictingPrograms?
		
		return YES;
	}	
	
	return NO;
}

-(NSString *)uniqueIdentifier
{
	// UpcomingRecording uniqueIdentifier uses Program.UpcomingProgramId
	// this isn't really used, we just call the Property directly
	// but this being here stops ArgusProgramme uniqueIdentifier being called, which
	// will assert because of missing properties!
	return [self.UpcomingProgramme Property:kUpcomingProgramId];
}

-(BOOL)willRecord
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, [self Property:kCardChannelAllocation]);
	
	// CardChannelAllocation being non-null means it will record
	return [self Property:kCardChannelAllocation] ? YES : NO;
}

@end
