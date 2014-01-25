//
//  ArgusProgramme.h
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

//#import <Foundation/Foundation.h>

#import "ArgusBaseObject.h"
#import "ArgusConnection.h"

// called by tables to decide what background colour to assign for a programme
typedef enum {
	ArgusProgrammeBgColourScheduled = 1,
	ArgusProgrammeBgColourCancelled = 2,
	ArgusProgrammeBgColourOnNow     = 3,
	ArgusProgrammeBgColourStandard  = 4, // table makes it's own mind up based on indexPath.row
} ArgusProgrammeBgColour;


#define kArgusProgrammeDone                     @"ArgusProgrammeDone"

#define kArgusProgrammeOnAirStatusChanged       @"ArgusProgrammeOnAirStatusChanged"
#define kArgusProgrammeUpcomingProgrammeChanged @"kArgusProgrammeUpcomingProgrammeChanged"


@class ArgusChannel;
@class ArgusUpcomingProgramme;
@interface ArgusProgramme : ArgusBaseObject

@property (nonatomic, retain) ArgusChannel *Channel;

@property (nonatomic, assign) BOOL fullDetailsDone;

// runs when the programme starts and ends
@property (nonatomic, retain) NSTimer *programmeStartOrEndTimer;


// caches
@property (nonatomic, retain) ArgusUpcomingProgramme *upcomingProgramme;
@property (nonatomic, assign) BOOL isOnNow;
@property (nonatomic, assign) BOOL hasFinished;

-(void)setChannel:(ArgusChannel *)c;
-(ArgusChannel *)Channel;


// class methods
+(UIColor *)bgColourStdOdd;
+(UIColor *)bgColourStdEven;
+(UIColor *)bgColourEpgCell;
+(UIColor *)bgColourUpcomingRec;
+(UIColor *)bgColourOnNow;

+(UIColor *)fgColourStd;
+(UIColor *)fgColourAlreadyShown;

-(id)initWithDictionary:(NSDictionary *)input;

-(void)getFullDetails;

-(NSString *)uniqueIdentifier;

@end