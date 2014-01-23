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

@interface ArgusProgramme ()
@property (nonatomic, retain) NSDate *StartTime;
@property (nonatomic, retain) NSDate *StopTime;
@end

@implementation ArgusProgramme

// backgrounds
+(UIColor *)bgColourStdOdd
{
	static UIColor *col = NULL;
	if (!col)
	{
		if (dark)
			col = [UIColor colorWithRed:.15 green:.15 blue:.15 alpha:1]; // dark
		else
			col = [UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1]; // light
		
	}
	
	return col;
}
+(UIColor *)bgColourStdEven
{
	static UIColor *col = NULL;
	if (!col)
	{
		if (dark)
			col = [UIColor colorWithRed:.25 green:.25 blue:.25 alpha:1]; // dark
		else
			col = [UIColor colorWithRed:.99 green:.99 blue:.99 alpha:1]; // light
		
	}
	
	return col;
}
+(UIColor *)bgColourEpgCell
{
	static UIColor *col = NULL;
	if (!col)
	{
		if (dark)
			col = [UIColor colorWithRed:.25 green:.25 blue:.30 alpha:1]; // dark
		else
			col = [UIColor colorWithRed:.90 green:.90 blue:.94 alpha:1]; // light
		
	}
	
	return col;
}
+(UIColor *)bgColourUpcomingRec
{
	static UIColor *col = NULL;
	if (!col)
	{
		if (dark)
			col = [UIColor colorWithRed:.40 green:.20 blue:.20 alpha:1]; // dark
		else
			col = [UIColor colorWithRed:.95 green:.80 blue:.80 alpha:1]; // light
		
	}
	
	return col;
}
+(UIColor *)bgColourOnNow
{
	static UIColor *col = NULL;
	if (!col)
	{
		if (dark)
			col = [UIColor colorWithRed:.33 green:.33 blue:.20 alpha:1]; // dark
		else
			col = [UIColor colorWithRed:.93 green:.93 blue:.80 alpha:1]; // light
		
	}
	
	return col;
}

+(UIColor *)fgColourStd
{
	static UIColor *col = NULL;
	if (!col)
	{
		if (dark)
			col = [UIColor whiteColor];
		else
			col = [UIColor blackColor];
		
	}
	
	return col;
}
+(UIColor *)fgColourAlreadyShown
{
	static UIColor *col = NULL;
	if (!col)
	{
		if (dark)
			col = [UIColor darkGrayColor];
		else
			col = [UIColor lightGrayColor];
		
	}
	
	return col;
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
	
	self.Channel = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.programmeStartOrEndTimer invalidate];
}

-(void)initProgrammeStartOrEndTimer
{
	// ensure we're not adding several timers at once
	[self.programmeStartOrEndTimer invalidate];
	
	// init of vars we'll use in a sec
	[self startOrEndTimerFired:nil];
	
	// schedule the timer to fire at the start or end, whichever comes first
	NSDate *tmp;
	
	if (self.isOnNow)
		tmp = self.StopTime;
	
	else if (!self.hasFinished)
		// is not on and has not finished, so wait for start time
		tmp = self.StartTime;
	
	// if tmp isn't set now, we never need to be fired, the programme has already shown
	if (tmp)
	{
		self.programmeStartOrEndTimer = [[NSTimer alloc] initWithFireDate:tmp
																 interval:0
																   target:self
																 selector:@selector(startOrEndTimerFired:)
																 userInfo:nil
																  repeats:NO];
		[[NSRunLoop mainRunLoop] addTimer:self.programmeStartOrEndTimer forMode:NSDefaultRunLoopMode];
	}
}

-(void)startOrEndTimerFired:(NSTimer *)timer
{
	// this is called when the programme starts or ends.
	// the variables it sets are used various other displays to set colours or whatever.
	
	BOOL isOnNow = self.isOnNow;
	BOOL hasFinished = self.hasFinished;
	
	self.isOnNow = ([self.StartTime timeIntervalSinceNow] < 0 && [self.StopTime timeIntervalSinceNow] > 0);
	self.hasFinished = [self.StopTime timeIntervalSinceNow] < 0;
	
	
	if (isOnNow != self.isOnNow || hasFinished != self.hasFinished)
	{
		//NSLog(@"%s %@ isOn=%d hasFin=%d", __PRETTY_FUNCTION__, [self Property:kTitle], self.isOnNow, self.hasFinished);
		[[NSNotificationCenter defaultCenter] postNotificationName:kArgusProgrammeOnAirStatusChanged object:self userInfo:nil];
	}
	
	// re-setup the timer, if we were called automatically
	// don't call this if timer==nil, it'll just loop forever
	if (timer)
	{
		// remove the old one first (may not even be necessary, but it makes sure)
		[timer invalidate];
		[self initProgrammeStartOrEndTimer];
	}
}

// when the list of upcoming programmes changes,
// our -upcomingProgramme will need to re-evaluate it's cache
// so kill the cache and let it re-evaluate when its next called
-(void)killUpcomingProgrammeCache:(NSNotification *)notify
{
	self.UpcomingProgrammeHaveCached = NO;
	self.UpcomingProgrammeCached = nil;
}

-(BOOL)populateSelfFromDictionary:(NSDictionary *)input
{
	if (! [super populateSelfFromDictionary:input])
		return NO;
	
	// cache some commonly used hard-to-calculate values
	self.StartTime = [self Property:kStartTime];
	self.StopTime = [self Property:kStopTime];
	
	[self initProgrammeStartOrEndTimer];
	
	return YES;
}

-(id)Property:(NSString *)what
{
	// couple of overrides to improve performance
	if (self.StartTime && [what isEqual:kStartTime])
		return self.StartTime;
	
	if (self.StopTime && [what isEqual:kStopTime])
		return self.StopTime;
	
	return [super Property:what];
}

#if 0
-(void)setChannel:(ArgusChannel *)c
{
	// debugging why channels are getting set to nil
	NSLog(@"setting channel of %@ to %@", [self Property:kTitle], c);
	_Channel = c;
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
	self.StartTime = [self Property:kStartTime];
	self.StopTime = [self Property:kStopTime];
	
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
	
	assert(self.Channel);
	
	NSString *ChannelId = [self.Channel originalData][kChannelId];
	//NSString *ChannelId = [self.Channel Property:kChannelId];
	
	// if either of these are nil, this won't work, but they shouldn't be..
	assert(ChannelId);
	//assert(![ChannelId isKindOfClass:[NSNull class]]);
	
	
	// most programmes will do this
	NSString *GuideProgramId = [self originalData][kGuideProgramId];
	//NSString *GuideProgramId = [self Property:kGuideProgramId];
	//if (![GuideProgramId isKindOfClass:[NSNull class]])
	if (GuideProgramId)
		return [ChannelId stringByAppendingString:GuideProgramId];
	
	// but manual recordings don't have a GuideProgramId, so use this
	NSString *Title = [self originalData][kTitle];
	//NSString *Title = [self Property:kTitle];
	assert(Title);
	//assert(![Title isKindOfClass:[NSNull class]]);
	
	NSString *uniqueId = @"";
	uniqueId = [uniqueId stringByAppendingString:ChannelId];
	uniqueId = [uniqueId stringByAppendingString:[NSString stringWithFormat:@"%@", self.StartTime]];
	uniqueId = [uniqueId stringByAppendingString:Title];
	return uniqueId;
	
	
	// old, slow way
	//return [NSString stringWithFormat:@"%@-%@-%@", ChannelId, self.StartTime, Title];
}

// find an ArgusUpcomingProgramme that matches this ArgusProgramme
-(ArgusUpcomingProgramme *)upcomingProgramme
{
	if (self.UpcomingProgrammeHaveCached)
		return self.UpcomingProgrammeCached;
	
	if ([[[argus UpcomingProgrammes] UpcomingProgrammesKeyedByUniqueIdentifier] count] == 0)
	{
		self.UpcomingProgrammeHaveCached = YES;
		self.UpcomingProgrammeCached = nil;
		return self.UpcomingProgrammeCached;
	}
	
	// cache the upcoming programme, it's expensive to calculate.
	// this cache is nuked when ArgusUpcomingProgrammesDone is seen (new upcoming programmes list)
	self.UpcomingProgrammeCached = [[argus UpcomingProgrammes] UpcomingProgrammesKeyedByUniqueIdentifier][[self uniqueIdentifier]];
	self.UpcomingProgrammeHaveCached = YES;
	return self.UpcomingProgrammeCached;
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
