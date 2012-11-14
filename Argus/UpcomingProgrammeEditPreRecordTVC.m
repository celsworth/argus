//
//  UpcomingProgrammeEditPreRecordTVC.m
//  Argus
//
//  Created by Chris Elsworth on 11/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "UpcomingProgrammeEditPreRecordTVC.h"

#import "NSNumber+humanSize.h"

@implementation UpcomingProgrammeEditPreRecordTVC
@synthesize UpcomingProgramId;

@synthesize active, picker;
@synthesize editType;

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
	
	ArgusUpcomingProgramme *Programme = [ArgusUpcomingProgramme UpcomingProgrammeForUpcomingProgramId:UpcomingProgramId];

	// ensure arguments are set
	assert(Programme != nil);
	assert(editType != 0);
	
	NSNumber *arg;
	
	switch (editType)
	{
		default: // silence warnings
		case ArgusScheduleEditTypePreRecord:
			arg = [Programme Property:kPreRecordSeconds];
			[[self navigationItem] setTitle:NSLocalizedString(@"Pre-Record", nil)];
			break;
			
		case ArgusScheduleEditTypePostRecord:
			arg = [Programme Property:kPostRecordSeconds];
			[[self navigationItem] setTitle:NSLocalizedString(@"Post-Record", nil)];
			break;
	}
	
	if (arg)
	{
		NSArray *hms = [arg hmsArray];
		[picker selectRow:[[hms objectAtIndex:0] intValue] inComponent:0 animated:NO];
		[picker selectRow:[[hms objectAtIndex:1] intValue] inComponent:1 animated:NO];
		[picker selectRow:[[hms objectAtIndex:2] intValue] inComponent:2 animated:NO];
	}
	else
		[active setOn:NO animated:NO];
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


#pragma mark - Picker View DataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component == 0) return 4; // 00 to 03
	return 60; // 60 minutes and 60 seconds
}

#pragma mark - Picker View Delegate
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	if (component == 0) return 45.0;
	return 60.0;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 30.0;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	switch (component)
	{
		default: abort();
		case 0: return [NSString stringWithFormat:@"%dh", row];
		case 1: return [NSString stringWithFormat:@"%02dm", row];	
		case 2: return [NSString stringWithFormat:@"%02ds", row];	
	}
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	// this could probably be cleaner, we just get the int of each selected row and add up the seconds
	NSNumber *secs = [NSNumber numberWithInt:([picker selectedRowInComponent:0] * 3600)
					  + ([picker selectedRowInComponent:1] * 60) + [picker selectedRowInComponent:2]
					  ];
	
	ArgusUpcomingProgramme *Programme = [ArgusUpcomingProgramme UpcomingProgrammeForUpcomingProgramId:UpcomingProgramId];

	switch (editType)
	{
		default: // silence warnings
		case ArgusScheduleEditTypePreRecord:
			[Programme setPreRecordSeconds:secs];
			break;
			
		case ArgusScheduleEditTypePostRecord:
			[Programme setPostRecordSeconds:secs];
			break;
	}
	
	// set active selector on when the date changes, if it wasn't on
	if (![active isOn])
		[active setOn:YES animated:YES];
}

// active switch delegate
-(IBAction)activeChanged:(id)sender
{
	ArgusUpcomingProgramme *Programme = [ArgusUpcomingProgramme UpcomingProgrammeForUpcomingProgramId:UpcomingProgramId];

	if ([active isOn])
	{
		NSNumber *secs = [NSNumber numberWithInt:([picker selectedRowInComponent:0] * 3600)
						  + ([picker selectedRowInComponent:1] * 60) + [picker selectedRowInComponent:2]
						  ];
		
		switch (editType)
		{
			default: // silence warnings
			case ArgusScheduleEditTypePreRecord:
				[Programme setPreRecordSeconds:secs];
				break;
				
			case ArgusScheduleEditTypePostRecord:
				[Programme setPostRecordSeconds:secs];
				break;
		}
	}
	else
	{
		switch (editType)
		{
			default: // silence warnings
			case ArgusScheduleEditTypePreRecord:
				[Programme setPreRecordSeconds:nil];
				break;
				
			case ArgusScheduleEditTypePostRecord:
				[Programme setPostRecordSeconds:nil];
				break;
		}
	}
}

@end
