//
//  ScheduleEditPreRecordTVC.h
//  Argus
//
//  Created by Chris Elsworth on 27/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ArgusSchedule.h"

@interface ScheduleEditPreRecordTVC : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, retain) ArgusSchedule *Schedule;

@property (nonatomic, weak) IBOutlet UISwitch *active;
@property (nonatomic, weak) IBOutlet UIPickerView *picker;

// this class is used for Pre and Post record
@property (nonatomic, assign) ArgusScheduleEditType editType;

@end
