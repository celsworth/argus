//
//  ScheduleEditRuleCategoryTVC.m
//  Argus
//
//  Created by Chris Elsworth on 16/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditRuleCategoryTVC.h"


#import "AppDelegate.h"

@implementation ScheduleEditRuleCategoryTVC
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redraw) name:kArgusCategoriesDone object:[argus Categories]];
	
	[[argus Categories] getCategories];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[argus Categories] Categories] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    
	NSString *Category = [[argus Categories] Categories][indexPath.row];
	cell.textLabel.text = Category;
    
	// is the category selected?
	cell.accessoryType = UITableViewCellAccessoryNone;
	NSMutableArray *selectedCategories = [Rule Arguments];
	for (NSString *tmp in selectedCategories)
	{
		if ([Category isEqualToString:tmp])
		{
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;
		}
	}
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *Category = [[argus Categories] Categories][indexPath.row];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	NSMutableArray *selectedCategories = [Rule Arguments];
	BOOL found = NO;
	for (NSString *tmp in selectedCategories)
	{
		if ([Category isEqualToString:tmp])
		{
			[selectedCategories removeObjectIdenticalTo:tmp];
			cell.accessoryType = UITableViewCellAccessoryNone;
			found = YES;
			break;
		}
	}

	if (!found)
	{
		if (![[Rule Arguments] isKindOfClass:[NSArray class]])
			[Rule setArguments:[NSMutableArray new]];
		
		[[Rule Arguments] addObject:Category];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
		
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	//[self.tableView reloadData];
}

@end
