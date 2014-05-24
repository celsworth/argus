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

#import "AppDelegate.h"

// encapsulating class for all communications with Argus Services.
@implementation Argus

#pragma mark - Public API methods

-(id)init
{
	self = [super init];
	if (self)
	{
		// set up containers
		self.Schedules = [ArgusSchedules new];
		self.UpcomingProgrammes = [ArgusUpcomingProgrammes new];
		self.UpcomingRecordings = [ArgusUpcomingRecordings new];
		
		self.Categories = [ArgusCategories new];
		
		self.ChannelGroups = [ArgusChannelGroups new];
		
		self.RecordingFileFormats = [ArgusRecordingFileFormats new];
		
		self.SelectedScheduleType = ArgusScheduleTypeRecording;
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
	
	ArgusConnectionCompletionBlock cmp = ^(NSHTTPURLResponse *response, NSData *data, NSError *error)
	{
		if (error) // error shown in ArgusConnectionQueue
			return [OnMainThread postNotificationName:kArgusApiVersionDone object:self userInfo:nil];
		
		NSInteger rv = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] intValue];
		NSDictionary *r = @{@"ApiVersion": @(rv)};
		[OnMainThread postNotificationName:kArgusApiVersionDone object:self userInfo:r];
	};
	
	(void)[[ArgusConnection alloc] initWithUrl:[NSString stringWithFormat:@"Core/Ping/%ld", version] completionBlock:cmp];
}

/* don't think this is actually used right now */
-(void)getVersion
{
	ArgusConnectionCompletionBlock cmp = ^(NSHTTPURLResponse *response, NSData *data, NSError *error)
	{
		if (error) // error shown in ArgusConnectionQueue
			return [OnMainThread postNotificationName:kArgusVersionDone object:self userInfo:nil];
		
		// remove " around the result, we can't parse it as JSON because it's a bare string, not really valid JSON
		self.Version = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
						stringByReplacingOccurrencesOfString:@"\"" withString:@""];
		
		[OnMainThread postNotificationName:kArgusVersionDone object:self userInfo:nil];
	};
	
	(void)[[ArgusConnection alloc] initWithUrl:@"Core/Version" completionBlock:cmp];
}


-(void)getChannels
{
	self.NewChannelsKeyedByChannelId = [NSMutableDictionary new];
	self.NewChannelsKeyedByGuideChannelId = [NSMutableDictionary new];
	
	// this starts by getting TV Channels, once that's done it'll get Radio
	ArgusConnection *c = [self getChannelsForChannelType:ArgusChannelTypeTelevision];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TvChannelsDone:) name:kArgusConnectionDone object:c];
}

-(ArgusConnection *)getChannelsForChannelType:(ArgusChannelType)ChannelType
{
	NSString *url = [NSString stringWithFormat:@"Scheduler/Channels/%ld", ChannelType];
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	return c;
}
-(void)ChannelsDone:(NSNotification *)notify
{
	// notify userInfo now needs parsing into ChannelGroups
	NSData *data = [notify userInfo][@"data"];
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
	
	for (NSDictionary *d in jsonObject)
	{
		ArgusChannel *c = [[ArgusChannel alloc] initWithDictionary:d];
		self.NewChannelsKeyedByChannelId[[c Property:kChannelId]] = c;
		
		// same for GuideChannelId. However this dictionary has arrays in it
		// because there could be more than one Channel with a given GuideChannelId
		NSString *GuideChannelId = [c Property:kGuideChannelId];
		
		if (!GuideChannelId)
			continue;
		
		NSMutableArray *tmpArr = self.NewChannelsKeyedByGuideChannelId[GuideChannelId];
		if (!tmpArr)
		{
			tmpArr = [NSMutableArray new];
			self.NewChannelsKeyedByGuideChannelId[GuideChannelId] = tmpArr;
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
	self.ChannelsKeyedByChannelId = self.NewChannelsKeyedByChannelId;
	self.ChannelsKeyedByGuideChannelId =self. NewChannelsKeyedByGuideChannelId;
	
	// when radio channels are done, send out notifications
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusChannelsDone object:self userInfo:nil];
}


-(void)getLiveStreams
{
	NSString *url = [NSString stringWithFormat:@"Control/GetLiveStreams"];
	
	ArgusConnectionCompletionBlock cmp = ^(NSHTTPURLResponse *response, NSData *data, NSError *error)
	{
		if (error) // error shown in ArgusConnectionQueue
			return [OnMainThread postNotificationName:kArgusLiveStreamsDone object:self userInfo:nil];
		
		NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		
		NSMutableArray *tmpArr = [NSMutableArray new];
		
		for (NSDictionary *d in jsonObject)
		{
			ArgusLiveStream *t = [[ArgusLiveStream alloc] initWithDictionary:d];
			[tmpArr addObject:t];
		}
		
		self.LiveStreams = tmpArr;
		
		[OnMainThread postNotificationName:kArgusLiveStreamsDone object:self userInfo:nil];
	};
	
	(void)[[ArgusConnection alloc] initWithUrl:url completionBlock:cmp];

}

-(void)getActiveRecordings
{
	NSString *url = [NSString stringWithFormat:@"Control/ActiveRecordings"];
	
	ArgusConnectionCompletionBlock cmp = ^(NSHTTPURLResponse *response, NSData *data, NSError *error)
	{
		if (error) // error shown in ArgusConnectionQueue
			return [OnMainThread postNotificationName:kArgusActiveRecordingsDone object:self userInfo:nil];
		
		NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		
		NSMutableArray *tmpArr = [NSMutableArray new];
		
		for (NSDictionary *d in jsonObject)
		{
			//NSLog(@"%s %@", __PRETTY_FUNCTION__, d);
			ArgusActiveRecording *t = [[ArgusActiveRecording alloc] initWithDictionary:d];
			[tmpArr addObject:t];
		}
		
		self.ActiveRecordings = tmpArr;
		[OnMainThread postNotificationName:kArgusActiveRecordingsDone object:self userInfo:nil];
	};
	
	(void)[[ArgusConnection alloc] initWithUrl:url completionBlock:cmp];
}

-(void)getRecordingDisksInfo
{
	NSString *url = [NSString stringWithFormat:@"Control/GetRecordingDisksInfo"];
	
	ArgusConnectionCompletionBlock cmp = ^(NSHTTPURLResponse *response, NSData *data, NSError *error)
	{
		if (error) // error shown in ArgusConnectionQueue
			return [OnMainThread postNotificationName:kArgusRecordingDisksInfoDone object:self userInfo:nil];
		
		NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		
		self.RecordingDisksInfo = [[ArgusRecordingDisksInfo alloc] initWithDictionary:jsonObject];
		
		[OnMainThread postNotificationName:kArgusRecordingDisksInfoDone object:self userInfo:nil];
	};
	
	(void)[[ArgusConnection alloc] initWithUrl:url completionBlock:cmp];
}

-(void)getUpcomingProgrammes
{
	[[self UpcomingProgrammes] getUpcomingProgrammes];
}

-(void)getEmptySchedule
{
	[AppDelegate requestLoadingSpinner];
	
	// fetch an empty schedule so it can be copied and edited to suit later
	self.EmptySchedule = [[ArgusSchedule alloc] initEmptyWithChannelType:ArgusChannelTypeTelevision
															scheduleType:ArgusScheduleTypeRecording];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(EmptyScheduleDone:)
												 name:kArgusScheduleDone
											   object:self.EmptySchedule];
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

