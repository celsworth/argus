//
//  ArgusChannelGroup.h
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusBaseObject.h"

#define kArgusChannelGroupCurrentAndNextDone @"ArgusChannelGroupCurrentAndNextDone"
#define kArgusChannelGroupChannelsDone       @"ArgusChannelGroupChannelsDone"

@interface ArgusChannelGroup : ArgusBaseObject
// special case, we have an initWithString, do we use it?
@property (nonatomic, retain) NSString *ChannelGroupId;

@property (nonatomic, retain) NSMutableArray *Channels;

@property (nonatomic, retain) NSMutableArray *CurrentAndNext;
@property (nonatomic, retain) NSDate *earliestCurrentStopTime;

@property (nonatomic, retain) NSMutableDictionary *ProgrammeArraysKeyedByChannelId;


-(id)initWithString:(NSString *)ChannelGroupId;
-(id)initWithDictionary:(NSDictionary *)input;

-(void)getChannels;
-(void)getCurrentAndNext;
-(void)getProgrammesFrom:(NSDate *)from to:(NSDate *)to;

@end
