//
//  ScheduleViewPRHTVC.m
//  Argus
//
//  Created by Chris Elsworth on 17/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleViewPRHTVC.h"

#import "ArgusProgramme.h"
#import "ArgusSchedule.h"
#import "ArgusScheduleRecordedProgram.h"

#import "AppDelegate.h"

@implementation ScheduleViewPRHTVC
@synthesize ScheduleId;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	ArgusSchedule *Schedule = [ArgusSchedule ScheduleForScheduleId:ScheduleId];
	[Schedule getPRH];
	
	// redraw the table when getPRH finishes (initial or reload)
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redraw)
												 name:kArgusScheduleGetPRHDone
											   object:nil];
	
	// redraw table when a removeFromPRH finishes
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redraw)
												 name:kArgusScheduleRecordedProgramRemoveFromPRHDone
											   object:nil];
	
	
	// set up top-right buttons, "Remove All" and Refresh
	UIBarButtonItem *removeAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Remove All"
																		style:UIBarButtonItemStyleBordered
																	   target:self
																	   action:@selector(removeAllPressed:)];
	[removeAllButton setTintColor:[UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1]];
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				   target:self
																				   action:@selector(refreshPressed:)];
	
	[[self navigationItem] setRightBarButtonItems:@[refreshButton, removeAllButton]];
	
	[self setEditing:YES];
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

-(void)redraw
{
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	ArgusSchedule *Schedule = [ArgusSchedule ScheduleForScheduleId:ScheduleId];
	
	// never return 0, we will retun a "None" cell for 0
	return MAX(1, [[Schedule PreviouslyRecordedHistory] count]);
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIColor *colourToSet = (indexPath.row % 2) ? [ArgusProgramme bgColourStdOdd] : [ArgusProgramme bgColourStdEven];
	cell.backgroundColor = colourToSet;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ArgusSchedule *Schedule = [ArgusSchedule ScheduleForScheduleId:ScheduleId];
	
	if ([[Schedule PreviouslyRecordedHistory] count] == 0)
		return [tableView dequeueReusableCellWithIdentifier:@"PRHNoneCell"];
	
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PRHCell"];
	
	ArgusScheduleRecordedProgram *srp = Schedule.PreviouslyRecordedHistory[indexPath.row];
    
	// could make this a tablecell class
	
	UILabel *title = (UILabel *)[cell viewWithTag:1];
	UILabel *date = (UILabel *)[cell viewWithTag:2];
	UILabel *episode = (UILabel *)[cell viewWithTag:3];
	UIActivityIndicatorView *removing = (UIActivityIndicatorView *)[cell viewWithTag:4];
	
	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateStyle:NSDateFormatterMediumStyle];
	[df setTimeStyle:NSDateFormatterMediumStyle];
	
	title.text = [srp Property:kTitle];
	date.text = [df stringFromDate:[srp Property:kRecordedOn]];
	episode.text = [srp Property:kEpisode];
	
	[srp IsRemovingFromPRH] ? [removing startAnimating] : [removing stopAnimating];
	
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	ArgusSchedule *Schedule = [ArgusSchedule ScheduleForScheduleId:ScheduleId];
	
	// "None" row not editable
	if ([[Schedule PreviouslyRecordedHistory] count] == 0)
		return NO;
	
	ArgusScheduleRecordedProgram *srp = [Schedule PreviouslyRecordedHistory][indexPath.row];
	
	// row being acted on not editable
	if ([srp IsRemovingFromPRH])
		return NO;
	
	return YES;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return @"Remove";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	ArgusSchedule *Schedule = [ArgusSchedule ScheduleForScheduleId:ScheduleId];
	ArgusScheduleRecordedProgram *srp = [Schedule PreviouslyRecordedHistory][indexPath.row];
	
	[srp removeFromPRH];
	
	// redraw so the spinny appears
	[self.tableView reloadData];
}

#pragma mark - IBActions
-(IBAction)refreshPressed:(id)sender
{
	ArgusSchedule *Schedule = [ArgusSchedule ScheduleForScheduleId:ScheduleId];
	[Schedule getPRH];
}

-(IBAction)removeAllPressed:(id)sender
{
	// confirmation dialog
	
	UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Confirm Remove All", nil)
													delegate:self
										   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
									  destructiveButtonTitle:NSLocalizedString(@"Remove All", nil)
										   otherButtonTitles:nil];
	if (iPad())
		[as showInView:self.view];
	else
		[as showFromTabBar:self.tabBarController.tabBar];
	
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// cancel == 1
	// delete == 0
	if (buttonIndex == 0)
	{
		// trigger the deletion
		ArgusSchedule *Schedule = [ArgusSchedule ScheduleForScheduleId:ScheduleId];
		[Schedule clearPRH];
	}
}

@end
