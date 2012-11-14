//
//  MasterViewController.h
//  Argus
//
//  Created by Chris Elsworth on 01/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class DetailViewController;

#define kArgusSidePanelDisplayStateChanged @"kArgusSidePanelDisplayStateChanged"

@interface MasterViewController : UITableViewController

//@property (strong, nonatomic) DetailViewController *detailViewController;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *hideShowMaster;
@property (nonatomic, assign) BOOL masterHidden;

@property (nonatomic, weak) IBOutlet UITableViewCell *versionCell;

-(IBAction)hideShowPressed:(id)sender;

@end
