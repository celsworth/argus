//
//  ArgusActiveRecording.h
//  Argus
//
//  Created by Chris Elsworth on 11/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusBaseObject.h"
#import "ArgusUpcomingProgramme.h"

#define kArgusAbortActiveRecordingDone @"ArgusAbortActiveRecordingDone"

@interface ArgusActiveRecording : ArgusBaseObject
@property (nonatomic, retain) ArgusUpcomingProgramme *UpcomingProgramme;
//CardChannelAllocation ignored for now
//ConflictingPrograms ignored for now

// our own metadata
// this is set to YES when AbortActiveRecording has been sent
// then back to NO when we get confirmation.
// Status->ActiveRecordings uses this to update it's table accordingly
@property (nonatomic, retain) NSNumber *StoppingAsNumber;

// public getter/setter for StoppingAsNumber, translated to BOOL
-(BOOL)Stopping;
-(void)setStopping:(BOOL)val;

-(id)initWithDictionary:(NSDictionary *)input;

-(void)AbortActiveRecording;


@end
