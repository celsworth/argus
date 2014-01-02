//
//  ArgusUpcomingRecordings.h
//  Argus
//
//  Created by Chris Elsworth on 04/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ArgusGlobalDefinitions.h"

#define kArgusUpcomingRecordingsDone @"ArgusUpcomingRecordingsDone"

@interface ArgusUpcomingRecordings : NSObject

@property (nonatomic, retain) NSMutableArray *UpcomingRecordings;

// these are used to find an ArgusUpcomingRecording from an ArgusUpcomingProgramme
@property (nonatomic, retain) NSMutableDictionary *UpcomingRecordingsKeyedByUpcomingProgramId;

-(void)getUpcomingRecordings;

// should not be called externally, hence not declared
//-(void)setUpcomingProgrammes:(NSArray *)arr forScheduleType:(ArgusScheduleType)scheduleType;

@end

// assign this protocol to anything that has an ArgusUpcomingRecordings object in it
// so far this is Argus and ArgusSchedule
@protocol UpcomingRecordingsDataSource <NSObject>
@property (nonatomic, retain) ArgusUpcomingRecordings *UpcomingRecordings;
-(void)getUpcomingRecordings;
@end