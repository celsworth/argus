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

// pass a JSONValue decoded dictionary.
-(id)initWithDictionary:(NSDictionary *)input
{
	self = [super init];
	if (self)
	{
		if (! [super populateSelfFromDictionary:input])
			return nil;
		
		// and some bits of our own
		_Logo = [[ArgusChannelLogo alloc] initWithChannelId: [self Property:kChannelId]];
		
		// a list of programmes for this channel. Timeframes are undefined, generally
		// this is whatever view happens to be using it, maybe from now to +12h for Whats On,
		// or 00:00 - 23:59 for a days worth.
		_Programmes = [NSMutableArray new];
	}
	
	return self;
}
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__); // spammy
	
	// release some retains, why doesn't ARC handle this?
	self.Programmes = nil;
	self.CurrentProgramme = nil;
	self.NextProgramme = nil;
	
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
	
	[[NSNotificationCenter defaultCenter] addObserverForName:kArgusConnectionDone
													  object:c
													   queue:[NSOperationQueue new]
												  usingBlock:^(NSNotification *note)
	 {
		 [self ProgrammesDone:note];
	 }];
}

-(void)ProgrammesDone:(NSNotification *)notify
{
	/*** THIS SELECTOR CAN RUN IN THE BACKGROUND ***/
	
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	BOOL dumpData = NO;
	
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
	
	self.Programmes = tmpArr;
	
	if (dumpData)
	{
		NSLog(@"%s: got a nil ArgusProgramme out of %@", __PRETTY_FUNCTION__, data);
	}
	
	// back to foreground for notification
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kArgusProgrammesDone object:self userInfo:nil];
	});
}

@end
