//
//  ScheduleEditKeepTVC.h
//  Argus
//
//  Created by Chris Elsworth on 11/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArgusSchedule.h"

@interface ScheduleEditKeepTVC : UITableViewController

@property (nonatomic, retain) ArgusSchedule *Schedule;

@property (nonatomic, weak) IBOutlet UILabel *KeepUntilValue;
@property (nonatomic, weak) IBOutlet UIStepper *KeepUntilValueStepper;
@property (nonatomic, weak) IBOutlet UIStepper *KeepUntilValueStepperTen;

@property (nonatomic, weak) IBOutlet UITableViewCell *space;
@property (nonatomic, weak) IBOutlet UITableViewCell *days;
@property (nonatomic, weak) IBOutlet UITableViewCell *recent;
@property (nonatomic, weak) IBOutlet UITableViewCell *watched;
@property (nonatomic, weak) IBOutlet UITableViewCell *forever;


@end
