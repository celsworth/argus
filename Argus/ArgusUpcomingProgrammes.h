//
//  ArgusUpcomingProgrammes.h
//  Argus
//
//  Created by Chris Elsworth on 02/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ArgusGlobalDefinitions.h"

#define kArgusUpcomingProgrammesDone @"ArgusUpcomingProgrammesDone"

@class ArgusSchedule;
@interface ArgusUpcomingProgrammes : NSObject

// DO NOT RETAIN THIS OBJECT.
// it is our parent ArgusSchedule, passed in, if we retain it there'll be a circular retain and we'll never get freed
@property (nonatomic, weak) ArgusSchedule *IsForSchedule;
@property (nonatomic, assign) ArgusScheduleType IsForScheduleType;

// arrays of ArgusUpcomingProgramme objects
@property (nonatomic, retain) NSMutableArray *UpcomingRecordings;

@property (nonatomic, retain) NSMutableArray *UpcomingAlerts;
@property (nonatomic, retain) NSMutableArray *UpcomingSuggestions;

@property (nonatomic, retain) NSMutableDictionary *UpcomingProgrammesKeyedByUniqueIdentifier;
@property (nonatomic, retain) NSMutableDictionary *tmpUpcomingProgrammesKeyedByUniqueIdentifier;

//@property (nonatomic, retain) NSMutableDictionary *UpcomingProgrammesKeyedByUpcomingProgramId;
//@property (nonatomic, retain) NSMutableDictionary *tmpUpcomingProgrammesKeyedByUpcomingProgramId;

@property (nonatomic, assign) BOOL RecordingsDone;
@property (nonatomic, assign) BOOL AlertsDone;
@property (nonatomic, assign) BOOL SuggestionsDone;

-(id)init;
-(id)initWithSchedule:(ArgusSchedule *)schedule;

-(void)redoLocalNotifications;

// called by [ArgusSchedule getUpcomingProgrammes]
-(void)getUpcomingProgrammesForSchedule;

// called by [Argus getUpcomingProgrammes]
-(void)getUpcomingProgrammes;

-(NSMutableArray *)upcomingProgrammesForScheduleType:(ArgusScheduleType)scheduleType;
-(NSMutableArray *)upcomingProgrammesForSchedule;

@end


// assign this protocol to anything that has an ArgusUpcomingProgrammes object in it
// so far this is Argus and ArgusSchedule
@protocol UpcomingProgrammesDataSource <NSObject>
@property (nonatomic, retain) ArgusUpcomingProgrammes *UpcomingProgrammes;
-(void)getUpcomingProgrammes;
@end