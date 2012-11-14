//
//  ArgusScheduleRecordedProgram.h
//  Argus
//
//  Created by Chris Elsworth on 17/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusBaseObject.h"

#define kArgusScheduleRecordedProgramRemoveFromPRHDone @"kArgusScheduleRecordedProgramRemoveFromPRHDone"


@interface ArgusScheduleRecordedProgram : ArgusBaseObject

@property (nonatomic, assign) BOOL IsRemovingFromPRH;
-(void)removeFromPRH;


@end
