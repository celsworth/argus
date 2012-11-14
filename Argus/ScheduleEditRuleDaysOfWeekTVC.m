//
//  ScheduleEditRuleOnDays.m
//  Argus
//
//  Created by Chris Elsworth on 27/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditRuleDaysOfWeekTVC.h"

@implementation ScheduleEditRuleDaysOfWeekTVC
@synthesize weekdays;
@synthesize Rule;

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
	
	weekdays = [NSMutableArray arrayWithArray:[[NSDateFormatter alloc] weekdaySymbols]];
	
	// shuffle first object (Sunday) to the end
	[weekdays addObject:[weekdays objectAtIndex:0]];
	[weekdays removeObjectAtIndex:0];

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

#pragma mark - Table view source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScheduleEditRuleOnDaysCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
	
	cell.textLabel.text = [weekdays objectAtIndex:indexPath.row];
	
	cell.accessoryType = UITableViewCellAccessoryNone;

	ArgusScheduleRuleDaysOfWeek day = [self dayOfWeekForIndexPath:indexPath];

	if ([Rule getArgumentAsDayOfWeekSelected:day])
		cell.accessoryType = UITableViewCellAccessoryCheckmark;

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ArgusScheduleRuleDaysOfWeek day = [self dayOfWeekForIndexPath:indexPath];
 
	if ([Rule getArgumentAsDayOfWeekSelected:day])
		// day is selected; deselect it
		[Rule setArgumentAsDayOfWeek:day selected:NO];
	else
		[Rule setArgumentAsDayOfWeek:day selected:YES];

	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(ArgusScheduleRuleDaysOfWeek)dayOfWeekForIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row)
	{
		default: // squash analyzer warning
		case 0:	return ArgusScheduleRuleDayOfWeekMonday;    break;
		case 1: return ArgusScheduleRuleDayOfWeekTuesday;   break;
		case 2: return ArgusScheduleRuleDayOfWeekWednesday; break;
		case 3: return ArgusScheduleRuleDayOfWeekThursday;  break;
		case 4: return ArgusScheduleRuleDayOfWeekFriday;    break;
		case 5: return ArgusScheduleRuleDayOfWeekSaturday;  break;
		case 6: return ArgusScheduleRuleDayOfWeekSunday;    break;
	}
}

-(IBAction)buttonPressedNone:(id)sender
{
	[Rule setArguments:nil];
	[[self tableView] reloadData];
}
-(IBAction)buttonPressedWDays:(id)sender
{
	// yes, magic numbers, but it's easy and they're unlikely to change :P
	[Rule setArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:62]]];
	[[self tableView] reloadData];
}
-(IBAction)buttonPressedWEnds:(id)sender
{
	[Rule setArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:65]]];
	[[self tableView] reloadData];
}


@end
