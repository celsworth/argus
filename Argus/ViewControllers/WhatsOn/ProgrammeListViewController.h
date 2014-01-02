//
//  ProgrammeListViewController.h
//  Argus
//
//  Created by Chris Elsworth on 01/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusChannel.h"

#define FETCH_PERIOD_INITIAL 28800
#define FETCH_PERIOD_SUBSEQUENT 28800

@interface ProgrammeListViewController : UITableViewController {
}

@property (nonatomic, retain) ArgusChannel *Channel;

@property (nonatomic, retain) NSDate *fetchStart;
@property (nonatomic, retain) NSDate *fetchEnd;

@property (nonatomic, assign) BOOL isFetchingMore;

@property (nonatomic, retain) NSTimer *autoRedrawTimer;

@end
