//
//  UpcomingProgrammeEditPreRecordTVC.h
//  Argus
//
//  Created by Chris Elsworth on 11/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusUpcomingProgramme.h"

@interface UpcomingProgrammeEditPreRecordTVC : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>

//@property (nonatomic, retain) ArgusUpcomingProgramme *Programme;
@property (nonatomic, retain) NSString *UpcomingProgramId;


@property (nonatomic, weak) IBOutlet UISwitch *active;
@property (nonatomic, weak) IBOutlet UIPickerView *picker;

// this class is used for Pre and Post record
@property (nonatomic, assign) ArgusScheduleEditType editType;

@end
