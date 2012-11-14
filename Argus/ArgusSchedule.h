//
//  ArgusSchedule.h
//  Argus
//
//  Created by Chris Elsworth on 05/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusBaseObject.h"

#import "ArgusUpcomingProgrammes.h"

#define kArgusScheduleDone           @"ArgusScheduleDone"
#define kArgusDeleteScheduleDone     @"ArgusDeleteScheduleDone"
#define kArgusSaveScheduleDone       @"ArgusSaveScheduleDone"

#define kArgusScheduleGetPRHDone     @"kArgusScheduleGetPRHDone"
#define kArgusScheduleDelPRHItemDone @"kArgusScheduleDelPRHItemDone"


typedef enum {
	ArgusKeepUntilModeUntilSpaceIsNeeded      = 0,
	ArgusKeepUntilModeForever                 = 1,
	ArgusKeepUntilModeNumberOfDays            = 2,
	ArgusKeepUntilModeNumberOfEpisodes        = 3,
	ArgusKeepUntilModeNumberOfWatchedEpisodes = 4,
} ArgusKeepUntilMode;

#define kArgusScheduleRuleTypeChannels                  @"Channels"
#define kArgusScheduleRuleTypeNotOnChannels             @"NotOnChannels"
#define kArgusScheduleRuleTypeAroundTime                @"AroundTime"
#define kArgusScheduleRuleTypeStartingBetween           @"StartingBetween"
#define kArgusScheduleRuleTypeOnDate                    @"OnDate"
#define kArgusScheduleRuleTypeDaysOfWeek                @"DaysOfWeek"
#define kArgusScheduleRuleTypeTitleEquals               @"TitleEquals"
#define kArgusScheduleRuleTypeSubTitleEquals            @"SubTitleEquals"
#define kArgusScheduleRuleTypeSubTitleStartsWith        @"SubTitleStartsWith"
#define kArgusScheduleRuleTypeSubTitleContains          @"SubTitleContains"
#define kArgusScheduleRuleTypeSubTitleDoesNotContain    @"SubTitleDoesNotContain"
#define kArgusScheduleRuleTypeEpisodeNumberEquals       @"EpisodeNumberEquals"
#define kArgusScheduleRuleTypeTitleStartsWith           @"TitleStartsWith"
#define kArgusScheduleRuleTypeTitleContains             @"TitleContains"
#define kArgusScheduleRuleTypeTitleDoesNotContain       @"TitleDoesNotContain"
#define kArgusScheduleRuleTypeDescriptionContains       @"DescriptionContains"
#define kArgusScheduleRuleTypeDescriptionDoesNotContain @"DescriptionDoesNotContain"
#define kArgusScheduleRuleTypeCategoryEquals            @"CategoryEquals"
#define kArgusScheduleRuleTypeCategoryDoesNotEqual      @"CategoryDoesNotEqual"
#define kArgusScheduleRuleTypeDirectedBy                @"DirectedBy"
#define kArgusScheduleRuleTypeWithActor                 @"WithActor"
#define kArgusScheduleRuleTypeSkipRepeats               @"SkipRepeats"
#define kArgusScheduleRuleTypeNewEpisodesOnly           @"NewEpisodesOnly"
#define kArgusScheduleRuleTypeNewTitlesOnly             @"NewTitlesOnly"
#define kArgusScheduleRuleTypeManualSchedule            @"ManualSchedule"
#define kArgusScheduleRuleTypeProgramInfoContains       @"ProgramInfoContains"
#define kArgusScheduleRuleTypeProgramInfoDoesNotContain @"ProgramInfoDoesNotContain"


// for the rule types that can have multiple matchtypes, like contains/startswith
// we also set the overriding type
#define kArgusScheduleRuleSuperTypeTitle                @"Title"
#define kArgusScheduleRuleSuperTypeSubTitle             @"SubTitle"
#define kArgusScheduleRuleSuperTypeEpisodeNumber        @"EpisodeNumber"
#define kArgusScheduleRuleSuperTypeDescription          @"Description"
#define kArgusScheduleRuleSuperTypeProgramInfo          @"ProgramInfo"
#define kArgusScheduleRuleSuperTypeChannels             @"Channels"
#define kArgusScheduleRuleSuperTypeCategories           @"Categories"



#define kArgusScheduleRuleTypeEpisodeNumberStartsWith      @"ArgusScheduleRuleTypeEpisodeNumberStartsWith"
#define kArgusScheduleRuleTypeEpisodeNumberContains        @"ArgusScheduleRuleTypeEpisodeNumberContains"
#define kArgusScheduleRuleTypeEpisodeNumberDoesNotContain  @"ArgusScheduleRuleTypeEpisodeNumberDoesNotContain"

typedef enum {
	ArgusScheduleRuleTypeChannels                      =  1,
	ArgusScheduleRuleTypeNotOnChannels                 =  2,
	ArgusScheduleRuleTypeAroundTime                    =  3,
	ArgusScheduleRuleTypeStartingBetween               =  4,
	ArgusScheduleRuleTypeOnDate                        =  5,
	ArgusScheduleRuleTypeDaysOfWeek                    =  6,
	ArgusScheduleRuleTypeTitleEquals                   =  7,
	ArgusScheduleRuleTypeSubTitleEquals                =  8,
	ArgusScheduleRuleTypeSubTitleStartsWith            =  9,
	ArgusScheduleRuleTypeSubTitleContains              = 10,
	ArgusScheduleRuleTypeSubTitleDoesNotContain        = 11,
	ArgusScheduleRuleTypeEpisodeNumberEquals           = 12,
	ArgusScheduleRuleTypeTitleStartsWith               = 13,
	ArgusScheduleRuleTypeTitleContains                 = 14,
	ArgusScheduleRuleTypeTitleDoesNotContain           = 15,
	ArgusScheduleRuleTypeDescriptionContains           = 16,
	ArgusScheduleRuleTypeDescriptionDoesNotContain     = 17,      
	ArgusScheduleRuleTypeCategoryEquals                = 18,
	ArgusScheduleRuleTypeCategoryDoesNotEqual          = 19,
	ArgusScheduleRuleTypeDirectedBy                    = 20,
	ArgusScheduleRuleTypeWithActor                     = 21, 
	ArgusScheduleRuleTypeSkipRepeats                   = 22,
	ArgusScheduleRuleTypeNewEpisodesOnly               = 23,
	ArgusScheduleRuleTypeNewTitlesOnly                 = 24,
	ArgusScheduleRuleTypeManualSchedule                = 25,
	ArgusScheduleRuleTypeProgramInfoContains           = 26,
	ArgusScheduleRuleTypeProgramInfoDoesNotContain     = 27,
	
	ArgusScheduleRuleTypeEpisodeNumberStartsWith       = 70,
	ArgusScheduleRuleTypeEpisodeNumberContains         = 71,
	ArgusScheduleRuleTypeEpisodeNumberDoesNotContain   = 72,
} ArgusScheduleRuleType;

// our own "super-types" to encompass StartsWith/Contains/etc of normal types
typedef enum {
	ArgusScheduleRuleSuperTypeTitle                  = 1001,
	ArgusScheduleRuleSuperTypeSubTitle               = 1002,
	ArgusScheduleRuleSuperTypeEpisodeNumber          = 1003,
	ArgusScheduleRuleSuperTypeDescription            = 1004,
	ArgusScheduleRuleSuperTypeProgramInfo            = 1005,
	ArgusScheduleRuleSuperTypeChannels               = 1006,
	ArgusScheduleRuleSuperTypeCategories             = 1007,
} ArgusScheduleRuleSuperType;

typedef enum {
	ArgusScheduleRuleMatchTypeEquals         = 1,
	ArgusScheduleRuleMatchTypeStartsWith     = 2,
	ArgusScheduleRuleMatchTypeContains       = 3,
	ArgusScheduleRuleMatchTypeDoesNotContain = 4,
} ArgusScheduleRuleMatchType;

typedef enum {
	ArgusScheduleRuleDayOfWeekSunday    = 1,
	ArgusScheduleRuleDayOfWeekMonday    = 2,
	ArgusScheduleRuleDayOfWeekTuesday   = 4,
	ArgusScheduleRuleDayOfWeekWednesday = 8,
	ArgusScheduleRuleDayOfWeekThursday  = 16,
	ArgusScheduleRuleDayOfWeekFriday    = 32,
	ArgusScheduleRuleDayOfWeekSaturday  = 64,
} ArgusScheduleRuleDaysOfWeek;

@interface ArgusScheduleRule : NSObject

// from Argus
@property (nonatomic, assign) ArgusScheduleRuleType Type;
@property (nonatomic, retain) NSMutableArray *Arguments;

// we do these to make for easier matching later
@property (nonatomic, assign) ArgusScheduleRuleSuperType SuperType;
@property (nonatomic, assign) ArgusScheduleRuleMatchType MatchType;

// set YES when Arguments changes, NO when we save it
@property (nonatomic, retain) NSNumber *Modified;

-(void)setArgumentAsBoolean:(BOOL)val;
-(BOOL)getArgumentAsBoolean;
-(void)setArgumentAsDate:(NSDate *)val;
-(NSDate *)getArgumentAsDate;
-(void)setArgumentAsFromDate:(NSDate *)fromVal toDate:(NSDate *)toVal;
-(NSDate *)getArgumentAsDateAtIndex:(NSInteger)index;
-(BOOL)getArgumentAsDayOfWeekSelected:(ArgusScheduleRuleDaysOfWeek)day;
-(void)setArgumentAsDayOfWeek:(ArgusScheduleRuleDaysOfWeek)day selected:(BOOL)selected;

@end

@class ArgusProgramme;
@interface ArgusSchedule : ArgusBaseObject <UpcomingProgrammesDataSource>
@property (nonatomic, retain) NSMutableDictionary *Rules;
@property (nonatomic, retain) NSMutableDictionary *RulesSuper;
@property (nonatomic, assign) BOOL fullDetailsDone;

@property (nonatomic, retain) ArgusUpcomingProgrammes *UpcomingProgrammes;
@property (nonatomic, retain) NSMutableArray *PreviouslyRecordedHistory;


// set YES when any member (including a rule) changes, NO when we save it
@property (nonatomic, retain) NSNumber *Modified;

+(ArgusSchedule *)ScheduleForScheduleId:(ArgusGuid *)ScheduleId;

-(id)initEmptyWithChannelType:(ArgusChannelType)ChannelType scheduleType:(ArgusScheduleType)ScheduleType;
-(id)initWithScheduleId:(NSString *)_ScheduleId;
-(id)initWithDictionary:(NSDictionary *)input;
-(id)initWithExistingSchedule:(ArgusSchedule *)sched;

-(void)setupForQuickRecord:(ArgusProgramme *)Programme;

//-(void)fetchEmptyScheduleOfChannelType:(ArgusChannelType)ChannelType scheduleType:(ArgusScheduleType)ScheduleType;

//-(void)populateSelfFromDictionary:(NSDictionary *)input;

// true if the schedule or any child rules are modified
-(BOOL)isModified;

-(void)getFullDetailsForced:(BOOL)forced;
-(void)getFullDetails;

-(void)getUpcomingProgrammes;

-(void)getPRH;


-(void)save;

-(void)delete;



//-(void)setScheduleId:(NSString *)val;
-(NSString *)ScheduleId;

-(void)setName:(NSString *)val;
//-(NSString *)Name;

-(void)setIsActive:(BOOL)val;
-(BOOL)IsActive;

-(void)setChannelType:(ArgusChannelType)val;
-(ArgusChannelType)ChannelType;

-(void)setScheduleType:(ArgusScheduleType)val;
-(ArgusScheduleType)ScheduleType;

-(void)setSchedulePriority:(NSNumber *)val;

-(void)setPreRecordSeconds:(NSNumber *)val;
-(void)setPostRecordSeconds:(NSNumber *)val;


-(void)setKeepUntilMode:(NSNumber *)val;
-(void)setKeepUntilValue:(NSNumber *)val;

-(void)setRecordingFileFormatId:(ArgusGuid *)val;


+(NSString *)stringForPriority:(ArgusPriority)priority;
+(NSString *)stringForKeepUntilMode:(ArgusKeepUntilMode)keepUntilMode;

@end
