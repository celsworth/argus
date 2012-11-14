//
//  ScheduleEditFileFormatTVC.m
//  Argus
//
//  Created by Chris Elsworth on 15/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditFileFormatTVC.h"
#import "ArgusRecordingFileFormat.h"

#import "AppDelegate.h"

@implementation ScheduleEditFileFormatTVC
@synthesize ScheduleId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redraw)
												 name:kArgusRecordingFileFormatsDone
											   object:[argus RecordingFileFormats]];
	
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
	// "default" recording file format dummy cell
	// list of RecordingFileFormats
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch ((ArgusScheduleEditFileFormatTableSection)section)
	{
		case ArgusScheduleEditFileFormatTableSectionDefault:
			return 1;
			break;
		
		case ArgusScheduleEditFileFormatTableSectionList:
			return [[[argus RecordingFileFormats] RecordingFileFormats] count];
	}
	/* NOTREACHED */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
	ArgusSchedule *Schedule = [ArgusSchedule ScheduleForScheduleId:ScheduleId];
	ArgusGuid *RecordingFileFormatId = [Schedule Property:kRecordingFileFormatId];
		
	switch ((ArgusScheduleEditFileFormatTableSection)indexPath.section)
	{	
		case ArgusScheduleEditFileFormatTableSectionDefault:
			cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingFileFormatDefaultCell"];
			if (!RecordingFileFormatId) // null == default
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			else
				cell.accessoryType = UITableViewCellAccessoryNone;
			break;
		
		case ArgusScheduleEditFileFormatTableSectionList:
			cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingFileFormatCell"];
			
			ArgusRecordingFileFormat *rff = [[[argus RecordingFileFormats] RecordingFileFormats] objectAtIndex:indexPath.row];
			
			cell.textLabel.text = [rff Property:kName];
			cell.detailTextLabel.text = [rff Property:kFormat];
			
			if ([RecordingFileFormatId isEqualToString:[rff Property:kRecordingFileFormatId]])
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			else
				cell.accessoryType = UITableViewCellAccessoryNone;
			
			break;
	}
	
	return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ArgusSchedule *Schedule = [ArgusSchedule ScheduleForScheduleId:ScheduleId];
	ArgusGuid *RecordingFileFormatId = [Schedule Property:kRecordingFileFormatId];

	switch ((ArgusScheduleEditFileFormatTableSection)indexPath.section)
	{	
		case ArgusScheduleEditFileFormatTableSectionDefault:
		{
			if (RecordingFileFormatId != nil)
				[Schedule setRecordingFileFormatId:(ArgusGuid *)[NSNull null]];
			break;
		}
			
		case ArgusScheduleEditFileFormatTableSectionList:
		{
			ArgusRecordingFileFormat *rff = [[[argus RecordingFileFormats] RecordingFileFormats] objectAtIndex:indexPath.row];
			if (![RecordingFileFormatId isEqualToString:[rff Property:kRecordingFileFormatId]])
				[Schedule setRecordingFileFormatId:[rff Property:kRecordingFileFormatId]];
			break;
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[tableView reloadData];
}

-(IBAction)refreshPressed:(id)sender
{
	[[argus RecordingFileFormats] getRecordingFileFormats];
	
}

@end
