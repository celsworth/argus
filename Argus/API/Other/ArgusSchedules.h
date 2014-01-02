//
//  ArgusSchedules.h
//  Argus
//
//  Created by Chris Elsworth on 02/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ArgusGlobalDefinitions.h"

@interface ArgusSchedules : NSObject
@property (nonatomic, retain) NSMutableDictionary *TvSchedules;
@property (nonatomic, retain) NSMutableDictionary *RadioSchedules;

@property (nonatomic, retain) NSMutableDictionary *SchedulesKeyedByScheduleId;
@property (nonatomic, retain) NSMutableDictionary *tmpSchedulesKeyedByScheduleId;

@property (nonatomic, assign) ArgusChannelType fetchingChannelType;

@property (nonatomic, assign) BOOL RecordingsDone;
@property (nonatomic, assign) BOOL AlertsDone;
@property (nonatomic, assign) BOOL SuggestionsDone;

-(void)getSchedulesForSelectedChannelType;

-(NSMutableArray *)schedulesForChannelType:(ArgusChannelType)channelType scheduleType:(ArgusScheduleType)scheduleType;
//-(void)setSchedules:(NSArray *)arr forChannelType:(ArgusChannelType)channelType scheduleType:(ArgusScheduleType)scheduleType;

@end
