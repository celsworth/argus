//
//  StatusTVC.h
//  Argus
//
//  Created by Chris Elsworth on 05/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	ArgusStatusTableSectionDiskUsage        = 0,
	ArgusStatusTableSectionActiveRecordings = 1,
	ArgusStatusTableSectionLiveStreams      = 2,
} ArgusStatusTableSection;


@interface StatusTVC : UITableViewController

// true when we're waiting for data to come back (spinny displayed)
@property (nonatomic, assign) BOOL LoadingDiskUsage;
@property (nonatomic, assign) BOOL LoadingActiveRecordings;
@property (nonatomic, assign) BOOL LoadingLiveStreams;

@property (nonatomic, retain) NSTimer *autoRedrawTimer;

-(IBAction)refreshPressed:(id)sender;

@end
