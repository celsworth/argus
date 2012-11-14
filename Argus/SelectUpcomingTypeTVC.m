//
//  SelectUpcomingTypeTVC.m
//  Argus
//
//  Created by Chris Elsworth on 10/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "SelectUpcomingTypeTVC.h"

#import "AppDelegate.h"

@implementation SelectUpcomingTypeTVC
@synthesize recordings, suggestions, alerts;
@synthesize delegate, popoverController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[self setCheckmarks];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	//	CGRect f = [[self tableView] bounds];
	//	[[self popoverController] setPopoverContentSize:CGSizeMake(f.size.width, f.size.height) animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ArgusScheduleType tmpScheduleType = [argus SelectedScheduleType];
	
	switch (indexPath.row)
	{
		case 0:
			tmpScheduleType = ArgusScheduleTypeRecording;
			break;
		case 1:
			tmpScheduleType = ArgusScheduleTypeSuggestion;
			break;
		case 2:
			tmpScheduleType = ArgusScheduleTypeAlert;
			break;
	}
	
	if (tmpScheduleType == [argus SelectedScheduleType])
		return;
	
	[argus setSelectedScheduleType:tmpScheduleType];	
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self setCheckmarks];
	
	// tell delegate we've changed
	if ([delegate respondsToSelector:@selector(selectUpcomingTypeViewController:changedSelectionToScheduleType:)])
		[delegate selectUpcomingTypeViewController:self changedSelectionToScheduleType:tmpScheduleType];
}

-(void)setCheckmarks
{
	// turn off all checkboxes except the selected ones
	ArgusScheduleType SelectedScheduleType = [argus SelectedScheduleType];
	
	recordings.accessoryType = (SelectedScheduleType == ArgusScheduleTypeRecording) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	suggestions.accessoryType = (SelectedScheduleType == ArgusScheduleTypeSuggestion) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	alerts.accessoryType = (SelectedScheduleType == ArgusScheduleTypeAlert) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

-(IBAction)didPressDone:(id)sender
{
	if (iPad())
		[popoverController dismissPopoverAnimated:YES];
	else
		[self dismissViewControllerAnimated:YES completion:nil];	
}

@end
