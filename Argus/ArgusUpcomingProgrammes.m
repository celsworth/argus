//
//  ArgusUpcomingProgrammes.m
//  Argus
//
//  Created by Chris Elsworth on 02/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

// this is used from both our main Argus object, and from each instantiated Schedule
// to set up our observers correctly, we need to know what type of object we're for

#import "ArgusUpcomingProgrammes.h"

#import "ArgusUpcomingProgramme.h"
#import "ArgusConnection.h"
#import "AppDelegate.h"

//#import "SBJson.h"
#import "JSONKit.h"

@implementation ArgusUpcomingProgrammes
@synthesize UpcomingRecordings, UpcomingAlerts, UpcomingSuggestions;
@synthesize IsForSchedule;
@synthesize IsForScheduleType;
@synthesize UpcomingProgrammesKeyedByUniqueIdentifier, tmpUpcomingProgrammesKeyedByUniqueIdentifier;
//@synthesize UpcomingProgrammesKeyedByUpcomingProgramId, tmpUpcomingProgrammesKeyedByUpcomingProgramId;


@synthesize RecordingsDone, AlertsDone, SuggestionsDone;


// init from the global Argus object
-(id)init
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	self = [super init];
	if (self)
	{
		UpcomingRecordings = [NSMutableArray new];
		UpcomingAlerts = [NSMutableArray new];
		UpcomingSuggestions = [NSMutableArray new];

		IsForSchedule = nil;

		// when any upcoming programme changes, refresh our lists
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingProgrammes)
													 name:kArgusRemoveFromPreviouslyRecordedHistoryDone
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingProgrammes)
													 name:kArgusAddToPreviouslyRecordedHistoryDone
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingProgrammes)
													 name:kArgusCancelUpcomingProgrammeDone
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingProgrammes)
													 name:kArgusUncancelUpcomingProgrammeDone
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingProgrammes)
													 name:kArgusSaveUpcomingProgrammeDone
												   object:nil];
		
		// when anything deletes a schedule, we should refresh our list to ensure it's up to date
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingProgrammes)
													 name:kArgusDeleteScheduleDone
												   object:nil];
		
		// when anything saves a schedule, we should refresh our list to ensure it's up to date
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingProgrammes)
													 name:kArgusSaveScheduleDone
												   object:nil];
	}
	return self;
}
// init from a Schedule
-(id)initWithSchedule:(ArgusSchedule *)schedule
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	self = [super init];
	if (self)
	{
		UpcomingRecordings = [NSMutableArray new];
		UpcomingAlerts = [NSMutableArray new];
		UpcomingSuggestions = [NSMutableArray new];

		IsForSchedule = schedule;
		SEL sel = @selector(getUpcomingProgrammesForSchedule);
		
		// when any upcoming programme changes, refresh our lists
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:sel
													 name:kArgusCancelUpcomingProgrammeDone
												   object:IsForSchedule];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:sel
													 name:kArgusUncancelUpcomingProgrammeDone
												   object:IsForSchedule];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:sel
													 name:kArgusSaveUpcomingProgrammeDone
												   object:IsForSchedule];
		
		// when anything deletes a schedule, we should refresh our list to ensure it's up to date
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:sel
													 name:kArgusDeleteScheduleDone
												   object:IsForSchedule];
		
		// when anything saves a schedule, we should refresh our list to ensure it's up to date
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:sel
													 name:kArgusSaveScheduleDone
												   object:IsForSchedule];

	}
	return self;
}

-(void)dealloc
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)redoLocalNotifications
{
	// ensure our queued local notifications are in sync with reality
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	[UpcomingAlerts enumerateObjectsUsingBlock:^(ArgusUpcomingProgramme *obj, NSUInteger idx, BOOL *stop)
	{
		[obj setupLocalNotification];
	}];
	
}

#pragma mark - Global Upcoming stuff

-(void)getUpcomingProgrammes
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// divert to the correct function if we are for a single schedule
	if (IsForSchedule)
		return [self getUpcomingProgrammesForSchedule];
	
	[AppDelegate requestLoadingSpinner];

	// upcoming programmes for the entire system have 3 types
	
	// we use these to check when to send the notification out
	RecordingsDone = AlertsDone = SuggestionsDone = NO;	
	
	tmpUpcomingProgrammesKeyedByUniqueIdentifier = [NSMutableDictionary new];
	//tmpUpcomingProgrammesKeyedByUpcomingProgramId = [NSMutableDictionary new];
	
	[self getUpcomingProgrammesForScheduleType:ArgusScheduleTypeRecording];
	[self getUpcomingProgrammesForScheduleType:ArgusScheduleTypeAlert];
	[self getUpcomingProgrammesForScheduleType:ArgusScheduleTypeSuggestion];
	
}

-(void)getUpcomingProgrammesForScheduleType:(ArgusScheduleType)scheduleType
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	NSString *url = [NSString stringWithFormat:@"Scheduler/UpcomingPrograms/%d?includeCancelled=true", scheduleType];
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
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:selector
												 name:kArgusConnectionDone
											   object:c];
}

-(NSMutableArray *)UpcomingProgrammesDone:(NSNotification *)notify forScheduleType:(ArgusScheduleType)scheduleType
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	NSData *data = [[notify userInfo] objectForKey:@"data"];
	
	NSArray *jsonObject = [data objectFromJSONData];
	
	NSMutableArray *tmpArr = [NSMutableArray new];
	
	for (NSDictionary *t in jsonObject)
	{
		//NSLog(@"%s %@", __PRETTY_FUNCTION__, t);
		
		ArgusUpcomingProgramme *p = [[ArgusUpcomingProgramme alloc] initWithDictionary:t ScheduleType:scheduleType];
		
		[tmpArr addObject:p];
		
		[tmpUpcomingProgrammesKeyedByUniqueIdentifier setObject:p forKey:[p uniqueIdentifier]];
		//[tmpUpcomingProgrammesKeyedByUpcomingProgramId setObject:p forKey:[p Property:kUpcomingProgramId]];
	}
	
	NSLog(@"%s done", __PRETTY_FUNCTION__);
	return tmpArr;
}


// recordings call a different processing function
-(void)RecordingsDone:(NSNotification *)notify
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	RecordingsDone = YES;
	
	NSMutableArray *tmpArr = [self UpcomingProgrammesDone:notify forScheduleType:ArgusScheduleTypeRecording];
	[self setUpcomingRecordings:tmpArr];
	
	[self sendNotifyIfAllDone];
}

// alerts and suggestions are the same
-(void)AlertsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	AlertsDone = YES;
	
	// cancel any notifications we happen to have lying about, we'll recreate them
	// as we learn new upcoming programmes in the below loop
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	NSMutableArray *tmpArr = [self UpcomingProgrammesDone:notify forScheduleType:ArgusScheduleTypeAlert];
	[self setUpcomingAlerts:tmpArr];
	
	[self sendNotifyIfAllDone];
}
-(void)SuggestionsDone:(NSNotification *)notify
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	SuggestionsDone = YES;
	
	NSMutableArray *tmpArr = [self UpcomingProgrammesDone:notify forScheduleType:ArgusScheduleTypeSuggestion];
	[self setUpcomingSuggestions:tmpArr];
	
	[self sendNotifyIfAllDone];
}

-(void)sendNotifyIfAllDone
{
	NSLog(@"%s %d %d %d", __PRETTY_FUNCTION__, RecordingsDone, AlertsDone, SuggestionsDone);
	if (RecordingsDone && AlertsDone && SuggestionsDone)
	{
		UpcomingProgrammesKeyedByUniqueIdentifier = tmpUpcomingProgrammesKeyedByUniqueIdentifier;
		//UpcomingProgrammesKeyedByUpcomingProgramId = tmpUpcomingProgrammesKeyedByUpcomingProgramId;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kArgusUpcomingProgrammesDone object:self userInfo:nil];
		
		[AppDelegate releaseLoadingSpinner];
	}
}

#pragma mark Reading Programmes
-(NSMutableArray *)upcomingProgrammesForScheduleType:(ArgusScheduleType)scheduleType
{
	switch (scheduleType)
	{
		case ArgusScheduleTypeRecording:
			return UpcomingRecordings;
			break;
		case ArgusScheduleTypeAlert:
			return UpcomingAlerts;
			break;
		case ArgusScheduleTypeSuggestion:
			return UpcomingSuggestions;
			break;
	}
}


#pragma mark - Schedule-specific functions


-(void)getUpcomingProgrammesForSchedule
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// upcoming programmes for a schedule can only have one type; the ScheduleType of the schedule
	
	NSString *url = [NSString stringWithFormat:@"Scheduler/UpcomingProgramsForSchedule"];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:NO lowPriority:NO];
	
	NSMutableDictionary *tmp = [NSMutableDictionary new];
	[tmp setObject:[IsForSchedule originalData] forKey:@"Schedule"];
	[tmp setObject:[NSNumber numberWithBool:YES] forKey:@"IncludeCancelled"];
	
	NSString *body = [tmp JSONString];
	
	NSLog(@"%s: upcoming for: %@", __PRETTY_FUNCTION__, [IsForSchedule originalData]);
	[c setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	[c enqueue];
	
	IsForScheduleType = [[IsForSchedule Property:kScheduleType] intValue];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(UpcomingProgrammesForScheduleDone:)
												 name:kArgusConnectionDone
											   object:c];
}
-(void)UpcomingProgrammesForScheduleDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	NSData *data = [[notify userInfo] objectForKey:@"data"];
	
	NSDictionary *jsonObject = [data objectFromJSONData];
	//NSLog(@"%@", jsonObject);

	NSMutableArray *tmpArr = [NSMutableArray new];
	
	for (NSDictionary *t in jsonObject)
	{
		ArgusUpcomingProgramme *p = [[ArgusUpcomingProgramme alloc] initWithDictionary:t ScheduleType:IsForScheduleType];
		
		NSLog(@"%@", p);
		
		[tmpArr addObject:p];
		[tmpUpcomingProgrammesKeyedByUniqueIdentifier setObject:p forKey:[p uniqueIdentifier]];
		//[tmpUpcomingProgrammesKeyedByUpcomingProgramId setObject:p forKey:[p Property:kUpcomingProgramId]];
	}
	
	UpcomingProgrammesKeyedByUniqueIdentifier = tmpUpcomingProgrammesKeyedByUniqueIdentifier;
	//UpcomingProgrammesKeyedByUpcomingProgramId = tmpUpcomingProgrammesKeyedByUpcomingProgramId;
	
	switch (IsForScheduleType)
	{
		case ArgusScheduleTypeRecording: [self setUpcomingRecordings:tmpArr]; break;
		case ArgusScheduleTypeAlert: [self setUpcomingAlerts:tmpArr]; break;
		case ArgusScheduleTypeSuggestion: [self setUpcomingSuggestions:tmpArr]; break;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusUpcomingProgrammesDone
														object:self
													  userInfo:nil];
}

#pragma mark Reading Programmes
-(NSMutableArray *)upcomingProgrammesForSchedule
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	if (IsForSchedule)
		return [self upcomingProgrammesForScheduleType:IsForScheduleType];

	return nil;
}


@end
