//
//  LoadingPageTVC.m
//  Argus
//
//  Created by Chris Elsworth on 31/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "LoadingPageTVC.h"

#import "ArgusUpcomingRecordings.h"

@implementation LoadingPageTVC
@synthesize retryButton, retryButtonCell;
@synthesize apiVersionCell, ChannelGroupsCell, ChannelsCell, UpcomingProgrammesCell, UpcomingRecordingsCell, RecordingFileFormatsCell, SchedulesCell, EmptyScheduleCell;
@synthesize Waiting;

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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// register for notifications that all the following are done, so we can
	// remove spinners and add checkboxes as we go
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ApiVersionDone:) name:kArgusApiVersionDone object:argus];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChannelGroupsDone:) name:kArgusChannelGroupsDone object:[argus ChannelGroups]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChannelsDone:) name:kArgusChannelsDone object:argus];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpcomingProgrammesDone:) name:kArgusUpcomingProgrammesDone object:[argus UpcomingProgrammes]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpcomingRecordingsDone:) name:kArgusUpcomingRecordingsDone object:[argus UpcomingRecordings]];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RecordingFileFormatsDone:) name:kArgusRecordingFileFormatsDone object:[argus RecordingFileFormats]];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SchedulesDone:) name:kArgusSchedulesDone object:[argus Schedules]];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EmptyScheduleDone:) name:kArgusEmptyScheduleDone object:argus];

	// check API version first
	[self checkApiVersion];
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

-(IBAction)retryPressed:(id)sender
{
	retryButtonCell.hidden = YES;
	[self checkApiVersion];
}
-(void)checkApiVersion
{
	[(UIActivityIndicatorView *)([apiVersionCell viewWithTag:1]) startAnimating];
	[argus checkApiVersion:REQUIRED_API_VERSION];
}
-(void)ApiVersionDone:(NSNotification *)notify
{
	NSInteger returnCode = [[[notify userInfo] objectForKey:@"ApiVersion"] intValue];
	
	[(UIActivityIndicatorView *)([apiVersionCell viewWithTag:1]) stopAnimating];

	if (returnCode == 0)
	{
		// we're ok, carry on!
		apiVersionCell.accessoryType = UITableViewCellAccessoryCheckmark;
		[self doMoreRequests];
		return;
	}
	else if (returnCode < 0)
	{
		// client is too old
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"API Version Error", nil)
														message:NSLocalizedString(@"This app is too old to use with your version of the Argus Services. You must update.", nil)
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		
		[alert show];
	}
	else if (returnCode > 0)
	{
		NSString *tmp = NSLocalizedString(@"Your Argus Services are too old to use with this app. You must update to %@.", nil);
		
		// server is too old
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"API Version Error", nil)
														message:[NSString stringWithFormat:tmp, REQUIRED_Argus_VERSION]
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		
		[alert show];	
	}
	
	retryButtonCell.hidden = NO;
	
	[(UIActivityIndicatorView *)([ChannelGroupsCell viewWithTag:1]) stopAnimating];
	[(UIActivityIndicatorView *)([ChannelsCell viewWithTag:1]) stopAnimating];
	[(UIActivityIndicatorView *)([UpcomingProgrammesCell viewWithTag:1]) stopAnimating];
	[(UIActivityIndicatorView *)([UpcomingRecordingsCell viewWithTag:1]) stopAnimating];
	[(UIActivityIndicatorView *)([RecordingFileFormatsCell viewWithTag:1]) stopAnimating];
	[(UIActivityIndicatorView *)([SchedulesCell viewWithTag:1]) stopAnimating];
	[(UIActivityIndicatorView *)([EmptyScheduleCell viewWithTag:1]) stopAnimating];
}


-(void)doMoreRequests
{	
	Waiting = 7;
	
	// get a list of channel groups and keep it handy so everyone else can access it
	[[argus ChannelGroups] getChannelGroups];
	[(UIActivityIndicatorView *)([ChannelGroupsCell viewWithTag:1]) startAnimating];

	[argus getChannels];
	[(UIActivityIndicatorView *)([ChannelsCell viewWithTag:1]) startAnimating];

	[[argus UpcomingProgrammes] getUpcomingProgrammes];
	[(UIActivityIndicatorView *)([UpcomingProgrammesCell viewWithTag:1]) startAnimating];
	
	[[argus UpcomingRecordings] getUpcomingRecordings];
	[(UIActivityIndicatorView *)([UpcomingRecordingsCell viewWithTag:1]) startAnimating];

	[[argus RecordingFileFormats] getRecordingFileFormats];
	[(UIActivityIndicatorView *)([RecordingFileFormatsCell viewWithTag:1]) startAnimating];

	[[argus Schedules] getSchedulesForSelectedChannelType];
	[(UIActivityIndicatorView *)([SchedulesCell viewWithTag:1]) startAnimating];

	// fetch an empty schedule; if Record is clicked, we'll edit it to suit
	[argus getEmptySchedule];
	[(UIActivityIndicatorView *)([EmptyScheduleCell viewWithTag:1]) startAnimating];

}


-(void)ChannelGroupsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// how many did we get?
	if ([[[argus ChannelGroups] TvEntries] count] + [[[argus ChannelGroups] RadioEntries] count] == 0)
	{
		// none
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Channel Groups Found", @"warning title when no channel groups found")
														message:NSLocalizedString(@"This app works best with Channel Groups, but you do not have any defined. EPG functionality may be very limited.", @"warning description when no channel groups found")
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		[alert show];
	}
	
	
	[ChannelGroupsCell setAccessoryType:UITableViewCellAccessoryCheckmark];
	[(UIActivityIndicatorView *)([ChannelGroupsCell viewWithTag:1]) stopAnimating];

	[self checkIfReadyToProgress];
}
-(void)ChannelsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[ChannelsCell setAccessoryType:UITableViewCellAccessoryCheckmark];
	[(UIActivityIndicatorView *)([ChannelsCell viewWithTag:1]) stopAnimating];

	[self checkIfReadyToProgress];
}
-(void)UpcomingProgrammesDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[UpcomingProgrammesCell setAccessoryType:UITableViewCellAccessoryCheckmark];
	[(UIActivityIndicatorView *)([UpcomingProgrammesCell viewWithTag:1]) stopAnimating];
	
	[self checkIfReadyToProgress];
}
-(void)UpcomingRecordingsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[UpcomingRecordingsCell setAccessoryType:UITableViewCellAccessoryCheckmark];
	[(UIActivityIndicatorView *)([UpcomingRecordingsCell viewWithTag:1]) stopAnimating];
	
	[self checkIfReadyToProgress];
}
-(void)RecordingFileFormatsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[RecordingFileFormatsCell setAccessoryType:UITableViewCellAccessoryCheckmark];
	[(UIActivityIndicatorView *)([RecordingFileFormatsCell viewWithTag:1]) stopAnimating];
	
	[self checkIfReadyToProgress];
}

-(void)SchedulesDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[SchedulesCell setAccessoryType:UITableViewCellAccessoryCheckmark];
	[(UIActivityIndicatorView *)([SchedulesCell viewWithTag:1]) stopAnimating];
	
	[self checkIfReadyToProgress];
}


-(void)EmptyScheduleDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[EmptyScheduleCell setAccessoryType:UITableViewCellAccessoryCheckmark];
	[(UIActivityIndicatorView *)([EmptyScheduleCell viewWithTag:1]) stopAnimating];
	
	[self checkIfReadyToProgress];
}


-(void)checkIfReadyToProgress
{
	if (--Waiting == 0)
	{
		[NSTimer scheduledTimerWithTimeInterval:0.2
										 target:self
									   selector:@selector(progress:)
									   userInfo:nil
										repeats:NO];
	}
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}


-(void)progress:(NSTimer *)timer
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	UIViewController *ivc = [[[AppDelegate sharedInstance] ActiveStoryboard] instantiateInitialViewController];
	
	// replace rootViewController with the main storyboard initial view controller
	// this allows LoadingPageTVC to dealloc
	[[[AppDelegate sharedInstance] window] setRootViewController:ivc];
	
	// this activates some refresh stuff in AppDelegate -applicationWillEnterForeground
	[[AppDelegate sharedInstance] setRefreshDataWhenForegrounded:YES];
}


@end
