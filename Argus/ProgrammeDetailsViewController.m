//
//  ProgrammeDetailsViewController.m
//  Argus
//
//  Created by Chris Elsworth on 02/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ProgrammeDetailsViewController.h"
#import "ScheduleViewController.h"
#import "UpcomingProgrammeEditTVC.h"

#import "WebViewVC.h"

#import "NSDateFormatter+LocaleAdditions.h"
#import "UILabel+Alignment.h"
#import "NSString+JSONDate.h"
#import "NSDate+Formatter.h"
#import "NSNumber+humanSize.h"

#import "ArgusChannel.h"

#import "AppDelegate.h"

@implementation ProgrammeDetailsViewController
@synthesize Programme;
@synthesize sv;
@synthesize progtitle, subtitle, description;
@synthesize date, dateSubtext, timeStart, timeDuration, timeEnd, pctDone;
@synthesize airChannel, airChannelLogo;
@synthesize recordButton;
@synthesize searchButton, searchIMDbButton, searchTvComButton;
@synthesize editScheduleButton, editProgrammeButton;
@synthesize recordButtons;
@synthesize recordActionSheet, searchActionSheet;
@synthesize UpcomingProgramme, upcomingIcon;
@synthesize detailsLoading;
@synthesize autoRedrawTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__); // spammy
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// show/hide the relevant buttons when our list of upcoming programmes changes
	// eg if our programme was set to record and now isn't, we'll show the Record buttons
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redraw)
												 name:kArgusUpcomingProgrammesDone
											   object:[argus UpcomingProgrammes]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redraw)
												 name:kArgusProgrammeDone
											   object:Programme];

		
	UIImage *redStretchImg = [UIImage imageNamed:@"chris_stretchable_button_red.png"];
	//	UIImage *yellowStretchImg = [UIImage imageNamed:@"chris_stretchable_button_yellow.png"];
	UIImage *greenStretchImg = [UIImage imageNamed:@"chris_stretchable_button_green.png"];

	UIImage *redStretch = [redStretchImg stretchableImageWithLeftCapWidth:redStretchImg.size.width/2	
															 topCapHeight:redStretchImg.size.height/2];

	//	UIImage *yellowStretch = [yellowStretchImg stretchableImageWithLeftCapWidth:yellowStretchImg.size.width/2
	//																   topCapHeight:yellowStretchImg.size.height/2];
	//
	
	UIImage *greenStretch = [greenStretchImg stretchableImageWithLeftCapWidth:greenStretchImg.size.width/2
																   topCapHeight:greenStretchImg.size.height/2];

	// add UTF8 red circle
	[recordButton setTitle:[NSString stringWithFormat:@"\U0001F534 %@", recordButton.titleLabel.text] forState:UIControlStateNormal];
	
	[recordButton setBackgroundImage:redStretch forState:UIControlStateNormal];
	
	// iPhone only, but just a nil-op on iPad
	[searchButton setBackgroundImage:greenStretch forState:UIControlStateNormal];
	
	// iPad only, but just a nil-op on iPhone
	[searchIMDbButton setBackgroundImage:greenStretch forState:UIControlStateNormal];
	[searchTvComButton setBackgroundImage:greenStretch forState:UIControlStateNormal];
	
	[editScheduleButton setBackgroundImage:redStretch forState:UIControlStateNormal];
	[[editScheduleButton titleLabel] setLineBreakMode:UILineBreakModeWordWrap];
	[[editScheduleButton titleLabel] setTextAlignment:UITextAlignmentCenter];
	[[editScheduleButton titleLabel] setNumberOfLines:0];
	//[editScheduleButton setTitle:@"Edit\nSchedule" forState:UIControlStateNormal];
	
	[editProgrammeButton setBackgroundImage:redStretch forState:UIControlStateNormal];
	[[editProgrammeButton titleLabel] setLineBreakMode:UILineBreakModeWordWrap];
	[[editProgrammeButton titleLabel] setTextAlignment:UITextAlignmentCenter];
	[[editProgrammeButton titleLabel] setNumberOfLines:0];
	//[editProgrammeButton setTitle:@"Edit\nProgramme" forState:UIControlStateNormal];

}

-(void)viewWillAppear:(BOOL)animated
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	[super viewWillAppear:animated];
	
	// note that all this is here because the scrollview sizes aren't setup yet in viewDidLoad
	// don't move it!
	
	// make scrolling work. this kinda sucks, why do I have to specify pixel sizes!
	// it must match original scrollview frame size in the storyboard
	// tried sv.contentSize = sv.frame.size but doesn't work, gets 389 instead of 296?
	if (iPad())
		sv.contentSize = CGSizeMake(description.frame.size.width, 642);
	else
		sv.contentSize = CGSizeMake(description.frame.size.width, 296);
	
	//	NSLog(@"sv is %f x %f", sv.contentSize.width, sv.contentSize.height);
	
	
	
	autoRedrawTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(redraw) userInfo:nil repeats:YES];

	[self redraw];
}

-(void)viewDidUnload
{
	[super viewDidUnload];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[autoRedrawTimer invalidate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[self redraw];
}


-(void)redraw
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	assert(Programme);
	
	//NSLog(@"%@", Programme.originalData);
	
	UpcomingProgramme = [Programme upcomingProgramme];
	if (UpcomingProgramme)
	{
		recordButton.hidden = YES;
		editScheduleButton.hidden = NO;
		editProgrammeButton.hidden = NO;
		
		upcomingIcon.image = [UpcomingProgramme iconImage];
	}
	else
	{
		editScheduleButton.hidden = YES;
		editProgrammeButton.hidden = YES;
		recordButton.hidden = NO;
		
		upcomingIcon.image = nil;
	}

	progtitle.text = [Programme Property:kTitle];
	subtitle.text = [Programme Property:kSubTitle];
	
	//NSLog(@"desc is %@", [Programme Property:kDescription]);
	
	if ([Programme Property:kDescription])
	{
		[detailsLoading stopAnimating];
		description.text = [Programme Property:kDescription];	
	}
	else
	{
		if ([Programme Property:kGuideProgramId])
		{
			description.text = nil;

			// no description, if we didn't try to fetch it already, do so
			if (! [Programme fullDetailsDone])
			{
				[detailsLoading startAnimating];
				
				// send a Guide/Program/{GuideProgramId} request to get description.
				[Programme getFullDetails];
			}
		}
		else
		{
			// do not attempt to fetch descriptions if GuideProgramId is nil
			// this signifies a manual recording
			description.text = NSLocalizedString(@"<manual recording, no details available>", @"details of a manual recording");
		}
	}
	
	// top-align the description text
	
	CGSize tmp = CGSizeMake(description.frame.size.width, MAXFLOAT);
	CGSize test = [[description text] sizeWithFont:[description font] constrainedToSize:tmp lineBreakMode:UILineBreakModeWordWrap];
	//NSLog(@"sizeWithFont: %f", test.height);
	
	// change description height to the new test.height
	// diff will be negative if new one is shorter
	CGFloat diff = test.height - description.frame.size.height;
	
	CGRect newDescRect = description.frame;
	newDescRect.size.height = description.frame.size.height + diff;
	description.frame = newDescRect;
	
	//NSLog(@"sv was %f x %f", sv.contentSize.width, sv.contentSize.height);
	
	// and change sv.contentSize by the same amount?
	CGSize newSvSize = CGSizeMake(description.frame.size.width, sv.contentSize.height + diff);
	sv.contentSize = newSvSize;
	//NSLog(@"sv is %f x %f", sv.contentSize.width, sv.contentSize.height);
	


	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterFullStyle];
	
	// some descriptive text about when the programme will be on
	NSString *airDateSubDescription;
	NSTimeInterval startTimeSinceNow = [[Programme Property:kStartTime] timeIntervalSinceNow];
	NSTimeInterval stopTimeSinceNow = [[Programme Property:kStopTime] timeIntervalSinceNow];
	if (stopTimeSinceNow < 0)
	{
		airDateSubDescription = NSLocalizedString(@"already shown", @"programme end time has passed");
	}
	else if (stopTimeSinceNow > 0 && startTimeSinceNow < 0)
	{
		airDateSubDescription = NSLocalizedString(@"started", @"prepended to a time period when a programme is showing");
		airDateSubDescription = [airDateSubDescription stringByAppendingFormat:@" %@ ", [[NSNumber numberWithInt:abs(startTimeSinceNow)] hmsStringReadable]];
		airDateSubDescription = [airDateSubDescription stringByAppendingString:NSLocalizedString(@"ago", @"appended to a time period when a programme is showing")];
		airDateSubDescription = [airDateSubDescription stringByAppendingString:@", "];
		airDateSubDescription = [airDateSubDescription stringByAppendingFormat:@"%@ ", [[NSNumber numberWithInt:abs(stopTimeSinceNow)] hmsStringReadable]];
		airDateSubDescription = [airDateSubDescription stringByAppendingString:NSLocalizedString(@"remaining", @"appended to a time period when a programme is showing")];
	}
	else
	{
		airDateSubDescription = NSLocalizedString(@"starts in", @"prepended to a time period when a programme has not yet started");
		airDateSubDescription = [airDateSubDescription stringByAppendingFormat:@" %@", [[NSNumber numberWithInt:startTimeSinceNow] hmsStringReadable]];
	}
	
	if (iPad())
		date.text = [NSString stringWithFormat:@"%@ (%@)", [df stringFromDate:[Programme Property:kStartTime]], airDateSubDescription];
	else
	{
		// iPhone has separate field for date Subtext
		date.text = [df stringFromDate:[Programme Property:kStartTime]];
		dateSubtext.text = airDateSubDescription;
	}

	
	timeStart.text = [[Programme Property:kStartTime] asFormat:@"HH:mm"];
	timeEnd.text = [[Programme Property:kStopTime] asFormat:@"HH:mm"];
	
	NSTimeInterval duration = stopTimeSinceNow - startTimeSinceNow;
	timeDuration.text = [NSString stringWithFormat:@"(%@)", [[NSNumber numberWithInt:duration] hmsStringReadable]];
	
	NSDate *StartTime = [Programme Property:kStartTime];

	// calculate how far through we are for the progressbar
	NSTimeInterval secondsIn = [[NSDate date] timeIntervalSinceDate:StartTime];
	
	if (secondsIn < 0)
	{
		// programme hasn't started
		pctDone.progress = 0;
	}
	else
	{
		NSTimeInterval duration = [[Programme Property:kStopTime] timeIntervalSinceDate:StartTime];
		// we have started, and we are secondsIn/duration done.
		double done = secondsIn/duration;
		pctDone.progress = done;
	}
	
	ArgusChannel *c = [Programme Channel];
	
	airChannel.text = [c Property:kDisplayName];
	
	// FIXME: cope with logo not existing yet, and being fetched later?
	airChannelLogo.image = [[c Logo] image];
	
}


// hmm, perhaps this should be in a segue?
-(IBAction)recordPressed:(id)sender
{
	recordActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Record", @"title of popup on Programme Details")
													delegate:self
										   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
									  destructiveButtonTitle:nil
										   otherButtonTitles:
						 NSLocalizedString(@"Once", @"record once"),
						 NSLocalizedString(@"Daily", @"record daily"),
						 NSLocalizedString(@"Weekly", @"record weekly"),
						 NSLocalizedString(@"Any Time", @"record anytime"),
						 nil];
	
	if (iPad())
	{
		UIButton *btn = sender;
		[recordActionSheet showFromRect:btn.frame inView:recordButtons animated:YES];
	}
	else
		[recordActionSheet showFromTabBar:self.tabBarController.tabBar];
}
// iPhone only
-(IBAction)searchPressed:(id)sender
{
	searchActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Search", @"title of popup on Programme Details")
													delegate:self
										   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
									  destructiveButtonTitle:nil
										   otherButtonTitles:
						 NSLocalizedString(@"Search IMDb", nil),
						 NSLocalizedString(@"Search tv.com", nil),
						 nil];
	
	if (iPad())
	{
		UIButton *btn = sender;
		[searchActionSheet showFromRect:btn.frame inView:recordButtons animated:YES];
	}
	else
		[searchActionSheet showFromTabBar:self.tabBarController.tabBar];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet == recordActionSheet)
		[self processRecordActionSheetClickAtIndex:buttonIndex];
	
	else if (actionSheet == searchActionSheet)
		[self processSearchActionSheetClickAtIndex:buttonIndex];
}

-(void)processRecordActionSheetClickAtIndex:(NSInteger)buttonIndex
{
	// cancel button
	if (buttonIndex == 4)
		return;
	
	// take a copy of EmptySchedule so we can mess with it
	ArgusSchedule *newSchedule = [[ArgusSchedule alloc] initWithExistingSchedule:[argus EmptySchedule]];
	[newSchedule setScheduleType:ArgusScheduleTypeRecording];

	// title and channel are always set
	ArgusScheduleRule *tmprule;
	tmprule = [[newSchedule Rules] objectForKey:kArgusScheduleRuleSuperTypeTitle];
	[tmprule setMatchType:ArgusScheduleRuleMatchTypeEquals];
	[tmprule setArguments:[NSMutableArray arrayWithObject:[Programme Property:kTitle]]];
	
	tmprule = [[newSchedule Rules] objectForKey:kArgusScheduleRuleSuperTypeChannels];
	[tmprule setMatchType:ArgusScheduleRuleMatchTypeContains];
	NSString *ChannelId = [[Programme Channel] Property:kChannelId];
	[tmprule setArguments:[NSMutableArray arrayWithObject:ChannelId]];
		
	if (buttonIndex == 0) // Once
	{	
		[newSchedule setName:[Programme Property:kTitle]];
		
		// set the date and time of this programme
		tmprule = [[newSchedule Rules] objectForKey:kArgusScheduleRuleTypeOnDate];
		[tmprule setArgumentAsDate:[Programme Property:kStartTime]];
		tmprule = [[newSchedule Rules] objectForKey:kArgusScheduleRuleTypeAroundTime];
		[tmprule setArgumentAsDate:[Programme Property:kStartTime]];
	}
	if (buttonIndex == 1)
	{
		NSString *t = NSLocalizedString(@"Daily", @"record daily");
		[newSchedule setName:[NSString stringWithFormat:@"%@ (%@)", [Programme Property:kTitle], t]];
		
		// set just the time
		tmprule = [[newSchedule Rules] objectForKey:kArgusScheduleRuleTypeAroundTime];
		[tmprule setArgumentAsDate:[Programme Property:kStartTime]];
	}
	if (buttonIndex == 2)
	{
		NSString *t = NSLocalizedString(@"Weekly", @"record weekly");
		[newSchedule setName:[NSString stringWithFormat:@"%@ (%@)", [Programme Property:kTitle], t]];

		// set the day of week
		NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *cmp = [cal components:NSWeekdayCalendarUnit fromDate:[Programme Property:kStartTime]];
		tmprule = [[newSchedule Rules] objectForKey:kArgusScheduleRuleTypeDaysOfWeek];
		// Sunday = 1 .. Saturday = 7
		switch ([cmp weekday])
		{
			case 1: [tmprule setArgumentAsDayOfWeek:ArgusScheduleRuleDayOfWeekSunday    selected:YES]; break;
			case 2: [tmprule setArgumentAsDayOfWeek:ArgusScheduleRuleDayOfWeekMonday    selected:YES]; break;
			case 3: [tmprule setArgumentAsDayOfWeek:ArgusScheduleRuleDayOfWeekTuesday   selected:YES]; break;
			case 4: [tmprule setArgumentAsDayOfWeek:ArgusScheduleRuleDayOfWeekWednesday selected:YES]; break;
			case 5: [tmprule setArgumentAsDayOfWeek:ArgusScheduleRuleDayOfWeekThursday  selected:YES]; break;
			case 6: [tmprule setArgumentAsDayOfWeek:ArgusScheduleRuleDayOfWeekFriday    selected:YES]; break;
			case 7: [tmprule setArgumentAsDayOfWeek:ArgusScheduleRuleDayOfWeekSaturday  selected:YES]; break;
		}
	}
	if (buttonIndex == 3)
	{
		NSString *t = NSLocalizedString(@"Any Time", @"record anytime");
		[newSchedule setName:[NSString stringWithFormat:@"%@ (%@)", [Programme Property:kTitle], t]];

		// no special time params, but set New Episodes
		tmprule = [[newSchedule Rules] objectForKey:kArgusScheduleRuleTypeNewEpisodesOnly];
		[tmprule setArgumentAsBoolean:YES];
	}
	
	// now shunt them over to schedule edit screen to fine-tune and save
	// set up the destination view controller	
	ScheduleViewController *dvc = [[[AppDelegate sharedInstance] ActiveStoryboard] instantiateViewControllerWithIdentifier:@"ScheduleViewController"];
	dvc.Schedule = newSchedule;
	
	[[self navigationController] pushViewController:dvc animated:YES];
}
-(void)processSearchActionSheetClickAtIndex:(NSInteger)buttonIndex
{
	// cancel
	if (buttonIndex == 2)
		return;
	
	if (buttonIndex == 0)
		[self searchIMDbPressed:nil];
	if (buttonIndex == 1)
		[self searchTvComPressed:nil];

}

-(IBAction)searchIMDbPressed:(id)sender
{
	
	NSString *url = [NSString stringWithFormat:@"http://www.imdb.com/find?q=%@&s=tt",
					 [[Programme Property:kTitle] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	
	UINavigationController *nc = [self navigationController];
	WebViewVC *vc = [[WebViewVC alloc] initWithFrame:nc.visibleViewController.view.frame];
	[vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
	[nc pushViewController:vc animated:YES];
}
-(IBAction)searchTvComPressed:(id)sender
{
	NSString *url = [NSString stringWithFormat:@"http://www.tv.com/search?q=%@",
					 [[Programme Property:kTitle] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	
	
	UINavigationController *nc = [self navigationController];
	WebViewVC *vc = [[WebViewVC alloc] initWithFrame:nc.visibleViewController.view.frame];
	[vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
	[nc pushViewController:vc animated:YES];	
}


#pragma mark - Segue Handling
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ScheduleEdit"])
    {
        ScheduleViewController *dvc = (ScheduleViewController *)[segue destinationViewController];
        
		// we need to look up and pull in ScheduleId?
		
		assert(UpcomingProgramme != nil);
		assert([UpcomingProgramme Property:kScheduleId] != nil);
		
		// fetch the ArgusSchedule for ScheduleId, then pass it to dvc..
		dvc.Schedule = [[ArgusSchedule alloc] initWithScheduleId:[UpcomingProgramme Property:kScheduleId]];
	}
	
	// edit upcoming programme details
	if ([[segue identifier] isEqualToString:@"ProgrammeEdit"])
	{
		UpcomingProgrammeEditTVC *dvc = (UpcomingProgrammeEditTVC *)[segue destinationViewController];
		
		assert(UpcomingProgramme);
		
		// pass the Id rather than the programme object, so if the object is reloaded, things don't break
		dvc.UpcomingProgramId = [UpcomingProgramme Property:kUpcomingProgramId];
	}
}


@end
