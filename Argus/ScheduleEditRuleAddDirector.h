//
//  ScheduleEditRuleAddDirector.h
//  Argus
//
//  Created by Chris Elsworth on 30/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArgusSchedule.h"

@interface ScheduleEditRuleAddDirector : UITableViewController

@property (nonatomic, retain) ArgusScheduleRule *Rule;

@property (nonatomic, weak) IBOutlet UITextField *addbox;


-(IBAction)addBoxEnded:(id)sender;
-(IBAction)addBoxDonePressed:(id)sender;

@end
