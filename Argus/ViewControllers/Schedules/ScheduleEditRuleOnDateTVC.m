//
//  ScheduleEditOnDateTVC.m
//  Argus
//
//  Created by Chris Elsworth on 27/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditRuleOnDateTVC.h"

@implementation ScheduleEditRuleOnDateTVC
@synthesize Rule;
@synthesize active, datepicker;
@synthesize cmv, cell;

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
	
	if ([Rule Arguments] && [Rule Arguments] != (NSArray *)[NSNull null])
		[datepicker setDate:[Rule getArgumentAsDate]];
	else
		[active setOn:NO animated:NO];

	
#if 0
	cmv = [[TKCalendarMonthView alloc] initWithSundayAsFirst:NO];
	NSDate *selectedDate = [Rule getArgumentAsDate];
	
	if (selectedDate)
		[cmv selectDate:selectedDate];
	else
		[active setOn:NO animated:NO];

	[cell addSubview:cmv];
#endif
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
		[Rule setArgumentAsDate:[datepicker date]];
	else
	{
		//[cmv selectDate:nil];
		[Rule setArguments:nil];
	}
}

-(IBAction)datePickerValueChanged:(id)sender
{
	[Rule setArgumentAsDate:[sender date]];
	
	// set active selector on when the date changes, if it wasn't on
	if (![active isOn])
		[active setOn:YES animated:YES];
}


@end
