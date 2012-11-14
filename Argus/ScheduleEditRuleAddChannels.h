//
//  ScheduleEditRuleAddChannels.h
//  Argus
//
//  Created by Chris Elsworth on 29/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectChannelGroupViewController.h"

#import "ArgusSchedule.h"

@interface ScheduleEditRuleAddChannels : UITableViewController <SelectChannelGroupDelegate>

@property (nonatomic, retain) Argus *localArgus;

@property (nonatomic, retain) ArgusSchedule *Schedule;
@property (nonatomic, retain) ArgusScheduleRule *Rule;

-(void)didSelectChannelGroup:(ArgusChannelGroup *)ChannelGroup;

@end
