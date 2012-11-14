//
//  ScheduleEditRulesTitleTVC.h
//  Argus
//
//  Created by Chris Elsworth on 15/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArgusSchedule.h"

@interface ScheduleEditRuleTitleTVC : UITableViewController

@property (nonatomic, weak) IBOutlet UISwitch *active;
@property (nonatomic, weak) IBOutlet UISegmentedControl *matchwhat;
@property (nonatomic, weak) IBOutlet UISegmentedControl *matchtype;
@property (nonatomic, weak) IBOutlet UITextField *textfield;

// pointer to field that we're editing passed in
@property (nonatomic, retain) ArgusScheduleRule *Rule;

-(IBAction)activeChanged:(id)sender;
-(IBAction)matchTypeChanged:(id)sender;
-(IBAction)textFieldChanged:(id)sender;


-(IBAction)titleReturn:(id)sender;

@end
