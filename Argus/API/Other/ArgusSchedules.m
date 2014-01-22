//
//  ArgusSchedules.m
//  Argus
//
//  Created by Chris Elsworth on 02/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

// holds our list of schedules
// two properties, TvSchedules and RadioSchedules
// these are dictionaries, the keys of which are scheduleTypes (as NSNumber)
// and therein you'll find array of schedules

#import "ArgusSchedules.h"

#import "ArgusConnection.h"
#import "AppDelegate.h"

#import "SBJson.h"

@implementation ArgusSchedules

-(id)init
{
	self = [super init];
	if (self)
	{
		_TvSchedules = [NSMutableDictionary new];
		_RadioSchedules = [NSMutableDictionary new];
		
		// when anything deletes a schedule, we should refresh our list to ensure it's up to date
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getSchedulesForSelectedChannelType)
													 name:kArgusDeleteScheduleDone
												   object:nil];
		
		// when anything saves a schedule, we should refresh our list to ensure it's up to date
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getSchedulesForSelectedChannelType)
													 name:kArgusSaveScheduleDone
												   object:nil];
		
	}
	return self;
}
-(void)dealloc
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)getSchedulesForSelectedChannelType
{
	[self getSchedulesForChannelType:[[argus ChannelGroups] SelectedChannelType]];
}

-(void)getSchedulesForChannelType:(ArgusChannelType)channelType
{
	// we use these to check when to send the notification out
	self.RecordingsDone = self.AlertsDone = self.SuggestionsDone = NO;
	
	self.fetchingChannelType = channelType;
	self.tmpSchedulesKeyedByScheduleId = [NSMutableDictionary new];
	
	[self getSchedulesForChannelType:channelType scheduleType:ArgusScheduleTypeRecording];
	[self getSchedulesForChannelType:channelType scheduleType:ArgusScheduleTypeAlert];
	[self getSchedulesForChannelType:channelType scheduleType:ArgusScheduleTypeSuggestion];
	
	[AppDelegate requestLoadingSpinner];
}

-(void)getSchedulesForChannelType:(ArgusChannelType)channelType scheduleType:(ArgusScheduleType)scheduleType
{
	//NSLog(@"%s %d %d", __PRETTY_FUNCTION__, channelType, scheduleType);
	
	NSString *url = [NSString stringWithFormat:@"Scheduler/Schedules/%d/%d", channelType, scheduleType];
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	// we poke a different selector depending on scheduleType
	// this is kinda crap. really ArgusConnection could do with opaque userInfo we could consult on return?
	SEL selector;
	switch (scheduleType)
	{
		case ArgusScheduleTypeRecording:
			selector = @selector(RecordingsDone:);
			break;
		case ArgusScheduleTypeAlert:
			selector = @selector(AlertsDone:);
			break;
		case ArgusScheduleTypeSuggestion:
			selector = @selector(SuggestionsDone:);
			break;
	}
	
	// tell us when the ArgusConnection is done, so we can poke any waiters
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:selector
												 name:kArgusConnectionDone
											   object:c];
	
	return;
}
-(void)RecordingsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	self.RecordingsDone = YES;
	[self setSchedules:[self SchedulesDone:notify] forChannelType:self.fetchingChannelType scheduleType:ArgusScheduleTypeRecording];
	[self sendNotifyIfAllDone];
}
-(void)AlertsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	self.AlertsDone = YES;
	[self setSchedules:[self SchedulesDone:notify] forChannelType:self.fetchingChannelType scheduleType:ArgusScheduleTypeAlert];
	[self sendNotifyIfAllDone];
}
-(void)SuggestionsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	self.SuggestionsDone = YES;
	[self setSchedules:[self SchedulesDone:notify] forChannelType:self.fetchingChannelType scheduleType:ArgusScheduleTypeSuggestion];
	[self sendNotifyIfAllDone];
}


-(NSMutableArray *)SchedulesDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	// notify userInfo now needs parsing into Schedules
	NSData *data = [notify userInfo][@"data"];
	
	SBJsonParser *jsonParser = [SBJsonParser new];
	NSArray *jsonObject = [jsonParser objectWithData:data];
	
	NSMutableArray *tmpArr = [NSMutableArray new];
	
	for (NSDictionary *d in jsonObject)
	{
		//NSLog(@"%s %@", __PRETTY_FUNCTION__, d);
		
		ArgusSchedule *t = [[ArgusSchedule alloc] initWithDictionary:d];
		[tmpArr addObject:t];
		self.tmpSchedulesKeyedByScheduleId[[t Property:kScheduleId]] = t;
	}
	
	return tmpArr;
}
-(void)sendNotifyIfAllDone
{
	NSLog(@"%s %d %d %d", __PRETTY_FUNCTION__, self.RecordingsDone, self.AlertsDone, self.SuggestionsDone);
	if (self.RecordingsDone && self.AlertsDone && self.SuggestionsDone)
	{
		// update SchedulesKeyedByScheduleId as well (used to tie up UpcomingProgrammes to a schedule details)
		self.SchedulesKeyedByScheduleId = self.tmpSchedulesKeyedByScheduleId;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kArgusSchedulesDone object:self userInfo:nil];
		
		[AppDelegate releaseLoadingSpinner];
	}
}



-(NSMutableArray *)schedulesForChannelType:(ArgusChannelType)channelType scheduleType:(ArgusScheduleType)scheduleType
{
	NSMutableDictionary *tD;
	
	switch (channelType)
	{
		case ArgusChannelTypeTelevision: tD = self.TvSchedules;    break;
		case ArgusChannelTypeRadio:      tD = self.RadioSchedules; break;
		case ArgusChannelTypeAny: assert(0); // cannot pass ArgusChannelTypeAny
	}
	
	return tD[@(scheduleType)];
}

-(void)setSchedules:(NSArray *)arr forChannelType:(ArgusChannelType)channelType scheduleType:(ArgusScheduleType)scheduleType
{
	NSMutableDictionary *tD;
	
	switch (channelType)
	{
		case ArgusChannelTypeTelevision: tD = self.TvSchedules;    break;
		case ArgusChannelTypeRadio:      tD = self.RadioSchedules; break;
		case ArgusChannelTypeAny: assert(0); // cannot pass ArgusChannelTypeAny
	}
	
	tD[@(scheduleType)] = arr;
}


@end
