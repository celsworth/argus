//
//  ArgusUpcomingRecording.h
//  Argus
//
//  Created by Chris Elsworth on 04/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusUpcomingProgramme.h"
#import "ArgusCardChannelAllocation.h"

@interface ArgusUpcomingRecording : ArgusProgramme

@property (nonatomic, retain) ArgusUpcomingProgramme *UpcomingProgramme;

@property (nonatomic, retain) ArgusCardChannelAllocation *CardChannelAllocation;

// ConflictingPrograms?


-(NSString *)uniqueIdentifier;

@end
