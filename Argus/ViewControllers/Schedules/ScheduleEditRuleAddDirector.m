//
//  ScheduleEditRuleAddDirector.m
//  Argus
//
//  Created by Chris Elsworth on 30/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditRuleAddDirector.h"

@implementation ScheduleEditRuleAddDirector
@synthesize Rule;
@synthesize addbox;

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
	
	[addbox becomeFirstResponder];
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

-(IBAction)addBoxEnded:(id)sender
{	
	NSString *val = [[addbox text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if ([val length] > 0)
	{
		// init Arguments if it's empty
		if (! [Rule Arguments])
			[Rule setArguments:[NSMutableArray new]];
	
		[[Rule Arguments] addObject:val];
	}
	
	// go back to previous view
	[self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)addBoxDonePressed:(id)sender
{
	[sender resignFirstResponder];
	// addBoxEnded will be called automatically now
}
@end
