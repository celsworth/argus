//
//  SelectUpcomingTypeTVC.h
//  Argus
//
//  Created by Chris Elsworth on 10/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusBaseObject.h" // for ArgusScheduleType


@class SelectUpcomingTypeTVC;
@protocol SelectUpcomingTypeDelegate <NSObject>
-(void)selectUpcomingTypeViewController:(SelectUpcomingTypeTVC *)sutvc changedSelectionToScheduleType:(ArgusScheduleType)scheduleType;
@end

@interface SelectUpcomingTypeTVC : UITableViewController

@property (nonatomic, weak) IBOutlet UITableViewCell *recordings;
@property (nonatomic, weak) IBOutlet UITableViewCell *suggestions;
@property (nonatomic, weak) IBOutlet UITableViewCell *alerts;

@property (nonatomic, retain) id <SelectUpcomingTypeDelegate> delegate;
@property (nonatomic, retain) UIPopoverController *popoverController;

-(IBAction)didPressDone:(id)sender;

@end
