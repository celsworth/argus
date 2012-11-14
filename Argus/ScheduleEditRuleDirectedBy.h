//
//  ScheduleEditRuleDirectedBy.h
//  Argus
//
//  Created by Chris Elsworth on 30/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArgusSchedule.h"

@interface ScheduleEditRuleDirectedBy : UITableViewController

// pointer to field that we're editing passed in
@property (nonatomic, retain) ArgusScheduleRule *Rule;

@end
