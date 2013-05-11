//
//  SchedulesViewController.m
//  Argus
//
//  Created by Chris Elsworth on 05/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "SchedulesViewController.h"

#import "ArgusProgramme.h"

#import "AppDelegate.h"

@implementation SchedulesViewController
@synthesize popoverController;

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void)dealloc
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
	UIBarButtonItem *btn = [[UIBarButtonItem alloc]
							initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
							target:self
							action:@selector(refreshSchedules:)];

	UIBarButtonItem *btn2 = [[UIBarButtonItem alloc]
							 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
							 target:self
							 action:@selector(newSchedule:)];

	[[self navigationItem] setRightBarButtonItems:@[btn, btn2]];
	
	// this allows Type to co-exist with Menu (back) on iPad
	// on iPhone it just has no effect as there is no Back button
	[[self navigationItem] setLeftItemsSupplementBackButton:YES];
	
	
	// redraw table when the schedules list changes
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadData)
												 name:kArgusSchedulesDone
											   object:[argus Schedules]];
	
	// no longer doing this, LoadingTVC does it.
	//[[argus Schedules] getSchedulesForSelectedChannelType];

	if (dark)
	{
		[[[self navigationController] navigationBar] setTintColor:[UIColor blackColor]];
	}

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

    [super viewWillAppear:animated];	
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSMutableArray *entries = [[argus Schedules] schedulesForChannelType:[[argus ChannelGroups] SelectedChannelType] scheduleType:[argus SelectedScheduleType]];
	
	// never return 0, we will show a "No Schedules" row instead
	return MAX(1, [entries count]);
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	ArgusChannelType cT = [[argus ChannelGroups] SelectedChannelType];
	ArgusScheduleType sT = [argus SelectedScheduleType];
	
	NSString *channelTypeStr, *scheduleTypeStr;
	
	if (cT == ArgusChannelTypeTelevision)
		channelTypeStr = NSLocalizedString(@"Television", nil);
	if (cT == ArgusChannelTypeRadio) 
		channelTypeStr = NSLocalizedString(@"Radio", nil);
	
	if (sT == ArgusScheduleTypeRecording)
		scheduleTypeStr = NSLocalizedString(@"Recordings", nil);
	if (sT == ArgusScheduleTypeSuggestion)
		scheduleTypeStr = NSLocalizedString(@"Suggestions", nil);
	if (sT == ArgusScheduleTypeAlert)
		scheduleTypeStr = NSLocalizedString(@"Alerts", nil);
	
	return [NSString stringWithFormat:@"%@ - %@", channelTypeStr, scheduleTypeStr];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *entries = [[argus Schedules] schedulesForChannelType:[[argus ChannelGroups] SelectedChannelType] scheduleType:[argus SelectedScheduleType]];
	if ([entries count] == 0)
		return [tableView dequeueReusableCellWithIdentifier:@"NoScheduleCell"];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"];

	ArgusSchedule *s = entries[indexPath.row];
	
	cell.textLabel.text = [s Property:kName];
	
	if ([s IsActive])
		cell.textLabel.textColor = [ArgusProgramme fgColourStd];
	else
		cell.textLabel.textColor = [ArgusProgramme fgColourAlreadyShown];
		
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIColor *colourToSet = (indexPath.row % 2) ? [ArgusProgramme bgColourStdOdd] : [ArgusProgramme bgColourStdEven];

	cell.backgroundColor = colourToSet;
}


#pragma mark - Segue Handling

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
    if ([[segue identifier] isEqualToString:@"ScheduleEdit"])
    {
		ScheduleViewController *dvc = (ScheduleViewController *)[segue destinationViewController];
				
        // tell dvc which entry has been tapped on
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSMutableArray *entries = [[argus Schedules] schedulesForChannelType:[[argus ChannelGroups] SelectedChannelType] scheduleType:[argus SelectedScheduleType]];
		dvc.Schedule = entries[indexPath.row];
		
		// additionally, trigger getting full details
		// don't do it in the view as that leads to complications:
		// a) in viewDidLoad, we could have out-of-date info on the second viewing of a schedule
		// b) in viewDidAppear, it reloads when we come back from Rules, nuking any changes
		[dvc.Schedule getFullDetailsForced:YES];
    }
	
	if ([[segue identifier] isEqualToString:@"ScheduleNew"])
	{
		ScheduleViewController *dvc;
		if (iPad())
			dvc = (ScheduleViewController *)[[segue destinationViewController] visibleViewController];
		else
			dvc = (ScheduleViewController *)[segue destinationViewController];

		dvc.Schedule = [ArgusSchedule new];
	}
	
	if ([[segue identifier] isEqualToString:@"SetScheduleType"])
	{
		// prevent more than one popup being visible
		if (iPad())
			[popoverController dismissPopoverAnimated:YES];

		ScheduleTypeTVC *dvc = (ScheduleTypeTVC *)[[segue destinationViewController] visibleViewController];

		// set delegate to us so when they're closed or change anything, we can update our display
		[dvc setDelegate:self];
		
		if (iPad())
		{
			popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
			[dvc setPopoverController:popoverController];
		}
	}
}

#pragma mark - Schedule Type Delegate

-(void)selectionChangedToChannelType:(ArgusChannelType)_channelType scheduleType:(ArgusScheduleType)_scheduleType
{
	[self refreshSchedules:self];
}


#pragma mark - Data Handling

-(IBAction)refreshSchedules:(id)sender
{
	[[argus Schedules] getSchedulesForSelectedChannelType];
}

// this is currently set up programmatically because the + button is added in viewDidLoad
-(IBAction)newSchedule:(id)sender
{
	ScheduleViewController *dvc;
	
#if 0
	UINavigationController *nc;
	// this used to be for when the Schedules list was in Master view
	if (iPad())
	{
		// on iPad, we need our own navigation controller to put into the detail view
		NSLog(@"%s", __PRETTY_FUNCTION__);

		nc = [sb instantiateViewControllerWithIdentifier:@"ScheduleViewControllerNC"];
		NSLog(@"%s", __PRETTY_FUNCTION__);

		//	nc.title = NSLocalizedString(@"Creating New Schedule", @"iPad title");
		NSLog(@"%s", __PRETTY_FUNCTION__);

		dvc = (ScheduleViewController *)[nc topViewController];
		NSLog(@"%s", __PRETTY_FUNCTION__);

	}
	else
#endif
	
	{
		// on iPhone, the navigation controller is kept and we just want the ScheduleViewController
		dvc = [[[AppDelegate sharedInstance] ActiveStoryboard] instantiateViewControllerWithIdentifier:@"ScheduleViewController"];
	}
		
	// pass the dvc an empty initialised schedule
	dvc.Schedule = [[ArgusSchedule alloc] initEmptyWithChannelType:[[argus ChannelGroups] SelectedChannelType]
													scheduleType:[argus SelectedScheduleType]];
	
#if 0
	// this used to be for when the Schedules list was in Master view
	if (iPad())
	{
		// keep master view the same, replace detail view with our navigation controller
		NSArray *vcs = [[self splitViewController] viewControllers];
		NSArray *newvcs = [NSArray arrayWithObjects:[vcs objectAtIndex:0], nc, nil];
		[[self splitViewController] setViewControllers:newvcs];
	}
	else
#endif
	
	{
		[[self navigationController] pushViewController:dvc animated:YES];
	}
}

-(void)reloadData
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
		
	[self.tableView reloadData];
}

@end
