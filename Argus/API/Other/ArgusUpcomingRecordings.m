
//
//  ArgusUpcomingRecordings.m
//  Argus
//
//  Created by Chris Elsworth on 04/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

// this is basically a simplified ArgusUpcomingProgrammes
// it only does one "scheduletype" obviously
// but we need it over ArgusUpcomingProgrammes because this gives us ConflictingPrograms data

#import "ArgusUpcomingRecordings.h"

#import "ArgusUpcomingRecording.h"
#import "ArgusConnection.h"
#import "AppDelegate.h"

//#import "SBJson.h"
#import "JSONKit.h"

@implementation ArgusUpcomingRecordings
@synthesize UpcomingRecordings;
@synthesize UpcomingRecordingsKeyedByUpcomingProgramId;

-(id)init
{
	self = [super init];
	if (self)
	{
		UpcomingRecordings = [NSMutableArray new];
		UpcomingRecordingsKeyedByUpcomingProgramId = [NSMutableDictionary new];
		
		// when any upcoming programme changes, refresh our lists
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingRecordings)
													 name:kArgusCancelUpcomingProgrammeDone
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingRecordings)
													 name:kArgusUncancelUpcomingProgrammeDone
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingRecordings)
													 name:kArgusSaveUpcomingProgrammeDone
												   object:nil];

		
		// when anything deletes a schedule, we should refresh our list to ensure it's up to date
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingRecordings)
													 name:kArgusDeleteScheduleDone
												   object:nil];
		
		// when anything saves a schedule, we should refresh our list to ensure it's up to date
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getUpcomingRecordings)
													 name:kArgusSaveScheduleDone
												   object:nil];

	}
	return self;
}
-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)getUpcomingRecordings
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[AppDelegate requestLoadingSpinner];
	
	NSString *url = [NSString stringWithFormat:@"Control/UpcomingRecordings/7?includeActive=true"];
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(UpcomingRecordingsDone:)
												 name:kArgusConnectionDone
											   object:c];
}

-(void)UpcomingRecordingsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	NSData *data = [notify userInfo][@"data"];
	
	//SBJsonParser *jsonParser = [SBJsonParser new];
	//	NSDictionary *jsonObject = [jsonParser objectWithData:data];
	NSDictionary *jsonObject = [data objectFromJSONData];

	NSMutableArray *tmpArr = [NSMutableArray new];
	NSMutableDictionary *tmpDict = [NSMutableDictionary new];
	
	for (NSDictionary *t in jsonObject)
	{
		//NSLog(@"%s %@", __PRETTY_FUNCTION__, t);
		
		ArgusUpcomingRecording *upr = [[ArgusUpcomingRecording alloc] initWithDictionary:t];
		
		tmpDict[[[upr UpcomingProgramme] Property:kUpcomingProgramId]] = upr;
		[tmpArr addObject:upr];
	}
	
	UpcomingRecordings = tmpArr;
	UpcomingRecordingsKeyedByUpcomingProgramId = tmpDict;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusUpcomingRecordingsDone object:self userInfo:nil];
	
	[AppDelegate releaseLoadingSpinner];
}



// not used afaik

#if 0
-(void)getUpcomingRecordingsForSchedule:(ArgusSchedule *)schedule
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// upcoming programmes for a schedule can only have one type; the ScheduleType of the schedule
	
	NSString *url = [NSString stringWithFormat:@"Control/UpcomingRecordingsForSchedule/%@?includeCancelled=true", [schedule ScheduleId]];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:YES];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(UpcomingRecordingsForScheduleDone:)
												 name:kArgusConnectionDone
											   object:c];
}
-(void)UpcomingRecordingsForScheduleDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	NSData *data = [[notify userInfo] objectForKey:@"data"];
	
	//SBJsonParser *jsonParser = [SBJsonParser new];
	//NSDictionary *jsonObject = [jsonParser objectWithData:data];
	NSDictionary *jsonObject = [data objectFromJSONData];

	NSMutableArray *tmpArr = [NSMutableArray new];
	NSMutableDictionary *tmpDict = [NSMutableDictionary new];
	
	for (NSDictionary *t in jsonObject)
	{
		//	NSLog(@"%@", jsonObject);
		
		ArgusUpcomingRecording *upr = [[ArgusUpcomingRecording alloc] initWithDictionary:t];
		
		[tmpDict setObject:upr forKey:[[upr UpcomingProgramme] Property:kUpcomingProgramId]];
		[tmpArr addObject:upr];
	}
	
	UpcomingRecordings = tmpArr;
	UpcomingRecordingsKeyedByUpcomingProgramId = tmpDict;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusUpcomingRecordingsDone object:self userInfo:nil];
}
#endif

@end