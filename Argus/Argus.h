//
//  Argus.h
//  Argus
//
//  Created by Chris Elsworth on 01/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ArgusColours.h"

#import "ArgusBaseObject.h"
#import "ArgusSchedule.h"
#import "ArgusRecordingDiskInfo.h"
#import "ArgusRecordingFileFormats.h"
#import "ArgusConnection.h"
#import "ArgusChannelGroups.h"
#import "ArgusCategories.h"

#import "ArgusUpcomingProgrammes.h"
#import "ArgusUpcomingRecordings.h"

#define kArgusLiveStreamsDone      @"ArgusLiveStreamsDone"
#define kArgusChannelsDone         @"ArgusChannelsDone"
#define kArgusSchedulesDone        @"ArgusSchedulesDone"
#define kArgusEmptyScheduleDone    @"ArgusEmptyScheduleDone"
#define kArgusActiveRecordingsDone @"ArgusActiveRecordingsDone"
#define kArgusVersionDone          @"ArgusVersionDone"
#define kArgusApiVersionDone       @"ArgusApiVersionDone"
#define kArgusEpgPartialSearchDone @"ArgusEpgPartialSearchDone"


@interface Argus : NSObject <UpcomingProgrammesDataSource>

// Channels keyed by ChannelId; NewChannels is about to replace Channels when getChannels is called
@property (nonatomic, retain) NSMutableDictionary *ChannelsKeyedByChannelId;
@property (nonatomic, retain) NSMutableDictionary *NewChannelsKeyedByChannelId;

// same, but keyed by GuideChannelId instead
@property (nonatomic, retain) NSMutableDictionary *ChannelsKeyedByGuideChannelId;
@property (nonatomic, retain) NSMutableDictionary *NewChannelsKeyedByGuideChannelId;


@property (nonatomic, retain) NSMutableArray *SearchResults;

@property (nonatomic, retain) NSMutableArray *LiveStreams;
@property (nonatomic, retain) NSMutableArray *ActiveRecordings;

@property (nonatomic, retain) ArgusCategories *Categories;

@property (nonatomic, retain) ArgusRecordingDisksInfo *RecordingDisksInfo;

@property (nonatomic, retain) ArgusRecordingFileFormats *RecordingFileFormats;

//@property (nonatomic, retain) NSMutableDictionary *UpcomingProgrammesKeyedByUniqueIdentifier;

@property (nonatomic, retain) ArgusUpcomingProgrammes *UpcomingProgrammes;
@property (nonatomic, retain) ArgusUpcomingRecordings *UpcomingRecordings;

@property (nonatomic, retain) ArgusSchedules *Schedules;
@property (nonatomic, retain) ArgusSchedule *EmptySchedule;

//@property (nonatomic, retain) ArgusChannelGroups *ChannelGroups;
//@property (nonatomic, retain) NSMutableArray *TvChannelGroups;
//@property (nonatomic, retain) NSMutableArray *RadioChannelGroups;

// selected types
//@property (nonatomic, assign) ArgusChannelType SelectedChannelType;
//@property (nonatomic, retain) ArgusChannelGroup *SelectedChannelGroup;

@property (nonatomic, retain) ArgusChannelGroups *ChannelGroups;

// this one is used in Schedules, obviously
@property (nonatomic, assign) ArgusScheduleType SelectedScheduleType;


// Argus version number, once fetched
@property (nonatomic, retain) NSString *Version;

-(void)checkApiVersion:(NSInteger)version;
-(void)getVersion;
-(void)getLiveStreams;
-(void)getChannels;
-(ArgusConnection *)getChannelsForChannelType:(ArgusChannelType)ChannelType;
//-(void)getChannelGroups;
-(void)getActiveRecordings;
-(void)getRecordingDisksInfo;
-(void)getEmptySchedule;

//-(void)getUpcomingProgrammes;

@end
