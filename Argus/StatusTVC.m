//
//  StatusTVC.m
//  Argus
//
//  Created by Chris Elsworth on 05/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "StatusTVC.h"

#import "DiskUsageCell.h"
#import "ProgrammeSummaryCell.h"
#import "LiveStreamCell.h"

#import "ProgrammeDetailsViewController.h"

#import "AppDelegate.h"

@implementation StatusTVC
@synthesize autoRedrawTimer;
@synthesize LoadingDiskUsage, LoadingLiveStreams, LoadingActiveRecordings;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(RecordingDisksInfoDone:)
												 name:kArgusRecordingDisksInfoDone
											   object:argus];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(ActiveRecordingsDone:)
												 name:kArgusActiveRecordingsDone
											   object:argus];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(LiveStreamsDone:)
												 name:kArgusLiveStreamsDone
											   object:argus];

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

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// trigger initial data load
	[self refreshPressed:self];
	
	autoRedrawTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(autoRedraw) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	
	[autoRedrawTimer invalidate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;	
}


-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// top section: Disk Usage
	// second section: active recordings
	// third: live streams
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch ((ArgusStatusTableSection)section)
	{
		case ArgusStatusTableSectionDiskUsage:
			return MAX(1, [[[argus RecordingDisksInfo] RecordingDiskInfos] count]);
			break;
		
		case ArgusStatusTableSectionActiveRecordings:
			return MAX(1, [[argus ActiveRecordings] count]);
			break;
			
		case ArgusStatusTableSectionLiveStreams:
			return MAX(1, [[argus LiveStreams] count]);
			break;
	}
	/* NOTREACHED */
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch ((ArgusStatusTableSection)section)
	{
		case ArgusStatusTableSectionDiskUsage:
			return NSLocalizedString(@"Disk Usage", @"table section header in Live Status");
			break;
			
		case ArgusStatusTableSectionActiveRecordings:
			return NSLocalizedString(@"Active Recordings", @"table section header in Live Status");
			break;
			
		case ArgusStatusTableSectionLiveStreams:
			return NSLocalizedString(@"Live Streams", @"table section header in Live Status");
			break;
	}
	/* NOTREACHED */
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch ((ArgusStatusTableSection)indexPath.section)
	{
		case ArgusStatusTableSectionDiskUsage:
			return iPad() ? 100 : 100;
			break;
			
		case ArgusStatusTableSectionActiveRecordings:
			return iPad() ? 58 : 85;
			break;
			
		case ArgusStatusTableSectionLiveStreams:
			return iPad() ? 58 : 75;
			break;
	}
	/* NOTREACHED */
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIColor *colourToSet = (indexPath.row % 2) ? [ArgusProgramme bgColourStdOdd] : [ArgusProgramme bgColourStdEven];
	cell.backgroundColor = colourToSet;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch ((ArgusStatusTableSection)indexPath.section)
	{
		case ArgusStatusTableSectionDiskUsage:
		{
			// check if we have to display a special cell type
			if ([[[argus RecordingDisksInfo] RecordingDiskInfos] count] == 0)
				return [tableView dequeueReusableCellWithIdentifier:(LoadingDiskUsage ? @"LoadingCell" : @"NoDataCell")];
			
			DiskUsageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DiskUsageCell"];
			ArgusRecordingDiskInfo *r = [[argus RecordingDisksInfo] RecordingDiskInfos][indexPath.row];
			[cell populateCellWithRecordingDiskInfo:r];
			return cell;
			break;
		}
		
		case ArgusStatusTableSectionActiveRecordings:
		{
			// check if we have to display a special cell type
			if ([[argus ActiveRecordings] count] == 0)
				return [tableView dequeueReusableCellWithIdentifier:(LoadingActiveRecordings ? @"LoadingCell" : @"NoDataCell")];

			ProgrammeSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActiveRecordingCell"];
			ArgusActiveRecording *ar = [argus ActiveRecordings][indexPath.row];
			[cell populateCellWithActiveRecording:ar];
			return cell;
			break;
		}
		
		case ArgusStatusTableSectionLiveStreams:
		{
			// check if we have to display a special cell type
			if ([[argus LiveStreams] count] == 0)
				return [tableView dequeueReusableCellWithIdentifier:(LoadingLiveStreams ? @"LoadingCell" : @"NoDataCell")];

			LiveStreamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveStreamCell"];
			ArgusLiveStream *ls = [argus LiveStreams][indexPath.row];
			[cell populateCellWithLiveStream:ls];
			return cell;
			break;
		}
	}
	/* NOTREACHED */
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch ((ArgusStatusTableSection)indexPath.section)
	{
		case ArgusStatusTableSectionDiskUsage:
		{
			return NO;
			break;
		}
		case ArgusStatusTableSectionActiveRecordings:
		{
			// loading or no results row
			if ([[argus ActiveRecordings] count] == 0) return NO;
			
			ArgusActiveRecording *ar = [argus ActiveRecordings][indexPath.row];
			
			// don't let them mess with the row when the recording is stopping
			return [ar Stopping] ? NO : YES;
			break;
		}
		case ArgusStatusTableSectionLiveStreams:
		{
			// loading or no results row
			if ([[argus LiveStreams] count] == 0) return NO;

			ArgusLiveStream *ls = [argus LiveStreams][indexPath.row];
			
			// don't let them mess with the row when the stream is stopping
			return [ls Stopping] ? NO : YES;
			break;
		}
	}
	/* NOTREACHED */
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch ((ArgusStatusTableSection)indexPath.section)
	{
		case ArgusStatusTableSectionDiskUsage:
			return UITableViewCellEditingStyleNone;
			break;
			
		case ArgusStatusTableSectionActiveRecordings:
			return UITableViewCellEditingStyleDelete;
			break;
			
		case ArgusStatusTableSectionLiveStreams:
			return UITableViewCellEditingStyleDelete;
			break;
	}
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch ((ArgusStatusTableSection)indexPath.section)
	{
		case ArgusStatusTableSectionDiskUsage:
			return @""; 
			break;
			
		case ArgusStatusTableSectionActiveRecordings:
			return NSLocalizedString(@"Abort", @"button to abort an active recording");
			break;
			
		case ArgusStatusTableSectionLiveStreams:
			return NSLocalizedString(@"Stop", @"button to stop a live stream");
			break;
	}	
	/* NOTREACHED */
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{	
	switch ((ArgusStatusTableSection)indexPath.section)
	{
		case ArgusStatusTableSectionDiskUsage:
		{
			// nothing here
			break;
		}
		case ArgusStatusTableSectionActiveRecordings:
		{
			// send command
			// the Done callback will refresh ActiveRecordings array
			ArgusActiveRecording *ar = [argus ActiveRecordings][indexPath.row];
			[ar AbortActiveRecording];
			
			// reload the row, which removes the edit elements and adds a spinner
			[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

			break;
		}
		case ArgusStatusTableSectionLiveStreams:
		{
			// send StopLiveStream command or whatever it is
			// the Done callback should then refresh LiveStreams?
			ArgusLiveStream *ls = [argus LiveStreams][indexPath.row];
			[ls StopLiveStream];
			
			// do not delete the row yet. The ArgusLiveStream object will trigger a getLiveStreams by itself, and we'll be reloaded
			
			// reload the row, which removes the edit elements and adds a spinner
			[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

			break;
		}
	}
	/* NOTREACHED */
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"ActiveRecording"])
	{
		NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
		ArgusActiveRecording *ar = [argus ActiveRecordings][indexPath.row];
		ArgusProgramme *p = [ar UpcomingProgramme];
		
		ProgrammeDetailsViewController *dvc = [segue destinationViewController];
		dvc.Programme = p;
	}
}

#pragma mark - Notification Selectors

-(void)RecordingDisksInfoDone:(NSNotification *)notify
{
	LoadingDiskUsage = NO;
	//[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ArgusStatusTableSectionDiskUsage] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView reloadData];
}
-(void)ActiveRecordingsDone:(NSNotification *)notify
{
	LoadingActiveRecordings = NO;
	//[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ArgusStatusTableSectionActiveRecordings] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView reloadData];
}

-(void)LiveStreamsDone:(NSNotification *)notify
{
	LoadingLiveStreams = NO;
	//[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ArgusStatusTableSectionLiveStreams] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView reloadData];
}

#pragma mark - IBAction Selectors

-(IBAction)refreshPressed:(id)sender
{
	LoadingDiskUsage = YES;
	LoadingActiveRecordings = YES;
	LoadingLiveStreams = YES;

	[argus getRecordingDisksInfo];
	[argus getActiveRecordings];
	[argus getLiveStreams];
	
	[self.tableView reloadData];
}

-(void)autoRedraw
{
	[self.tableView reloadData];
	
	if (isOnWWAN())
	{
		if (autoReloadDataOn3G)
			[self refreshPressed:self];
	}
	else
		[self refreshPressed:self];
}

@end
