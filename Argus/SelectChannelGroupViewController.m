//
//  SelectChannelGroupViewController.m
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "SelectChannelGroupViewController.h"

#import "ArgusProgramme.h"

#import "AppDelegate.h"

@implementation SelectChannelGroupViewController
@synthesize myArgus;
@synthesize ForceChannelType;
@synthesize SelectedChannelGroup;
@synthesize delegate, popoverController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// reload our table whenever the list of Channel Groups is updated
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData)
												 name:kArgusChannelGroupsDone
											   object:[myArgus ChannelGroups]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	// this class maintains a local record of which ChannelGroup is selected
	// pulled in here at display time - it assumes that we're displayed modally and nothing else
	// will change them while we're onscreen
	SelectedChannelGroup = [[myArgus ChannelGroups] SelectedChannelGroup];
}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (iPad())
	{
		//CGRect f = [[self tableView] bounds];
		//[[self popoverController] setPopoverContentSize:CGSizeMake(f.size.width, f.size.height) animated:NO];
	}
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
	{
		default:
		case 0: return [[[myArgus ChannelGroups] TvEntries] count];
		case 1: return [[[myArgus ChannelGroups] RadioEntries] count];
	}
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		default:
		case 0: return NSLocalizedString(@"Television", nil);
		case 1: return NSLocalizedString(@"Radio", nil);			
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectChannelGroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	
	NSMutableArray *cgs;
	switch (indexPath.section)
	{
		case 0: cgs = [[myArgus ChannelGroups] TvEntries]; break;
		case 1: cgs = [[myArgus ChannelGroups] RadioEntries]; break;
	}
	
	
    // Configure the cell...
	ArgusChannelGroup *cg = cgs[indexPath.row];
	cell.textLabel.text = [cg Property:kGroupName];
	
	if ([[SelectedChannelGroup ChannelGroupId] isEqualToString:[cg ChannelGroupId]])
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (ForceChannelType != ArgusChannelTypeAny && ForceChannelType != indexPath.section)
	{
		cell.textLabel.textColor = [UIColor lightGrayColor];
		cell.userInteractionEnabled = NO;
	}
	else
	{
		cell.textLabel.textColor = [UIColor blackColor];
		cell.userInteractionEnabled = YES;
	}

	
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
	NSMutableArray *cgs;
	switch (indexPath.section)
	{
		case 0: cgs = [[myArgus ChannelGroups] TvEntries]; break;
		case 1: cgs = [[myArgus ChannelGroups] RadioEntries]; break;
	}
		
	ArgusChannelGroup *ncg = cgs[indexPath.row];
	if (SelectedChannelGroup == ncg) return; // avoid doing useless work
	SelectedChannelGroup = ncg;
	
	// tell the our parent controller (our delegate) what they selected.
	// delegate must conform to protocol <SelectChannelGroupDelegate>
	[delegate didSelectChannelGroup:SelectedChannelGroup];
	
	[self.tableView reloadData];
}

-(IBAction)refreshChannelGroups:(id)sender
{
	[[myArgus ChannelGroups] getChannelGroups];	
}

-(void)reloadData
{
	[self.tableView reloadData];
}

-(IBAction)didPressDone:(id)sender
{
	if (iPad())
		[popoverController dismissPopoverAnimated:YES];
	else
		[self dismissViewControllerAnimated:YES completion:nil];
}

@end
