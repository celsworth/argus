//
//  LoadingPageTVC.h
//  Argus
//
//  Created by Chris Elsworth on 31/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

@interface LoadingPageTVC : UITableViewController

@property (nonatomic, weak) IBOutlet UITableViewCell *retryButtonCell;
@property (nonatomic, weak) IBOutlet UIButton *retryButton;


@property (nonatomic, weak) IBOutlet UITableViewCell *apiVersionCell;

@property (nonatomic, weak) IBOutlet UITableViewCell *ChannelGroupsCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *ChannelsCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *UpcomingProgrammesCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *UpcomingRecordingsCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *RecordingFileFormatsCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *SchedulesCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *EmptyScheduleCell;


@property (nonatomic, assign) NSInteger Waiting;

@end
