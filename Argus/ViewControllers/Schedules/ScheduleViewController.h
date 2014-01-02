//
//  ScheduleViewController.h
//  Argus
//
//  Created by Chris Elsworth on 05/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusSchedule.h"

@interface ScheduleViewController : UITableViewController <UIActionSheetDelegate> {
}

//@property (nonatomic, weak) IBOutlet UITableViewCell *title;
@property (nonatomic, weak) IBOutlet UITextField *title;

@property (nonatomic, weak) IBOutlet UISwitch *active;

@property (nonatomic, weak) IBOutlet UIStepper *priorityStepper;
@property (nonatomic, weak) IBOutlet UILabel *priority;

@property (nonatomic, weak) IBOutlet UILabel *keep;

@property (nonatomic, weak) IBOutlet UISegmentedControl *type;

@property (nonatomic, weak) IBOutlet UITableViewCell *prerec;
@property (nonatomic, weak) IBOutlet UITableViewCell *postrec;

@property (nonatomic, weak) IBOutlet UITableViewCell *rules;

@property (nonatomic, weak) IBOutlet UITableViewCell *fileformat;

@property (nonatomic, weak) IBOutlet UITableViewCell *del;

//@property (nonatomic, retain) UIButton *delbtn;

@property (nonatomic, retain) ArgusSchedule *Schedule;


-(IBAction)scheduleTypeSegmentChanged:(id)sender;

-(IBAction)titleReturn:(id)sender;

-(IBAction)activeChanged:(id)sender;

-(IBAction)saveButtonPressed:(id)sender;

@end
