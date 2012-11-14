//
//  FirstViewController.h
//  Argus
//
//  Created by Chris Elsworth on 28/02/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EpgGridDefines.h"
#import "EpgGridLabel.h"
#import "EpgGridChannel.h"
#import "ArgusChannelGroup.h"
#import "SelectChannelGroupViewController.h"

#import "EpgGridCalendarPickerVC.h"

@interface EpgGridTVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, SelectChannelGroupDelegate, EpgGridLabelDelegate, EpgGridChannelDelegate, TKCalendarMonthViewDelegate, UIActionSheetDelegate> {
    //IBOutlet UIScrollView *sv1;
	IBOutlet UIScrollView *sv2;
    IBOutlet UITableView *tv;
	
	IBOutlet UITableView *tv_chanlogos;
}

// bottom-of-screen buttons for date selection
// outlet for current day so we can change it's title
@property (nonatomic, weak) IBOutlet UIBarButtonItem *curDay;
-(IBAction)prevDayPressed:(id)sender;
-(IBAction)curDayPressed:(id)sender; // calendar popup?
-(IBAction)nextDayPressed:(id)sender;

@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;

@property (nonatomic, retain) NSTimer *autoUpdateTimer;

@property (nonatomic, assign) NSInteger rowHeight;

@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, retain) UIView *timeRow;
@property (nonatomic, retain) UIView *timeRow2;
@property (nonatomic, retain) UIView *curTimeLine;

@property (nonatomic, retain) NSMutableDictionary *labelsByProgrammeUniqueIdentifier;
@property (nonatomic, retain) NSMutableDictionary *labelsByIndexPath;
@property (nonatomic, retain) NSMutableDictionary *viewsByChannelId;

@property (nonatomic, retain) NSDate *epgStartTime;
@property (nonatomic, assign) float pps;

@property (nonatomic, assign) NSInteger RequestsOutstanding;
@property (nonatomic, assign) NSInteger RequestsTotal;

-(IBAction)refreshPressed:(id)sender;

-(void)didSelectChannelGroup:(ArgusChannelGroup *)ChannelGroup;

@end
