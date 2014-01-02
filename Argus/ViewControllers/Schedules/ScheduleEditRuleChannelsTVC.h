//
//  ScheduleEditRuleChannelsTVC.h
//  Argus
//
//  Created by Chris Elsworth on 29/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArgusSchedule.h"

@interface ScheduleEditRuleChannelsTVC : UITableViewController

@property (nonatomic, retain) IBOutlet UISegmentedControl *matchtype;

// pointer to what we're editing passed in
@property (nonatomic, retain) ArgusSchedule *Schedule;
@property (nonatomic, retain) ArgusScheduleRule *Rule;

-(IBAction)matchTypeChanged:(id)sender;

@end
