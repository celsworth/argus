//
//  UpcomingProgrammeEditTVC.m
//  Argus
//
//  Created by Chris Elsworth on 08/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "UpcomingProgrammeEditTVC.h"
#import "UpcomingProgrammeEditPreRecordTVC.h"

#import "ArgusUpcomingProgrammes.h"
#import "AppDelegate.h"

#import "NSNumber+humanSize.h"

@implementation UpcomingProgrammeEditTVC
@synthesize UpcomingProgramId;

@synthesize priority, priorityStepper;
@synthesize prerec, postrec;
@synthesize cancelCell, prhCell;
@synthesize cancelText, cancelSpinner;
@synthesize prhText, prhSpinner;

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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redraw)
												 name:kArgusUpcomingProgrammesDone
											   object:[argus UpcomingProgrammes]];

	// it'd be nice just to respond to notifications from the right upcoming programme object
	// but we don't know what it is, we just have a UpcomingProgramId so the object can change
	// responding to any of them isn't so bad anyway, there's hardly a flood of saves and cancels


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
	
	[self redraw];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


-(void)redraw
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	ArgusUpcomingProgramme *Programme = [ArgusUpcomingProgramme UpcomingProgrammeForUpcomingProgramId:UpcomingProgramId];
	
	
	if ([Programme isModified])
		[[self navigationItem] setPrompt:NSLocalizedString(@"Programme changed, don't forget to Save!", nil)];
	else
		[[self navigationItem] setPrompt:nil];
	
	priority.text = [[Programme Property:kPriority] priorityString];
	priorityStepper.value = [[Programme Property:kPriority] intValue];
	
	if ([Programme Property:kPreRecordSeconds])
	{
		prerec.detailTextLabel.text = [[Programme Property:kPreRecordSeconds] hmsString];
	}
	else
	{
		prerec.detailTextLabel.text = NSLocalizedString(@"schedule default", @"no defined pre/post-record time for a programme");
	}
	if ([Programme Property:kPostRecordSeconds])
	{
		postrec.detailTextLabel.text = [[Programme Property:kPostRecordSeconds] hmsString];
	}
	else
	{
		postrec.detailTextLabel.text = NSLocalizedString(@"schedule default", @"no defined pre/post-record time for a programme");
	}

	ArgusCancellationReason cancellationReason = [[Programme Property:kCancellationReason] intValue];
	BOOL overrideDisableCancelCell = NO;
	
	switch (cancellationReason)
	{
		case ArgusCancellationReasonNone:
			// not cancelled, give them the option
			cancelText.text = NSLocalizedString(@"Cancel this Programme", @"cancel an upcoming recording");
			break;
			
		case ArgusCancellationReasonPreviouslyRecorded:
			// disable cancel cell entirely, it doesn't function when the programme is in recorded history
			overrideDisableCancelCell = YES;
			break;
			
		default:
			// other possibilities, offer uncancel
			cancelText.text = NSLocalizedString(@"Uncancel this Programme", @"reverse a cancelled recording");
			break;
			
	}

	if (overrideDisableCancelCell || [Programme IsCancelling] || [Programme IsUncancelling])
	{
		cancelText.textColor = [UIColor lightGrayColor];
		[cancelCell setUserInteractionEnabled:NO];

		// only spin when waiting for something to complete, not when just overridden (PreviouslyRecorded)
		if ([Programme IsCancelling] || [Programme IsUncancelling])
			[cancelSpinner startAnimating];
	}
	else
	{
		cancelText.textColor = [UIColor blackColor];
		[cancelCell setUserInteractionEnabled:YES];

		[cancelSpinner stopAnimating];
	}

	// Recorded History buttons should only be active when the schedule type for this upcoming programme is Recording
	NSString *ScheduleId = [Programme Property:kScheduleId];
	ArgusSchedule *Schedule = [ArgusSchedule ScheduleForScheduleId:ScheduleId];
	if ((ArgusScheduleType)[[Schedule Property:kScheduleType] intValue] == ArgusScheduleTypeRecording)
	{
		switch (cancellationReason)
		{
			default:
				// if a programme is not cancelled, display both cancel and add to history
				prhText.text = NSLocalizedString(@"Add to Recorded History", nil);
				break;
				
			case ArgusCancellationReasonPreviouslyRecorded:
				// if cancelled because of previous recording, offer to remove from history
				prhText.text = NSLocalizedString(@"Remove from Recorded History", nil);
				break;
		}
		
		if ([Programme IsRemovingFromPRH] || [Programme IsAddingToPRH])
		{
			prhText.textColor = [UIColor lightGrayColor];
			[prhCell setUserInteractionEnabled:NO];
			[prhSpinner startAnimating];
		}
		else
		{
			prhText.textColor = [UIColor blackColor];
			[prhCell setUserInteractionEnabled:YES];
			[prhSpinner stopAnimating];
		}
	}
	else
	{
		// not a recording, disable the Recorded History cell
		prhText.textColor = [UIColor lightGrayColor];
		[prhCell setUserInteractionEnabled:NO];
		[prhSpinner stopAnimating];
	}
	
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ArgusUpcomingProgramme *Programme = [ArgusUpcomingProgramme UpcomingProgrammeForUpcomingProgramId:UpcomingProgramId];

	ArgusCancellationReason cancellationReason = [[Programme Property:kCancellationReason] intValue];

	// check if it's the "Cancel" or "Uncancel" cell
	// this is kind of crap, if the table layout changes in Interface Builder this'll be wrong
	if (indexPath.section == 2 && indexPath.row == 0)
	{
		switch (cancellationReason)
		{
			case ArgusCancellationReasonNone:
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpcomingChangeDone:)
															 name:kArgusCancelUpcomingProgrammeDone
														   object:Programme];
				[Programme cancelUpcomingProgramme];
				break;
				
			case ArgusCancellationReasonPreviouslyRecorded:
				// shouldn't get here
				break;
				
			default:
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpcomingChangeDone:)
															 name:kArgusUncancelUpcomingProgrammeDone
														   object:Programme];
				[Programme uncancelUpcomingProgramme];
				break;
				
		}

		// draws in spinner and disables cell because Programme.IsCancelling is now YES
		[self redraw];
	}
	
	if (indexPath.section == 3 && indexPath.row == 0)
	{
		
		if (cancellationReason == ArgusCancellationReasonPreviouslyRecorded)
		{
			// remove from recorded history
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpcomingChangeDone:)
														 name:kArgusRemoveFromPreviouslyRecordedHistoryDone
													   object:Programme];
			[Programme removeFromPreviouslyRecordedHistory];
		}
		else
		{
			// add to recorded history
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpcomingChangeDone:)
														 name:kArgusAddToPreviouslyRecordedHistoryDone
													   object:Programme];
			[Programme addToPreviouslyRecordedHistory];

		}
	}
	
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"UpcomingProgrammeEditPreRecord"])
	{
		UpcomingProgrammeEditPreRecordTVC *dvc = [segue destinationViewController];
		dvc.UpcomingProgramId = UpcomingProgramId;
		dvc.editType = ArgusScheduleEditTypePreRecord;
	}
	if ([[segue identifier] isEqualToString:@"UpcomingProgrammeEditPostRecord"])
	{
		UpcomingProgrammeEditPreRecordTVC *dvc = [segue destinationViewController];
		dvc.UpcomingProgramId = UpcomingProgramId;
		dvc.editType = ArgusScheduleEditTypePostRecord;
	}

}

#pragma mark - IBAction Selectors

-(IBAction)priorityChanged:(UIStepper *)sender
{
	ArgusUpcomingProgramme *Programme = [ArgusUpcomingProgramme UpcomingProgrammeForUpcomingProgramId:UpcomingProgramId];
	NSInteger value = [sender value];
	[Programme setPriority:[NSNumber numberWithInt:value]];
	[self redraw];
}

-(IBAction)savePressed:(id)sender
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	ArgusUpcomingProgramme *Programme = [ArgusUpcomingProgramme UpcomingProgrammeForUpcomingProgramId:UpcomingProgramId];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpcomingChangeDone:)
												 name:kArgusSaveUpcomingProgrammeDone
											   object:Programme];
	[Programme saveUpcomingProgramme];
}

#pragma mark - NSNotification Selectors
-(void)UpcomingChangeDone:(NSNotification *)notify
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[notify name] object:[notify object]];
	[self redraw];
}

@end
