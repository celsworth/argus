//
//  ScheduleViewPRHTVC.h
//  Argus
//
//  Created by Chris Elsworth on 17/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusGlobalDefinitions.h"

@interface ScheduleViewPRHTVC : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, retain) ArgusGuid *ScheduleId;


-(IBAction)refreshPressed:(id)sender;

@end