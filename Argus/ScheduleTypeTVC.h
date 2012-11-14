//
//  ScheduleTypeTVC.h
//  Argus
//
//  Created by Chris Elsworth on 10/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArgusBaseObject.h"

@protocol ArgusSelectedScheduleTypesChanger <NSObject>
-(void)selectionChangedToChannelType:(ArgusChannelType)channelType scheduleType:(ArgusScheduleType)scheduleType;
@end

@interface ScheduleTypeTVC : UITableViewController {
}

@property (nonatomic, weak) IBOutlet UITableViewCell *tv;
@property (nonatomic, weak) IBOutlet UITableViewCell *radio;
@property (nonatomic, weak) IBOutlet UITableViewCell *recordings;
@property (nonatomic, weak) IBOutlet UITableViewCell *suggestions;
@property (nonatomic, weak) IBOutlet UITableViewCell *alerts;

@property (nonatomic, retain) id <ArgusSelectedScheduleTypesChanger> delegate;
@property (nonatomic, retain) UIPopoverController *popoverController;

-(IBAction)didPressDone:(id)sender;

@end
