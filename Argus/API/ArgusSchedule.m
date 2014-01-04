//
//  ArgusSchedule.m
//  Argus
//
//  Created by Chris Elsworth on 05/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusSchedule.h"
#import "ArgusConnection.h"
#import "ArgusChannel.h"
#import "ArgusProgramme.h"
#import "ArgusScheduleRecordedProgram.h"
#import "Argus.h"

#import "ISO8601DateFormatter.h"
#import "NSDateFormatter+LocaleAdditions.h"

#import "AppDelegate.h"

#import "SBJson.h"
#import "JSONKit.h"

@implementation ArgusScheduleRule

-(id)initWithSuperType:(ArgusScheduleRuleSuperType)SuperType
{
	self = [super init];
	if (self)
	{
		_SuperType = SuperType;
		
		// these are defaults but let's be implicit
		_MatchType = 0;
		_Arguments = nil;
		_Modified = @NO;
	}
	return self;
}
-(id)initWithType:(ArgusScheduleRuleType)Type
{
	self = [super init];
	if (self)
	{
		_Type = Type;
		
		// these are defaults but let's be implicit
		_MatchType = 0;
		_Arguments = nil;
		_Modified = @NO;
	}
	return self;
}

-(void)setMatchType:(ArgusScheduleRuleMatchType)MatchType
{
	self.Modified = @YES;
	_MatchType = MatchType;
	
	if (self.SuperType)
		self.Type = [self typeForMatchType:self.MatchType andSuperType:self.SuperType];
}
-(void)setArguments:(NSMutableArray *)Arguments
{
	self.Modified = @YES;
	_Arguments = Arguments;
}

-(void)setArgumentAsBoolean:(BOOL)val
{
	// Arguments should be an array with one value
	// @"True" for true
	// empty for false?
	if (val)
		self.Arguments = [@[@"True"] mutableCopy];
	else
		self.Arguments = nil;
}
-(BOOL)getArgumentAsBoolean
{
	return [self.Arguments[0] isEqualToString:@"True"];
}

-(NSDate *)getArgumentAsDate
{
	NSString *tmp = self.Arguments[0];
	if (!tmp) return nil;
	
	if (self.Type == ArgusScheduleRuleTypeOnDate)
	{
		ISO8601DateFormatter *isodf = [ISO8601DateFormatter new];
		return [isodf dateFromString:tmp];
	}
	
	if (self.Type == ArgusScheduleRuleTypeAroundTime)
	{
		NSDateFormatter *df = [[NSDateFormatter alloc] initWithPOSIXLocaleAndFormat:@"HH:mm:ss"];
		return [df dateFromString:tmp];
	}
	return nil;
}
-(void)setArgumentAsDate:(NSDate *)val
{
	if (self.Type == ArgusScheduleRuleTypeOnDate)
	{
		ISO8601DateFormatter *isodf = [ISO8601DateFormatter new];
		self.Arguments = [@[[isodf stringFromDate:val]] mutableCopy];
	}
	
	if (self.Type == ArgusScheduleRuleTypeAroundTime)
	{
		NSDateFormatter *df = [[NSDateFormatter alloc] initWithPOSIXLocaleAndFormat:@"HH:mm:00"];
		self.Arguments = [@[[df stringFromDate:val]] mutableCopy];
	}
}

-(void)setArgumentAsFromDate:(NSDate *)fromVal toDate:(NSDate *)toVal
{
	NSDateFormatter *df = [[NSDateFormatter alloc] initWithPOSIXLocaleAndFormat:@"HH:mm:00"];
	NSString *fromString = [df stringFromDate:fromVal];
	NSString *toString = [df stringFromDate:toVal];
	self.Arguments = [@[fromString, toString] mutableCopy];
}
-(NSDate *)getArgumentAsDateAtIndex:(NSInteger)index
{
	NSDateFormatter *df = [[NSDateFormatter alloc] initWithPOSIXLocaleAndFormat:@"HH:mm:ss"];
	return [df dateFromString:self.Arguments[index]];
}

-(BOOL)getArgumentAsDayOfWeekSelected:(ArgusScheduleRuleDaysOfWeek)day
{
	// Arguments[0] is a bitmask of days of week
	NSInteger days = [self.Arguments[0] intValue];
	return (days & day);
}
-(void)setArgumentAsDayOfWeek:(ArgusScheduleRuleDaysOfWeek)day selected:(BOOL)selected
{
	NSInteger days = [self.Arguments[0] intValue];

	if (selected)
		days |= day;
	else
		days &= ~day;
	
	self.Arguments = [@[@(days)] mutableCopy];
}

#pragma mark - Output Formats; converting structures back to JSON

-(NSDictionary *)ruleAsDictionary
{
	if (self.Type && self.Arguments)
	{
		NSMutableDictionary *tmp = [NSMutableDictionary new];
		tmp[kArguments] = self.Arguments;
		tmp[kType] = [self typeAsString];
	
		return [NSDictionary dictionaryWithDictionary:tmp];
	}
	return nil;
}
	 
// convert Type to an NSString to send back to Argus
-(NSString *)typeAsString
{	
	switch(self.Type)
	{		
		case ArgusScheduleRuleTypeTitleStartsWith:                   return kArgusScheduleRuleTypeTitleStartsWith;
		case ArgusScheduleRuleTypeTitleEquals:                       return kArgusScheduleRuleTypeTitleEquals;
		case ArgusScheduleRuleTypeTitleContains:                     return kArgusScheduleRuleTypeTitleContains;
		case ArgusScheduleRuleTypeTitleDoesNotContain:               return kArgusScheduleRuleTypeTitleDoesNotContain;

		case ArgusScheduleRuleTypeSubTitleStartsWith:                return kArgusScheduleRuleTypeSubTitleStartsWith;
		case ArgusScheduleRuleTypeSubTitleEquals:                    return kArgusScheduleRuleTypeSubTitleEquals;
		case ArgusScheduleRuleTypeSubTitleContains:                  return kArgusScheduleRuleTypeSubTitleContains;
		case ArgusScheduleRuleTypeSubTitleDoesNotContain:            return kArgusScheduleRuleTypeSubTitleDoesNotContain;

		case ArgusScheduleRuleTypeEpisodeNumberStartsWith:           return kArgusScheduleRuleTypeEpisodeNumberStartsWith;
		case ArgusScheduleRuleTypeEpisodeNumberEquals:               return kArgusScheduleRuleTypeEpisodeNumberEquals;
		case ArgusScheduleRuleTypeEpisodeNumberContains:             return kArgusScheduleRuleTypeEpisodeNumberContains;
		case ArgusScheduleRuleTypeEpisodeNumberDoesNotContain:       return kArgusScheduleRuleTypeEpisodeNumberDoesNotContain;

		case ArgusScheduleRuleTypeDescriptionContains:               return kArgusScheduleRuleTypeDescriptionContains;
		case ArgusScheduleRuleTypeDescriptionDoesNotContain:         return kArgusScheduleRuleTypeDescriptionDoesNotContain;

		case ArgusScheduleRuleTypeProgramInfoContains:               return kArgusScheduleRuleTypeProgramInfoContains;
		case ArgusScheduleRuleTypeProgramInfoDoesNotContain:         return kArgusScheduleRuleTypeProgramInfoDoesNotContain;

		case ArgusScheduleRuleTypeChannels:                          return kArgusScheduleRuleTypeChannels;
		case ArgusScheduleRuleTypeNotOnChannels:                     return kArgusScheduleRuleTypeNotOnChannels;

		case ArgusScheduleRuleTypeCategoryEquals:                    return kArgusScheduleRuleTypeCategoryEquals;
		case ArgusScheduleRuleTypeCategoryDoesNotEqual:              return kArgusScheduleRuleTypeCategoryDoesNotEqual;

			
		case ArgusScheduleRuleTypeStartingBetween:                   return kArgusScheduleRuleTypeStartingBetween;
		case ArgusScheduleRuleTypeAroundTime:                        return kArgusScheduleRuleTypeAroundTime;

		case ArgusScheduleRuleTypeOnDate:                            return kArgusScheduleRuleTypeOnDate;

		case ArgusScheduleRuleTypeDaysOfWeek:                        return kArgusScheduleRuleTypeDaysOfWeek;

		case ArgusScheduleRuleTypeSkipRepeats:                       return kArgusScheduleRuleTypeSkipRepeats;
		case ArgusScheduleRuleTypeNewTitlesOnly:                     return kArgusScheduleRuleTypeNewTitlesOnly;
		case ArgusScheduleRuleTypeNewEpisodesOnly:                   return kArgusScheduleRuleTypeNewEpisodesOnly;

		case ArgusScheduleRuleTypeDirectedBy:                        return kArgusScheduleRuleTypeDirectedBy;
		case ArgusScheduleRuleTypeWithActor:                         return kArgusScheduleRuleTypeWithActor;

		case ArgusScheduleRuleTypeManualSchedule:                    return kArgusScheduleRuleTypeManualSchedule;
	}
}

// convert SuperType+MatchType back to Type (for sending back to Argus)
-(ArgusScheduleRuleType)typeForMatchType:(ArgusScheduleRuleMatchType)MatchType andSuperType:(ArgusScheduleRuleSuperType)SuperType
{
	// based on SuperType and MatchType, set a new Type
	// ie Title + Equals -> TitleEquals
	switch (SuperType)
	{
		case ArgusScheduleRuleSuperTypeTitle:
			if (MatchType == ArgusScheduleRuleMatchTypeEquals)         return ArgusScheduleRuleTypeTitleEquals;
			if (MatchType == ArgusScheduleRuleMatchTypeContains)       return ArgusScheduleRuleTypeTitleContains;
			if (MatchType == ArgusScheduleRuleMatchTypeDoesNotContain) return ArgusScheduleRuleTypeTitleDoesNotContain;
			if (MatchType == ArgusScheduleRuleMatchTypeStartsWith)     return ArgusScheduleRuleTypeTitleStartsWith;
			break;
			
		case ArgusScheduleRuleSuperTypeSubTitle:
			if (MatchType == ArgusScheduleRuleMatchTypeEquals)         return ArgusScheduleRuleTypeSubTitleEquals;
			if (MatchType == ArgusScheduleRuleMatchTypeContains)       return ArgusScheduleRuleTypeSubTitleContains;
			if (MatchType == ArgusScheduleRuleMatchTypeDoesNotContain) return ArgusScheduleRuleTypeSubTitleDoesNotContain;
			if (MatchType == ArgusScheduleRuleMatchTypeStartsWith)     return ArgusScheduleRuleTypeSubTitleStartsWith;
			break;

		case ArgusScheduleRuleSuperTypeEpisodeNumber:
			if (MatchType == ArgusScheduleRuleMatchTypeEquals)         return ArgusScheduleRuleTypeEpisodeNumberEquals;
			if (MatchType == ArgusScheduleRuleMatchTypeContains)       return ArgusScheduleRuleTypeEpisodeNumberContains;
			if (MatchType == ArgusScheduleRuleMatchTypeDoesNotContain) return ArgusScheduleRuleTypeEpisodeNumberDoesNotContain;
			if (MatchType == ArgusScheduleRuleMatchTypeStartsWith)     return ArgusScheduleRuleTypeEpisodeNumberStartsWith;
			break;
			
		case ArgusScheduleRuleSuperTypeProgramInfo:
			if (MatchType == ArgusScheduleRuleMatchTypeContains)       return ArgusScheduleRuleTypeProgramInfoContains;
			if (MatchType == ArgusScheduleRuleMatchTypeDoesNotContain) return ArgusScheduleRuleTypeProgramInfoDoesNotContain;
			break;

		case ArgusScheduleRuleSuperTypeDescription:
			if (MatchType == ArgusScheduleRuleMatchTypeContains)       return ArgusScheduleRuleTypeDescriptionContains;
			if (MatchType == ArgusScheduleRuleMatchTypeDoesNotContain) return ArgusScheduleRuleTypeDescriptionDoesNotContain;
			break;
		
		case ArgusScheduleRuleSuperTypeChannels:
			if (MatchType == ArgusScheduleRuleMatchTypeContains)       return ArgusScheduleRuleTypeChannels;
			if (MatchType == ArgusScheduleRuleMatchTypeDoesNotContain) return ArgusScheduleRuleTypeNotOnChannels;
			break;
			
		case ArgusScheduleRuleSuperTypeCategories:
			if (MatchType == ArgusScheduleRuleMatchTypeContains)       return ArgusScheduleRuleTypeCategoryEquals;
			if (MatchType == ArgusScheduleRuleMatchTypeDoesNotContain) return ArgusScheduleRuleTypeCategoryDoesNotEqual;
			break;
	}
	return 0;
}


@end

@class ArgusSchedule; // make initWithExistingSchedule build
@implementation ArgusSchedule
@synthesize Rules, RulesSuper;
@synthesize fullDetailsDone;
@synthesize UpcomingProgrammes, PreviouslyRecordedHistory;
@synthesize Modified;

+(ArgusSchedule *)ScheduleForScheduleId:(ArgusGuid *)ScheduleId
{
	return [[argus Schedules] SchedulesKeyedByScheduleId][ScheduleId];
}

-(id)init
{
	self = [super init];
	if (self)
	{
		UpcomingProgrammes = [[ArgusUpcomingProgrammes alloc] initWithSchedule:self];
	}
	return self;
}

-(id)initEmptyWithChannelType:(ArgusChannelType)ChannelType scheduleType:(ArgusScheduleType)ScheduleType
{
	self = [self init];
	if (self)
	{
		// fetch a new empty schedule populated with defaults
		[self fetchEmptyScheduleOfChannelType:ChannelType scheduleType:ScheduleType];

		// maybe set an editable flag which is true when the schedule is done?
	}
	return self;
}

-(id)initWithScheduleId:(NSString *)_ScheduleId
{
	self = [self init];
	if (self)
	{
		// fetch schedule identified by ScheduleId
		[self fetchScheduleId:_ScheduleId];	
	}
	return self;
}

-(id)initWithDictionary:(NSDictionary *)input
{
	self = [self init];
	if (self)
	{
		if (! [self populateSelfFromDictionary:input])
			return nil;
		
	}
	return self;
}

-(id)initWithExistingSchedule:(ArgusSchedule *)sched
{
	self = [self init];
	if (self)
	{
		// use originalData to copy everything over to ourselves
		// this does rules too
		if (! [self populateSelfFromDictionary:[sched originalData]])
			return nil;
	}
	return self;
}
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setupForQuickRecord:(ArgusProgramme *)Programme
{
	[self setName:[Programme Property:kTitle]];
	[self setScheduleType:ArgusScheduleTypeRecording];
	[self setChannelType:[[[Programme Channel] Property:kChannelType] intValue]];
	
	// title
	ArgusScheduleRule *tmprule;
	tmprule = Rules[kArgusScheduleRuleSuperTypeTitle];
	[tmprule setMatchType:ArgusScheduleRuleMatchTypeEquals];
	[tmprule setArguments:[NSMutableArray arrayWithObject:[Programme Property:kTitle]]];
	
	// channel
	tmprule = Rules[kArgusScheduleRuleSuperTypeChannels];
	[tmprule setMatchType:ArgusScheduleRuleMatchTypeContains];
	NSString *ChannelId = [[Programme Channel] Property:kChannelId];
	[tmprule setArguments:[NSMutableArray arrayWithObject:ChannelId]];
	
	// date and time 
	tmprule = Rules[kArgusScheduleRuleTypeOnDate];
	[tmprule setArgumentAsDate:[Programme Property:kStartTime]];
	tmprule = Rules[kArgusScheduleRuleTypeAroundTime];
	[tmprule setArgumentAsDate:[Programme Property:kStartTime]];
}

-(void)setupEmptyRules
{
	// initialise rules
	Rules = [[NSMutableDictionary alloc] initWithCapacity:32];
	
	// set up a bunch of empty placeholder rules that may be filled in later
	Rules[kArgusScheduleRuleSuperTypeTitle] = [[ArgusScheduleRule alloc] initWithSuperType:ArgusScheduleRuleSuperTypeTitle];
	Rules[kArgusScheduleRuleSuperTypeSubTitle] = [[ArgusScheduleRule alloc] initWithSuperType:ArgusScheduleRuleSuperTypeSubTitle];
	Rules[kArgusScheduleRuleSuperTypeEpisodeNumber] = [[ArgusScheduleRule alloc] initWithSuperType:ArgusScheduleRuleSuperTypeEpisodeNumber];
	Rules[kArgusScheduleRuleSuperTypeDescription] = [[ArgusScheduleRule alloc] initWithSuperType:ArgusScheduleRuleSuperTypeDescription];
	Rules[kArgusScheduleRuleSuperTypeProgramInfo] = [[ArgusScheduleRule alloc] initWithSuperType:ArgusScheduleRuleSuperTypeProgramInfo];
	Rules[kArgusScheduleRuleSuperTypeChannels] = [[ArgusScheduleRule alloc] initWithSuperType:ArgusScheduleRuleSuperTypeChannels];
	Rules[kArgusScheduleRuleSuperTypeCategories] = [[ArgusScheduleRule alloc] initWithSuperType:ArgusScheduleRuleSuperTypeCategories];
	
	Rules[kArgusScheduleRuleTypeOnDate] = [[ArgusScheduleRule alloc] initWithType:ArgusScheduleRuleTypeOnDate];
	Rules[kArgusScheduleRuleTypeDaysOfWeek] = [[ArgusScheduleRule alloc] initWithType:ArgusScheduleRuleTypeDaysOfWeek];
	
	Rules[kArgusScheduleRuleTypeAroundTime] = [[ArgusScheduleRule alloc] initWithType:ArgusScheduleRuleTypeAroundTime];
	Rules[kArgusScheduleRuleTypeStartingBetween] = [[ArgusScheduleRule alloc] initWithType:ArgusScheduleRuleTypeStartingBetween];
	
	Rules[kArgusScheduleRuleTypeNewEpisodesOnly] = [[ArgusScheduleRule alloc] initWithType:ArgusScheduleRuleTypeNewEpisodesOnly];
	Rules[kArgusScheduleRuleTypeNewTitlesOnly] = [[ArgusScheduleRule alloc] initWithType:ArgusScheduleRuleTypeNewTitlesOnly];
	Rules[kArgusScheduleRuleTypeSkipRepeats] = [[ArgusScheduleRule alloc] initWithType:ArgusScheduleRuleTypeSkipRepeats];
	
	Rules[kArgusScheduleRuleTypeDirectedBy] = [[ArgusScheduleRule alloc] initWithType:ArgusScheduleRuleTypeDirectedBy];
	Rules[kArgusScheduleRuleTypeWithActor] = [[ArgusScheduleRule alloc] initWithType:ArgusScheduleRuleTypeWithActor];
}

-(BOOL)populateSelfFromDictionary:(NSDictionary *)input
{
	Modified = @NO;

	if ([input isKindOfClass:[NSDictionary class]])
	{

		// re-initalise rules
		[self setupEmptyRules];

		// this copies input to originalData
		if (! [super populateSelfFromDictionary:input])
			return NO;

		// ProcessingCommands not done yet
		
		// Rules
		if ([input[kRules] isKindOfClass:[NSArray class]])
			[self populateRulesFromArray:input[kRules]];
		
		return YES;
	}
	
	return NO;
}

// initial loading, takes array and populates into ArgusScheduleRule objects
-(void)populateRulesFromArray:(NSArray *)input
{
	for (NSDictionary *d in input)
	{
		ArgusScheduleRule *rp;
		NSString *tmp = d[kType];
		
		// parse string type into enum type via lots of isEqualTo :(	
		
		if ([tmp isEqualToString:kArgusScheduleRuleTypeChannels])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeChannels];
			rp.MatchType = ArgusScheduleRuleMatchTypeContains;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeNotOnChannels])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeChannels];
			rp.MatchType = ArgusScheduleRuleMatchTypeDoesNotContain;
		}
		
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeCategoryEquals])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeCategories];
			rp.MatchType = ArgusScheduleRuleMatchTypeContains;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeCategoryDoesNotEqual])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeCategories];
			rp.MatchType = ArgusScheduleRuleMatchTypeDoesNotContain;
		}
		
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeAroundTime])
		{
			rp = Rules[kArgusScheduleRuleTypeAroundTime];

		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeStartingBetween])
		{
			rp = Rules[kArgusScheduleRuleTypeStartingBetween];

		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeOnDate])
		{
			rp = Rules[kArgusScheduleRuleTypeOnDate];

		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeDaysOfWeek])
		{
			rp = Rules[kArgusScheduleRuleTypeDaysOfWeek];
			
		}
		
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeSubTitleEquals])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeSubTitle];
			rp.MatchType = ArgusScheduleRuleMatchTypeEquals;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeSubTitleStartsWith])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeSubTitle];
			rp.MatchType = ArgusScheduleRuleMatchTypeStartsWith;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeSubTitleContains])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeSubTitle];
			rp.MatchType = ArgusScheduleRuleMatchTypeContains;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeSubTitleDoesNotContain])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeSubTitle];
			rp.MatchType = ArgusScheduleRuleMatchTypeDoesNotContain;
		}
		
		// EPISODE NUMBER
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeEpisodeNumberEquals])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeEpisodeNumber];
			rp.MatchType = ArgusScheduleRuleMatchTypeEquals;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeEpisodeNumberStartsWith])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeEpisodeNumber];
			rp.MatchType = ArgusScheduleRuleMatchTypeStartsWith;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeEpisodeNumberContains])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeEpisodeNumber];
			rp.MatchType = ArgusScheduleRuleMatchTypeContains;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeEpisodeNumberDoesNotContain])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeEpisodeNumber];
			rp.MatchType = ArgusScheduleRuleMatchTypeDoesNotContain;
		}

		// TITLE
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeTitleEquals])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeTitle];
			rp.MatchType = ArgusScheduleRuleMatchTypeEquals;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeTitleStartsWith])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeTitle];
			rp.MatchType = ArgusScheduleRuleMatchTypeStartsWith;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeTitleContains])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeTitle];
			rp.MatchType = ArgusScheduleRuleMatchTypeContains;		
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeTitleDoesNotContain])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeTitle];
			rp.MatchType = ArgusScheduleRuleMatchTypeDoesNotContain;
		}
		
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeDescriptionContains])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeDescription];
			rp.MatchType = ArgusScheduleRuleMatchTypeContains;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeDescriptionDoesNotContain])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeDescription];
			rp.MatchType = ArgusScheduleRuleMatchTypeDoesNotContain;
		}
		
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeDirectedBy])
		{
			rp = Rules[kArgusScheduleRuleTypeDirectedBy];
			rp.MatchType = ArgusScheduleRuleMatchTypeContains;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeWithActor])
		{
			rp = Rules[kArgusScheduleRuleTypeWithActor];
			rp.MatchType = ArgusScheduleRuleMatchTypeContains;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeSkipRepeats])
		{
			rp = Rules[kArgusScheduleRuleTypeSkipRepeats];

		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeNewEpisodesOnly])
		{
			rp = Rules[kArgusScheduleRuleTypeNewEpisodesOnly];
			
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeNewTitlesOnly])
		{
			rp = Rules[kArgusScheduleRuleTypeNewTitlesOnly];

		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeManualSchedule])
		{
			rp = Rules[kArgusScheduleRuleTypeManualSchedule];

		}

		else if ([tmp isEqualToString:kArgusScheduleRuleTypeProgramInfoContains])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeProgramInfo];
			rp.MatchType = ArgusScheduleRuleMatchTypeContains;
		}
		else if ([tmp isEqualToString:kArgusScheduleRuleTypeProgramInfoDoesNotContain])
		{
			rp = Rules[kArgusScheduleRuleSuperTypeProgramInfo];
			rp.MatchType = ArgusScheduleRuleMatchTypeDoesNotContain;
		}

		rp.Arguments = d[kArguments];
		
		// setArguments will have set Modified=YES, reset that
		rp.Modified = @NO;
	}
}
// the reverse, takes our Rules dictionary and presents json-ready array
-(NSMutableArray *)arrayFromRules
{
	NSMutableArray *tmp = [NSMutableArray new];
	for (NSString *key in Rules)
	{
		ArgusScheduleRule *t = Rules[key];
		NSDictionary *d = [t ruleAsDictionary];
		if (d)
			[tmp addObject:d];
	}
	return tmp;
}

-(BOOL)isModified
{
	// return true if the schedule or any rule is modified
	if ([Modified boolValue]) return YES;
		
	// if not, check all the rules
	for (NSString *key in Rules)
	{
		ArgusScheduleRule *t = Rules[key];
		if ([[t Modified] boolValue])
		{
			// this'll let us return quicker next time
			Modified = @YES;
			
			return YES;
		}
	}
	return NO;
}

#pragma mark - Get Schedule By Id
-(void)fetchEmptyScheduleOfChannelType:(ArgusChannelType)ChannelType scheduleType:(ArgusScheduleType)ScheduleType
{
	Modified = @NO;
	
	NSString *url = [NSString stringWithFormat:@"Scheduler/EmptySchedule/%d/%d", ChannelType, ScheduleType];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	// await notification from ArgusConnection that the request has finished
	// we re-use GetFullDetailsDone for this, it's basically the same as FetchEmptyFinished would be
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(GetFullScheduleDetailsDone:)
												 name:kArgusConnectionDone
											   object:c];	
}


-(void)getFullDetails
{
	[self getFullDetailsForced:NO];
}
-(void)getFullDetailsForced:(BOOL)forced
{
	if (!forced && fullDetailsDone)
		return;
	
	Modified = @NO;
	
	NSString *url = [NSString stringWithFormat:@"Scheduler/ScheduleById/%@", [self ScheduleId]];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(GetFullScheduleDetailsDone:)
												 name:kArgusConnectionDone
											   object:c];
}
-(void)GetFullScheduleDetailsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];

	NSData *data = [notify userInfo][@"data"];
	
	SBJsonParser *jsonParser = [SBJsonParser new];
	NSDictionary *jsonObject = [jsonParser objectWithData:data];
	
	//NSLog(@"%s %@", __PRETTY_FUNCTION__, jsonObject);
	
	//self.originalData = [[NSMutableDictionary alloc] initWithDictionary:jsonObject];
	[self populateSelfFromDictionary:jsonObject];
	
	// mark the object as full details fetched so we don't end up looping
	// if description isn't populated now, there isn't one
	self.fullDetailsDone = true;
	
	//NSLog(@"%s sending kArgusScheduleDone", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusScheduleDone object:self];
}


#pragma mark - Get Full Details / New Empty Schedule

-(void)fetchScheduleId:(NSString *)_ScheduleId
{
	Modified = @NO;

	NSString *url = [NSString stringWithFormat:@"Scheduler/ScheduleById/%@", _ScheduleId];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	// await notification from ArgusConnection that the request has finished
	// we re-use GetFullDetailsDone for this, it's basically the same as fetchScheduleFinished would be
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(GetFullScheduleDetailsDone:)
												 name:kArgusConnectionDone
											   object:c];
}


#pragma mark - Get Upcoming Programmes for schedule
-(void)getUpcomingProgrammes
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// update Rules in originalData
	(self.originalData)[kRules] = [self arrayFromRules];

	[UpcomingProgrammes getUpcomingProgrammesForSchedule];
	
	// await notification
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(UpcomingProgrammesDone:)
												 name:kArgusUpcomingProgrammesDone
											   object:UpcomingProgrammes];

}
-(void)UpcomingProgrammesDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kArgusUpcomingProgrammesDone object:[notify object]];

	
	// post our own notification
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusUpcomingProgrammesDone object:self];

	// anything else?
}

#pragma mark - Previously Recorded History
-(void)getPRH
{
	[AppDelegate requestLoadingSpinner];
	
	NSString *url = [NSString stringWithFormat:@"Control/PreviouslyRecordedHistory/%@", [self Property:kScheduleId]];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(getPRHDone:)
												 name:kArgusConnectionDone
											   object:c];
}
-(void)getPRHDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];

	NSData *data = [notify userInfo][@"data"];
	NSArray *jsonObject = [data objectFromJSONData];

	NSMutableArray *tmpArr = [NSMutableArray new];
	
	for (NSDictionary *d in jsonObject)
	{
		NSLog(@"%s %@", __PRETTY_FUNCTION__, d);
		
		ArgusScheduleRecordedProgram *srp = [[ArgusScheduleRecordedProgram alloc] initWithDictionary:d];
		
		[tmpArr addObject:srp];
	}
	
	PreviouslyRecordedHistory = tmpArr;

	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusScheduleGetPRHDone object:self];

	[AppDelegate releaseLoadingSpinner];
}

// deleteFromPRH
// actually, put this in ArgusScheduleRecordedProgram



#pragma mark - Schedule Saving
-(void)save
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// update Rules in originalData
	(self.originalData)[kRules] = [self arrayFromRules];
		
	NSString *url = [NSString stringWithFormat:@"Scheduler/SaveSchedule"];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:NO lowPriority:NO];

	//NSLog(@"%@", url);

	NSString *body = [self.originalData JSONRepresentation];

	NSLog(@"Saving Schedule: %@", body);
	
	[c setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	[c enqueue];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SaveScheduleDone:) name:kArgusConnectionDone object:c];	

}
-(void)SaveScheduleDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];

	// after saving, the new schedule is sent back to us in the body, with an incremented Version
	// we need to fill this new data into our structures or subsequent saves will fail with err500
	
	NSInteger statusCode = [[[notify object] httpresponse] statusCode];
	NSData *data = [notify userInfo][@"data"];
	
	if (statusCode == 200)
	{
		SBJsonParser *jsonParser = [SBJsonParser new];
		NSDictionary *jsonObject = [jsonParser objectWithData:data];

		// populateSelfFromDictionary sets Schedule.Modified=NO
		[self populateSelfFromDictionary:jsonObject];
	}
	else
	{
		//NSString *body = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		//NSLog(@"SaveScheduleDone: %@", body);
	}
	
	/*
	NSLog(@"sched modified=%d", [Modified boolValue]);
	for (NSString *k in Rules)
	{
		ArgusScheduleRule *r = [Rules objectForKey:k];
		NSLog(@"r=%@", r);
		NSLog(@"ruletype=%d mod=%d", [r Type], [[r Modified] boolValue]);
	}
	 */
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusSaveScheduleDone object:self];
}


#pragma mark - Schedule Deletion

-(void)delete
{
	// delete the schedule from the server
	NSString *url = [NSString stringWithFormat:@"Scheduler/DeleteSchedule/%@", [self ScheduleId]];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url ];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(DeleteScheduleDone:)
												 name:kArgusConnectionDone
											   object:c];	
}
-(void)DeleteScheduleDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];

	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusDeleteScheduleDone object:self];
}


#pragma mark - Object Getters/Setters

-(NSString *)ScheduleId
{
	return [self originalData][kScheduleId];
}

-(void)setName:(NSString *)val
{
	[[self originalData] setValue:val forKey:kName];
	Modified = @YES;
}
-(NSString *)Name
{
	return [self originalData][kName];
}

-(void)setSchedulePriority:(NSNumber *)val
{
	[[self originalData] setValue:val forKey:kSchedulePriority];
	Modified = @YES;
}
-(NSNumber *)SchedulePriority
{
	return [self originalData][kSchedulePriority];
}

-(void)setIsActive:(BOOL)val
{
	NSNumber *n = @(val);
	[[self originalData] setValue:n forKey:kIsActive];
	Modified = @YES;
}
-(BOOL)IsActive
{
	return [[self originalData][kIsActive] boolValue];
}

-(void)setChannelType:(ArgusChannelType)val
{
	[[self originalData] setValue:@(val) forKey:kChannelType];
	Modified = @YES;
}
-(ArgusChannelType)ChannelType
{
	return [[self originalData][kChannelType] intValue];
}
-(void)setScheduleType:(ArgusScheduleType)val
{
	[[self originalData] setValue:@(val) forKey:kScheduleType];
	Modified = @YES;
}
-(ArgusScheduleType)ScheduleType
{
	return [[self originalData][kScheduleType] intValue];
}


-(void)setPreRecordSeconds:(NSNumber *)val
{
	[[self originalData] setValue:val forKey:kPreRecordSeconds];
	Modified = @YES;
}
-(NSNumber *)PreRecordSeconds
{
	return [self originalData][kPreRecordSeconds];
}

-(void)setPostRecordSeconds:(NSNumber *)val
{
	[[self originalData] setValue:val forKey:kPostRecordSeconds];
	Modified = @YES;
}
-(NSNumber *)PostRecordSeconds
{
	return [self originalData][kPostRecordSeconds];
}

-(void)setKeepUntilMode:(NSNumber *)val
{
	[[self originalData] setValue:val forKey:kKeepUntilMode];
	Modified = @YES;
}
-(NSNumber *)KeepUntilMode
{
	return [self originalData][kKeepUntilMode];
}

-(void)setKeepUntilValue:(NSNumber *)val
{
	[[self originalData] setValue:val forKey:kKeepUntilValue];
	Modified = @YES;
}
-(NSNumber *)KeepUntilValue
{
	return [self originalData][kKeepUntilValue];
}

-(void)setRecordingFileFormatId:(ArgusGuid *)val
{
	[[self originalData] setValue:val forKey:kRecordingFileFormatId];
	
	Modified = @YES;
}



#pragma mark - Helper Methods


+(NSString *)stringForPriority:(ArgusPriority)priority
{
	switch (priority)
	{
		case ArgusPriorityVeryLow:
			return NSLocalizedString(@"very low", @"priority rating");

		case ArgusPriorityLow:
			return NSLocalizedString(@"low", @"priority rating");

		case ArgusPriorityNormal:
			return NSLocalizedString(@"normal", @"priority rating");

		case ArgusPriorityHigh:
			return NSLocalizedString(@"high", @"priority rating");

		case ArgusPriorityVeryHigh:
			return NSLocalizedString(@"very high", @"priority rating");
	}
}

+(NSString *)stringForKeepUntilMode:(ArgusKeepUntilMode)keepUntilMode
{
	switch (keepUntilMode)
	{
		case ArgusKeepUntilModeUntilSpaceIsNeeded:
			return NSLocalizedString(@"until space is needed", @"keep until mode description");
			
		case ArgusKeepUntilModeForever:
			return NSLocalizedString(@"forever", @"keep until mode description");
			
		case ArgusKeepUntilModeNumberOfDays:
			return NSLocalizedString(@"days", @"keep until mode description");
			
		case ArgusKeepUntilModeNumberOfEpisodes:
			return NSLocalizedString(@"recordings", @"keep until mode description");
			
		case ArgusKeepUntilModeNumberOfWatchedEpisodes:
			return NSLocalizedString(@"watched recordings", @"keep until mode description");
	}
}

@end
