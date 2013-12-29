//
//  ScheduleEditRulesTVC.m
//  Argus
//
//  Created by Chris Elsworth on 15/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditRulesTVC.h"
#import "ScheduleEditRuleTitleTVC.h"
#import "ScheduleEditRuleOnDateTVC.h"
#import "ScheduleEditRuleDaysOfWeekTVC.h"
#import "ScheduleEditRuleAroundTimeTVC.h"
#import "ScheduleEditRuleChannelsTVC.h"
#import "ScheduleEditRuleCategoryTVC.h"
#import "ScheduleEditRuleDirectedBy.h"

#import "ArgusSchedule.h"
#import "ArgusChannel.h"

#import "AppDelegate.h"

@implementation ScheduleEditRulesTVC
@synthesize Schedule;
@synthesize title, subtitle, episode_number, description, program_info;
@synthesize on_date, days_of_week, around_time, starts_between;
@synthesize neew_episodes, unique_titles, skip_repeats;
@synthesize channels, categories, directed_by, with_actor;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
	// this causes a redraw when a sub-page returns control to us,
	// and when we load initially.
	[super viewWillAppear:animated];
	[self redraw];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
// STATIC CELLS, no  table data source

-(void)redraw
{
	[self setTitleCell];
	[self setSubTitleCell];
	[self setEpisodeNumberCell];
	[self setDescriptionCell];
	[self setProgramInfoCell];
	
	[self setOnDateCell];
	[self setDaysOfWeekCell];
	[self setAroundTimeCell];
	[self setStartingBetweenCell];
	
	[self setNewEpisodesCell];
	[self setUniqueTitlesCell];
	[self setSkipRepeatsCell];
	
	[self setChannelsCell];
	[self setCategoryCell];
	
	[self setWithActorCell];
	[self setDirectedByCell];
}


-(void)setCell:(UITableViewCell *)cell value:(NSString *)value subValue:(NSString *)subValue
{
	UILabel *valueLabel = (UILabel *)[cell viewWithTag:1];
	UILabel *subValueLabel = (UILabel *)[cell viewWithTag:2];
	
	if (value)
	{
		valueLabel.text = value;
		valueLabel.textColor = [UIColor colorWithRed:75/255.0 green:105/255.0 blue:151/255.0 alpha:1.0];
	}
	else
	{
		valueLabel.text = NSLocalizedString(@"not set", @"schedule rule has no defined value");
		valueLabel.textColor = [UIColor lightGrayColor];
	}
	subValueLabel.text = subValue;
}

-(NSString *)subValueForRule:(ArgusScheduleRule *)rule
{
	// don't display "Equals" for an otherwise empty rule
	if ([rule Type] == 0)
		return nil;
		
	switch([rule MatchType])
	{
		case ArgusScheduleRuleMatchTypeEquals:
			return NSLocalizedString(@"Equals", nil);
		case ArgusScheduleRuleMatchTypeContains:
			return NSLocalizedString(@"Contains", nil);
		case ArgusScheduleRuleMatchTypeDoesNotContain:
			return NSLocalizedString(@"Does Not Contain", nil);
		case ArgusScheduleRuleMatchTypeStartsWith:
			return NSLocalizedString(@"Starts With", nil);
	}
	
	return nil;
}

-(void)setTitleCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleSuperTypeTitle];
	NSString *value = [[r Arguments] componentsJoinedByString:@" OR "];
	[self setCell:title value:value subValue:[self subValueForRule:r]];
}

-(void)setSubTitleCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleSuperTypeSubTitle];
	NSString *value = [[r Arguments] componentsJoinedByString:@" OR "];
	[self setCell:subtitle value:value subValue:[self subValueForRule:r]];
}

-(void)setEpisodeNumberCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleSuperTypeEpisodeNumber];
	NSString *value = [[r Arguments] componentsJoinedByString:@" OR "];
	[self setCell:episode_number value:value subValue:[self subValueForRule:r]];
}

-(void)setDescriptionCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleSuperTypeDescription];
	NSString *value = [[r Arguments] componentsJoinedByString:@" OR "];
	[self setCell:description value:value subValue:[self subValueForRule:r]];
}

-(void)setProgramInfoCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleSuperTypeProgramInfo];
	NSString *value = [[r Arguments] componentsJoinedByString:@" OR "];
	[self setCell:program_info value:value subValue:[self subValueForRule:r]];
}

-(void)setOnDateCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeOnDate];
	NSString *arg = [r Arguments][0];
	if (arg && arg != (NSString *)[NSNull null])
	{
		NSDate *date = [r getArgumentAsDate];
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateStyle:NSDateFormatterFullStyle];
		[self setCell:on_date value:[df stringFromDate:date] subValue:nil];
	}
	else
		[self setCell:on_date value:nil subValue:nil];
}

-(void)setDaysOfWeekCell
{
	NSMutableArray *weekdays = [NSMutableArray arrayWithArray:[[NSDateFormatter new] shortWeekdaySymbols]];
	
	// shuffle first object (Sunday) to the end, so we're Mon=0 - Sun=6
	[weekdays addObject:weekdays[0]];
	[weekdays removeObjectAtIndex:0];
	
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeDaysOfWeek];
	NSMutableArray *selected = [NSMutableArray new];
	
	// and decide which we're showing
	if ([r getArgumentAsDayOfWeekSelected:ArgusScheduleRuleDayOfWeekMonday])
		[selected addObject:weekdays[0]];
	if ([r getArgumentAsDayOfWeekSelected:ArgusScheduleRuleDayOfWeekTuesday])
		[selected addObject:weekdays[1]];
	if ([r getArgumentAsDayOfWeekSelected:ArgusScheduleRuleDayOfWeekWednesday])
		[selected addObject:weekdays[2]];
	if ([r getArgumentAsDayOfWeekSelected:ArgusScheduleRuleDayOfWeekThursday])
		[selected addObject:weekdays[3]];
	if ([r getArgumentAsDayOfWeekSelected:ArgusScheduleRuleDayOfWeekFriday])
		[selected addObject:weekdays[4]];

	if ([r getArgumentAsDayOfWeekSelected:ArgusScheduleRuleDayOfWeekSaturday])
		[selected addObject:weekdays[5]];
	if ([r getArgumentAsDayOfWeekSelected:ArgusScheduleRuleDayOfWeekSunday])
		[selected addObject:weekdays[6]];
	
	NSString *val = [selected count] ? [selected componentsJoinedByString:@", "] : nil;
	
	[self setCell:days_of_week value:val subValue:nil];
}

-(void)setAroundTimeCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeAroundTime];

	NSDate *arg = [r getArgumentAsDate];
	NSString *val;
	if (arg && arg != (NSDate *)[NSNull null])
	{
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setTimeStyle:NSDateFormatterMediumStyle];
		val = [df stringFromDate:arg];
	}
	[self setCell:around_time value:val subValue:nil];
}
-(void)setStartingBetweenCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeStartingBetween];
	NSDate *from = [r getArgumentAsDateAtIndex:0];
	NSDate *to = [r getArgumentAsDateAtIndex:1];

	if (from && from != (NSDate *)[NSNull null] && to && to != (NSDate *)[NSNull null])
	{
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setTimeStyle:NSDateFormatterMediumStyle];
		NSString *val = [NSString stringWithFormat:@"%@ - %@", [df stringFromDate:from], [df stringFromDate:to]];

		[self setCell:starts_between value:val subValue:nil];
	}
	else
		[self setCell:starts_between value:nil subValue:nil];

}

-(void)setNewEpisodesCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeNewEpisodesOnly];
	[neew_episodes setAccessoryType:[r getArgumentAsBoolean] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
}
-(void)setUniqueTitlesCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeNewTitlesOnly];
	[unique_titles setAccessoryType:[r getArgumentAsBoolean] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
}
-(void)setSkipRepeatsCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeSkipRepeats];
	[skip_repeats setAccessoryType:[r getArgumentAsBoolean] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];	
}


-(void)setChannelsCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleSuperTypeChannels];

	NSMutableArray *tmp = [NSMutableArray new];
	
	// Arguments is an array of ChannelIds
	// look them up and extract DisplayNames
	for (ArgusGuid *ChannelId in [r Arguments])
	{
		ArgusChannel *c = [argus ChannelsKeyedByChannelId][ChannelId];
		if (!c || ![c Property:kDisplayName])
		{
			// seen this crop up a few times but I don't know why, could be that a channel
			// is being returned that isn't in our Channels lookup dictionary..
			NSLog(@"ERROR: c=%@ DisplayName=%@", c, [c Property:kDisplayName]);
			[tmp addObject:ChannelId]; // best we can do :/
		}
		else
			[tmp addObject:[c Property:kDisplayName]];
	}
	
	// we'll just try displaying as much as we can, for a lot of channels it'll run out of room
	NSString *value = [tmp count] ? [tmp componentsJoinedByString:@", "] : nil;
	[self setCell:channels value:value subValue:[self subValueForRule:r]];
}

-(void)setCategoryCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleSuperTypeCategories];

	NSMutableArray *tmp = [NSMutableArray new];

	for (NSString *Category in [r Arguments])
	{
		[tmp addObject:Category];
	}
	
	NSString *value = [tmp count] ? [tmp componentsJoinedByString:@", "] : nil;
	[self setCell:categories value:value subValue:[self subValueForRule:r]];
}

-(void)setDirectedByCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeDirectedBy];
	
	// subValue UILabel doesn't actually exist in this cell
	
	NSString *value = [[r Arguments] componentsJoinedByString:@", "];
	[self setCell:directed_by value:value subValue:nil];
}
-(void)setWithActorCell
{
	ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeWithActor];
	
	// subValue UILabel doesn't actually exist in this cell
	
	NSString *value = [[r Arguments] componentsJoinedByString:@", "];
	[self setCell:with_actor value:value subValue:nil];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// section 0 is all handled via Segues
	
	// section 1
	if (indexPath.section == 1)
	{
		// cells 0-3 handled by Segues
		if (indexPath.row == 4)
		{
			// New Episodes cell, toggle the setting
			ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeNewEpisodesOnly];
			BOOL val = ! [r getArgumentAsBoolean];
			
			[r setArgumentAsBoolean:val];
			[self setNewEpisodesCell];
			
			// New Episodes and New Titles are mutually exclusive
			if (val)
			{
				ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeNewTitlesOnly];
				[r setArgumentAsBoolean:NO];
				[self setUniqueTitlesCell];
			}
		}
		if (indexPath.row == 5)
		{
			// New Titles cell, toggle the setting
			ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeNewTitlesOnly];
			BOOL val = ! [r getArgumentAsBoolean];
			
			[r setArgumentAsBoolean:val];
			[self setUniqueTitlesCell];
			
			// New Episodes and New Titles are mutually exclusive
			if (val)
			{
				ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeNewEpisodesOnly];
				[r setArgumentAsBoolean:NO];
				[self setNewEpisodesCell];
			}

		}
		if (indexPath.row == 6)
		{
			// Skip Repeats cell, toggle the setting
			ArgusScheduleRule *r = [Schedule Rules][kArgusScheduleRuleTypeSkipRepeats];
			BOOL val = ! [r getArgumentAsBoolean];
			
			[r setArgumentAsBoolean:val];
			[self setSkipRepeatsCell];
		}
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	// section 2 all handled by Segues
}
	
#pragma mark - Segue Handling
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleTitle"])
    {
        ScheduleEditRuleTitleTVC *dvc = (ScheduleEditRuleTitleTVC *)[segue destinationViewController];
        
		// send over a pointer to the element being edited
		// in this case, title - when it's changed in the delegate, ours will be updated too	
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleSuperTypeTitle];
    }

	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleSubTitle"])
    {
        ScheduleEditRuleTitleTVC *dvc = (ScheduleEditRuleTitleTVC *)[segue destinationViewController];
        
		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleSuperTypeSubTitle];
    }

	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleEpNumber"])
    {
        ScheduleEditRuleTitleTVC *dvc = (ScheduleEditRuleTitleTVC *)[segue destinationViewController];
        
		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleSuperTypeEpisodeNumber];
    }

	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleDescription"])
    {
		ScheduleEditRuleTitleTVC *dvc = (ScheduleEditRuleTitleTVC *)[segue destinationViewController];

		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleSuperTypeDescription];
    }
	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleProgramInfo"])
    {
		ScheduleEditRuleTitleTVC *dvc = (ScheduleEditRuleTitleTVC *)[segue destinationViewController];
		
		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleSuperTypeProgramInfo];
    }

	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleOnDate"])
    {
		ScheduleEditRuleOnDateTVC *dvc = (ScheduleEditRuleOnDateTVC *)[segue destinationViewController];
		
		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleTypeOnDate];
    }

	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleDaysOfWeek"])
    {
		ScheduleEditRuleDaysOfWeekTVC *dvc = (ScheduleEditRuleDaysOfWeekTVC *)[segue destinationViewController];
		
		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleTypeDaysOfWeek];
    }

	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleAroundTime"])
    {
		ScheduleEditRuleAroundTimeTVC *dvc = (ScheduleEditRuleAroundTimeTVC *)[segue destinationViewController];
		
		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleTypeAroundTime];
		dvc.editType = ArgusScheduleEditTypeAroundTime;
    }
	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleStartingBetween"])
    {
		ScheduleEditRuleAroundTimeTVC *dvc = (ScheduleEditRuleAroundTimeTVC *)[segue destinationViewController];
		
		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleTypeStartingBetween];
		dvc.editType = ArgusScheduleEditTypeStartingBetween;
    }

	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleChannels"])
    {
		ScheduleEditRuleChannelsTVC *dvc = (ScheduleEditRuleChannelsTVC *)[segue destinationViewController];
		
		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleSuperTypeChannels];
		
		// pass Schedule too, they need to know Schedule.ChannelType
		// so the user can't add TV channels to a Radio schedule.
		dvc.Schedule = Schedule;
    }

	// categories, last one to do \o/
	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleCategory"])
    {
		ScheduleEditRuleCategoryTVC *dvc = (ScheduleEditRuleCategoryTVC *)[segue destinationViewController];
		
		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleSuperTypeCategories];
    }

	
	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleDirectedBy"])
    {
		ScheduleEditRuleDirectedBy *dvc = (ScheduleEditRuleDirectedBy *)[segue destinationViewController];
		
		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleTypeDirectedBy];
    }
	if ([[segue identifier] isEqualToString:@"ScheduleEditRuleWithActor"])
    {
		ScheduleEditRuleDirectedBy *dvc = (ScheduleEditRuleDirectedBy *)[segue destinationViewController];
		
		// send over a pointer to the element being edited
		dvc.Rule = [Schedule Rules][kArgusScheduleRuleTypeWithActor];
    }


}

@end
