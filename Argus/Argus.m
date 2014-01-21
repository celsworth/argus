//
//  Argus.m
//  Argus
//
//  Created by Chris Elsworth on 01/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "Argus.h"
#import "ArgusChannelGroup.h"
#import "ArgusSchedule.h"
#import "ArgusLiveStream.h"
#import "ArgusActiveRecording.h"

#import "ArgusUpcomingRecordings.h"

#import "SBJson.h"
#import "JSONKit.h"

#import "AppDelegate.h"

// encapsulating class for all communications with Argus Services.
@implementation Argus
@synthesize ChannelsKeyedByChannelId, NewChannelsKeyedByChannelId;
@synthesize ChannelsKeyedByGuideChannelId, NewChannelsKeyedByGuideChannelId;
@synthesize SearchResults;
@synthesize ChannelGroups;
@synthesize Categories;
@synthesize RecordingFileFormats;
@synthesize EmptySchedule;
@synthesize ActiveRecordings, LiveStreams, Schedules, RecordingDisksInfo;
@synthesize UpcomingProgrammes, UpcomingRecordings;
@synthesize SelectedScheduleType;
@synthesize Version;

#pragma mark - Public API methods

-(id)init
{
	self = [super init];
	if (self)
	{
		// set up containers
		Schedules = [ArgusSchedules new];
		UpcomingProgrammes = [ArgusUpcomingProgrammes new];
		UpcomingRecordings = [ArgusUpcomingRecordings new];
		
		Categories = [ArgusCategories new];
		
		ChannelGroups = [ArgusChannelGroups new];
		
		RecordingFileFormats = [ArgusRecordingFileFormats new];
		
		SelectedScheduleType = ArgusScheduleTypeRecording;
	}
	return self;
}

-(void)dealloc
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Network methods
-(void)checkApiVersion:(NSInteger)version
{
	// this is so trivial it doesn't really need to be completed in a background block, but it's a sample of how its done
	
	ConnectionCompletionBlock cmp = ^(NSHTTPURLResponse *response, NSData *data, NSError *error)
	{
		//NSLog(@"%s %@ %@ %@", __PRETTY_FUNCTION__, response, data, error);
		
		// will need error handling!
		
		NSInteger rv = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] intValue];
		NSDictionary *r = @{@"ApiVersion": @(rv)};
		[OnMainThread postNotificationName:kArgusApiVersionDone object:self userInfo:r];
	};
	
	__unused ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:[NSString stringWithFormat:@"Core/Ping/%d", version]
													   completionBlock:cmp];
}


-(void)getVersion
{
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:@"Core/Version"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(VersionDone:)
												 name:kArgusConnectionDone
											   object:c];
}

-(void)VersionDone:(NSNotification *)notify
{
	// notify userInfo now needs parsing into a string
	NSData *data = [notify userInfo][@"data"];
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	// remove " around the result, we can't parse it as JSON because it's a bare string, not really valid JSON
	Version = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusVersionDone object:self userInfo:nil];
}

-(void)doEpgPartialSearchforString:(NSString *)search inChannelType:(ArgusChannelType)ChannelType
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
		
	NSString *url = [NSString stringWithFormat:@"Scheduler/SearchGuideByPartialTitle/%d", ChannelType];
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:NO lowPriority:NO];
	
	NSString *body = [NSString stringWithFormat:@"\"%@\"", search];
	[c setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	[c enqueue];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EpgPartialSearchforStringDone:) name:kArgusConnectionDone object:c];
	
	[AppDelegate requestLoadingSpinner];
}

-(void)EpgPartialSearchforStringDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	NSData *data = [notify userInfo][@"data"];
	
	SBJsonParser *jsonParser = [SBJsonParser new];
	NSArray *jsonObject = [jsonParser objectWithData:data];
	
	NSMutableArray *tmpArr = [NSMutableArray new];
	
	for (NSDictionary *d in jsonObject)
	{
		ArgusProgramme *p = [[ArgusProgramme alloc] initWithDictionary:d];
		
		NSString *ChannelId = d[kChannel][kChannelId];
		assert(ChannelId);
		
		ArgusChannel *c = [argus ChannelsKeyedByChannelId][ChannelId];
		assert(c);
		
		[p setChannel:c];
		
		
		[tmpArr addObject:p];
	}
	
	SearchResults = tmpArr;
	
	// notifications
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusEpgPartialSearchDone object:self userInfo:nil];
	
	[AppDelegate releaseLoadingSpinner];
}




-(void)getChannels
{
	NewChannelsKeyedByChannelId = [NSMutableDictionary new];
	NewChannelsKeyedByGuideChannelId = [NSMutableDictionary new];
	
	// this starts by getting TV Channels, once that's done it'll get Radio
	ArgusConnection *c = [self getChannelsForChannelType:ArgusChannelTypeTelevision];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TvChannelsDone:) name:kArgusConnectionDone object:c];
}

-(ArgusConnection *)getChannelsForChannelType:(ArgusChannelType)ChannelType
{
	NSString *url = [NSString stringWithFormat:@"Scheduler/Channels/%d", ChannelType];
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	return c;
}
-(void)ChannelsDone:(NSNotification *)notify
{
	// notify userInfo now needs parsing into ChannelGroups
	NSData *data = [notify userInfo][@"data"];
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	//SBJsonParser *jsonParser = [SBJsonParser new];
	//NSArray *jsonObject = [jsonParser objectWithData:data];
	NSArray *jsonObject = [data objectFromJSONData];
	
	for (NSDictionary *d in jsonObject)
	{
		ArgusChannel *c = [[ArgusChannel alloc] initWithDictionary:d];
		NewChannelsKeyedByChannelId[[c Property:kChannelId]] = c;
		
		// same for GuideChannelId. However this dictionary has arrays in it
		// because there could be more than one Channel with a given GuideChannelId
		NSString *GuideChannelId = [c Property:kGuideChannelId];
		
		if (!GuideChannelId)
			continue;
		
		NSMutableArray *tmpArr = NewChannelsKeyedByGuideChannelId[GuideChannelId];
		if (!tmpArr)
		{
			tmpArr = [NSMutableArray new];
			NewChannelsKeyedByGuideChannelId[GuideChannelId] = tmpArr;
		}
		[tmpArr addObject:c];
	}
}

-(void)TvChannelsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[self ChannelsDone:notify];
	
	// now get Radio channels
	ArgusConnection *c = [self getChannelsForChannelType:ArgusChannelTypeRadio];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RadioChannelsDone:) name:kArgusConnectionDone object:c];
}

-(void)RadioChannelsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[self ChannelsDone:notify];
	
	// replace Channels with NewChannels
	ChannelsKeyedByChannelId = NewChannelsKeyedByChannelId;
	ChannelsKeyedByGuideChannelId = NewChannelsKeyedByGuideChannelId;
	
	// when radio channels are done, send out notifications
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusChannelsDone object:self userInfo:nil];
}


-(void)getLiveStreams
{
	
	[AppDelegate requestLoadingSpinner];
	
	NSString *url = [NSString stringWithFormat:@"Control/GetLiveStreams"];
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	// tell us when the ArgusConnection is done, so we can poke any waiters
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(LiveStreamsDone:)
												 name:kArgusConnectionDone
											   object:c];
}

-(void)LiveStreamsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	// notify userInfo now needs parsing into ChannelGroups
	NSData *data = [notify userInfo][@"data"];
	
	SBJsonParser *jsonParser = [SBJsonParser new];
	NSArray *jsonObject = [jsonParser objectWithData:data];
	
	NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:32];
	
	for (NSDictionary *d in jsonObject)
	{
		ArgusLiveStream *t = [[ArgusLiveStream alloc] initWithDictionary:d];
		[tmpArr addObject:t];
	}
	
	LiveStreams = tmpArr;
	
	// done, send out notifications
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusLiveStreamsDone object:self userInfo:nil];
	
	[AppDelegate releaseLoadingSpinner];
}

-(void)getActiveRecordings
{
	[AppDelegate requestLoadingSpinner];
	
	NSString *url = [NSString stringWithFormat:@"Control/ActiveRecordings"];
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	// tell us when the ArgusConnection is done, so we can poke any waiters
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(ActiveRecordingsDone:)
												 name:kArgusConnectionDone
											   object:c];
}

-(void)ActiveRecordingsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	// notify userInfo now needs parsing into ChannelGroups
	NSData *data = [notify userInfo][@"data"];
	
	SBJsonParser *jsonParser = [SBJsonParser new];
	NSArray *jsonObject = [jsonParser objectWithData:data];
	
	NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:32];
	
	for (NSDictionary *d in jsonObject)
	{
		//NSLog(@"%s %@", __PRETTY_FUNCTION__, d);
		ArgusActiveRecording *t = [[ArgusActiveRecording alloc] initWithDictionary:d];
		[tmpArr addObject:t];
	}
	
	ActiveRecordings = tmpArr;
	
	// done, send out notifications
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusActiveRecordingsDone object:self userInfo:nil];
	
	[AppDelegate releaseLoadingSpinner];
}

-(void)getRecordingDisksInfo
{
	[AppDelegate requestLoadingSpinner];
	
	NSString *url = [NSString stringWithFormat:@"Control/GetRecordingDisksInfo"];
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	// tell us when the ArgusConnection is done, so we can poke any waiters
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(RecordingDisksInfoDone:)
												 name:kArgusConnectionDone
											   object:c];
}

-(void)RecordingDisksInfoDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	NSData *data = [notify userInfo][@"data"];
	
	SBJsonParser *jsonParser = [SBJsonParser new];
	NSDictionary *jsonObject = [jsonParser objectWithData:data];
	
	RecordingDisksInfo = [[ArgusRecordingDisksInfo alloc] initWithDictionary:jsonObject];
	
	// done, send out notifications
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusRecordingDisksInfoDone object:self userInfo:nil];
	
	[AppDelegate releaseLoadingSpinner];
}

-(void)getUpcomingProgrammes
{
	[[self UpcomingProgrammes] getUpcomingProgrammes];
}

-(void)getEmptySchedule
{
	[AppDelegate requestLoadingSpinner];
	
	// fetch an empty schedule so it can be copied and edited to suit later
	EmptySchedule = [[ArgusSchedule alloc] initEmptyWithChannelType:ArgusChannelTypeTelevision
													   scheduleType:ArgusScheduleTypeRecording];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(EmptyScheduleDone:)
												 name:kArgusScheduleDone
											   object:EmptySchedule];
}
-(void)EmptyScheduleDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusEmptyScheduleDone object:self];
	
	[AppDelegate releaseLoadingSpinner];
	
}


@end

