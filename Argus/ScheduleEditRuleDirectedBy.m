//
//  ScheduleEditRuleDirectedBy.m
//  Argus
//
//  Created by Chris Elsworth on 30/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditRuleDirectedBy.h"
#import "ScheduleEditRuleAddDirector.h"

@implementation ScheduleEditRuleDirectedBy
@synthesize Rule;

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
	
	// force table into editing mode and leave it there for the duration of the view life
	[self setEditing:YES animated:NO];

	// this class is used for both Directed By and With Actor
	switch ([Rule Type])
	{
		default: // silence warnings
		case ArgusScheduleRuleTypeDirectedBy:
			[[self navigationItem] setTitle:NSLocalizedString(@"Directed By", @"rule edit title bar")];
			break;
		
		case ArgusScheduleRuleTypeWithActor:
			[[self navigationItem] setTitle:NSLocalizedString(@"With Actor", @"rule edit title bar")];
			break;			
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// redraw the table when the view appears. for a fluider experience this should really be
// viewWillAppear, but that seems to fire too early to see the new entries when the user
// presses 'Back' from AddDirector. viewDidAppear works.
-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.tableView reloadData];
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
	if (section == 0)
		return 1;

	return [[Rule Arguments] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	if (indexPath.section == 0)
	{
		// top section is a single Add All Channels cell
		cell = [tableView dequeueReusableCellWithIdentifier:@"AddDirectorCell"];
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"DirectorCell"];
		cell.textLabel.text = [[Rule Arguments] objectAtIndex:indexPath.row];
    }
    
    return cell;
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
		return UITableViewCellEditingStyleInsert;
	
	return UITableViewCellEditingStyleDelete;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        // Delete the row from the data source
		[[Rule Arguments] removeObjectAtIndex:indexPath.row];
		
		if ([[Rule Arguments] count] == 0)
		{
			[Rule setArguments:nil];
			[Rule setMatchType:0];
		}
		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert)
	{
		// not done here, we pass control over to a child view
    }   
}


#pragma mark - Segue Handling
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleAddDirector"])
    {
		ScheduleEditRuleAddDirector *dvc = (ScheduleEditRuleAddDirector *)[segue destinationViewController];
        
		// send over a pointer to the rule being edited
		dvc.Rule = Rule;
    }
}


@end
