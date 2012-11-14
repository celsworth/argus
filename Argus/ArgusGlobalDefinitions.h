//
//  ArgusGlobalDefinitions.h
//  Argus
//
//  Created by Chris Elsworth on 26/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ArgusChannelTypeAny        = -1, // our own addition
	ArgusChannelTypeTelevision = 0,
	ArgusChannelTypeRadio      = 1,
} ArgusChannelType;

typedef enum {
	ArgusScheduleTypeRecording  = 82,
	ArgusScheduleTypeSuggestion = 83,
	ArgusScheduleTypeAlert      = 65,
} ArgusScheduleType;

typedef enum
{
	ArgusScheduleEditTypePreRecord       = 1,
	ArgusScheduleEditTypePostRecord      = 2,
	
	ArgusScheduleEditTypeAroundTime      = 3,
	ArgusScheduleEditTypeStartingBetween = 4,
} ArgusScheduleEditType;

typedef enum
{
	ArgusCancellationReasonNone               = 0,
	ArgusCancellationReasonManual             = 1,
	ArgusCancellationReasonAlreadyQueued      = 2,
	ArgusCancellationReasonPreviouslyRecorded = 3,
} ArgusCancellationReason;



typedef enum {
	ArgusPriorityVeryLow  = -2,
	ArgusPriorityLow      = -1,
	ArgusPriorityNormal   =  0,
	ArgusPriorityHigh     =  1,
	ArgusPriorityVeryHigh =  2,
} ArgusPriority;


typedef NSString ArgusGuid;


#define kArgusProgrammesDone @"ArgusProgrammesDone"
#define kArgusProgrammesFail @"ArgusProgrammesFail"


#define kChannel                   @"Channel"
#define kCurrent                   @"Current"
#define kNext                      @"Next"

#define kActualStartTime           @"ActualStartTime"
#define kActualStopTime            @"ActualStopTime"
#define kArguments                 @"Arguments"
#define kCardChannelAllocation     @"CardChannelAllocation"
#define kCardId                    @"CardId"
#define kCancellationReason        @"CancellationReason"
#define kChannelGroupId            @"ChannelGroupId"
#define kChannel                   @"Channel"
#define kChannelId                 @"ChannelId"
#define kChannelType               @"ChannelType"
#define kConflictingPrograms       @"ConflictingPrograms"
#define kDisplayName               @"DisplayName"
#define kDescription               @"Description"
#define kDuration                  @"Duration"
#define kEpisode                   @"Episode"
#define kFormat                    @"Format"
#define kFreeSpaceBytes            @"FreeSpaceBytes"
#define kFreeHoursHD               @"FreeHoursHD"
#define kFreeHoursSD               @"FreeHoursSD"
#define kGroupName                 @"GroupName"
#define kGuideChannelId            @"GuideChannelId"
#define kGuideProgramId            @"GuideProgramId"
#define kName                      @"Name"
#define kIsActive                  @"IsActive"
#define kIsCancelled               @"IsCancelled"
#define kIsOneTime                 @"IsOneTime"
#define kIsPartOfSeries            @"IsPartOfSeries"
#define kKeepUntilMode             @"KeepUntilMode"
#define kKeepUntilValue            @"KeepUntilValue"
#define kPercentageUsed            @"PercentageUsed"
#define kProgram                   @"Program"
#define kPreRecordSeconds          @"PreRecordSeconds"
#define kPostRecordSeconds         @"PostRecordSeconds"
#define kPreRecordMinutes          @"PreRecordMinutes"
#define kPriority                  @"Priority"
#define kPostRecordMinutes         @"PostRecordMinutes"
#define kRecordedOn                @"RecordedOn"
#define kRecordingDiskInfos        @"RecordingDiskInfos"
#define kRecordingFileFormatId     @"RecordingFileFormatId"
#define kRecordingFileName         @"RecordingFileName"
#define kRecordingId               @"RecordingId"
#define kRecordingStartTime        @"RecordingStartTime"
#define kRecorderTunerId           @"RecorderTunerId"
#define kRtspUrl                   @"RtspUrl"
#define kRules                     @"Rules"
#define kScheduleId                @"ScheduleId"
#define kScheduleType              @"ScheduleType"
#define kSchedulePriority          @"SchedulePriority"
#define kScheduleRecordedProgramId @"ScheduleRecordedProgramId"
#define kSequence                  @"Sequence"
#define kStreamLastAliveTime       @"StreamLastAliveTime"
#define kStreamStartedTime         @"StreamStartedTime"
#define kStartTime                 @"StartTime"
#define kStopTime                  @"StopTime"
#define kSubTitle                  @"SubTitle"
#define kTimeshiftFile             @"TimeshiftFile"
#define kTitle                     @"Title"
#define kTotalSizeBytes            @"TotalSizeBytes"
#define kType                      @"Type"
#define kUpcomingProgramId         @"UpcomingProgramId"
#define kVersion                   @"Version"
#define kVisibleInGuide            @"VisibleInGuide"


//@interface ArgusGlobalDefinitions : NSObject
//@end
