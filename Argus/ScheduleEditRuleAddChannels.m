//
//  ScheduleEditRuleAddChannels.m
//  Argus
//
//  Created by Chris Elsworth on 29/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditRuleAddChannels.h"
#import "ArgusSchedule.h"
#import "ArgusChannelGroup.h"
#import "ArgusChannel.h"

@implementation ScheduleEditRuleAddChannels
@synthesize localArgus;
@synthesize Schedule, Rule;

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
	
	// this is a local argus object so we don't have to mess with the global one
	// when changing Channel Groups; a schedule can have channels from multiple
	// channel groups etc, and if AddChannels view changes it, we don't want to
	// interfere with WhatsOn etc.
	localArgus = [Argus new];
	
	// set the SelectedChannelType to the Schedule ChannelType
	[[localArgus ChannelGroups] setSelectedChannelType:[Schedule ChannelType]];
	
	// notify when localArgus finishes getting channel groups
	// we'll autoselect the first one and get channels for it
	// then we can finally draw the table..
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(ChannelGroupsDone:)
												 name:kArgusChannelGroupsDone
											   object:[localArgus ChannelGroups]];

	// and get the Channel Groups for that Channel Type
	[[localArgus ChannelGroups] getChannelGroups];
}
-(void)ChannelGroupsDone:(NSNotification *)notify
{
	// select the first channel group in the appropriate Channel Type

	switch ([Schedule ChannelType])
	{
		default:
		case ArgusChannelTypeTelevision:
			[self didSelectChannelGroup:[[[localArgus ChannelGroups] TvEntries] objectAtIndex:0]];
			break;
			
		case ArgusChannelTypeRadio:
			[self didSelectChannelGroup:[[[localArgus ChannelGroups] RadioEntries] objectAtIndex:0]];
			break;
	}
	//[self didSelectChannelGroup:[[[localArgus ChannelGroups] Entries] objectAtIndex:0]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
	// top section is "Add All Channels"
	if (section == 0) return 1;
	
    // second section is list of channels
    return [[[[localArgus ChannelGroups] SelectedChannelGroup] Channels] count];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// top section has no header
	if (section == 0) return nil;
	
	// second section is group name
	return [[[localArgus ChannelGroups] SelectedChannelGroup] Property:kGroupName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		// top section is a single Add All Channels cell
		NSString *CellIdentifier = @"AddAllChannelsCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		return cell;
	}
	
	
    NSString *CellIdentifier = @"AddChannelCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    ArgusChannel *c = [[[[localArgus ChannelGroups] SelectedChannelGroup] Channels] objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [c Property:kDisplayName];
	
	if ([[Rule Arguments] containsObject:[c Property:kChannelId]])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;	
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ArgusChannelGroup *cg = [[localArgus ChannelGroups] SelectedChannelGroup];
	
	if (indexPath.section == 0)
	{
		// section 0 has one cell which is "Add All Channels"
		for (ArgusChannel *c in [cg Channels])
		{
			[self updateChannel:c addOnly:YES];
		}
		NSIndexSet *is = [[NSIndexSet alloc] initWithIndex:1];
		[tableView reloadSections:is withRowAnimation:UITableViewRowAnimationFade];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}

	// just one channel to worry about then
	
	// selected channel
	ArgusChannel *c = [[cg Channels] objectAtIndex:indexPath.row];
	
	[self updateChannel:c addOnly:NO];
	
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
					 withRowAnimation:UITableViewRowAnimationFade];
}

-(void)updateChannel:(ArgusChannel *)c addOnly:(BOOL)addOnly
{
	if ([[Rule Arguments] containsObject:[c Property:kChannelId]])
	{
		if (!addOnly)
		{
			// channel was selected already, remove it if addOnly isn't set
			[[Rule Arguments] removeObject:[c Property:kChannelId]];
			
			if ([[Rule Arguments] count] == 0)
			{
				[Rule setArguments:nil];
				[Rule setMatchType:0];
			}
		}
	}
	else
	{
		// if necessary, init Arguments to an array
		if (![Rule Arguments])
			[Rule setArguments:[NSMutableArray new]];
		
		// if a Matchtype isn't set, default to Contains
		if ([Rule MatchType] == 0)
			[Rule setMatchType:ArgusScheduleRuleMatchTypeContains];
		
		// channel not selected, add it
		[[Rule Arguments] addObject:[c Property:kChannelId]];
	}
	
	
	// parent will redraw on viewWillAppear
}

-(void)reloadData
{
	[self.tableView reloadData];
}

#pragma mark - Segue Handling
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{	
    if ([[segue identifier] isEqualToString:@"SelectChannelGroup"])
	{
		UINavigationController *navC = [segue destinationViewController];
		SelectChannelGroupViewController *dvc = [[navC viewControllers] objectAtIndex:0];
		
		// a link back to us from the SelectChannelGroup controller, so it can tell us what they selected.
		dvc.delegate = self;
		
		// pass in our localArgus object, so it doesn't have to mess with the global one
		dvc.myArgus = localArgus;
		
		// only allow Schedule.ChannelType to be selected; we don't want a TV channel adding to a Radio schedule!
		dvc.ForceChannelType = [Schedule ChannelType];
		
		if (iPad())
			dvc.popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
	}
}

#pragma mark - SelectChannelGroup delegate
-(void)didSelectChannelGroup:(ArgusChannelGroup *)ChannelGroup
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[[localArgus ChannelGroups] setSelectedChannelGroup:ChannelGroup];
	
	// trigger fetching channels for this group. When done, we can draw them
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadData)
												 name:kArgusChannelGroupChannelsDone
											   object:ChannelGroup];

	[ChannelGroup getChannels];
}

@end
