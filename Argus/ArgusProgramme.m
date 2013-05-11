//
//  ArgusProgramme.m
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusProgramme.h"
#import "ArgusChannel.h"
#import "ArgusUpcomingProgramme.h"

#import "AppDelegate.h"

#import "SBJson.h"

#import "NSString+JSONDate.h"
#import "NSDate+Formatter.h"

@implementation ArgusProgramme
@synthesize Channel;
//@synthesize ChannelId;
@synthesize fullDetailsDone;

// cache
@synthesize StartTime, StopTime, UpcomingProgrammeHaveCached, UpcomingProgrammeCached;

// backgrounds
+(UIColor *)bgColourStdOdd
{
	if (dark) return [UIColor colorWithRed:.15 green:.15 blue:.15 alpha:1]; // dark
	return [UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1]; // light
}
+(UIColor *)bgColourStdEven
{
	if (dark) return [UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1]; // dark
	return [UIColor colorWithRed:.99 green:.99 blue:.99 alpha:1]; // light
}
+(UIColor *)bgColourEpgCell
{
	if (dark) return [UIColor colorWithRed:.25 green:.25 blue:.30 alpha:1]; // dark
	return [UIColor colorWithRed:.90 green:.90 blue:.94 alpha:1]; // light
}
+(UIColor *)bgColourUpcomingRec
{
	if (dark) return [UIColor colorWithRed:.40 green:.20 blue:.20 alpha:1]; // dark
	return [UIColor colorWithRed:.95 green:.80 blue:.80 alpha:1]; // light
}
+(UIColor *)bgColourOnNow
{
	if (dark) return [UIColor colorWithRed:.33 green:.33 blue:.20 alpha:1]; // dark
	return [UIColor colorWithRed:.93 green:.93 blue:.80 alpha:1]; // light
}

+(UIColor *)fgColourStd
{
	if (dark) return [UIColor whiteColor];
	return [UIColor blackColor];
}
+(UIColor *)fgColourAlreadyShown
{
	if (dark) return [UIColor darkGrayColor];
	return [UIColor lightGrayColor];
}


-(id)initWithDictionary:(NSDictionary *)input
{
	self = [super init];
	if (self)
	{
		[self populateSelfFromDictionary:input];
		
		// invalidate UpcomingProgrammeCached when necessary
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(killUpcomingProgrammeCache:)
													 name:kArgusUpcomingProgrammesDone
												   object:[argus UpcomingProgrammes]];
	}
	return self;
}
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__); // spammy
	
	//ChannelId = nil;
	Channel = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

// when the list of upcoming programmes changes,
// our -upcomingProgramme will need to re-evaluate it's cache
// so kill the cache and let it re-evaluate when its next called
-(void)killUpcomingProgrammeCache:(NSNotification *)notify
{
	UpcomingProgrammeHaveCached = NO;
	UpcomingProgrammeCached = nil;
}

-(BOOL)populateSelfFromDictionary:(NSDictionary *)input
{
	if (! [super populateSelfFromDictionary:input])
		return NO;
	
	// cache some commonly used hard-to-calculate values
	StartTime = [self Property:kStartTime];
	StopTime = [self Property:kStopTime];
	
	return YES;
}

#if 0
-(void)setChannel:(ArgusChannel *)c
{
	ChannelId = [c Property:kChannelId];
}
-(ArgusChannel *)Channel
{
	return [[argus Channels] objectForKey:ChannelId];
}
#endif

-(void)getFullDetails
{
	// trigger a Program/{GuideProgramId} request to populate Description etc for this Programme
	NSString *url = [NSString stringWithFormat:@"Guide/Program/%@", [self Property:kGuideProgramId]];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
		
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(GetFullProgrammeDetailsDone:)
												 name:kArgusConnectionDone
											   object:c];
}

-(void)GetFullProgrammeDetailsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];

	NSData *data = [notify userInfo][@"data"];
	
	SBJsonParser *jsonParser = [SBJsonParser new];
	NSDictionary *jsonObject = [jsonParser objectWithData:data];
	
	//[self populateSelfFromDictionary:jsonObject];
	// do not nuke originalData in here, merge them
	[self.originalData addEntriesFromDictionary:jsonObject];

	// cache some commonly used hard-to-calculate values.. ensure they're up to date
	StartTime = [self Property:kStartTime];
	StopTime = [self Property:kStopTime];

	// mark the object as full details fetched so we don't end up looping
	// if description isn't populated now, there isn't one
	self.fullDetailsDone = true;
	
	//NSLog(@"%@", self.originalData);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusProgrammeDone object:self];
}


-(NSString *)uniqueIdentifier
{
	// a single GuideProgramId can be seen several times across multiple channels, so this
	// returns a string that can uniquely identify an ArgusProgramme object across channels too
	
	// stopped using Property here because it's quite expensive when doing various checks
	
	//NSString *ChannelId = [[Channel originalData] objectForKey:kChannelId];
	NSString *ChannelId = [Channel Property:kChannelId];
	
	// if either of these are nil, this won't work, but they shouldn't be..
	assert(ChannelId);
	//assert(![ChannelId isKindOfClass:[NSNull class]]);
	
	
	// most programmes will do this
	//NSString *GuideProgramId = [[self originalData] objectForKey:kGuideProgramId];
	NSString *GuideProgramId = [self Property:kGuideProgramId];
	//if (![GuideProgramId isKindOfClass:[NSNull class]])
	if (GuideProgramId)
		return [ChannelId stringByAppendingString:GuideProgramId];
	
	// but manual recordings don't have a GuideProgramId, so use this
	//NSString *Title = [[self originalData] objectForKey:kTitle];
	NSString *Title = [self Property:kTitle];
	assert(Title);
	//assert(![Title isKindOfClass:[NSNull class]]);
	
	NSString *uniqueId = @"";
	uniqueId = [uniqueId stringByAppendingString:ChannelId];
	uniqueId = [uniqueId stringByAppendingString:[NSString stringWithFormat:@"%@", StartTime]];
	uniqueId = [uniqueId stringByAppendingString:Title];
	return uniqueId;
	
	
	// old, slow way
	//return [NSString stringWithFormat:@"%@-%@", [Channel Property:kChannelId], [self Property:kGuideProgramId]];
}

// find an ArgusUpcomingProgramme that matches this ArgusProgramme
-(ArgusUpcomingProgramme *)upcomingProgramme
{
	if (UpcomingProgrammeHaveCached)
		return UpcomingProgrammeCached;
	
	if ([[[argus UpcomingProgrammes] UpcomingProgrammesKeyedByUniqueIdentifier] count] == 0)
	{
		UpcomingProgrammeHaveCached = YES;
		UpcomingProgrammeCached = nil;
		return UpcomingProgrammeCached;
	}
	
	// cache the upcoming programme, it's expensive to calculate.
	// this cache is nuked when ArgusUpcomingProgrammesDone is seen (new upcoming programmes list)
	UpcomingProgrammeCached = [[argus UpcomingProgrammes] UpcomingProgrammesKeyedByUniqueIdentifier][[self uniqueIdentifier]];
	UpcomingProgrammeHaveCached = YES;
	return UpcomingProgrammeCached;
}

-(BOOL)isOnNow
{
	if (!StartTime || !StopTime)
	{
		StartTime = [self Property:kStartTime];
		StopTime = [self Property:kStopTime];	
	}
	return ([StartTime timeIntervalSinceNow] < 0 && [StopTime timeIntervalSinceNow] > 0);
	
	//return ([[self Property:kStartTime] timeIntervalSinceNow] < 0 && [[self Property:kStopTime] timeIntervalSinceNow] > 0);
}

-(ArgusProgrammeBgColour)backgroundColour
{
	// given a programme, decide what colour a background should be:
	// 1) whether it's scheduled (lighter if it's cancelled?)
	// 2) whether it's on now
	
	ArgusUpcomingProgramme *upc = [self upcomingProgramme];
	if (upc) // if we have an upcoming entry for this programme
	{
		// ask the upcoming programme for details?
		ArgusUpcomingProgrammeScheduleStatus upcss = [upc scheduleStatus];
		
		switch (upcss)
		{
			case ArgusUpcomingProgrammeScheduleStatusRecordingScheduled:
			case ArgusUpcomingProgrammeScheduleStatusRecordingScheduledConflict:
				// scheduled recordings are red
				return ArgusProgrammeBgColourScheduled;
				break;
			
			case ArgusUpcomingProgrammeScheduleStatusRecordingCancelledManually:
			case ArgusUpcomingProgrammeScheduleStatusRecordingCancelledAlreadyRecorded:
			case ArgusUpcomingProgrammeScheduleStatusRecordingCancelledConflict:
				//return ArgusProgrammeBgColourCancelled;
				break;
				
			default:
				// everything else no colour for now
				break;
		}
	}
	
	if ([self isOnNow])
	{
		// current programme
		return ArgusProgrammeBgColourOnNow;
	}
	
	// no special instructions
	return ArgusProgrammeBgColourStandard;
}


@end
