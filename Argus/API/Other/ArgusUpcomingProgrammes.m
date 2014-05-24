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

@implementation ArgusUpcomingProgrammes

// init from the global Argus object
-(id)init
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	self = [super init];
	if (self)
	{
		_UpcomingRecordings = [NSMutableArray new];
		_UpcomingAlerts = [NSMutableArray new];
		_UpcomingSuggestions = [NSMutableArray new];
		
		_IsForSchedule = nil;
		
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
		_UpcomingRecordings = [NSMutableArray new];
		_UpcomingAlerts = [NSMutableArray new];
		_UpcomingSuggestions = [NSMutableArray new];
		
		_IsForSchedule = schedule;
		SEL sel = @selector(getUpcomingProgrammesForSchedule);
		
		// when any upcoming programme changes, refresh our lists
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:sel
													 name:kArgusCancelUpcomingProgrammeDone
												   object:self.IsForSchedule];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:sel
													 name:kArgusUncancelUpcomingProgrammeDone
												   object:self.IsForSchedule];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:sel
													 name:kArgusSaveUpcomingProgrammeDone
												   object:self.IsForSchedule];
		
		// when anything deletes a schedule, we should refresh our list to ensure it's up to date
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:sel
													 name:kArgusDeleteScheduleDone
												   object:self.IsForSchedule];
		
		// when anything saves a schedule, we should refresh our list to ensure it's up to date
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:sel
													 name:kArgusSaveScheduleDone
												   object:self.IsForSchedule];
		
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
	
	[self.UpcomingAlerts enumerateObjectsUsingBlock:^(ArgusUpcomingProgramme *obj, NSUInteger idx, BOOL *stop)
	 {
		 [obj setupLocalNotification];
	 }];
	
}

#pragma mark - Global Upcoming stuff

-(void)getUpcomingProgrammes
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// divert to the correct function if we are for a single schedule
	if (self.IsForSchedule)
		return [self getUpcomingProgrammesForSchedule];
	
	[AppDelegate requestLoadingSpinner];
	
	// upcoming programmes for the entire system have 3 types
	
	// we use these to check when to send the notification out
	self.RecordingsDone = self.AlertsDone = self.SuggestionsDone = NO;
	
	self.tmpUpcomingProgrammesKeyedByUniqueIdentifier = [NSMutableDictionary new];
	//tmpUpcomingProgrammesKeyedByUpcomingProgramId = [NSMutableDictionary new];
	
	[self getUpcomingProgrammesForScheduleType:ArgusScheduleTypeRecording];
	[self getUpcomingProgrammesForScheduleType:ArgusScheduleTypeAlert];
	[self getUpcomingProgrammesForScheduleType:ArgusScheduleTypeSuggestion];
	
}

-(void)getUpcomingProgrammesForScheduleType:(ArgusScheduleType)scheduleType
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	NSString *url = [NSString stringWithFormat:@"Scheduler/UpcomingPrograms/%ld?includeCancelled=true", scheduleType];
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
	
	NSData *data = [notify userInfo][@"data"];
	
	NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	
	NSMutableArray *tmpArr = [NSMutableArray new];
	
	for (NSDictionary *t in jsonObject)
	{
		//NSLog(@"%s %@", __PRETTY_FUNCTION__, t);
		
		ArgusUpcomingProgramme *p = [[ArgusUpcomingProgramme alloc] initWithDictionary:t ScheduleType:scheduleType];
		
		[tmpArr addObject:p];
		
		self.tmpUpcomingProgrammesKeyedByUniqueIdentifier[[p uniqueIdentifier]] = p;
		//[tmpUpcomingProgrammesKeyedByUpcomingProgramId setObject:p forKey:[p Property:kUpcomingProgramId]];
	}
	
	NSLog(@"%s done", __PRETTY_FUNCTION__);
	return tmpArr;
}


// recordings call a different processing function
-(void)RecordingsDone:(NSNotification *)notify
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	self.RecordingsDone = YES;
	
	NSMutableArray *tmpArr = [self UpcomingProgrammesDone:notify forScheduleType:ArgusScheduleTypeRecording];
	[self setUpcomingRecordings:tmpArr];
	
	[self sendNotifyIfAllDone];
}

// alerts and suggestions are the same
-(void)AlertsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	self.AlertsDone = YES;
	
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
	
	self.SuggestionsDone = YES;
	
	NSMutableArray *tmpArr = [self UpcomingProgrammesDone:notify forScheduleType:ArgusScheduleTypeSuggestion];
	[self setUpcomingSuggestions:tmpArr];
	
	[self sendNotifyIfAllDone];
}

-(void)sendNotifyIfAllDone
{
	NSLog(@"%s %d %d %d", __PRETTY_FUNCTION__, self.RecordingsDone, self.AlertsDone, self.SuggestionsDone);
	if (self.RecordingsDone && self.AlertsDone && self.SuggestionsDone)
	{
		self.UpcomingProgrammesKeyedByUniqueIdentifier = self.tmpUpcomingProgrammesKeyedByUniqueIdentifier;
		
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
			return self.UpcomingRecordings;
			break;
		case ArgusScheduleTypeAlert:
			return self.UpcomingAlerts;
			break;
		case ArgusScheduleTypeSuggestion:
			return self.UpcomingSuggestions;
			break;
	}
}


#pragma mark - Schedule-specific functions

-(void)getUpcomingProgrammesForSchedule
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// upcoming programmes for a schedule can only have one type; the ScheduleType of the schedule
	self.IsForScheduleType = [[self.IsForSchedule Property:kScheduleType] intValue];
	
	
	NSMutableDictionary *tmp = [NSMutableDictionary new];
	tmp[@"Schedule"] = [self.IsForSchedule originalData];
	tmp[@"IncludeCancelled"] = @YES;
	
	NSString *url = [NSString stringWithFormat:@"Scheduler/UpcomingProgramsForSchedule"];
	
	// block to run when the request finishes
	ArgusConnectionCompletionBlock cmp = ^(NSHTTPURLResponse *response, NSData *data, NSError *error)
	{
		NSLog(@"%s", __PRETTY_FUNCTION__);
		
		if (error)
		{
			// FIXME: handle error in getUpcomingProgrammesForSchedule
			return;
		}
		
		NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		//NSLog(@"%@", jsonObject);
		
		NSMutableArray *tmpArr = [NSMutableArray new];
		
		for (NSDictionary *t in jsonObject)
		{
			ArgusUpcomingProgramme *p = [[ArgusUpcomingProgramme alloc] initWithDictionary:t
																			  ScheduleType:self.IsForScheduleType];
			
			[tmpArr addObject:p];
			self.tmpUpcomingProgrammesKeyedByUniqueIdentifier[[p uniqueIdentifier]] = p;
		}
		
		self.UpcomingProgrammesKeyedByUniqueIdentifier = self.tmpUpcomingProgrammesKeyedByUniqueIdentifier;
		
		switch (self.IsForScheduleType)
		{
			case ArgusScheduleTypeRecording:  [self setUpcomingRecordings:tmpArr];  break;
			case ArgusScheduleTypeAlert:      [self setUpcomingAlerts:tmpArr];      break;
			case ArgusScheduleTypeSuggestion: [self setUpcomingSuggestions:tmpArr]; break;
		}
		
		[OnMainThread postNotificationName:kArgusUpcomingProgrammesDone object:self userInfo:nil];
	};
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:NO lowPriority:NO completionBlock:cmp];
	
	//NSLog(@"%s: upcoming for: %@", __PRETTY_FUNCTION__, [self.IsForSchedule originalData]);
	[c setHTTPBody:[NSJSONSerialization dataWithJSONObject:tmp options:0 error:nil]];
	[c enqueue];
}


#pragma mark Reading Programmes
-(NSMutableArray *)upcomingProgrammesForSchedule
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	if (self.IsForSchedule)
		return [self upcomingProgrammesForScheduleType:self.IsForScheduleType];
	
	return nil;
}


@end
