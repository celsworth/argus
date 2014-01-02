//
//  ArgusScheduleIcons.h
//  Argus
//
//  Created by Chris Elsworth on 12/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArgusUpcomingProgramme.h"

@interface ArgusScheduleIcons : NSObject

@property (nonatomic, retain) UIImage *spriteImage;
@property (nonatomic, assign) CGImageRef spriteImageCG;
@property (nonatomic, assign) CGFloat scale;

+(id)sharedInstance;

-(UIImage *)iconFor:(ArgusUpcomingProgramme *)UpcomingProgramme;

@end
