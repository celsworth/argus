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
	// this records which index position various actionsheet buttons are in
	
	// record AS
	NSInteger actionSheetRecordOnceIndex;
	NSInteger actionSheetRecordDailyIndex;
	NSInteger actionSheetRecordWeeklyIndex;
	NSInteger actionSheetRecordAnyTimeIndex;
	
	// options AS
	NSInteger actionSheetEditScheduleIndex;
	NSInteger actionSheetEditProgrammeIndex;
	
	// search AS
	NSInteger actionSheetSearchImdbIndex;
	NSInteger actionSheetSearchTvcomIndex;
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

// keep track of which actionsheet is showing, so our delegate function works properly
@property (nonatomic, retain) UIActionSheet *recordActionSheet;
@property (nonatomic, retain) UIActionSheet *editActionSheet;
@property (nonatomic, retain) UIActionSheet *searchActionSheet;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *optionsButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButtonItem;


@property (nonatomic, retain) ArgusProgramme *Programme;

@property (nonatomic, retain) ArgusUpcomingProgramme *UpcomingProgramme;
@property (nonatomic, weak) IBOutlet UIImageView *upcomingIcon;

@property (nonatomic, retain) NSTimer *autoRedrawTimer;


- (IBAction)optionsButtonPressed:(id)sender;
- (IBAction)searchButtonPressed:(id)sender;

@end
