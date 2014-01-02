//
//  ProgrammeSummaryCell.h
//  Argus
//
//  Created by Chris Elsworth on 05/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusUpcomingProgramme.h"
#import "ArgusActiveRecording.h"

@interface ProgrammeSummaryCell : UITableViewCell

@property (nonatomic, retain) ArgusProgramme *Programme;
@property (nonatomic, retain) ArgusUpcomingProgramme *UpcomingProgramme;
@property (nonatomic, retain) ArgusActiveRecording *ActiveRecording;

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *time;
//@property (nonatomic, weak) IBOutlet UILabel *desc;
@property (nonatomic, weak) IBOutlet UILabel *priority;

// upcoming programme icon
@property (nonatomic, weak) IBOutlet UIImageView *icon;

@property (nonatomic, weak) IBOutlet UIImageView *chan_image;
@property (nonatomic, weak) IBOutlet UILabel *chan;

@property (nonatomic, weak) IBOutlet UILabel *card;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;

-(void)populateCellWithActiveRecording:(ArgusActiveRecording *)_ActiveRecording;
-(void)populateCellWithUpcomingProgramme:(ArgusUpcomingProgramme *)_UpcomingProgramme;
-(void)populateCellWithProgramme:(ArgusProgramme *)_Programme;

@end
