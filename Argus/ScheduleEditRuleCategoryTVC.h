//
//  ScheduleEditRuleCategoryTVC.h
//  Argus
//
//  Created by Chris Elsworth on 16/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusSchedule.h"

#import "ArgusBaseObject.h"

@interface ScheduleEditRuleCategoryTVC : UITableViewController

// the ScheduleId of the rule we're editing, so we work even when schedule is refreshed?
@property (nonatomic, retain) ArgusScheduleRule *Rule;

@end
