//
//  ArgusChannel.m
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusChannel.h"
#import "Argus.h"

#import "JSONKit.h"

#import "AppDelegate.h"

#import "NSDateFormatter+LocaleAdditions.h"

// representation of a single Channel object as sent from Argus, plus our own extra bits

@implementation ArgusChannel
@synthesize Logo, Programmes, CurrentProgramme, NextProgramme;

// pass a JSONValue decoded dictionary.
-(id)initWithDictionary:(NSDictionary *)input
{
	self = [super init];
	if (self)
	{
		if (! [super populateSelfFromDictionary:input])
			return nil;

		// and some bits of our own
		Logo = [[ArgusChannelLogo alloc] initWithChannelId: [self Property:kChannelId]];
		
		// a list of programmes for this channel. Timeframes are undefined, generally
		// this is whatever view happens to be using it, maybe from now to +12h for Whats On,
		// or 00:00 - 23:59 for a days worth.
		Programmes = [NSMutableArray new];
	}
	
	return self;
}
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__); // spammy

	// release some retains, why doesn't ARC handle this?
	Programmes = nil;
	CurrentProgramme = nil;
	NextProgramme = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)getProgrammesFrom:(NSDate *)from to:(NSDate *)to
{
	// don't try to make an invalid url - if there's no GuideChannelId there will be no programmes
	// should really report back to the user somehow in a non-annoying way (NOT a popup!)
	NSString *GuideChannelId = [self Property:kGuideChannelId];
	if (! GuideChannelId)
	{
		NSLog(@"%s skipping %@, no GuideChannelId",
			  __PRETTY_FUNCTION__, [self Property:kDisplayName]);
		return;
	}
	
	time_t fromTimeT = [from timeIntervalSince1970];
	time_t toTimeT = [to timeIntervalSince1970];
	struct tm timeStruct;
	char buffer[80];
	
	localtime_r(&fromTimeT, &timeStruct);
	strftime(buffer, 80, "%Y-%m-%dT%H:%M:%S", &timeStruct);
	NSString *fromAsStr = @(buffer);

	localtime_r(&toTimeT, &timeStruct);
	strftime(buffer, 80, "%Y-%m-%dT%H:%M:%S", &timeStruct);
	NSString *toAsStr = @(buffer);

	NSString *url = [NSString stringWithFormat:@"Guide/FullPrograms/%@/%@/%@/false", GuideChannelId, fromAsStr, toAsStr];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(ProgrammesDone:)
												 name:kArgusConnectionDone
											   object:c];
}

-(void)ProgrammesDone:(NSNotification *)notify
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	// try doing this in the bg, it's heavy..
	[self performSelectorInBackground:@selector(ProgrammesDoneBgThread:) withObject:notify];
	
}
-(void)ProgrammesDoneBgThread:(NSNotification *)notify
{
	BOOL dumpData = NO;
	
	// parse the data, which is an array of ArgusProgramme objects?
	
	NSData *data = [notify userInfo][@"data"];
	
	NSArray *jsonObject = [data objectFromJSONData];
	
	NSMutableArray *tmpArr = [NSMutableArray new];
	
	ArgusProgramme *t;
	for (NSDictionary *d in jsonObject)
	{
		if ((t = [[ArgusProgramme alloc] initWithDictionary:d]))
		{
			// populate the Channel object in the ArgusProgramme with ourselves
			// this makes anything relying on uniqueIdentifier work
			[t setChannel:self];
			
			[tmpArr addObject:t];
		}
		else
		{
			dumpData = YES;
			NSLog(@"%s: t is nil for %@", __PRETTY_FUNCTION__, d);
		}
	}
	
	Programmes = tmpArr;
	
	if (dumpData)
	{
		NSLog(@"%s: got a nil ArgusProgramme out of %@", __PRETTY_FUNCTION__, data);
	}
	
	// back to foreground for notify
	[self performSelectorOnMainThread:@selector(PostProgrammesDone) withObject:nil waitUntilDone:NO];
	//	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusProgrammesDone object:self userInfo:nil];
}

-(void)PostProgrammesDone
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusProgrammesDone object:self userInfo:nil];
}

@end
