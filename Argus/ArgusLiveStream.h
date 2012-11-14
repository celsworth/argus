//
//  ArgusLiveStream.h
//  Argus
//
//  Created by Chris Elsworth on 10/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusBaseObject.h"
#import "ArgusChannel.h"


#define kArgusStopLiveStreamDone @"ArgusStopLiveStreamDone"


@interface ArgusLiveStream : ArgusBaseObject

@property (nonatomic, retain) ArgusChannel *Channel;

// our own metadata
// this is set to YES when StopLiveStream has been sent
// then back to NO when we get confirmation.
// Status->LiveStreams uses this to update it's table accordingly
@property (nonatomic, retain) NSNumber *StoppingAsNumber;

// public getter/setter for StoppingAsNumber, translated to BOOL
-(BOOL)Stopping;
-(void)setStopping:(BOOL)val;


-(id)initWithDictionary:(NSDictionary *)input;

-(void)StopLiveStream;


@end
