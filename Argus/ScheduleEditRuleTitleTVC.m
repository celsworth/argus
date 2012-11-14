//
//  ScheduleEditRulesTitleTVC.m
//  Argus
//
//  Created by Chris Elsworth on 15/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ScheduleEditRuleTitleTVC.h"

@implementation ScheduleEditRuleTitleTVC
@synthesize active, matchwhat, matchtype, textfield;
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

	switch ([Rule SuperType])
	{
		default: // squash warning about channels and categories supertypes not being handled
			break;
			
		case ArgusScheduleRuleSuperTypeTitle:
			[[self navigationItem] setTitle:NSLocalizedString(@"Edit Title Rule", nil)];
			break;

		case ArgusScheduleRuleSuperTypeSubTitle:
			[[self navigationItem] setTitle:NSLocalizedString(@"Edit SubTitle Rule", nil)];
			break;

		case ArgusScheduleRuleSuperTypeEpisodeNumber:
			[[self navigationItem] setTitle:NSLocalizedString(@"Edit Episode Number Rule", nil)];
			break;

		case ArgusScheduleRuleSuperTypeDescription:
			[[self navigationItem] setTitle:NSLocalizedString(@"Edit Description Rule", nil)];
			[matchtype setTitle:NSLocalizedString(@"Contains", nil) forSegmentAtIndex:0];
			[matchtype removeSegmentAtIndex:1 animated:NO];
			[matchtype removeSegmentAtIndex:1 animated:NO];
			break;

		case ArgusScheduleRuleSuperTypeProgramInfo:
			[[self navigationItem] setTitle:NSLocalizedString(@"Edit Program Info Rule", nil)];
			[matchtype setTitle:NSLocalizedString(@"Contains", nil) forSegmentAtIndex:0];
			[matchtype removeSegmentAtIndex:1 animated:NO];
			[matchtype removeSegmentAtIndex:1 animated:NO];
			break;
	}

	if ([Rule Arguments] && [Rule MatchType] != 0)
	{
		// if MatchType is DoesNotContain, prepend our textstring with NOT
		// and change MatchType to Contains
		if ([Rule MatchType] == ArgusScheduleRuleMatchTypeDoesNotContain)
		{
			[[Rule Arguments] insertObject:@"NOT" atIndex: 0];
			[Rule setMatchType:ArgusScheduleRuleMatchTypeContains];
		}
		
		textfield.text = [[Rule Arguments] componentsJoinedByString:@" OR "];
		[self updateMatchTypeDisplay];
	}
	else
	{
		[active setOn:NO animated:NO];
	}
	
	[textfield becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// active switch delegate
-(IBAction)activeChanged:(id)sender
{
	if (active.on)
	{
		[matchtype setSelectedSegmentIndex:0];
		[self setMatchTypeFromSelectedSegment];
	}
	else 
	{
		[matchtype setSelectedSegmentIndex:-1];
		[self setMatchTypeFromSelectedSegment];
		
		textfield.text = nil;
		[Rule setArguments:nil];
	}
}

// matchtype delegate
-(IBAction)matchTypeChanged:(id)sender
{
	[self setMatchTypeFromSelectedSegment];

	if (!active.on)
		[active setOn:YES animated:YES];
}


// textfield delegate
-(IBAction)textFieldChanged:(id)sender
{	
	
	NSString *val = [[sender text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if ([val length] == 0)
	{
		[active setOn:NO animated:YES];
		[matchtype setSelectedSegmentIndex:-1]; // select nothing
		[self setMatchTypeFromSelectedSegment];
	}
	else if (!active.on)
	{
		[active setOn:YES animated:YES];
		
		// select default matchtype
		[matchtype setSelectedSegmentIndex:0];
		[self setMatchTypeFromSelectedSegment];
	}
	
	[Rule setArguments:[NSMutableArray arrayWithArray:[val componentsSeparatedByString:@" OR "]]];
}


-(IBAction)titleReturn:(id)sender
{
	[textfield resignFirstResponder];
}


-(void)updateMatchTypeDisplay
{
	// convert [Rule MatchType] into selected segment index.
	// for Description/ProgramInfo, this is only Contains or Does Not Contain
	if ([Rule SuperType] == ArgusScheduleRuleSuperTypeDescription ||
		[Rule SuperType] == ArgusScheduleRuleSuperTypeProgramInfo)
	{
		switch([Rule MatchType])
		{
			default:
				[matchtype setSelectedSegmentIndex:-1];
				break;

			case ArgusScheduleRuleMatchTypeContains:
				[matchtype setSelectedSegmentIndex:0];
				break;
		}
	}
	else
	{
		// for all others, it's Equals/Starts/Contains
		switch([Rule MatchType])
		{
			default:
				[matchtype setSelectedSegmentIndex:-1];
				break;
				
			case ArgusScheduleRuleMatchTypeEquals:
				[matchtype setSelectedSegmentIndex:0];
				break;
				
			case ArgusScheduleRuleMatchTypeStartsWith:
				[matchtype setSelectedSegmentIndex:1];
				break;
				
			case ArgusScheduleRuleMatchTypeContains:
				[matchtype setSelectedSegmentIndex:2];
				break;
				
		}
	}
}

-(void)setMatchTypeFromSelectedSegment
{
	NSInteger selected = [matchtype selectedSegmentIndex];

	if ([Rule SuperType] == ArgusScheduleRuleSuperTypeDescription ||
		[Rule SuperType] == ArgusScheduleRuleSuperTypeProgramInfo)
	{
		// for ProgramInfo/Description
		switch(selected)
		{
			case -1: // nothing selected
				[Rule setMatchType:0];
				break;
				
			case 0:
				[Rule setMatchType:ArgusScheduleRuleMatchTypeContains];
				break;
		}
	}
	else
	{
		// for Title/SubTitle/EpNumber
		switch(selected)
		{
			case -1: // nothing selected
				[Rule setMatchType:0];
				break;
				
			case 0:
				[Rule setMatchType:ArgusScheduleRuleMatchTypeEquals];
				break;
				
			case 1:
				[Rule setMatchType:ArgusScheduleRuleMatchTypeStartsWith];
				break;
				
			case 2:
				[Rule setMatchType:ArgusScheduleRuleMatchTypeContains];
				break;	
		}
	}	
}

@end
