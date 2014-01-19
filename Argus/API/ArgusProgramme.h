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


#define kArgusProgrammeDone                 @"ArgusProgrammeDone"

@class ArgusChannel;
@class ArgusUpcomingProgramme;
@interface ArgusProgramme : ArgusBaseObject

@property (nonatomic, retain) ArgusChannel *Channel;

@property (nonatomic, assign) BOOL fullDetailsDone;

// caches
@property (nonatomic, retain) NSDate *StartTime;
@property (nonatomic, retain) NSDate *StopTime;
@property (nonatomic, retain) ArgusUpcomingProgramme *UpcomingProgrammeCached;
@property (nonatomic, assign) BOOL UpcomingProgrammeHaveCached;

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

//-(BOOL)populateSelfFromDictionary:(NSDictionary *)input;

-(void)getFullDetails;


-(NSString *)uniqueIdentifier;

-(ArgusUpcomingProgramme *)upcomingProgramme;

-(BOOL)isOnNow;

@end