//
//  ScheduleEditOnDateTVC.h
//  Argus
//
//  Created by Chris Elsworth on 27/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArgusSchedule.h"

#import "TKCalendarMonthView.h"

@interface ScheduleEditRuleOnDateTVC : UITableViewController

// pointer to field that we're editing passed in
@property (nonatomic, retain) ArgusScheduleRule *Rule;

@property (nonatomic, weak) IBOutlet UISwitch *active;
@property (nonatomic, weak) IBOutlet UIDatePicker *datepicker;

@property (nonatomic, weak) IBOutlet UIView *cell;

@property (nonatomic, retain) TKCalendarMonthView *cmv;

-(IBAction)activeChanged:(id)sender;
-(IBAction)datePickerValueChanged:(id)sender;

@end
