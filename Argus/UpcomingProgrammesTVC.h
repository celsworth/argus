//
//  UpcomingProgrammesTVC.h
//  Argus
//
//  Created by Chris Elsworth on 26/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SelectUpcomingTypeTVC.h"

#import "ArgusUpcomingProgrammes.h"
#import "ArgusSchedule.h"

@interface UpcomingProgrammesTVC: UITableViewController <SelectUpcomingTypeDelegate>

@property (nonatomic, retain) id <UpcomingProgrammesDataSource> upcds;
@property (nonatomic, retain) ArgusSchedule *Schedule;

@property (nonatomic, retain) UIPopoverController *popoverController;

-(IBAction)refreshPressed:(id)sender;

@property (nonatomic, assign) NSInteger UpcomingNavigationCount;

@end
