//
//  ScheduleEditRuleOnDays.h
//  Argus
//
//  Created by Chris Elsworth on 27/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArgusSchedule.h"

@interface ScheduleEditRuleDaysOfWeekTVC : UITableViewController

@property (nonatomic, retain) NSMutableArray *weekdays;

// pointer to field that we're editing passed in
@property (nonatomic, retain) ArgusScheduleRule *Rule;

-(IBAction)buttonPressedNone:(id)sender;
-(IBAction)buttonPressedWDays:(id)sender;
-(IBAction)buttonPressedWEnds:(id)sender;

@end
