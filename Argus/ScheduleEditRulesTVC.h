//
//  ScheduleEditRulesTVC.h
//  Argus
//
//  Created by Chris Elsworth on 15/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArgusSchedule.h"

@interface ScheduleEditRulesTVC : UITableViewController {
}

@property (nonatomic, retain) ArgusSchedule *Schedule;

@property (nonatomic, weak) IBOutlet UITableViewCell *title;
@property (nonatomic, weak) IBOutlet UITableViewCell *subtitle;
@property (nonatomic, weak) IBOutlet UITableViewCell *episode_number;
@property (nonatomic, weak) IBOutlet UITableViewCell *description;
@property (nonatomic, weak) IBOutlet UITableViewCell *program_info;

@property (nonatomic, weak) IBOutlet UITableViewCell *on_date;
@property (nonatomic, weak) IBOutlet UITableViewCell *days_of_week;
@property (nonatomic, weak) IBOutlet UITableViewCell *around_time;
@property (nonatomic, weak) IBOutlet UITableViewCell *starts_between;

@property (nonatomic, weak) IBOutlet UITableViewCell *neew_episodes;
@property (nonatomic, weak) IBOutlet UITableViewCell *unique_titles;
@property (nonatomic, weak) IBOutlet UITableViewCell *skip_repeats;

@property (nonatomic, weak) IBOutlet UITableViewCell *channels;
@property (nonatomic, weak) IBOutlet UITableViewCell *categories;
@property (nonatomic, weak) IBOutlet UITableViewCell *directed_by;
@property (nonatomic, weak) IBOutlet UITableViewCell *with_actor;



-(void)redraw;

@end
