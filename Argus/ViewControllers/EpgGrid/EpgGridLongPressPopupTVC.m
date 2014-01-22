//
//  EpgGidLongPressPopupTVC.m
//  Argus
//
//  Created by Chris Elsworth on 11/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "EpgGridLongPressPopupTVC.h"
#import "ArgusChannel.h"
#import "ArgusUpcomingProgramme.h"

#import "AppDelegate.h"

#import "WebViewVC.h"

@implementation EpgGridLongPressPopupTVC
@synthesize popoverController;
@synthesize oneTouchRecordCell, searchIMDbCell, searchTvComCell;
@synthesize emptySchedule, Programme;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// make One Touch Record red
	UIImage *imgR = [UIImage imageNamed:@"chris_stretchable_button_red.png"];
	UIImage *imgRstretch = [imgR stretchableImageWithLeftCapWidth:imgR.size.width/2 topCapHeight:imgR.size.height/2];
	
	oneTouchRecordCell.backgroundView = [[UIImageView alloc] initWithImage:imgRstretch];
	
	// add the Record "image" (UTF8 symbol) to the One Tap Record cell
	UILabel *oneTouchRecordLabel = oneTouchRecordCell.textLabel;
	[oneTouchRecordLabel setText:[NSString stringWithFormat:@"\U0001F534 %@", oneTouchRecordLabel.text]];
	
	
	UIImage *imgG = [UIImage imageNamed:@"chris_stretchable_button_green.png"];
	UIImage *imgGstretch = [imgG stretchableImageWithLeftCapWidth:imgG.size.width/2 topCapHeight:imgG.size.height/2];
	
	searchIMDbCell.backgroundView = [[UIImageView alloc] initWithImage:imgGstretch];
	
	searchTvComCell.backgroundView = [[UIImageView alloc] initWithImage:imgGstretch];
	
	
	ArgusUpcomingProgramme *upc = [Programme upcomingProgramme];
	if (upc)
	{
		if ([[upc Property:kIsCancelled] boolValue] == YES)
		{
			oneTouchRecordCell.textLabel.text = NSLocalizedString(@"Uncancel Programme", nil);
		}
		else
		{
			// if the programme is already going to record, make it a cancel button instead
			oneTouchRecordCell.textLabel.text = NSLocalizedString(@"Cancel Programme", nil);
		}
	}
	
	
	// remove the grey background of the grouped tablecell, so the popup background shows through (dark blue)
	// which makes the red record button look a lot better
	[[self tableView] setBackgroundView:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// ensure I'm calling this properly
	// note this is in viewWillAppear because a popover view is loaded on init?
	assert(Programme);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	ArgusUpcomingProgramme *upc = [Programme upcomingProgramme];
	
	if (cell == oneTouchRecordCell && !upc)
	{
		// set up empty schedule, populate for Programme, and save
		
		// take a copy of EmptySchedule so we can mess with it
		emptySchedule = [[ArgusSchedule alloc] initWithExistingSchedule:[argus EmptySchedule]];
		
		[emptySchedule setupForQuickRecord:Programme];
		
		// save
		[emptySchedule save];
		
		// some feedback to the user?
		oneTouchRecordCell.textLabel.text = NSLocalizedString(@"Saving...", nil);
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SaveScheduleDone:) name:kArgusSaveScheduleDone object:emptySchedule];
		
	}
	else if (cell == oneTouchRecordCell && upc)
	{
		if ([[upc Property:kIsCancelled] boolValue] == YES)
		{
			// Uncancel Programme
			[upc uncancelUpcomingProgramme];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UncancelUpcomingProgrammeDone:) name:kArgusUncancelUpcomingProgrammeDone object:upc];
		}
		else
		{
			// Cancel Programme
			[upc cancelUpcomingProgramme];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CancelUpcomingProgrammeDone:) name:kArgusCancelUpcomingProgrammeDone object:upc];
		}
	}
	else if (cell == searchIMDbCell)
	{
		UINavigationController *nc;
		if (iPad())
		{
			UISplitViewController *svc = (UISplitViewController *)[[[AppDelegate sharedInstance] window] rootViewController];
			nc = [svc viewControllers][1];
			
			[[self popoverController] dismissPopoverAnimated:YES];
		}
		else
		{
			nc = [self navigationController];
			[nc popViewControllerAnimated:NO];
		}
		
		NSString *url = [NSString stringWithFormat:@"http://www.imdb.com/find?q=%@&s=tt",
						 [[Programme Property:kTitle] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
		//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		
		WebViewVC *vc = [[WebViewVC alloc] initWithFrame:nc.visibleViewController.view.frame];
		[vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
		
		[nc pushViewController:vc animated:YES];
	}
	else if (cell == searchTvComCell)
	{
		UISplitViewController *svc = (UISplitViewController *)[[[AppDelegate sharedInstance] window] rootViewController];
		UINavigationController *nc = [svc viewControllers][1];
		
		[[self popoverController] dismissPopoverAnimated:YES];
		
		NSString *url = [NSString stringWithFormat:@"http://www.tv.com/search?q=%@",
						 [[Programme Property:kTitle] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
		//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		
		WebViewVC *vc = [[WebViewVC alloc] initWithFrame:nc.visibleViewController.view.frame];
		[vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
		
		[nc pushViewController:vc animated:YES];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}



-(void)SaveScheduleDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[self goAway];
}

-(void)CancelUpcomingProgrammeDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[self goAway];
}
-(void)UncancelUpcomingProgrammeDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[self goAway];
}


-(IBAction)didPressDone:(id)sender
{
	[self goAway];
}

-(void)goAway
{
	if (iPad())
		[[self popoverController] dismissPopoverAnimated:YES];
	else
		[[self navigationController] popViewControllerAnimated:YES];
	
}

@end
