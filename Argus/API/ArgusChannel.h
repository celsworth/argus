//
//  ArgusChannel.h
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

//#import <Foundation/Foundation.h>

#import "ArgusBaseObject.h"
#import "ArgusChannelLogo.h"
#import "ArgusProgramme.h"


@class ArgusChannelLogo;

@interface ArgusChannel : ArgusBaseObject

@property (nonatomic, retain) ArgusChannelLogo *Logo;

// for ProgrammeList
@property (nonatomic, retain) NSMutableArray *Programmes;

// for current and next, populated by WhatsOn
@property (nonatomic, retain) ArgusProgramme *CurrentProgramme;
@property (nonatomic, retain) ArgusProgramme *NextProgramme;

-(id)initWithDictionary:(NSDictionary *)input;

-(void)getProgrammesFrom:(NSDate *)from to:(NSDate *)to;

@end
