//
//  ScheduleEditRuleChannelsTVC.m
//  Argus
//
//  Created by Chris Elsworth on 29/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditRuleChannelsTVC.h"
#import "ScheduleEditRuleAddChannels.h"
#import "ArgusChannel.h"

#import "AppDelegate.h"

@implementation ScheduleEditRuleChannelsTVC
@synthesize matchtype;
@synthesize Schedule, Rule;

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
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;

	// force table into editing mode and leave it there for the duration of the view life
	[self setEditing:YES animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
	// this causes a redraw when a sub-page returns control to us,
	// and when we load initially.

	[super viewWillAppear:animated];
	
	[self updateMatchTypeDisplay];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
		return 1;
	
	return [[Rule Arguments] count];	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
	
    // Configure the cell...
	
	if (indexPath.section == 0)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"AddChannelCell"];
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell"];

		NSString *ChannelId = [Rule Arguments][indexPath.row];
    
		ArgusChannel *c = [argus ChannelsKeyedByChannelId][ChannelId];
		if (!c || ![c Property:kDisplayName])
		{
			// seen this crop up a few times but I don't know why, could be that a channel
			// is being returned that isn't in our Channels lookup dictionary..
			NSLog(@"ERROR: c=%@ DisplayName=%@", c, [c Property:kDisplayName]);
			cell.textLabel.text = ChannelId;
		}
		else
			cell.textLabel.text = [c Property:kDisplayName];

	}
    return cell;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
		return UITableViewCellEditingStyleInsert;
	
	return UITableViewCellEditingStyleDelete;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NSLocalizedString(@"Remove", @"button to remove a channel from a schedule");
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        // Delete the row from the data source
		[[Rule Arguments] removeObjectAtIndex:indexPath.row];
		
		if ([[Rule Arguments] count] == 0)
		{
			[Rule setArguments:nil];
			[Rule setMatchType:0];
			[self updateMatchTypeDisplay];
		}

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert)
	{
		// not supported here, we pass control over to ScheduleEditRuleAddChannels
    }   
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Segue Handling
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleAddChannels"])
    {
        ScheduleEditRuleAddChannels *dvc = (ScheduleEditRuleAddChannels *)[segue destinationViewController];
        
		// send over a pointer to the rule being edited
		dvc.Rule = Rule;
		
		// and the Schedule; it needs Schedule.ChannelType to avoid adding TV channels to a Radio schedule
		dvc.Schedule = Schedule;
    }
}

// matchtype delegate
-(IBAction)matchTypeChanged:(id)sender
{
	[self setMatchTypeFromSelectedSegment];
}

-(void)updateMatchTypeDisplay
{
	switch([Rule MatchType])
	{
		default:
			[matchtype setSelectedSegmentIndex:-1];
			break;
			
		case ArgusScheduleRuleMatchTypeContains:
			[matchtype setSelectedSegmentIndex:0];
			break;
		
		case ArgusScheduleRuleMatchTypeDoesNotContain:
			[matchtype setSelectedSegmentIndex:1];
			break;
	}
}

-(void)setMatchTypeFromSelectedSegment
{
	NSInteger selected = [matchtype selectedSegmentIndex];
	
	switch(selected)
	{
		case -1: // nothing selected
			[Rule setMatchType:0];
			break;
			
		case 0:
			[Rule setMatchType:ArgusScheduleRuleMatchTypeContains];
			break;
			
		case 1:
			[Rule setMatchType:ArgusScheduleRuleMatchTypeDoesNotContain];
			break;
	}
}



@end
