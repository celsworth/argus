//
//  WhatsOnViewController.h
//  Argus
//
//  Created by Chris Elsworth on 01/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusChannelGroup.h"

#import "ProgrammeListViewController.h"
#import "SelectChannelGroupViewController.h"

@interface WhatsOnViewController : UITableViewController <SelectChannelGroupDelegate>

@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, retain) NSTimer *autoRedrawTimer;

-(IBAction)refreshWhatsOn:(id)sender;

-(void)reloadData;

-(void)didSelectChannelGroup:(ArgusChannelGroup *)ChannelGroup;

@end