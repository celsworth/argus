//
//  ProgrammeListViewController.m
//  Argus
//
//  Created by Chris Elsworth on 01/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ProgrammeListViewController.h"
#import "ProgrammeDetailsViewController.h"

#import "NSDateFormatter+LocaleAdditions.h"
#import "UILabel+Alignment.h"

#import "MasterViewController.h"

#import "AppDelegate.h"

#import "ProgrammeCell.h"

@implementation ProgrammeListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[[self navigationItem] setTitle:[self.Channel Property:kDisplayName]];
	
	// if the channel has some Programmes present already, use those and just set fetchedUpTo
	if ([self.Channel Programmes] && [[self.Channel Programmes] count])
	{
		self.fetchStart = [[self.Channel Programmes][0] Property:kStartTime];
		self.fetchEnd = [[[self.Channel Programmes] lastObject] Property:kStopTime];
	}
	else
	{
		// none present, fetch a few initial programmes from $NOW to $NOW + FETCH_PERIOD_INITIAL
		self.fetchStart = [NSDate date];
		self.fetchEnd = [NSDate dateWithTimeIntervalSinceNow:FETCH_PERIOD_INITIAL];
		[self.Channel getProgrammesFrom:self.fetchStart to:self.fetchEnd];
		self.isFetchingMore = YES;
	}
	
	// tell us when new programmes are ready to display
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(programmesDone)
												 name:kArgusProgrammesDone
											   object:self.Channel];
	
	// redraw our rows when the sidepanel changes, so we can recalculate heights
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadData)
												 name:kArgusSidePanelDisplayStateChanged
											   object:nil];

	// scroll to the programme that is on now
	NSInteger row = -1;
	for (ArgusProgramme *p in [self.Channel Programmes])
	{
		if ([p isOnNow])
		{
			row = [[self.Channel Programmes] indexOfObject:p];
			break;
		}
	}
	if (row != -1)
		[[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
								atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	
	[self.view setBackgroundColor:[ArgusColours bgColour]];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
    [super viewWillAppear:animated];
	[[self tableView] reloadData];
	
	self.autoRedrawTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
															target:self.tableView
														  selector:@selector(reloadData)
														  userInfo:nil
														   repeats:YES];
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
	
	[self.autoRedrawTimer invalidate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	// recalculate row heights so we still display properly
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
    // Return the number of rows in the section.
	return [[self.Channel Programmes] count] + 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//	NSLog(@"%s %@", __PRETTY_FUNCTION__, indexPath);
	
	if ([[self.Channel Programmes] count] == 0)
		return 50.0f;
	
	// last row is "fetch more" which is static at 50px
	if (indexPath.row == [[self.Channel Programmes] count])
		return 50.0f;
	
	ArgusProgramme *p;
	if ((p = [self.Channel Programmes][indexPath.row]))
	{
		// work out our optimal height
		if ([p Property:kDescription])
		{
			CGFloat width, fontSize;
			
			// work out how wide our description label will be
			if (iPad())
			{
				// try to work out how wide the description box is.
				// this uses the widths we know in portrait
				// This is 768px (table width) minus 636px (desc box width)
				// take that off actual table width and hopefully we cope with landscape too
				width = tableView.frame.size.width - (768-636);
				fontSize = 15.0;
			}
			else
			{
				// on iPhone, the numbers are 320 and 228
				width = tableView.frame.size.width - (320-228);
				fontSize = 13.0;
			}
			
			CGSize constrain = CGSizeMake(width, MAXFLOAT);
			// this sucks, I don't want to specify the font here :(
			UIFont *font = [UIFont systemFontOfSize:fontSize];
			
			if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
			{
				// iOS6 and below; we know this is deprecated so ignore the warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
				CGSize tmp = [[p Property:kDescription] sizeWithFont:font
												   constrainedToSize:constrain
													   lineBreakMode:UILineBreakModeWordWrap];
#pragma clang diagnostic pop
				return (iPad() ? 40.0f : 30.0f) + ceil(tmp.height);
			}
			else
			{
				// iOS7+
				CGRect tmp = [[p Property:kDescription] boundingRectWithSize:constrain
																	 options:NSStringDrawingUsesLineFragmentOrigin
																  attributes:@{NSFontAttributeName:font}
																	 context:nil];
				return (iPad() ? 40.0f : 30.0f) + ceil(tmp.size.height);
			}
		}
	}
	
	// failsafe ;)
	NSLog(@"%s: no programme details for row %d", __PRETTY_FUNCTION__, indexPath.row);
	return 50.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
		
	if (indexPath.row == [[self.Channel Programmes] count])
	{
		// last row in this table is a dummy "fetch more" cell, when tapped it will do exactly that.
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FetchMoreCell"];
		if (self.isFetchingMore)
		{
			[cell viewWithTag:1].hidden = YES;
			[cell viewWithTag:2].hidden = NO;
			[(UIActivityIndicatorView *)[cell viewWithTag:2] startAnimating];
		}
		else
		{
			[cell viewWithTag:1].hidden = NO;			
			[(UIActivityIndicatorView *)[cell viewWithTag:2] stopAnimating];
		}
		return cell;
	}
	else
	{
		ProgrammeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgrammeCell"];
		ArgusProgramme *p = [self.Channel Programmes][indexPath.row];
		[cell populateCellWithProgramme:p];
		return cell;
	}
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger c = [[self.Channel Programmes] count];
	if (c == 0) // no programmes!
		return;

	if (indexPath.row == c)
	{
		// fetch more cell
		cell.backgroundColor = [UIColor clearColor];
		return;
	}
	
	ArgusProgramme *p = [self.Channel Programmes][indexPath.row];

	// start off with standard table odd/even colour
	UIColor *colourToSet = (indexPath.row % 2) ? [ArgusProgramme bgColourStdOdd] : [ArgusProgramme bgColourStdEven];
	
	// programmes that are on now
	// this is overridden by active recordings since it's above the next block..
	if ([p isOnNow])
		colourToSet = [ArgusProgramme bgColourOnNow];
	
	ArgusUpcomingProgramme *upc = [p upcomingProgramme];
	if (upc)
	{
		// icon is set in cellForRowAtIndexPath
		
		// set a red background for programmes that are goign to be recorded
		switch ([upc scheduleStatus])
		{
			case ArgusUpcomingProgrammeScheduleStatusRecordingScheduled:
			case ArgusUpcomingProgrammeScheduleStatusRecordingScheduledConflict:

				colourToSet = [ArgusProgramme bgColourUpcomingRec];
				break;
				
			default:
				// nothing else gets a colour so far
				break;
		}
		
	}
	else
	{
		//iconView.image = nil;
		//[iconView removeFromSuperview];
	}
	
	cell.backgroundColor = colourToSet;
}



#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	// if we ever want the detail disclosure indicator to do something other than tapping on the row
	// this is the place to do it.. for now it just invokes the same segue
	[[self tableView] selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self performSegueWithIdentifier:@"ProgrammeDetails" sender:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.isFetchingMore == NO && indexPath.row == [[self.Channel Programmes] count])
	{
		// fetching more programmes
		self.isFetchingMore = YES;
		[self reloadData]; // hides "fetch more", show spinner
		
		self.fetchEnd = [self.fetchEnd dateByAddingTimeInterval:FETCH_PERIOD_SUBSEQUENT];
		[self.Channel getProgrammesFrom:self.fetchStart to:self.fetchEnd];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue Handling
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ProgrammeDetails"])
    {
        ProgrammeDetailsViewController *dvc = (ProgrammeDetailsViewController *)[segue destinationViewController];
        
        // tell dvc which programme has been tapped on
		NSInteger r = [self.tableView indexPathForSelectedRow].row;
		dvc.Programme = [self.Channel Programmes][r];
	}
}

-(void)programmesDone
{
	self.isFetchingMore = NO;
	[self reloadData];
}

-(void)reloadData
{
	[self.tableView reloadData];
}

@end
