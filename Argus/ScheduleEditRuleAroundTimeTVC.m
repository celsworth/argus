//
//  ScheduleEditRuleAroundTimeTVC.m
//  Argus
//
//  Created by Chris Elsworth on 27/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditRuleAroundTimeTVC.h"

@implementation ScheduleEditRuleAroundTimeTVC
@synthesize editType;
@synthesize Rule;
@synthesize fromDate, toDate;
@synthesize active, from_to_picker, datepicker;

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

	if (editType == ArgusScheduleEditTypeAroundTime)
	{
		[from_to_picker setTitle:NSLocalizedString(@"Around", @"button label for 'starts at around time'") forSegmentAtIndex:0];
		[from_to_picker removeSegmentAtIndex:1 animated:NO];
	
		if ([Rule Arguments] && [Rule Arguments] != (NSArray *)[NSNull null])
			[datepicker setDate:[Rule getArgumentAsDate]];
		else
		{
			[active setOn:NO animated:NO];
			[from_to_picker setSelectedSegmentIndex:-1];
		}

	}
	if (editType == ArgusScheduleEditTypeStartingBetween)
	{
		if ([Rule Arguments] && [Rule Arguments] != (NSArray *)[NSNull null])
		{
			// in starting between mode, pull in both from and to
			fromDate = [Rule getArgumentAsDateAtIndex:0];
			toDate = [Rule getArgumentAsDateAtIndex:1];
			[datepicker setDate:fromDate];
		}
		else
		{
			fromDate = [NSDate date];
			toDate = [NSDate date];

			[active setOn:NO animated:NO];
			[from_to_picker setSelectedSegmentIndex:-1];
		}
	}
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


-(IBAction)activeChanged:(id)sender
{
	if ([active isOn])
	{
		[from_to_picker setSelectedSegmentIndex:0];
		if (editType == ArgusScheduleEditTypeAroundTime)
		{
			NSLog(@"%s saving %@", [datepicker date]);
			[Rule setArgumentAsDate:[datepicker date]];
		}
		if (editType == ArgusScheduleEditTypeStartingBetween)
		{
			
		}
	}
	else
	{
		[from_to_picker setSelectedSegmentIndex:-1];
		[Rule setArguments:nil];
	}
}

-(IBAction)fromToChanged:(id)sender
{
	// no action here for AroundTime, it has only one segment
	
	if (editType == ArgusScheduleEditTypeStartingBetween)
	{
		switch ([sender selectedSegmentIndex])
		{
			case 0:
				[datepicker setDate:fromDate animated:YES];
				break;
				
			case 1:
				[datepicker setDate:toDate animated:YES];
				break;
		}
	}
}

-(IBAction)datePickerValueChanged:(id)sender
{
	if (editType == ArgusScheduleEditTypeAroundTime)
		[Rule setArgumentAsDate:[sender date]];
	
	if (editType == ArgusScheduleEditTypeStartingBetween)
	{
		if ([from_to_picker selectedSegmentIndex] == 0)
		{
			[Rule setArgumentAsFromDate:[sender date] toDate:toDate];
			fromDate = [Rule getArgumentAsDateAtIndex:0];
		}
		if ([from_to_picker selectedSegmentIndex] == 1)
		{
			[Rule setArgumentAsFromDate:fromDate toDate:[sender date]];
			toDate = [Rule getArgumentAsDateAtIndex:1];
		}
	}
	
	// set active selector on when the date changes, if it wasn't on
	if (![active isOn])
	{
		[from_to_picker setSelectedSegmentIndex:0];
		[active setOn:YES animated:YES];
	}
}


@end
