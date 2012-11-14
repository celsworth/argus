//
//  WhatsOnViewController.m
//  Argus
//
//  Created by Chris Elsworth on 01/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "WhatsOnViewController.h"
#import "ArgusBaseObject.h"
#import "ArgusUpcomingProgramme.h"

#import "NSDateFormatter+LocaleAdditions.h"

@implementation WhatsOnViewController
@synthesize popoverController;
@synthesize autoRedrawTimer;

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		// be notified when a ChannelGroup finishes CurrentAndNext. This *could* lead to false
		// positives because we sign up to any object, but oh well.
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData)
													 name:kArgusChannelGroupCurrentAndNextDone
												   object:nil];
		// populate will be called when CurrentAndNextDone calls us back
		
		// be notified when channel groups change, and refresh our display (Argus.m will always pre-select one)
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWhatsOn:)
													 name:kArgusChannelGroupsDone
												   object:[argus ChannelGroups]];
		
		// be notified when the active channel group changes (from another view probably)
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWhatsOn:)
													 name:kArgusSelectedChannelGroupChanged
												   object:[argus ChannelGroups]];
	
	}
	return self;
}

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

- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
    [super viewWillAppear:animated];

	// refresh CurrentandNext if we have a Selected Channel Group
	if ([[argus ChannelGroups] SelectedChannelGroup])
	{
		ArgusChannelGroup *scg = [[argus ChannelGroups] SelectedChannelGroup];
		[scg getCurrentAndNext];
	}
	
	autoRedrawTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(autoRedraw) userInfo:nil repeats:YES];
	[self reloadData];
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
	
	[autoRedrawTimer invalidate];
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
    // Return the number of rows in the section.
	ArgusChannelGroup *scg = [[argus ChannelGroups] SelectedChannelGroup];
    return [[scg CurrentAndNext] count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	ArgusChannelGroup *scg = [[argus ChannelGroups] SelectedChannelGroup];
	return [scg Property:kGroupName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WhatsOnCell"];
    
    // Configure the cell...
	
	ArgusChannelGroup *scg = [[argus ChannelGroups] SelectedChannelGroup];
	ArgusChannel *channel;
    if ((channel = [[scg CurrentAndNext] objectAtIndex:indexPath.row]))
    {
		UIImage *img = [[channel Logo] image];
		UIImageView *logo = (UIImageView *)[cell viewWithTag:0];
		if (img)
		{
			logo.image = img;
		}
		else
		{
			// logo not done yet, wait for a notification and we'll load it later?
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(reloadData)
														 name:kArgusChannelLogoDone
													   object:[channel Logo]];

			logo.image = nil;
			
			// draw a spinny for now?
		}

        UILabel *now_label = (UILabel *)[cell viewWithTag:1];
        UILabel *next_label = (UILabel *)[cell viewWithTag:2];
		
		UIImageView *now_iv = (UIImageView *)[cell viewWithTag:4];
		UIImageView *next_iv = (UIImageView *)[cell viewWithTag:5];

        NSDateFormatter *df = [[NSDateFormatter alloc] initWithPOSIXLocaleAndFormat:@"HH:mm"];
					
        ArgusProgramme *now_data = [channel CurrentProgramme];
		now_label.textColor = [ArgusProgramme fgColourStd];

		if (now_data && now_data != (ArgusProgramme *)[NSNull null] && [now_data Property:kTitle])
		{
			NSDate *date = [now_data Property:kStartTime];
			now_label.text = [NSString stringWithFormat:@"%@ %@", [df stringFromDate:date], [now_data Property:kTitle]];

			NSDate *StartTime = [now_data Property:kStartTime];
			
			UIProgressView *pctDone = (UIProgressView *)[cell viewWithTag:3];
			
			// calculate how far through we are for the progressbar
			NSTimeInterval secondsIn = [[NSDate date] timeIntervalSinceDate:StartTime];
			
			if (secondsIn < 0)
			{
				// programme hasn't started
				pctDone.progress = 0;
			}
			else
			{
				NSTimeInterval duration = [[now_data Property:kStopTime] timeIntervalSinceDate:StartTime];
				// we have started, and we are secondsIn/duration done.
				double done = secondsIn/duration;
				pctDone.progress = done;
			}
			if ([now_data upcomingProgramme])
				now_iv.image = [[now_data upcomingProgramme] iconImage];
			else
				now_iv.image = nil;

		}
		else
			now_label.text = NSLocalizedString(@"No Data Available", @"Now/Next display when no programme in the EPG");

		
		ArgusProgramme *next_data = [channel NextProgramme];
		next_label.textColor = [ArgusProgramme fgColourStd];
		if (next_data && next_data != (ArgusProgramme *)[NSNull null] && [next_data Property:kTitle])
		{
			NSDate *date = [next_data Property:kStartTime];
			next_label.text = [NSString stringWithFormat:@"%@ %@", [df stringFromDate:date], [next_data Property:kTitle]];
			if ([next_data upcomingProgramme])
				next_iv.image = [[next_data upcomingProgramme] iconImage];
			else
				next_iv.image = nil;


		}
		else
			next_label.text = NSLocalizedString(@"No Data Available", @"Now/Next display when no programme in the EPG");
    }
    else
    {
        // spinny?
    }
	
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIColor *colourToSet = (indexPath.row % 2) ? [ArgusProgramme bgColourStdOdd] : [ArgusProgramme bgColourStdEven];
	cell.backgroundColor = colourToSet;
}



#pragma mark - Navigation Bar Buttons
-(IBAction)refreshWhatsOn:(id)sender
{
	NSLog(@"%s (%@)", __PRETTY_FUNCTION__, sender);
	
	ArgusChannelGroup *scg = [[argus ChannelGroups] SelectedChannelGroup];
	[scg getCurrentAndNext];
}

#pragma mark - Segue Handling
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ProgrammeList"])
    {
        ProgrammeListViewController *dvc = (ProgrammeListViewController *)[segue destinationViewController];
        
        // tell dvc which channel has been tapped on
		NSInteger r = [[[self tableView] indexPathForSelectedRow] row];
		ArgusChannelGroup *scg = [[argus ChannelGroups] SelectedChannelGroup];
		[dvc setChannel:[[scg CurrentAndNext] objectAtIndex:r]];
    }
	
    if ([[segue identifier] isEqualToString:@"SelectChannelGroup"])
	{
		// prevent more than one popup being visible
		if (iPad())
			[popoverController dismissPopoverAnimated:YES];

		UINavigationController *navC = [segue destinationViewController];
		SelectChannelGroupViewController *dvc = (SelectChannelGroupViewController *)[navC visibleViewController];
		
		// we pass in the global argus object here
		[dvc setMyArgus:argus];
		
		[dvc setForceChannelType:ArgusChannelTypeAny];
		
		// a link back to us from the SelectChannelGroup controller, so it can tell us what they selected.
		[dvc setDelegate:self];
		
		if (iPad())
		{
			popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
			[dvc setPopoverController:popoverController];
		}
	}
}

#pragma mark - Delegate Handling
-(void)didSelectChannelGroup:(ArgusChannelGroup *)ChannelGroup
{
	[[argus ChannelGroups] setSelectedChannelGroup:ChannelGroup];

	// don't do this here anymore, kArgusSelectedChannelGroupChanged observer will do it
	// our delegate (SelectChannelGroup) selected something; get CaN for it
	//[ChannelGroup getCurrentAndNext];
}

#pragma mark - Data Handling


-(void)autoRedraw
{
	[self.tableView reloadData];
	
	// if any Current programmes have finished, get new CurrentAndNext data
	// the CurrentAndNext object stores the earliest StopTime it finds when populating
	// so we can just check that one item
	ArgusChannelGroup *scg = [[argus ChannelGroups] SelectedChannelGroup];
	if ([[scg earliestCurrentStopTime] timeIntervalSinceNow] < 0)
	{
		if (isOnWWAN())
		{
			if (autoReloadDataOn3G)
				[self refreshWhatsOn:self];
		}
		else
			[self refreshWhatsOn:self];
	}
}

-(void)reloadData
{
	[self.tableView reloadData];
}

@end
