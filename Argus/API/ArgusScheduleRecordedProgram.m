//
//  ArgusScheduleRecordedProgram.m
//  Argus
//
//  Created by Chris Elsworth on 17/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusScheduleRecordedProgram.h"
#import "ArgusSchedule.h"

#import "ArgusConnection.h"

@implementation ArgusScheduleRecordedProgram

-(void)removeFromPRH
{
	NSString *url = [NSString stringWithFormat:@"Control/DeleteFromPreviouslyRecordedHistory/%@", [self Property:kScheduleRecordedProgramId]];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(removeFromPRHDone:)
												 name:kArgusConnectionDone
											   object:c];
	
	self.IsRemovingFromPRH = YES;
}
-(void)removeFromPRHDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];

	self.IsRemovingFromPRH = NO;
	
	// trigger a refetch of the PreviouslyRecordedHistory for the schedule, as it will now be out of date
	ArgusSchedule *Schedule = [ArgusSchedule ScheduleForScheduleId:[self Property:kScheduleId]];
	[Schedule getPRH];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusScheduleRecordedProgramRemoveFromPRHDone object:self];
}


@end
