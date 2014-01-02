//
//  ScheduleEditPreRecordTVC.m
//  Argus
//
//  Created by Chris Elsworth on 27/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditPreRecordTVC.h"
#import "NSNumber+humanSize.h"

@implementation ScheduleEditPreRecordTVC
@synthesize Schedule;
@synthesize editType;
@synthesize active, picker;

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
	
	NSNumber *arg;
	
	switch (editType)
	{
		default: // silence warnings
		case ArgusScheduleEditTypePreRecord:
			arg = [Schedule Property:kPreRecordSeconds];
			[[self navigationItem] setTitle:NSLocalizedString(@"Pre-Record", nil)];
			break;
		
		case ArgusScheduleEditTypePostRecord:
			arg = [Schedule Property:kPostRecordSeconds];
			[[self navigationItem] setTitle:NSLocalizedString(@"Post-Record", nil)];
			break;
	}
	
	if (arg)
	{
		NSArray *hms = [arg hmsArray];
		[picker selectRow:[hms[0] intValue] inComponent:0 animated:NO];
		[picker selectRow:[hms[1] intValue] inComponent:1 animated:NO];
		[picker selectRow:[hms[2] intValue] inComponent:2 animated:NO];
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
	NSNumber *secs = @(([picker selectedRowInComponent:0] * 3600)
					  + ([picker selectedRowInComponent:1] * 60) + [picker selectedRowInComponent:2]);
	
	switch (editType)
	{
		default: // silence warnings
		case ArgusScheduleEditTypePreRecord:
			[Schedule setPreRecordSeconds:secs];
			break;
			
		case ArgusScheduleEditTypePostRecord:
			[Schedule setPostRecordSeconds:secs];
			break;
	}
	
	// set active selector on when the date changes, if it wasn't on
	if (![active isOn])
		[active setOn:YES animated:YES];
}

// active switch delegate
-(IBAction)activeChanged:(id)sender
{
	if ([active isOn])
	{
		NSNumber *secs = @(([picker selectedRowInComponent:0] * 3600)
						  + ([picker selectedRowInComponent:1] * 60) + [picker selectedRowInComponent:2]);
		
		switch (editType)
		{
			default: // silence warnings
			case ArgusScheduleEditTypePreRecord:
				[Schedule setPreRecordSeconds:secs];
				break;
				
			case ArgusScheduleEditTypePostRecord:
				[Schedule setPostRecordSeconds:secs];
				break;
		}
	}
	else
	{
		switch (editType)
		{
			default: // silence warnings
			case ArgusScheduleEditTypePreRecord:
				[Schedule setPreRecordSeconds:nil];
				break;
				
			case ArgusScheduleEditTypePostRecord:
				[Schedule setPostRecordSeconds:nil];
				break;
		}
	}
}

@end
