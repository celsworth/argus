//
//  ScheduleEditRuleAroundTimeTVC.h
//  Argus
//
//  Created by Chris Elsworth on 27/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArgusSchedule.h"

@interface ScheduleEditRuleAroundTimeTVC : UITableViewController

// pointer to field that we're editing passed in
@property (nonatomic, retain) ArgusScheduleRule *Rule;

@property (nonatomic, weak) IBOutlet UISwitch *active;
@property (nonatomic, weak) IBOutlet UISegmentedControl *from_to_picker;
@property (nonatomic, weak) IBOutlet UIDatePicker *datepicker;

@property (nonatomic, retain) NSDate *fromDate;
@property (nonatomic, retain) NSDate *toDate;

// can be AroundTime or StartingBetween
@property (nonatomic, assign) ArgusScheduleEditType editType;

-(IBAction)activeChanged:(id)sender;
-(IBAction)fromToChanged:(id)sender;
-(IBAction)datePickerValueChanged:(id)sender;

@end
