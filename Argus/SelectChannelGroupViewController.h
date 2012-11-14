//
//  SelectChannelGroupViewController.h
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArgusChannelGroup.h"

#import "AppDelegate.h"

@protocol SelectChannelGroupDelegate <NSObject>
-(void)didSelectChannelGroup:(ArgusChannelGroup *)ChannelGroup;
@end

@interface SelectChannelGroupViewController : UITableViewController <UIPopoverControllerDelegate>

// pass in an Argus object for us to get Channel Groups from
@property (nonatomic, retain) Argus *myArgus;

@property (nonatomic, weak) id <SelectChannelGroupDelegate> delegate;
@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, assign) ArgusChannelType ForceChannelType;

@property (nonatomic, assign) ArgusChannelGroup *SelectedChannelGroup;

-(IBAction)refreshChannelGroups:(id)sender;

-(IBAction)didPressDone:(id)sender;

@end
