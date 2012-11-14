//
//  ScheduleEditKeepTVC.m
//  Argus
//
//  Created by Chris Elsworth on 11/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditKeepTVC.h"


@implementation ScheduleEditKeepTVC
@synthesize Schedule;
@synthesize KeepUntilValue, KeepUntilValueStepper, KeepUntilValueStepperTen;
@synthesize forever, recent, space, watched, days;

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
	
	[self redraw];
}

-(void)redraw
{
	ArgusKeepUntilMode kum = [[Schedule Property:kKeepUntilMode] intValue];

	if (kum == ArgusKeepUntilModeForever || kum == ArgusKeepUntilModeUntilSpaceIsNeeded)
	{
		KeepUntilValue.text = @"n/a";
		KeepUntilValueStepper.enabled = false;
		KeepUntilValueStepperTen.enabled = false;
	}
	else if ([Schedule Property:kKeepUntilValue])
	{
		KeepUntilValue.text = [[Schedule Property:kKeepUntilValue] stringValue];
		KeepUntilValueStepper.value = [[Schedule Property:kKeepUntilValue] intValue];
		KeepUntilValueStepper.enabled = true;

		KeepUntilValueStepperTen.value = [[Schedule Property:kKeepUntilValue] intValue];
		KeepUntilValueStepperTen.enabled = true;
	}
	
	// set the appropriate checkbox
	space.accessoryType = kum == ArgusKeepUntilModeUntilSpaceIsNeeded ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	days.accessoryType = kum == ArgusKeepUntilModeNumberOfDays ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	recent.accessoryType = kum == ArgusKeepUntilModeNumberOfEpisodes ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	watched.accessoryType = kum == ArgusKeepUntilModeNumberOfWatchedEpisodes ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	forever.accessoryType = kum == ArgusKeepUntilModeForever ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

// static cells, nothing to do



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1)
	{
		if (indexPath.row == 0)
		{
			[Schedule setKeepUntilMode:[NSNumber numberWithInt:ArgusKeepUntilModeUntilSpaceIsNeeded]];
			[Schedule setKeepUntilValue:(NSNumber *)[NSNull null]];
		}
		if (indexPath.row == 1)
		{
			[Schedule setKeepUntilMode:[NSNumber numberWithInt:ArgusKeepUntilModeNumberOfDays]];
			if (! [Schedule Property:kKeepUntilValue])
				[Schedule setKeepUntilValue:[NSNumber numberWithInt:7]];
		}
		if (indexPath.row == 2)
		{
			[Schedule setKeepUntilMode:[NSNumber numberWithInt:ArgusKeepUntilModeNumberOfEpisodes]];
			if (! [Schedule Property:kKeepUntilValue])
				[Schedule setKeepUntilValue:[NSNumber numberWithInt:10]];
		}
		if (indexPath.row == 3)
		{
			[Schedule setKeepUntilMode:[NSNumber numberWithInt:ArgusKeepUntilModeNumberOfWatchedEpisodes]];
			if (! [Schedule Property:kKeepUntilValue])
				[Schedule setKeepUntilValue:[NSNumber numberWithInt:10]];
		}
		if (indexPath.row == 4)
		{
			[Schedule setKeepUntilMode:[NSNumber numberWithInt:ArgusKeepUntilModeForever]];
			[Schedule setKeepUntilValue:(NSNumber *)[NSNull null]];
		}
	}
	
	//[[self tableView] deselectRowAtIndexPath:indexPath animated:NO];
	[self redraw];
}


-(IBAction)stepperChanged:(UIStepper *)sender
{
	NSInteger value = [sender value];
	[Schedule setKeepUntilValue:[NSNumber numberWithInt:value]];

	[KeepUntilValueStepper setValue:value];
	[KeepUntilValueStepperTen setValue:value];
	
	[self redraw];
}

@end
