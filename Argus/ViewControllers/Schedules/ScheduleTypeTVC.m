//
//  ScheduleTypeTVC.m
//  Argus
//
//  Created by Chris Elsworth on 10/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleTypeTVC.h"

#import "AppDelegate.h"
#import "Argus.h"

@implementation ScheduleTypeTVC
@synthesize delegate, popoverController;
@synthesize tv, radio, recordings, suggestions, alerts;

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
	NSLog(@"%s", __PRETTY_FUNCTION__);

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, indexPath);

	ArgusChannelType tmpChannelType = [[argus ChannelGroups] SelectedChannelType];
	ArgusScheduleType tmpScheduleType = [argus SelectedScheduleType];
	
	// could do with improving this, it relies on our IB layout not changing :(
	if (indexPath.section == 0)
	{
		switch (indexPath.row)
		{
			case 0:
				tmpChannelType = ArgusChannelTypeTelevision;
				break;
			case 1:
				tmpChannelType = ArgusChannelTypeRadio;
				break;
		}
	}
	else if (indexPath.section == 1)
	{
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
	}

	if (tmpScheduleType != [argus SelectedScheduleType] || tmpChannelType != [[argus ChannelGroups] SelectedChannelType])
	{
		if (tmpChannelType != [[argus ChannelGroups] SelectedChannelType])
			[[argus ChannelGroups] setSelectedChannelType:tmpChannelType];
		
		if (tmpScheduleType != [argus SelectedScheduleType])
			[argus setSelectedScheduleType:tmpScheduleType];

		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self setCheckmarks];
		
		// tell delegate we've changed
		if ([delegate respondsToSelector:@selector(selectionChangedToChannelType:scheduleType:)])
			[delegate selectionChangedToChannelType:tmpChannelType scheduleType:tmpScheduleType];
	}
}

-(void)setCheckmarks
{
	// turn off all checkboxes except the selected ones
	ArgusChannelType SelectedChannelType = [[argus ChannelGroups] SelectedChannelType];
	ArgusScheduleType SelectedScheduleType = [argus SelectedScheduleType];
	
	tv.accessoryType = (SelectedChannelType == ArgusChannelTypeTelevision) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	radio.accessoryType = (SelectedChannelType == ArgusChannelTypeRadio) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
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
