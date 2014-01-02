//
//  UpcomingProgrammeEditTVC.h
//  Argus
//
//  Created by Chris Elsworth on 08/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusUpcomingProgramme.h"

@interface UpcomingProgrammeEditTVC : UITableViewController

@property (nonatomic, weak) IBOutlet UIStepper *priorityStepper;
@property (nonatomic, weak) IBOutlet UILabel *priority;

@property (nonatomic, weak) IBOutlet UITableViewCell *prerec;
@property (nonatomic, weak) IBOutlet UITableViewCell *postrec;

@property (nonatomic, weak) IBOutlet UITableViewCell *cancelCell;
@property (nonatomic, weak) IBOutlet UILabel *cancelText;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *cancelSpinner;


@property (nonatomic, weak) IBOutlet UITableViewCell *prhCell;
@property (nonatomic, weak) IBOutlet UILabel *prhText;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *prhSpinner;


// removed this in favour of passing over an UpcomingProgramId instead
// this lets us refresh the upcoming list, and this instance can still look up the new object
//@property (nonatomic, retain) ArgusUpcomingProgramme *Programme;
@property (nonatomic, retain) NSString *UpcomingProgramId;


-(IBAction)priorityChanged:(UIStepper *)sender;

-(IBAction)savePressed:(id)sender;

@end
