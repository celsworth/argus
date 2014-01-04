//
//  ArgusActiveRecording.m
//  Argus
//
//  Created by Chris Elsworth on 11/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "Argus.h"
#import "ArgusActiveRecording.h"

#import "SBJson.h"

#import "NSString+JSONDate.h"

#import "AppDelegate.h"

@implementation ArgusActiveRecording

// pass a JSONValue decoded dictionary.
-(id)initWithDictionary:(NSDictionary *)input
{
	self = [super init];
	if (self)
	{
		if (! [super populateSelfFromDictionary:input])
			return nil;
		
		// this needs forcing for an active recording, it can only ever be this
		self.UpcomingProgramme = [[ArgusUpcomingProgramme alloc] initWithDictionary:input[kProgram] ScheduleType:ArgusScheduleTypeRecording];
				
		// CardChannelAllocation
		
	}
	
	return self;
}
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__); // spammy
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setStopping:(BOOL)val
{
	self.StoppingAsNumber = @(val);
}
-(BOOL)Stopping
{
	return [self.StoppingAsNumber boolValue];
}

-(void)AbortActiveRecording
{
	// trigger a Program/{GuideProgramId} request to populate Description etc for this Programme
	NSString *url = [NSString stringWithFormat:@"Control/AbortActiveRecording"];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:NO lowPriority:NO];

	// request body is the live stream to stop, ie ourselves
	NSString *body = [self.originalData JSONRepresentation];
	[c setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	[c enqueue];

	self.StoppingAsNumber = @YES;
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(AbortActiveRecordingDone:)
												 name:kArgusConnectionDone
											   object:c];
}

-(void)AbortActiveRecordingDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];

	self.StoppingAsNumber = @NO;
	
	// now update our ActiveRecordings list
	// put a delay on this, active recordings seem to take a second or two to stop even after Abort returns
	[NSTimer scheduledTimerWithTimeInterval:2.0
									 target:argus
								   selector:@selector(getActiveRecordings)
								   userInfo:nil
									repeats:NO];
	//[argus getActiveRecordings];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusAbortActiveRecordingDone object:self];
}

		
@end
