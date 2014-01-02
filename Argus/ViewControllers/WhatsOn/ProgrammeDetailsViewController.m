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

#import "AppDelegate.h"

@implementation ProgrammeDetailsViewController

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
	
	// refresh when upcoming programmes returns, just to make sure we're accurate
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redraw)
												 name:kArgusUpcomingProgrammesDone
											   object:[argus UpcomingProgrammes]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redraw)
												 name:kArgusProgrammeDone
											   object:self.Programme];
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
		self.sv.contentSize = CGSizeMake(self.description.frame.size.width, 642);
	else
		self.sv.contentSize = CGSizeMake(self.description.frame.size.width, 296);
	
	//	NSLog(@"sv is %f x %f", sv.contentSize.width, sv.contentSize.height);
	
	self.autoRedrawTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(redraw) userInfo:nil repeats:YES];

	[self redraw];
}

-(void)viewDidUnload
{
	[super viewDidUnload];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[self.autoRedrawTimer invalidate];
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

	assert(self.Programme);
	
	//NSLog(@"%@", self.Programme.originalData);
	
	self.UpcomingProgramme = [self.Programme upcomingProgramme];
	if (self.UpcomingProgramme)
	{
		self.upcomingIcon.image = [self.UpcomingProgramme iconImage];
	}
	else
	{
		self.upcomingIcon.image = nil;
	}

	self.progtitle.text = [self.Programme Property:kTitle];
	self.subtitle.text = [self.Programme Property:kSubTitle];
	
	if ([self.Programme Property:kDescription])
	{
		[self.detailsLoading stopAnimating];
		self.description.text = [self.Programme Property:kDescription];
	}
	else
	{
		if ([self.Programme Property:kGuideProgramId])
		{
			self.description.text = nil;

			// no description, if we didn't try to fetch it already, do so
			if (! [self.Programme fullDetailsDone])
			{
				[self.detailsLoading startAnimating];
				
				// send a Guide/Program/{GuideProgramId} request to get description.
				[self.Programme getFullDetails];
			}
		}
		else
		{
			// do not attempt to fetch descriptions if GuideProgramId is nil
			// this signifies a manual recording
			self.description.text = NSLocalizedString(@"<manual recording, no details available>", nil);
		}
	}
	
	// top-align the description text
	[self.description topAlign];
	
#if 0
	CGSize tmp = CGSizeMake(self.description.frame.size.width, MAXFLOAT);
	CGSize test = [[self.description text] sizeWithFont:[self.description font] constrainedToSize:tmp lineBreakMode:UILineBreakModeWordWrap];
	//NSLog(@"sizeWithFont: %f", test.height);
	
	// change description height to the new test.height
	// diff will be negative if new one is shorter
	CGFloat diff = test.height - self.description.frame.size.height;
	
	CGRect newDescRect = self.description.frame;
	newDescRect.size.height = self.description.frame.size.height + diff;
	self.description.frame = newDescRect;
	
	//NSLog(@"sv was %f x %f", sv.contentSize.width, sv.contentSize.height);
	
	// and change sv.contentSize by the same amount?
	CGSize newSvSize = CGSizeMake(self.description.frame.size.width, self.sv.contentSize.height + diff);
	self.sv.contentSize = newSvSize;
	//NSLog(@"sv is %f x %f", sv.contentSize.width, sv.contentSize.height);
#endif

	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterFullStyle];
	
	// some descriptive text about when the programme will be on
	NSString *airDateSubDescription;
	NSTimeInterval startTimeSinceNow = [[self.Programme Property:kStartTime] timeIntervalSinceNow];
	NSTimeInterval stopTimeSinceNow = [[self.Programme Property:kStopTime] timeIntervalSinceNow];
	if (stopTimeSinceNow < 0)
	{
		airDateSubDescription = NSLocalizedString(@"already shown", @"displayed when programme has finished");
	}
	else if (stopTimeSinceNow > 0 && startTimeSinceNow < 0)
	{
		airDateSubDescription = [NSString stringWithFormat:NSLocalizedString(@"started %@ ago, %@ remaining", nil),
								 [@(abs(startTimeSinceNow)) hmsStringReadable], [@(abs(stopTimeSinceNow)) hmsStringReadable]];
	}
	else
	{
		airDateSubDescription = [NSString stringWithFormat:NSLocalizedString(@"starts in %@", @"displayed when programme hasn't started"),
								 [@(startTimeSinceNow) hmsStringReadable]];
	}
	
	if (iPad())
		self.date.text = [NSString stringWithFormat:@"%@ (%@)", [df stringFromDate:[self.Programme Property:kStartTime]], airDateSubDescription];
	else
	{
		// iPhone has separate field for date Subtext
		self.date.text = [df stringFromDate:[self.Programme Property:kStartTime]];
		self.dateSubtext.text = airDateSubDescription;
	}

	
	self.timeStart.text = [[self.Programme Property:kStartTime] asFormat:@"HH:mm"];
	self.timeEnd.text = [[self.Programme Property:kStopTime] asFormat:@"HH:mm"];
	
	NSTimeInterval duration = stopTimeSinceNow - startTimeSinceNow;
	self.timeDuration.text = [NSString stringWithFormat:@"(%@)", [@(duration) hmsStringReadable]];
	
	NSDate *StartTime = [self.Programme Property:kStartTime];

	// calculate how far through we are for the progressbar
	NSTimeInterval secondsIn = [[NSDate date] timeIntervalSinceDate:StartTime];
	
	if (secondsIn < 0)
	{
		// programme hasn't started
		self.pctDone.progress = 0;
	}
	else
	{
		NSTimeInterval duration = [[self.Programme Property:kStopTime] timeIntervalSinceDate:StartTime];
		// we have started, and we are secondsIn/duration done.
		double done = secondsIn/duration;
		self.pctDone.progress = done;
	}
	
	ArgusChannel *c = [self.Programme Channel];
	
	self.airChannel.text = [c Property:kDisplayName];
	
	// FIXME: cope with logo not existing yet, and being fetched later?
	self.airChannelLogo.image = [[c Logo] image];
	
}

-(void)showOptionsActionSheet
{
	// start with generic action sheet with no buttons
	UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Recording Options", nil)
													delegate:self
										   cancelButtonTitle:iPad() ? nil : NSLocalizedString(@"Cancel", nil)
									  destructiveButtonTitle:nil
										   otherButtonTitles:nil];
	
	// add titles depending on state
	self.UpcomingProgramme = [self.Programme upcomingProgramme];
	if (self.UpcomingProgramme)
	{
		actionSheetEditScheduleIndex = [as addButtonWithTitle:NSLocalizedString(@"Edit Schedule", nil)];
		actionSheetEditProgrammeIndex = [as addButtonWithTitle:NSLocalizedString(@"Edit Programme", nil)];
		
		self.editActionSheet = as;
	}
	else
	{
		// TODO: add Reminders/Suggestions?
		
		actionSheetRecordOnceIndex = [as addButtonWithTitle:NSLocalizedString(@"Record Once", nil)];
		actionSheetRecordDailyIndex = [as addButtonWithTitle:NSLocalizedString(@"Record Daily", nil)];
		actionSheetRecordWeeklyIndex = [as addButtonWithTitle:NSLocalizedString(@"Record Weekly", nil)];
		actionSheetRecordAnyTimeIndex = [as addButtonWithTitle:NSLocalizedString(@"Record AnyTime", nil)];
		
		self.recordActionSheet = as;
	}
	
	if (iPad())
		[as showFromBarButtonItem:self.optionsButtonItem animated:YES];
	else
		[as showFromTabBar:self.tabBarController.tabBar];
	
}
-(void)showSearchActionSheet
{
	UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Search", @"title of popup on Programme Details")
													delegate:self
										   cancelButtonTitle:iPad() ? nil : NSLocalizedString(@"Cancel", nil)
									  destructiveButtonTitle:nil
										   otherButtonTitles:nil];
	
	actionSheetSearchImdbIndex = [as addButtonWithTitle:NSLocalizedString(@"Search IMDb", nil)];
	actionSheetSearchTvcomIndex = [as addButtonWithTitle:NSLocalizedString(@"Search tv.com", nil)];
	
	self.searchActionSheet = as;
	
	if (iPad())
		[as showFromBarButtonItem:self.searchButtonItem animated:YES];
	else
		[as showFromTabBar:self.tabBarController.tabBar];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet == self.recordActionSheet)
		[self processRecordActionSheetClickAtIndex:buttonIndex];
	
	else if (actionSheet == self.editActionSheet)
		[self processEditActionSheetClickAtIndex:buttonIndex];

	else if (actionSheet == self.searchActionSheet)
		[self processSearchActionSheetClickAtIndex:buttonIndex];
}


-(void)processRecordActionSheetClickAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"%s: %d", __PRETTY_FUNCTION__, buttonIndex);
	
	// take a copy of EmptySchedule so we can mess with it
	ArgusSchedule *newSchedule = [[ArgusSchedule alloc] initWithExistingSchedule:[argus EmptySchedule]];
	[newSchedule setScheduleType:ArgusScheduleTypeRecording];

	ArgusScheduleRule *tmprule;
	NSMutableDictionary *rules = [newSchedule Rules];
	
	// title and channel are always set
	tmprule = rules[kArgusScheduleRuleSuperTypeTitle];
	[tmprule setMatchType:ArgusScheduleRuleMatchTypeEquals];
	[tmprule setArguments:[NSMutableArray arrayWithObject:[self.Programme Property:kTitle]]];
	
	tmprule = rules[kArgusScheduleRuleSuperTypeChannels];
	[tmprule setMatchType:ArgusScheduleRuleMatchTypeContains];
	NSString *ChannelId = [[self.Programme Channel] Property:kChannelId];
	[tmprule setArguments:[NSMutableArray arrayWithObject:ChannelId]];
		
	if (buttonIndex == actionSheetRecordOnceIndex) // Once
	{	
		[newSchedule setName:[self.Programme Property:kTitle]];
		
		// set the date and time of this programme
		tmprule = rules[kArgusScheduleRuleTypeOnDate];
		[tmprule setArgumentAsDate:[self.Programme Property:kStartTime]];
		tmprule = rules[kArgusScheduleRuleTypeAroundTime];
		[tmprule setArgumentAsDate:[self.Programme Property:kStartTime]];
	}
	else if (buttonIndex == actionSheetRecordDailyIndex)
	{
		NSString *t = NSLocalizedString(@"Daily", @"record daily");
		[newSchedule setName:[NSString stringWithFormat:@"%@ (%@)", [self.Programme Property:kTitle], t]];
		
		// set just the time
		tmprule = rules[kArgusScheduleRuleTypeAroundTime];
		[tmprule setArgumentAsDate:[self.Programme Property:kStartTime]];
	}
	else if (buttonIndex == actionSheetRecordWeeklyIndex)
	{
		NSString *t = NSLocalizedString(@"Weekly", @"record weekly");
		[newSchedule setName:[NSString stringWithFormat:@"%@ (%@)", [self.Programme Property:kTitle], t]];

		// set the day of week
		NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *cmp = [cal components:NSWeekdayCalendarUnit fromDate:[self.Programme Property:kStartTime]];
		tmprule = rules[kArgusScheduleRuleTypeDaysOfWeek];
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
	else if (buttonIndex == actionSheetRecordAnyTimeIndex)
	{
		NSString *t = NSLocalizedString(@"Any Time", @"record anytime");
		[newSchedule setName:[NSString stringWithFormat:@"%@ (%@)", [self.Programme Property:kTitle], t]];

		// no special time params, but set New Episodes
		tmprule = rules[kArgusScheduleRuleTypeNewEpisodesOnly];
		[tmprule setArgumentAsBoolean:YES];
	}
	else
	{
		return; // cancel?
	}
	
	// now shunt them over to schedule edit screen to fine-tune and save
	// set up the destination view controller	
	ScheduleViewController *dvc = [[[AppDelegate sharedInstance] ActiveStoryboard] instantiateViewControllerWithIdentifier:@"ScheduleViewController"];
	dvc.Schedule = newSchedule;
	
	[[self navigationController] pushViewController:dvc animated:YES];
}
-(void)processEditActionSheetClickAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheetEditScheduleIndex)
		[self performSegueWithIdentifier:@"ScheduleEdit" sender:self];
	
	else if (buttonIndex == actionSheetEditProgrammeIndex)
		[self performSegueWithIdentifier:@"ProgrammeEdit" sender:self];
}
-(void)processSearchActionSheetClickAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheetSearchImdbIndex)
		[self searchIMDbPressed:nil];
	
	else if (buttonIndex == actionSheetSearchTvcomIndex)
		[self searchTvComPressed:nil];
}

-(IBAction)searchIMDbPressed:(id)sender
{
	NSString *url = [NSString stringWithFormat:@"http://www.imdb.com/find?q=%@&s=tt",
					 [[self.Programme Property:kTitle] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	return;
	
	UINavigationController *nc = [self navigationController];
	WebViewVC *vc = [[WebViewVC alloc] initWithFrame:nc.visibleViewController.view.frame];
	[vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
	[nc pushViewController:vc animated:YES];
}
-(IBAction)searchTvComPressed:(id)sender
{
	NSString *url = [NSString stringWithFormat:@"http://www.tv.com/search?q=%@",
					 [[self.Programme Property:kTitle] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	return;
	
	UINavigationController *nc = [self navigationController];
	WebViewVC *vc = [[WebViewVC alloc] initWithFrame:nc.visibleViewController.view.frame];
	[vc loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
	[nc pushViewController:vc animated:YES];
}

- (IBAction)optionsButtonPressed:(id)sender
{
	[self showOptionsActionSheet];
}

- (IBAction)searchButtonPressed:(id)sender
{
	[self showSearchActionSheet];
}


#pragma mark - Segue Handling
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ScheduleEdit"])
    {
        ScheduleViewController *dvc = (ScheduleViewController *)[segue destinationViewController];
        
		// we need to look up and pull in ScheduleId?
		
		assert(self.UpcomingProgramme);
		assert([self.UpcomingProgramme Property:kScheduleId]);
		
		// fetch the ArgusSchedule for ScheduleId, then pass it to dvc..
		dvc.Schedule = [[ArgusSchedule alloc] initWithScheduleId:[self.UpcomingProgramme Property:kScheduleId]];
	}
	
	// edit upcoming programme details
	if ([[segue identifier] isEqualToString:@"ProgrammeEdit"])
	{
		UpcomingProgrammeEditTVC *dvc = (UpcomingProgrammeEditTVC *)[segue destinationViewController];
		
		assert(self.UpcomingProgramme);
		
		// pass the Id rather than the programme object, so if the object is reloaded, things don't break
		dvc.UpcomingProgramId = [self.UpcomingProgramme Property:kUpcomingProgramId];
	}
}


@end
