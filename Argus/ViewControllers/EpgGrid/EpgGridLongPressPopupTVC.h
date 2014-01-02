//
//  EpgGidLongPressPopupTVC.h
//  Argus
//
//  Created by Chris Elsworth on 11/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusProgramme.h"
#import "ArgusSchedule.h"

@interface EpgGridLongPressPopupTVC : UITableViewController

@property (nonatomic, retain) ArgusProgramme *Programme;
@property (nonatomic, retain) ArgusSchedule *emptySchedule;


@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, weak) IBOutlet UITableViewCell *oneTouchRecordCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *searchIMDbCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *searchTvComCell;


-(IBAction)didPressDone:(id)sender;
@end
