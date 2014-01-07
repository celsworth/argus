//
//  ScheduleViewController.m
//  Argus
//
//  Created by Chris Elsworth on 05/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ScheduleEditKeepTVC.h"
#import "ScheduleEditRulesTVC.h"
#import "ScheduleEditPreRecordTVC.h"
#import "ScheduleEditFileFormatTVC.h"
#import "ScheduleViewPRHTVC.h"
#import "UpcomingProgrammesTVC.h"

#import "ArgusRecordingFileFormat.h"

#import "NSNumber+humanSize.h"

#import "AppDelegate.h"

@implementation ScheduleViewController

@synthesize title, active, priority, priorityStepper, keep, type;
@synthesize prerec, postrec, rules, fileformat, del;

@synthesize Schedule;

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
	if (DEBUG) NSLog(@"%s", __PRETTY_FUNCTION__);
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
		
	// redraw on any schedule update
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redraw)
												 name:kArgusScheduleDone
											   object:Schedule];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redraw)
												 name:kArgusSaveScheduleDone
											   object:Schedule];

	// schedule details are loaded in the segue from the previous view
	// initial draw is done in viewWillAppear
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	//delbtn = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

    [super viewWillAppear:animated];

	[self redraw];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)redraw
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	if ([Schedule isModified])
		[[self navigationItem] setPrompt:NSLocalizedString(@"Schedule changed, don't forget to Save!", nil)];
	else
		[[self navigationItem] setPrompt:nil];
	
	if ([Schedule Property:kName])
	{
		[[self navigationItem] setTitle:[Schedule Property:kName]];
		title.text = [Schedule Property:kName];
	}
	else
	{
		[[self navigationItem] setTitle:NSLocalizedString(@"Creating New Schedule", nil)];
	}
	
	[active setOn:[Schedule IsActive]];
	
	priority.text = [[Schedule Property:kSchedulePriority] priorityString];
	priorityStepper.value = [[Schedule Property:kSchedulePriority] intValue];
	
	switch ((ArgusScheduleType)[Schedule ScheduleType])
	{
		case ArgusScheduleTypeRecording: [type setSelectedSegmentIndex:0]; break;
		case ArgusScheduleTypeAlert: [type setSelectedSegmentIndex:1]; break;
		case ArgusScheduleTypeSuggestion: [type setSelectedSegmentIndex:2]; break;
	}
	
	ArgusKeepUntilMode k = [[Schedule Property:kKeepUntilMode] unsignedIntValue];
	if (k == ArgusKeepUntilModeForever || k == ArgusKeepUntilModeUntilSpaceIsNeeded)
	{
		keep.text = [ArgusSchedule stringForKeepUntilMode:k];
	}
	else
	{
		keep.text = [NSString stringWithFormat:@"%@ %@", [Schedule Property:kKeepUntilValue], [ArgusSchedule stringForKeepUntilMode:k]];
	}
	
	if ([Schedule Property:kPreRecordSeconds])
	{
		prerec.detailTextLabel.text = [[Schedule Property:kPreRecordSeconds] hmsString];
	}
	else
	{
		prerec.detailTextLabel.text = NSLocalizedString(@"default", nil);
	}
	if ([Schedule Property:kPostRecordSeconds])
	{
		postrec.detailTextLabel.text = [[Schedule Property:kPostRecordSeconds] hmsString];
	}
	else
	{
		postrec.detailTextLabel.text = NSLocalizedString(@"default", nil);
	}
	
	ArgusGuid *RecordingFileFormatId = [Schedule Property:kRecordingFileFormatId];
	if (RecordingFileFormatId)
	{
		ArgusRecordingFileFormat *rff = [[argus RecordingFileFormats] RecordingFileFormatsKeyedById][RecordingFileFormatId];
		fileformat.detailTextLabel.text = [rff Property:kName];
	}
	else
	{
		fileformat.detailTextLabel.text = NSLocalizedString(@"default", nil);
	}
	
}

// STATIC TABLE CELL CLASS
// no functions to return section/cell count or cellForIndexPath.


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// bring up keyboard when they tap anywhere in Name cell
	if (indexPath.section == 0 && indexPath.row == 0)
		[title becomeFirstResponder];

	// delete schedule button
	// CAUTION - this relies on the table layout not changing, and being the same for iPad and iPhone!!
	if (indexPath.section == 6 && indexPath.row == 0)
		[self deleteSchedule];
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Segue Handling
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ScheduleEditKeep"])
    {
        ScheduleEditKeepTVC *dvc = (ScheduleEditKeepTVC *)[segue destinationViewController];
        
		// send over a pointer to our Schedule; dvc uses this to display and also update,
		// meaning our copy is updated as well when something is changed.
		dvc.Schedule = Schedule;
    }
	
	if ([[segue identifier] isEqualToString:@"ScheduleEditPreRecord"])
    {
        ScheduleEditPreRecordTVC *dvc = (ScheduleEditPreRecordTVC *)[segue destinationViewController];
        
		// send over a pointer to our Schedule
		dvc.Schedule = Schedule;
		dvc.editType = ArgusScheduleEditTypePreRecord;
    }
	if ([[segue identifier] isEqualToString:@"ScheduleEditPostRecord"])
    {
		// the Pre-Record class handles this too, just with another editType
        ScheduleEditPreRecordTVC *dvc = (ScheduleEditPreRecordTVC *)[segue destinationViewController];
        
		// send over a pointer to our Schedule
		dvc.Schedule = Schedule;
		dvc.editType = ArgusScheduleEditTypePostRecord;
    }
	
	if ([[segue identifier] isEqualToString:@"ScheduleEditFileFormat"])
    {
		// the Pre-Record class handles this too, just with another editType
        ScheduleEditFileFormatTVC *dvc = (ScheduleEditFileFormatTVC *)[segue destinationViewController];
        
		// send over a pointer to our Schedule
		dvc.ScheduleId = [Schedule Property:kScheduleId];
    }

	if ([[segue identifier] isEqualToString:@"ScheduleEditRules"])
    {
        ScheduleEditRulesTVC *dvc = (ScheduleEditRulesTVC *)[segue destinationViewController];
        
		// send over a pointer to our Schedule; dvc uses this to display and also update,
		// meaning our copy is updated as well when something is changed.
		dvc.Schedule = Schedule;
    }
	if ([[segue identifier] isEqualToString:@"UpcomingProgrammes"])
    {
        UpcomingProgrammesTVC *dvc = (UpcomingProgrammesTVC *)[segue destinationViewController];
        
		// send over a pointer to our Schedule
		dvc.Schedule = Schedule;
    }

	if ([[segue identifier] isEqualToString:@"ScheduleViewPRH"])
    {
		// the Pre-Record class handles this too, just with another editType
        ScheduleViewPRHTVC *dvc = (ScheduleViewPRHTVC *)[segue destinationViewController];
        
		// send over a pointer to our Schedule
		dvc.ScheduleId = [Schedule Property:kScheduleId];
    }
	
}

-(IBAction)stepperChanged:(UIStepper *)sender
{
	NSInteger value = [sender value];
	[Schedule setSchedulePriority:@(value)];
	[self redraw];
}

-(IBAction)scheduleTypeSegmentChanged:(id)sender
{
	switch ([sender selectedSegmentIndex])
	{
		case 0: [Schedule setScheduleType:ArgusScheduleTypeRecording]; break;
		case 1: [Schedule setScheduleType:ArgusScheduleTypeAlert]; break;
		case 2: [Schedule setScheduleType:ArgusScheduleTypeSuggestion]; break;			
	}
	[self redraw];
}

-(IBAction)textFieldChanged:(id)sender
{	
	NSString *val = [[sender text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	[Schedule setName:val];
}
-(IBAction)titleReturn:(id)sender
{
	[title resignFirstResponder];
	[self redraw];
}

-(IBAction)activeChanged:(id)sender
{
	[Schedule setIsActive:[sender isOn]];
	[self redraw];
}


-(IBAction)saveButtonPressed:(id)sender
{
	// some sanity checking
	if (! [Schedule Property:kName] || [[Schedule Property:kName] length] == 0)
	{
		// Name cannot be empty
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Save Error", @"an error when trying to save a schedule")
														message:NSLocalizedString(@"Schedule name cannot be empty", nil)
													   delegate:nil 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	[Schedule save];
}


-(void)deleteSchedule
{
	UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Confirm Deletion", @"delete schedule confirmation title")
													delegate:self
										   cancelButtonTitle:NSLocalizedString(@"Cancel", @"delete schedule cancellation button")
									  destructiveButtonTitle:NSLocalizedString(@"Delete", @"delete schedule confirmation button")
										   otherButtonTitles:nil];
	if (iPad())
		// no tab bar on iPad
		[as showInView:self.view];
	else
		[as showFromTabBar:self.tabBarController.tabBar];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	// cancel == 1
	// delete == 0
	if (buttonIndex == 0)
	{
		// trigger the deletion
		[Schedule delete];
		
		// this schedule no longer exists so remove ourselves from view
		[[self navigationController] popViewControllerAnimated:YES];
	}
}

@end
