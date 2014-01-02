//
//  SearchEpgTVC.m
//  Argus
//
//  Created by Chris Elsworth on 01/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "SearchEpgTVC.h"
#import "Argus.h"
#import "ArgusProgramme.h"
#import "ArgusChannel.h"
#import "ProgrammeDetailsViewController.h"

#import "ProgrammeSummaryCell.h"

#import "AppDelegate.h"

@implementation SearchEpgTVC

-(void)dealloc
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
#if USE_EPG_PARTIAL_SEARCH
	// reload table whenever search results come in
	[[NSNotificationCenter defaultCenter] addObserverForName:kArgusEpgPartialSearchDone object:argus
													   queue:[NSOperationQueue mainQueue]
												  usingBlock:^(NSNotification *note)
	{
		NSLog(@"%s", __PRETTY_FUNCTION__);

		[self.tableView reloadData];
	}];
#else
	// reload table whenever search results come in
	[[NSNotificationCenter defaultCenter] addObserverForName:kArgusUpcomingProgrammesDone object:_SearchSchedule
													   queue:[NSOperationQueue mainQueue]
												  usingBlock:^(NSNotification *note)
	 {
		 NSLog(@"%s", __PRETTY_FUNCTION__);
		 
		 [self.tableView reloadData];
	 }];
#endif
	
	if (dark)
	{
		[[[self navigationController] navigationBar] setTintColor:[UIColor blackColor]];
	}

	[self.view setBackgroundColor:[ArgusColours bgColour]];
	[self.tableView setBackgroundColor:[ArgusColours bgColour]];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
#if USE_EPG_PARTIAL_SEARCH
	ArgusProgramme *p = [argus SearchResults] count];
#else
	return [[[self.SearchSchedule UpcomingProgrammes] upcomingProgrammesForSchedule] count];
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if USE_EPG_PARTIAL_SEARCH
	ArgusProgramme *p = [argus SearchResults][indexPath.row];
#else
	ArgusProgramme *p = [[self.SearchSchedule UpcomingProgrammes] upcomingProgrammesForSchedule][indexPath.row];
#endif
	
	ProgrammeSummaryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchEpgResultCell"];
	[cell populateCellWithProgramme:p];
	return cell;
}
-(void)tableView:(UITableView *)_tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// programmes due to record get a red colour
	
#if USE_EPG_PARTIAL_SEARCH
	ArgusProgramme *p = [argus SearchResults][indexPath.row];
#else
	ArgusProgramme *p = [[self.SearchSchedule UpcomingProgrammes] upcomingProgrammesForSchedule][indexPath.row];
#endif
	
	// start off with standard table odd/even colour
	UIColor *colourToSet = (indexPath.row % 2) ? [ArgusProgramme bgColourStdOdd] : [ArgusProgramme bgColourStdEven];
	
	// programmes that are on now
	// this is overridden by active recordings next
	if ([p isOnNow])
		colourToSet = [ArgusProgramme bgColourOnNow];
	
	ArgusUpcomingProgramme *upc = [p upcomingProgramme];
	if (upc)
	{
		switch ([upc scheduleStatus])
		{
			case ArgusUpcomingProgrammeScheduleStatusRecordingScheduled:
			case ArgusUpcomingProgrammeScheduleStatusRecordingScheduledConflict:
				// set a red background for programmes that are going to be recorded
				colourToSet = [ArgusProgramme bgColourUpcomingRec];
				break;
				
			default:
				// nothing else gets a colour so far
				break;
		}
	}
	
	cell.backgroundColor = colourToSet;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Segue Handling
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ProgrammeDetails"])
    {
        ProgrammeDetailsViewController *dvc = (ProgrammeDetailsViewController *)[segue destinationViewController];
        
        // tell dvc which programme has been tapped on
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
#if USE_EPG_PARTIAL_SEARCH
		dvc.Programme = [argus SearchResults][indexPath.row];
#else
		dvc.Programme = [[self.SearchSchedule UpcomingProgrammes] upcomingProgrammesForSchedule][indexPath.row];
#endif
	}
}


#pragma mark - Search Bar Delegate

/*
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	// this could do "Google Instant" style searching if we wanted it
}
*/

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	[self.search resignFirstResponder];
	
	NSString *searchStr = [[searchBar text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([searchStr length] > 0)
	{
#if USE_EPG_PARTIAL_SEARCH
		[argus doEpgPartialSearchforString:searchStr inChannelType:[self.search selectedScopeButtonIndex]];
#else
		self.SearchSchedule = [[ArgusSchedule alloc] initWithExistingSchedule:[argus EmptySchedule]];
		[self.SearchSchedule setChannelType:[self.search selectedScopeButtonIndex]];
		[self.SearchSchedule setScheduleType:ArgusScheduleTypeRecording];
		
		ArgusScheduleRule *Rule = [self.SearchSchedule Rules][kArgusScheduleRuleSuperTypeProgramInfo];
		[Rule setArguments:(NSMutableArray *)@[searchStr]];
		[Rule setMatchType:ArgusScheduleRuleMatchTypeContains];
		
		[self.SearchSchedule getUpcomingProgrammes];
#endif
	}
	
}

@end
