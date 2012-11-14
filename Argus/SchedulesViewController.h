//
//  SchedulesViewController.h
//  Argus
//
//  Created by Chris Elsworth on 05/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ScheduleViewController.h"
#import "ArgusSchedule.h"
#import "ScheduleTypeTVC.h"
#import "LoadingSpinner.h"


@interface SchedulesViewController : UITableViewController <ArgusSelectedScheduleTypesChanger>

@property (nonatomic, retain) UIPopoverController *popoverController;

-(void)selectionChangedToChannelType:(ArgusChannelType)channelType scheduleType:(ArgusScheduleType)scheduleType;

-(IBAction)newSchedule:(id)sender;
-(IBAction)refreshSchedules:(id)sender;

@end
