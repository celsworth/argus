//
//  ArgusUpcomingProgramme.h
//  Argus
//
//  Created by Chris Elsworth on 03/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusProgramme.h"

#import "ArgusUpcomingRecording.h"

#define kArgusCancelUpcomingProgrammeDone             @"ArgusCancelUpcomingProgrammeDone"
#define kArgusUncancelUpcomingProgrammeDone           @"ArgusUncancelUpcomingProgrammeDone"
#define kArgusSaveUpcomingProgrammeDone               @"ArgusSaveUpcomingProgrammeDone"
#define kArgusAddToPreviouslyRecordedHistoryDone      @"ArgusAddToPreviouslyRecordedHistoryDone"
#define kArgusRemoveFromPreviouslyRecordedHistoryDone @"ArgusRemoveFromPreviouslyRecordedHistoryDone"


// series or one-off not included here, we can just use IsPartOfSeries
typedef enum {
	ArgusUpcomingProgrammeScheduleStatusRecordingScheduled,
	ArgusUpcomingProgrammeScheduleStatusRecordingScheduledConflict,
	
	ArgusUpcomingProgrammeScheduleStatusRecordingCancelledManually,
	ArgusUpcomingProgrammeScheduleStatusRecordingCancelledAlreadyRecorded,
	ArgusUpcomingProgrammeScheduleStatusRecordingCancelledConflict,
	
	ArgusUpcomingProgrammeScheduleStatusAlertScheduled,
	ArgusUpcomingProgrammeScheduleStatusAlertCancelled,
	
	ArgusUpcomingProgrammeScheduleStatusSuggestionScheduled,
	ArgusUpcomingProgrammeScheduleStatusSuggestionCancelled,
	
} ArgusUpcomingProgrammeScheduleStatus;

@class ArgusUpcomingRecording;
@interface ArgusUpcomingProgramme : ArgusProgramme
@property (nonatomic, assign) ArgusScheduleType ScheduleType;

// true if the upcoming programme details are modified
@property (nonatomic, assign) BOOL isModified;

@property (nonatomic, retain) ArgusChannel *rChannel;

@property (nonatomic, assign) NSInteger SaveUpcomingProgrammeRequestsOutstanding;

@property (nonatomic, retain) UILocalNotification *localNotification;

+(ArgusUpcomingProgramme *)UpcomingProgrammeForUpcomingProgramId:(NSString *)UpcomingProgramId;

//-(id)initWithDictionary:(NSDictionary *)input;
-(id)initWithDictionary:(NSDictionary *)input ScheduleType:(ArgusScheduleType)_ScheduleType;
-(void)setupLocalNotification;
-(void)showLocalNotification;
-(BOOL)populateSelfFromDictionary:(NSDictionary *)input;

-(void)cancelUpcomingProgramme;
@property (nonatomic, assign) BOOL IsCancelling;
-(void)uncancelUpcomingProgramme;
@property (nonatomic, assign) BOOL IsUncancelling;
-(void)saveUpcomingProgramme;
@property (nonatomic, assign) BOOL IsSaving;

-(void)addToPreviouslyRecordedHistory;
@property (nonatomic, assign) BOOL IsAddingToPRH;
-(void)removeFromPreviouslyRecordedHistory;
@property (nonatomic, assign) BOOL IsRemovingFromPRH;

-(void)setPriority:(NSNumber *)val;
-(void)setPreRecordSeconds:(NSNumber *)val;
-(void)setPostRecordSeconds:(NSNumber *)val;

-(ArgusUpcomingProgrammeScheduleStatus)scheduleStatus;

-(UIImage *)iconImage;

-(ArgusUpcomingRecording *)upcomingRecording;

@end
