//
//  ProgrammeDetailsViewController.h
//  Argus
//
//  Created by Chris Elsworth on 02/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "ArgusUpcomingProgramme.h" // also includes ArgusProgramme
#include "ArgusChannel.h"
#include "ArgusSchedule.h"

@interface ProgrammeDetailsViewController : UIViewController <UIActionSheetDelegate> {
}

@property (nonatomic, weak) IBOutlet UIScrollView *sv;

@property (nonatomic, weak) IBOutlet UILabel *progtitle;
@property (nonatomic, weak) IBOutlet UILabel *subtitle;
@property (nonatomic, weak) IBOutlet UILabel *description;

@property (nonatomic, weak) IBOutlet UILabel *timeStart;
@property (nonatomic, weak) IBOutlet UILabel *timeDuration;
@property (nonatomic, weak) IBOutlet UILabel *timeEnd;

@property (nonatomic, weak) IBOutlet UILabel *date;
@property (nonatomic, weak) IBOutlet UILabel *dateSubtext;

@property (nonatomic, weak) IBOutlet UILabel *airChannel;
@property (nonatomic, weak) IBOutlet UIImageView *airChannelLogo;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *detailsLoading;

@property (nonatomic, weak) IBOutlet UIProgressView *pctDone;

@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *searchButton; // iPhone only

// keep track of which actionsheet is showing, so our delegate function works properly
@property (nonatomic, retain) UIActionSheet *recordActionSheet;
@property (nonatomic, retain) UIActionSheet *searchActionSheet;

//@property (nonatomic, weak) IBOutlet UIButton *alertButton;
@property (nonatomic, weak) IBOutlet UIButton *searchIMDbButton; // iPad only
@property (nonatomic, weak) IBOutlet UIButton *searchTvComButton; // iPad only

@property (nonatomic, weak) IBOutlet UIButton *editScheduleButton;
@property (nonatomic, weak) IBOutlet UIButton *editProgrammeButton;

@property (nonatomic, weak) IBOutlet UIView *recordButtons;

@property (nonatomic, retain) ArgusProgramme *Programme;

@property (nonatomic, retain) ArgusUpcomingProgramme *UpcomingProgramme;
@property (nonatomic, weak) IBOutlet UIImageView *upcomingIcon;

@property (nonatomic, retain) NSTimer *autoRedrawTimer;

-(IBAction)recordPressed:(id)sender;
-(IBAction)searchPressed:(id)sender;
-(IBAction)searchIMDbPressed:(id)sender;
-(IBAction)searchTvComPressed:(id)sender;

@end
