//
//  UpcomingProgrammesTVC.m
//  Argus
//
//  Created by Chris Elsworth on 26/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "UpcomingProgrammesTVC.h"
#import "ArgusProgramme.h"
#import "ArgusChannel.h"
#import "ProgrammeDetailsViewController.h"

#import "ArgusUpcomingRecordings.h"

#import "ProgrammeSummaryCell.h"

#import "AppDelegate.h"

@implementation UpcomingProgrammesTVC
@synthesize UpcomingNavigationCount;
@synthesize upcds;
@synthesize Schedule;
@synthesize popoverController;

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
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// trigger a request to get the upcoming programmes	
	if (Schedule)
	{
		// remember we will be using Schedule later, for retrieving programmes
		upcds = Schedule;
		[upcds getUpcomingProgrammes];
		
		// remove the left bar button items (Type).. in a schedule you cannot change the type anyway
		[[self navigationItem] setLeftBarButtonItem:nil];
	}
	else
	{
		// remember we are using our main argus object, for retrieving programmes
		upcds = argus;
		
		// no need for getUpcomingProgrammes here, LoadingPageTVC did it for us
	}
	
	
	// wait for notification that we have them
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redraw)
												 name:kArgusUpcomingProgrammesDone
											   object:[upcds UpcomingProgrammes]];
	
	// redraw when upcoming recordings changes (to draw conflict icons properly)
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redraw)
												 name:kArgusUpcomingRecordingsDone
											   object:[argus UpcomingRecordings]];

	
	// count the number of UpcomingProgrammes instances in the navigation tree
	for (UIViewController *vc in [[self navigationController] viewControllers])
	{
		if ([vc isKindOfClass:[UpcomingProgrammesTVC class]])
			UpcomingNavigationCount++;
	}
	
	// don't overwrite Back on the iPhone
	[[self navigationItem] setLeftItemsSupplementBackButton:YES];
	
	if (dark)
	{
		[[[self navigationController] navigationBar] setTintColor:[UIColor blackColor]];
	}

	[self.view setBackgroundColor:[ArgusColours bgColour]];
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

-(NSArray *)upcomingProgrammesForUPCDS
{
	if (Schedule)
		return [[upcds UpcomingProgrammes] upcomingProgrammesForSchedule];
	else
		return [[upcds UpcomingProgrammes] upcomingProgrammesForScheduleType:[argus SelectedScheduleType]];	
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// never return 0. We will show a "No Programmes" cell.
    return MAX(1, [[self upcomingProgrammesForUPCDS] count]);
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	ArgusScheduleType sT;
	sT = Schedule ? [Schedule ScheduleType] : [argus SelectedScheduleType];
	
	NSString *scheduleTypeStr;
	if (sT == ArgusScheduleTypeRecording)
		scheduleTypeStr = NSLocalizedString(@"Recordings", nil);
	if (sT == ArgusScheduleTypeSuggestion)
		scheduleTypeStr = NSLocalizedString(@"Suggestions", nil);
	if (sT == ArgusScheduleTypeAlert)
		scheduleTypeStr = NSLocalizedString(@"Alerts", nil);
	
	return scheduleTypeStr;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[self upcomingProgrammesForUPCDS] count] == 0)
		return [tableView dequeueReusableCellWithIdentifier:@"NoUpcomingProgrammeCell"];
	
	ArgusUpcomingProgramme *p = [self upcomingProgrammesForUPCDS][indexPath.row];
	ProgrammeSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpcomingProgrammeCell"];
	[cell populateCellWithUpcomingProgramme:p];
	return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIColor *colourToSet = (indexPath.row % 2) ? [ArgusProgramme bgColourStdOdd] : [ArgusProgramme bgColourStdEven];
	cell.backgroundColor = colourToSet;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// this segue is assigned to the UITableViewController rather than the cell, so we can invoke it conditionally
	// we only draw indicators and process segues if UpcomingNavigationCount is one (the one we're in now)
	if (UpcomingNavigationCount == 1)
		[self performSegueWithIdentifier:@"UpcomingProgramme" sender:self];
	
	[[self tableView] deselectRowAtIndexPath:indexPath animated:YES];

}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	// if we ever want the detail disclosure indicator to do something other than tapping on the row
	// this is the place to do it.. for now it just invokes the same segue
	[[self tableView] selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self performSegueWithIdentifier:@"UpcomingProgramme" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"UpcomingProgramme"])
	{
		NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
		NSArray *tmp = [[upcds UpcomingProgrammes] upcomingProgrammesForScheduleType:[argus SelectedScheduleType]];
		ArgusProgramme *p = tmp[indexPath.row];
		
		ProgrammeDetailsViewController *dvc = [segue destinationViewController];
		dvc.Programme = p;
	}
	
	if ([[segue identifier] isEqualToString:@"SetUpcomingProgrammeType"])
	{
		// prevent more than one popup being visible
		if (iPad())
			[popoverController dismissPopoverAnimated:YES];
		
		SelectUpcomingTypeTVC *dvc = (SelectUpcomingTypeTVC *)[[segue destinationViewController] visibleViewController];
				
		// set delegate to us so when they're closed or change anything, we can update our display
		[dvc setDelegate:self];
		
		if (iPad())
		{
			popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
			[dvc setPopoverController:popoverController];
		}
	}
}

-(IBAction)refreshPressed:(id)sender
{
	[[upcds UpcomingProgrammes] getUpcomingProgrammes];
	[[argus UpcomingRecordings] getUpcomingRecordings];
}

-(void)redraw
{
	[[self tableView] reloadData];
}


#pragma mark - Select Upcoming Type Delegate
-(void)selectUpcomingTypeViewController:(SelectUpcomingTypeTVC *)sutvc changedSelectionToScheduleType:(ArgusScheduleType)scheduleType
{
	[[upcds UpcomingProgrammes] getUpcomingProgrammes];
}

@end
