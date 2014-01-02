//
//  EpgGridCalendarPickerVC.m
//  Argus
//
//  Created by Chris Elsworth on 07/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "EpgGridCalendarPickerVC.h"

#import "AppDelegate.h"

@implementation EpgGridCalendarPickerVC
@synthesize delegate, popoverController;
@synthesize cal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	cal = [[TKCalendarMonthView alloc] initWithSundayAsFirst:NO];
	[self.view addSubview:cal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewDidAppear:(BOOL)animated
{
	// I have no idea why, but setting the cal delegate in the segue of our
	// caller just doesn't work. Maybe it resets it when the view appears?
	[cal setDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)month animated:(BOOL)animated
{
	// just pass the message along for now
	if ([delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
		[delegate calendarMonthView:monthView monthDidChange:month animated:animated];
}
-(void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)date
{
	// we could dismiss the view here if we wanted
	if (iPad())
		[popoverController dismissPopoverAnimated:YES];
	else
	{
		//[[self navigationController] dismissViewControllerAnimated:YES completion:nil];
		//[self dismissViewControllerAnimated:YES completion:nil];
	}
	
	// just pass the message along for now
	if ([delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
		[delegate calendarMonthView:monthView didSelectDate:date];
}

@end
