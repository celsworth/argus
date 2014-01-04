//
//  ArgusChannelGroup.m
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "AppDelegate.h"

#import "ArgusChannelGroup.h"
#import "ArgusChannel.h"
#import "ArgusProgramme.h"

#import "JSONKit.h"

// representation of a single ChannelGroup object as sent from Argus, plus our own extra bits

@implementation ArgusChannelGroup

#pragma mark - Initialisation and Deallocation

-(id)initWithString:(NSString *)ChannelGroupId
{
	self = [super init];
	if (self)
	{
		_ChannelGroupId = ChannelGroupId;
	}
	return self;
}

-(id)initWithDictionary:(NSDictionary *)input
{
	self = [super init];
	if (self)
	{
		if (! [super populateSelfFromDictionary:input])
			return nil;

		_ChannelGroupId = input[kChannelGroupId];
		
		// channels within the channel group, once we know them
		// pointer to an NSMutableArray
		_Channels = nil;
		
		// Current and Next for group, once we know it
		// pointer to NSMutableArray
		_CurrentAndNext = nil;
	}
	return self;
}
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	// ensure we don't leave any orphaned notification observers lying about! very important!
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Channels
-(void)getChannels
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// fire off a ChannelsInGroup request
	NSString *url = [NSString stringWithFormat:@"Scheduler/ChannelsInGroup/%@", self.ChannelGroupId];
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(ChannelsDone:)
												 name:kArgusConnectionDone
											   object:c];
	
	// what about failures?
		
	return;	
}
-(void)ChannelsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];

	// parse the data into Channels
	
	NSData *data = [notify userInfo][@"data"];
	
	//SBJsonParser *jsonParser = [SBJsonParser new];
	//NSArray *jsonObject = [jsonParser objectWithData:data];
	NSArray *jsonObject = [data objectFromJSONData];
	
	NSMutableArray *tmpArr = [NSMutableArray new];
	
	for (NSDictionary *d in jsonObject)
	{	
		//NSLog(@"%@", d);
		ArgusChannel *c = [[ArgusChannel alloc] initWithDictionary:d];

		// crash reported that could have been because of a NULL ChannelId
		// surely that should never happen?
		assert([c Property:kChannelId]);
	
		[tmpArr addObject:c];
	}
	
	// prevent leaks because ARC can't clean up circular references
	//for (ArgusChannel *c in Channels)
	//{
		//[c setProgrammes:nil];
	//}
	
	self.Channels = tmpArr;
	
	// notifications
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusChannelGroupChannelsDone object:self userInfo:nil];
}

#pragma mark - Current And Next

-(void)getCurrentAndNext
{
	// fire off a CurrentAndNextForGroup request
	NSString *url = [NSString stringWithFormat:@"Scheduler/CurrentAndNextForGroup"];

	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:NO lowPriority:NO];
	
	NSString *body = [@{kChannelGroupId: self.ChannelGroupId} JSONString];

	[c setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	[c enqueue];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(CurrentAndNextDone:)
												 name:kArgusConnectionDone
											   object:c];
	
	[AppDelegate requestLoadingSpinner];
}

-(void)CurrentAndNextDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];

	// parse the data into CurrentAndNext
	
	NSData *data = [notify userInfo][@"data"];

	//NSString *r = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	//NSLog(@"%@", r);

	//SBJsonParser *jsonParser = [SBJsonParser new];
	//NSArray *jsonObject = [jsonParser objectWithData:data];
	NSArray *jsonObject = [data objectFromJSONData];

	NSMutableArray *tmpArr = [NSMutableArray new];
	
	self.earliestCurrentStopTime = [NSDate distantFuture];
	
	ArgusProgramme *p;
	NSDictionary *tmp;
	for (NSDictionary *d in jsonObject)
	{
		//NSLog(@"%@", d);
		
		ArgusChannel *c = [[ArgusChannel alloc] initWithDictionary:d[kChannel]];
		
		tmp = d[kCurrent];
		if (tmp && tmp != (NSDictionary *)[NSNull null]) // avoid ArgusBaseObject nil error when no programme is on
		{
			p = [[ArgusProgramme alloc] initWithDictionary:tmp];
			//[p setChannelId:[c Property:kChannelId]];
			[p setChannel:c];
			[c setCurrentProgramme:p];
		
			// remember the earliest Current StopTime we find
			// What's On uses this so it knows when to refresh data
			if ([[p StopTime] timeIntervalSinceDate:self.earliestCurrentStopTime] < 0)
			{
				//NSLog(@"%@ matched", [p Property:kTitle]);
				self.earliestCurrentStopTime = [p StopTime];
			}
		}
		
		tmp = d[kNext];
		if (tmp && tmp != (NSDictionary *)[NSNull null])
		{
			p = [[ArgusProgramme alloc] initWithDictionary:tmp];
			//[p setChannelId:[c Property:kChannelId]];
			[p setChannel:c];
			[c setNextProgramme:p];
		}
		
		[tmpArr addObject:c];
	}
	
	// before we lose access to the old CurrentAndNext, remove the circular references
	// between Channel and Programme, so ARC can deallocate stuff properly
	//for (ArgusChannel *c in CurrentAndNext)
	//{
		////[[c CurrentProgramme] setChannel:nil];
		//[c setCurrentProgramme:nil];
		////[[c NextProgramme] setChannel:nil];
		//[c setNextProgramme:nil];
	//}
	
	self.CurrentAndNext = tmpArr;
	
	// notifications
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusChannelGroupCurrentAndNextDone object:self userInfo:nil];
	
	[AppDelegate releaseLoadingSpinner];
}

-(void)getProgrammesFrom:(NSDate *)from to:(NSDate *)to
{
	// get all programmes for channels in this channel group, between two NSDates
	// used for EPG
	
	[AppDelegate requestLoadingSpinner];
	
	// this relies on an API endpoint added in 1.6.1.0 B7 (api v50)
	NSString *url = @"Guide/ChannelsPrograms";
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:NO lowPriority:NO];
	
	time_t fromTimeT = [from timeIntervalSince1970];
	time_t toTimeT = [to timeIntervalSince1970];
	NSString *fromX = [NSString stringWithFormat:@"/Date(%llu+0000)/", fromTimeT * 1000LL];
	NSString *toX = [NSString stringWithFormat:@"/Date(%llu+0000)/", toTimeT * 1000LL];

	// send an array of GuideChannelId to get
	NSMutableArray *GuideChannelIds = [NSMutableArray new];
	for (ArgusChannel *c in self.Channels)
	{
		// don't attempt to add nil objects to the array
		// these can occur when a channel has no guide channel
		NSString *GuideChannelId = [c Property:kGuideChannelId];
		if (GuideChannelId)
			[GuideChannelIds addObject:GuideChannelId];
	}
	
	NSMutableDictionary *bodyDict = [NSMutableDictionary new];
	bodyDict[@"GuideChannelIds"] = GuideChannelIds;
	bodyDict[@"LowerTime"] = fromX;
	bodyDict[@"UpperTime"] = toX;
	
	//NSLog(@"%@", bodyDict);
	
	NSError *error;
	[c setHTTPBody:[bodyDict JSONDataWithOptions:JKSerializeOptionNone error:&error]];
	
	[c enqueue];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(ProgrammesDone:)
												 name:kArgusConnectionDone
											   object:c];

	// catch 404 failure for this one, if they're running earlier than 1.6.1.0 B7 it won't be there
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(ProgrammesFail:)
												 name:kArgusConnectionFail
											   object:c];

}
-(void)ProgrammesFail:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that connection
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];

	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusProgrammesFail object:self userInfo:[notify object]];
	
	[AppDelegate releaseLoadingSpinner];
}

-(void)ProgrammesDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that connection
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	//NSDate *start = [NSDate date];
	
	NSData *data = [notify userInfo][@"data"];
	
	NSArray *jsonObject = [data objectFromJSONData];

	NSMutableDictionary *tmpDict = [NSMutableDictionary new];
	
	for (NSDictionary *d in jsonObject)
	{
		NSString *GuideChannelId = d[kGuideChannelId];
		
		// look up all ChannelIds that use this GuideChannelId, noting there could be multiple
		for (ArgusChannel *c in [argus ChannelsKeyedByGuideChannelId][GuideChannelId])
		{
			NSString *ChannelId = [c Property:kChannelId];
			
			// find the array to add this programme into (one array per ChannelId)
			NSMutableArray *tmpArr = tmpDict[ChannelId];
			if (!tmpArr)
			{
				tmpArr = [NSMutableArray new];
				tmpDict[ChannelId] = tmpArr;
			}
			
			ArgusProgramme *p = [[ArgusProgramme alloc] initWithDictionary:d];
			[p setChannel:c];
			[tmpArr addObject:p];
		}
	}
	
	self.ProgrammeArraysKeyedByChannelId = tmpDict;
	
	//NSLog(@"%s took %f seconds", __PRETTY_FUNCTION__, [[NSDate date] timeIntervalSinceDate:start]);

	//NSLog(@"%@", ProgrammeArraysKeyedByChannelId);
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusProgrammesDone object:self userInfo:nil];
	
	[AppDelegate releaseLoadingSpinner];

	//NSLog(@"%s after notify, %f seconds", __PRETTY_FUNCTION__, [[NSDate date] timeIntervalSinceDate:start]);
}


@end
