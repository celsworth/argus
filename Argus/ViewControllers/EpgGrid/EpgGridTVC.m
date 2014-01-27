//
//  FirstViewController.m
//  Argus
//
//  Created by Chris Elsworth on 28/02/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "EpgGridTVC.h"
#import "ArgusChannel.h"

#import "ProgrammeDetailsViewController.h"
#import "ProgrammeListViewController.h"

#import "AppDelegate.h"
#import "MasterViewController.h"

#import "EpgGridCalendarPickerVC.h"
#import "EpgGridLongPressPopupTVC.h"

@implementation EpgGridTVC
@synthesize rowHeight;
@synthesize autoUpdateTimer;
@synthesize popoverController;
@synthesize labelsByProgrammeUniqueIdentifier, viewsByChannelId, labelsByIndexPath;
@synthesize timeRow, timeRow2, curTimeLine;
@synthesize epgStartTime, pps;
@synthesize curDay, toolBar;
@synthesize RequestsOutstanding, RequestsTotal;

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		// fire off a programmes request for each channel in the group when we know them
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(ChannelGroupChannelsDone:)
													 name:kArgusChannelGroupChannelsDone
												   object:nil];
		
		// be notified when the active channel group changes (from another view probably)
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(refreshPressed:)
													 name:kArgusSelectedChannelGroupChanged
												   object:[argus ChannelGroups]];
		
		// redraw visible boxes when UpcomingProgrammes changes, so red boxes appear correctly
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reloadData)
													 name:kArgusUpcomingProgrammesDone
												   object:[argus UpcomingProgrammes]];
		
		// when the side panel is hidden/shown on iPad, we need to fix our frame
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(fixGridFrame)
													 name:kArgusSidePanelDisplayStateChanged
												   object:nil];
		
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
-(void)dealloc
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	viewsByChannelId = nil;
	labelsByIndexPath = nil;
	labelsByProgrammeUniqueIdentifier = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
    [super viewDidLoad];
	
	[self invalidateCaches];
	
	// getChannels for the selected group
	[[[argus ChannelGroups] SelectedChannelGroup] getChannels];
	
	UIBarButtonItem *rbtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																		  target:self
																		  action:@selector(refreshPressed:)];
	
	UIBarButtonItem *rbtn2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Now", @"go to current time in EPG Grid")
															  style:UIBarButtonItemStyleBordered
															 target:self
															 action:@selector(nowPressed:)];
	
	[[self navigationItem] setRightBarButtonItems:@[rbtn, rbtn2]];
	
    
    // setting height arbitrarily low stops the scrollview doing vertical scroll
    sv2.contentSize = CGSizeMake(tv.frame.size.width, 1);
	
	//sv2.maximumZoomScale = 3;
	
	// iPad has slightly bigger cells
	if (iPad())
	{
		// iPad
		rowHeight = 70;
	}
	else
	{
		// iPhone
		rowHeight = 54;
	}
	
	
	// we have EPG_TABLE_WIDTH pixels to use
	// minus 50 for the logo on the left
	// gives us (EPG_TABLE_WIDTH-50)/86400 pixels per second of a day
	pps = EPG_TABLE_WIDTH/86400.0;
	
	timeRow = [[UIView alloc] initWithFrame:CGRectZero];
	timeRow.backgroundColor = [UIColor whiteColor];
	timeRow.alpha = 0.8;
	
	timeRow2 = [[UIView alloc] initWithFrame:CGRectZero];
	timeRow2.backgroundColor = [UIColor whiteColor];
	timeRow2.alpha = 0.8;
	
	// midnight is an NSDate representing the start of the day we're showing
	epgStartTime = [self epgStartTimeForDate:[NSDate date]];
	
	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateStyle:NSDateFormatterNoStyle];
	[df setTimeStyle:NSDateFormatterShortStyle];
	
	// generate labels for each hour from midnight to 23:00
	NSTimeInterval addOn = 0;
	for (addOn = 0; addOn < 86400; addOn += 3600)
	{
		NSDate *hour = [epgStartTime dateByAddingTimeInterval:addOn];
		
		[timeRow addSubview:[self labelForTimeHeaderAtTime:hour usingDateFormatter:df]];
		[timeRow2 addSubview:[self labelForTimeHeaderAtTime:hour usingDateFormatter:df]];
		
		// light gray vertical lines on each hour marker
		NSInteger x = pps * addOn;
		UIView *hourLine = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 1, tv.frame.size.height)];
		hourLine.backgroundColor = [UIColor lightGrayColor];
		hourLine.alpha = 0.7;
		hourLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[sv2 addSubview:hourLine];
		[sv2 sendSubviewToBack:hourLine];
	}
	
	// set up red vertical line to show the current time
	// it's shown by default and hidden if necessary in updateCurTimeLine
	NSInteger x = pps * [[NSDate date] timeIntervalSinceDate:epgStartTime];
	curTimeLine = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 2, tv.frame.size.height)];
	curTimeLine.backgroundColor = [UIColor redColor];
	curTimeLine.alpha = 1;
	curTimeLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[sv2 addSubview:curTimeLine];
	[sv2 sendSubviewToBack:curTimeLine];
	
	[self zoomToDate:[NSDate date] animated:NO];
	
	if (dark)
	{
		[toolBar setBarTintColor:[UIColor blackColor]];
	}
	
	[self.view setBackgroundColor:[ArgusColours bgColour]];
}

- (void)viewDidUnload
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	curTimeLine = nil;
	timeRow = nil;
	timeRow2 = nil;
	
	[self invalidateCaches];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
    [super viewWillAppear:animated];
	
	// reverse what we did in viewWillDisappear
	sv2.delegate = self;
	
	// ensure our sv2 size is still right (in case we rotated while offview)
	[self fixGridFrame];
	
	[self updateCurTimeLine];
	[self updateCurDayButton];
	
	// update the current timeline
	autoUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
													   target:self
													 selector:@selector(updateCurTimeLine)
													 userInfo:nil
													  repeats:YES];
}

/*
 - (void)viewDidAppear:(BOOL)animated
 {
 [super viewDidAppear:animated];
 }
 */

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	// this stops a crash when repeatedly quickly reloading the view
	// because we call zoomToNow in Appear, it's possible for it to be sent to
	// an instance which is being deallocated. This stops it.
	sv2.delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// stop auto-updating
	[autoUpdateTimer invalidate];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// update frame of sv2
	// to be display width - chanlogo table width (and gap), and x offset to be chanlogo width (and gap)
	// height is kept as-is
	[self fixGridFrame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)fixGridFrame
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	sv2.frame = CGRectMake(CHANNEL_SCROLLVIEW_GAP + tv_chanlogos.frame.size.width, sv2.frame.origin.y,
						   self.view.frame.size.width - tv_chanlogos.frame.size.width - CHANNEL_SCROLLVIEW_GAP, sv2.frame.size.height);
}

-(void)invalidateCaches
{
	labelsByIndexPath = [NSMutableDictionary new];
	labelsByProgrammeUniqueIdentifier = [NSMutableDictionary new];
	viewsByChannelId = [NSMutableDictionary new];
}

-(NSDate *)epgStartTimeForDate:(NSDate *)date
{
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	// subtract 3 hours from the passed-in date, so when the user is viewing midnight-2:59am, we drop back
	// into the previous day, because our EPG runs from 3am-3am.
	NSDateComponents *cmps = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
									fromDate:[date dateByAddingTimeInterval:-kArgusEpgGridStartHour]];
	
	
	// our EPG day starts at 3am
	[cmps setHour:kArgusEpgGridStartHour];
	
	return [cal dateFromComponents:cmps];
}

-(UILabel *)labelForTimeHeaderAtTime:(NSDate *)time usingDateFormatter:(NSDateFormatter *)df
{
	static NSTimeInterval duration = 3600;
	
	NSInteger offset = pps * [time timeIntervalSinceDate:epgStartTime];
	NSInteger width = (pps*duration)-2;
	
	UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(offset, 0, width, HEADER_HEIGHT)];
	l.font = [UIFont systemFontOfSize:12.0];
	l.text = [df stringFromDate:time];
	l.backgroundColor = [UIColor clearColor];
	return l;
}

-(void)zoomToDate:(NSDate *)date animated:(BOOL)animated
{
	// timeDiff < 0 = requested date is before our start time
	// timeDiff > 0 && < 86400 = requested date is in our day
	// timeDiff > 86400 = requested date is day after our displayed day
	
	NSLog(@"%s %@", __PRETTY_FUNCTION__, date);
	
	NSTimeInterval timeDiff = [date timeIntervalSinceDate:epgStartTime];
	//if ([epgStartTime timeIntervalSince1970] != [[self epgStartTimeForDate:date] timeIntervalSince1970])
	if (timeDiff < 0 || timeDiff > 86400)
	{
		// the requested date is outside the date currently shown
		epgStartTime = [self epgStartTimeForDate:date];
		NSLog(@"%s go to %@", __PRETTY_FUNCTION__, epgStartTime);
		[self refreshPressed:self];
		
		// disable animation if we're going to be busy reloading the EPG as well
		animated = NO;
	}
	
	NSInteger x = pps * [date timeIntervalSinceDate:epgStartTime] - 100;
	
	// ensure that going to this offset won't show any empty space
	if (x < 0)
		x = 0;
	
	if (x > (EPG_TABLE_WIDTH - sv2.frame.size.width))
		x = EPG_TABLE_WIDTH - sv2.frame.size.width;
	
	CGPoint p = CGPointMake(x, 0);
	[sv2 setContentOffset:p animated:animated];
}

-(void)updateCurTimeLine
{
	NSInteger secsPastMidnight = [[NSDate date] timeIntervalSinceDate:epgStartTime];
	
	// are we in the right day to show the current time line?
	//if ([epgStartTime timeIntervalSince1970] != [[self epgStartTimeForDate:date] timeIntervalSince1970])
	if (secsPastMidnight > 0 && secsPastMidnight < 86400)
	{
		curTimeLine.hidden = NO;
		
		// do we actually need to move it?
		if (curTimeLine.frame.origin.x != (pps * secsPastMidnight))
		{
			CGRect new = CGRectMake(pps * secsPastMidnight, 0, 2, tv.frame.size.height);
			curTimeLine.frame = new;
			
			// update labels and background colours if we moved the line
			// TESTING PER PROGRAMME NOTIFICATION UPDATES
			//[self updateVisibleLabels];
		}
	}
	else
		curTimeLine.hidden = YES;
	
}

-(void)updateCurDayButton
{
	// make sure curDay is right too
	NSDateFormatter *df = [NSDateFormatter new];
	if (iPad())
		[df setDateStyle:NSDateFormatterFullStyle];
	else
		[df setDateStyle:NSDateFormatterMediumStyle];
	
	curDay.title = [df stringFromDate:epgStartTime];
}


#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[argus ChannelGroups] SelectedChannelGroup] Channels] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (tableView == tv_chanlogos)
		return [[UIView alloc] initWithFrame:CGRectZero];
	
	return timeRow;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	if (tableView == tv_chanlogos)
		return [[UIView alloc] initWithFrame:CGRectZero];
	
	return timeRow2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return HEADER_HEIGHT;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return HEADER_HEIGHT;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s %@", __PRETTY_FUNCTION__, indexPath);
	
	UITableViewCell *cell;
	
	ArgusChannel *c = [[[argus ChannelGroups] SelectedChannelGroup] Channels][indexPath.row];
	
	if (tableView == tv_chanlogos)
	{
		// CHANNEL LOGOS TABLE
		cell = [tableView dequeueReusableCellWithIdentifier:@"epg_chanlogo"];
		
		// remove any previous egc instances
		for (UIView *subview in [[cell contentView] subviews])
		{
			if ([subview isKindOfClass:[UIImageView class]])
				[subview removeFromSuperview];
		}
		
		EpgGridChannel *egc = viewsByChannelId[[c Property:kChannelId]];
		
		if (egc)
			// and add the new one
			[[cell contentView] addSubview:egc.view];
		
		return cell;
	}
	
	
	// MAIN TABLE
    cell = [tableView dequeueReusableCellWithIdentifier:@"epg_chan"];
	
	// remove all the old labels first
	for (UIView *subview in [[cell contentView] subviews])
	{
		if ([subview isKindOfClass:[UIView class]])
			[subview removeFromSuperview];
	}
	
	
	NSArray *arr = labelsByIndexPath[@(indexPath.row)];
	
	// and add the right ones back
	if (arr)
	{
		for (EpgGridLabel *egl in arr)
		{
			// TESTING PER PROGRAMME NOTIFICATION UPDATES
			//[egl updateColours];
			
			[[cell contentView] addSubview:egl.view];
		}
	}
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// needed in iOS7?
	[cell setBackgroundColor:[UIColor clearColor]];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//NSLog(@"%s %@", __PRETTY_FUNCTION__, scrollView);
	
	if (scrollView == tv)
	{
		// update chanlogo table to match this contentOffset
		CGPoint newOffset = tv_chanlogos.contentOffset;
		newOffset.y = tv.contentOffset.y;
		tv_chanlogos.contentOffset = newOffset;
		return;
	}
	
	if (scrollView == tv_chanlogos)
	{
		// update main tv to match this contentOffset
		CGPoint newOffset = tv.contentOffset;
		newOffset.y = tv_chanlogos.contentOffset.y;
		tv.contentOffset = newOffset;
		return;
	}
	
	if (scrollView == sv2)
	{
		// fall through to adjusting programme title labels below
		//return;
	}
	
	//NSDate *start = [NSDate date];
	
	// update labels and background colours
	[self updateVisibleLabels];
	
	//NSLog(@"updateVisibleLabels took %f seconds", [[NSDate date] timeIntervalSinceDate:start]);
}

-(void)updateVisibleLabels
{
	CGFloat hScrollOffset = sv2.contentOffset.x;
	CGFloat hScrollOffsetEnd = hScrollOffset + sv2.frame.size.width;
	
	// for each visible row
	for (NSIndexPath *indexPath in [tv indexPathsForVisibleRows])
	{
		// each EpgGridLabel in that row
		for (EpgGridLabel *egl in labelsByIndexPath[@(indexPath.row)])
		{
			// ignore if the cell is completely invisible
			CGRect viewFrame = [[egl view] frame];
			
			if (hScrollOffset > (viewFrame.origin.x + viewFrame.size.width))
			{
				// frame is off the left hand side of the display
				continue;
			}
			
			else if (hScrollOffsetEnd < viewFrame.origin.x)
			{
				// frame is off the right hand side of the display
				// we don't need to check any more
				break;
			}
			
			// now we know frame is visible
			
			// check the background colour is still right
			// TESTING PER PROGRAMME NOTIFICATION UPDATES
			//[egl updateColours];
			
			// now we start looking at the label
			CGRect labelFrame = [[egl label] frame];
			
			if (viewFrame.origin.x < hScrollOffset)
			{
				// start of frame is offscreen, we need to move this title!
				CGFloat moveTo = hScrollOffset - viewFrame.origin.x;
				
				// only move the title if there is a decent chunk of the cell left (100px)
				// or we are moving left, deduced by moveTo < labelFrame.origin.x
				if (labelFrame.size.width > 100 || moveTo < labelFrame.origin.x)
				{
					CGRect newFrame = CGRectMake(moveTo, labelFrame.origin.y, viewFrame.size.width-moveTo, labelFrame.size.height);
					[egl resizeLabel:newFrame];
				}
			}
			
			else
			{
				// start of frame is onscreen (end of frame not necessarily but we don't care about that)
				// check the title is in the right place (resetLabel checks whether to change frame)
				[egl resetLabel];
			}
		}
		
	}
}

#pragma mark - ScrollView test stuff
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return tv;
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}



#pragma mark - EpgGridLabel delegate
-(void)epgGridLabel:(EpgGridLabel *)egl receivedTapOn:(UITapGestureRecognizer *)recognizer
{
	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	ProgrammeDetailsViewController *dvc = [[[AppDelegate sharedInstance] ActiveStoryboard] instantiateViewControllerWithIdentifier:@"ProgrammeDetailsViewController"];
	dvc.Programme = egl.Programme;
	
	if (0 && iPad())
	{
		/* popover test */
		
		// get rid of any existing popover, cannot have more than one up at a time
		[popoverController dismissPopoverAnimated:YES];
		
		CGRect fromRect = egl.view.frame;
		fromRect.origin.y = egl.tableViewCell.frame.origin.y;
		
		popoverController = [[UIPopoverController alloc] initWithContentViewController:dvc];
		[popoverController setPopoverContentSize:CGSizeMake(500, 400)];
		[popoverController presentPopoverFromRect:fromRect inView:tv permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else
		[[self navigationController] pushViewController:dvc animated:YES];
	
}

#pragma mark - EpgGridChannel delegate
-(void)epgGridChannel:(EpgGridChannel *)egl receivedTapOn:(UITapGestureRecognizer *)recognizer
{
	ProgrammeListViewController *dvc = [[[AppDelegate sharedInstance] ActiveStoryboard] instantiateViewControllerWithIdentifier:@"ProgrammeListViewController"];
	dvc.Channel = egl.Channel;
	
	[[self navigationController] pushViewController:dvc animated:YES];
}
-(void)epgGridLabel:(EpgGridLabel *)egl receivedLongPressOn:(UILongPressGestureRecognizer *)recognizer
{
	if (!iPad())
	{
		// for now, disabled on iPhone until I work out a way to implement
		// the actions without needing the code in 3 different places
		return;
		
#if 0
		// on iPhone, the long press menu is in a UIActionSheet
		UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Quick Options"
														delegate:self
											   cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:nil
											   otherButtonTitles:
							 @"Record",
							 @"Search IMDb",
							 @"Search tv.com",
							 nil];
		
		[as showFromTabBar:[[self tabBarController] tabBar]];
		return;
#endif
	}
	
	
	
	// on iPad, it's in a popover
	
	
	UINavigationController *nc;
	EpgGridLongPressPopupTVC *dvc;
	
	// get rid of any existing popover, cannot have more than one up at a time
	[popoverController dismissPopoverAnimated:YES];
	
	nc = [[[AppDelegate sharedInstance] ActiveStoryboard] instantiateViewControllerWithIdentifier:@"QuickProgrammeOptionsNC"];
	dvc = (EpgGridLongPressPopupTVC *)[nc visibleViewController];
	
	
	// this presents a popover here rather than in a segue, because in the segue, the anchor point
	// of the popover cannot be set programmatically (fromRect in here)
	//[self performSegueWithIdentifier:@"QuickProgrammeOptions" sender:egl];
	//return;
	
	[[dvc navigationItem] setTitle:[egl.Programme Property:kTitle]];
	
	[dvc setProgramme:egl.Programme];
	
	UIView *v = egl.view;
	UITableViewCell *cell = egl.tableViewCell;
	CGRect fromRect = CGRectMake(v.frame.origin.x, cell.frame.origin.y, v.frame.size.width, v.frame.size.height);
	
	popoverController = [[UIPopoverController alloc] initWithContentViewController:nc];
	[dvc setPopoverController:popoverController];
	[popoverController setPopoverContentSize:CGSizeMake(330, 220)];
	[popoverController presentPopoverFromRect:fromRect inView:tv permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// currently for Quick Options actionsheet on iPhone
	// which is disabled, so this does nothing yet
}


#pragma mark - SelectChannelGroup Delegate
-(void)didSelectChannelGroup:(ArgusChannelGroup *)ChannelGroup
{
	// this will set various other things in motion like getChannels etc.
	[[argus ChannelGroups] setSelectedChannelGroup:ChannelGroup];
	
	// be nice to cancel all outstanding requests..
	
	// release all the EpgGridChannel objects we just removed from view
	// and all their programmes/labels
	[self invalidateCaches];
}

#pragma mark - TKCalendarMonthView delegate
-(void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)date
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, date);
	
	// because our EPG starts at 3am, we need to add 3 hours to this.
	// otherwise zoomToDate thinks we want the previous day to what we actually selected.
	NSDate *actualZoom = [date dateByAddingTimeInterval:kArgusEpgGridStartHour];
	
	[self zoomToDate:actualZoom animated:YES];
	
	if (!iPad())
	{
		// dismissing the calendar immediately with animation on iPhone seems to lead
		// to the wrong date being shown in the grid. probably interpreting a second
		// press while it's moving.. a short delay works around it
		[NSTimer scheduledTimerWithTimeInterval:0.3
										 target:self
									   selector:@selector(dismissCalendarOniPhone)
									   userInfo:nil
										repeats:NO];
	}
	
}
-(void)dismissCalendarOniPhone
{
	[[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Segue Handling
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, [segue identifier]);
    if ([[segue identifier] isEqualToString:@"SelectChannelGroup"])
	{
		// prevent two being visible at once
		if (iPad())
			[popoverController dismissPopoverAnimated:YES];
		
		UINavigationController *navC = [segue destinationViewController];
		SelectChannelGroupViewController *dvc = (SelectChannelGroupViewController *)[navC visibleViewController];
		
		if (iPad())
		{
			popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
			[dvc setPopoverController:popoverController];
		}
		// we pass in the global argus object here
		[dvc setMyArgus:argus];
		
		[dvc setForceChannelType:ArgusChannelTypeAny];
		
		// a link back to us from the SelectChannelGroup controller, so it can tell us what they selected.
		[dvc setDelegate:self];
	}
	
	
	if ([[segue identifier] isEqualToString:@"EpgGridCalendarPicker"])
	{
		EpgGridCalendarPickerVC *cmvc = (EpgGridCalendarPickerVC *)[segue destinationViewController];
		[cmvc setDelegate:self];
		
		// this needs testing for timezone issues, I think I fixed it
		[[cmvc cal] selectDate:epgStartTime];
		
		if (iPad())
		{
			// prevent two being visible at once
			[popoverController dismissPopoverAnimated:YES];
			
			popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
			[cmvc setPopoverController:popoverController];
			
			CGRect frame = cmvc.cal.frame;
			[popoverController setPopoverContentSize:CGSizeMake(frame.size.width, 309)];
		}
	}
	
#if 0
	// not actually currently used, we do it in receivedLongPressOn: instead, see comments in there
	if ([[segue identifier] isEqualToString:@"QuickProgrammeOptions"])
	{
		EpgGridLabel *egl = sender;
		
		// get rid of any existing popover, cannot have more than one up at a time
		[popoverController dismissPopoverAnimated:YES];
		
		UINavigationController *nc = [segue destinationViewController];
		
		EpgGridLongPressPopupTVC *dvc = (EpgGridLongPressPopupTVC *)[nc visibleViewController];
		[[dvc navigationItem] setTitle:[egl.Programme Property:kTitle]];
		
		UIView *v = egl.view;
		UITableViewCell *cell = egl.tableViewCell;
		CGRect fromRect = CGRectMake(v.frame.origin.x, cell.frame.origin.y, v.frame.size.width, v.frame.size.height);
		
		popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
		[popoverController setPopoverContentSize:CGSizeMake(300, 100)];
	}
#endif
}

#pragma mark - IBActions
-(IBAction)refreshPressed:(id)sender
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	
	// cancel all outstanding requests - but how?
	
	[[[argus ChannelGroups] SelectedChannelGroup] getChannels];
	[self updateCurTimeLine];
	[self updateCurDayButton];
}
-(IBAction)nowPressed:(id)sender
{
	[self updateCurTimeLine];
	[self zoomToDate:[NSDate date] animated:YES];
}

-(IBAction)prevDayPressed:(id)sender
{
	epgStartTime = [epgStartTime dateByAddingTimeInterval:-86400];
	[self refreshPressed:self];
}
-(IBAction)curDayPressed:(id)sender
{
	
}
-(IBAction)nextDayPressed:(id)sender
{
	epgStartTime = [epgStartTime dateByAddingTimeInterval:86400];
	[self refreshPressed:self];
}


#pragma mark - Observer Selectors
-(void)ChannelGroupChannelsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	ArgusChannelGroup *cg = [notify object];
	
	[self invalidateCaches];
	[self reloadData];
	
	// 1.6.1.0 B7 (API 50) and newer have an API call we can use to get all channel data for a CG
	// if the new API call fails, we fall back in ChannelGroupProgrammesFail
	
	[cg getProgrammesFrom:epgStartTime to:[epgStartTime dateByAddingTimeInterval:86400]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChannelGroupProgrammesDone:)
												 name:kArgusProgrammesDone
											   object:cg];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChannelGroupProgrammesFail:)
												 name:kArgusProgrammesFail
											   object:cg];
}

-(void)ChannelGroupProgrammesFail:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	ArgusChannelGroup *cg = [notify object];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:cg];
	
	// fall back to old way
	[self getProgrammesForChannelGroupOneAtATime:cg];
}

-(void)ChannelGroupProgrammesDone:(NSNotification *)notify
{
	// a channel data for a channel group
	
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	ArgusChannelGroup *cg = [notify object];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:cg];
	
	// fill out EpgGridChannel and EpgGridLabel objects, then redraw the entire table
	for (ArgusChannel *c in [cg Channels])
	{
		// EpgGridChannel object
		EpgGridChannel *egc;
		NSString *ChannelId = [c Property:kChannelId];
		
		if (! (egc = viewsByChannelId[ChannelId]))
		{
			egc = [[EpgGridChannel alloc] initWithRowHeight:rowHeight channel:c delegate:self];
			
			[egc makeView];
			
			// retain the object so cellForRowAtIndexPath can use it shortly..
			viewsByChannelId[ChannelId] = egc;
		}
		
		// EpgGridLabel objects
		
		// programme data for that channel..
		NSMutableArray *Programmes = [cg ProgrammeArraysKeyedByChannelId][ChannelId];
		
		NSMutableArray *tmpArr = [NSMutableArray new];
		
		EpgGridLabel *egl;
		for (ArgusProgramme *p in Programmes)
		{
			// caching optimisation
			NSString *UniqueIdentifier = [p uniqueIdentifier];
			
			if (! (egl = labelsByProgrammeUniqueIdentifier[UniqueIdentifier]) )
			{
				egl = [[EpgGridLabel alloc] initWithRowHeight:rowHeight
													 midnight:epgStartTime
													programme:p
													 delegate:self];
				[egl makeView];
				
				//	[labelsByTGR setObject:egl forKey:egl.label.gestureRecognizers];
				labelsByProgrammeUniqueIdentifier[UniqueIdentifier] = egl;
			}
			
			[tmpArr addObject:egl];
			
			// updateColours is done in cellForRowAtIndexPath so no need to do it here
			//[egl updateColours];
		}
		
		NSUInteger row = [[cg Channels] indexOfObjectIdenticalTo:c];
		labelsByIndexPath[@(row)] = tmpArr;
	}
	
	[tv_chanlogos reloadData]; [tv reloadData];
	
	[self updateVisibleLabels];
}


-(void)getProgrammesForChannelGroupOneAtATime:(ArgusChannelGroup *)cg
{
	RequestsOutstanding = 0;
	RequestsTotal = 0;
	// as each one is done, reload that row
	for (ArgusChannel *c in [[[argus ChannelGroups] SelectedChannelGroup] Channels])
	{
		// getProgrammes for each entry of SelectedChannelGroup Channels
		// from midnight to midnight+86400
		[c getProgrammesFrom:epgStartTime to:[epgStartTime dateByAddingTimeInterval:86400]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChannelProgrammesDone:)
													 name:kArgusProgrammesDone
												   object:c];
		
		RequestsOutstanding++;
		RequestsTotal++;
	}
}
-(void)ChannelProgrammesDone:(NSNotification *)notify
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// probably for a channel in the previous channel group?
	if ([[[argus ChannelGroups] SelectedChannelGroup] Channels] == nil)
		// ignore it
		return;
	
	ArgusChannel *c = [notify object];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kArgusProgrammesDone object:c];
	
	RequestsOutstanding--;
	
	// prepare our model so cellForRowAtIndexPath doesn't have much work to do
	
	NSUInteger row = [[[[argus ChannelGroups] SelectedChannelGroup] Channels] indexOfObjectIdenticalTo:c];
	
	// crash fix, bit hacky. check that the SelectedChannelGroup hasn't changed since
	// we requested these programmes. if it has, do not attempt to draw them into the table!
	if (row == NSNotFound)
		return;
	
	
	// had a crash report which could have been explained by either c or ChannelId being nil
	if (!c)
	{
		NSLog(@"%s c=nil :(", __PRETTY_FUNCTION__);
	}
	if (![c Property:kChannelId])
	{
		NSLog(@"%s c.ChannelId=nil :(", __PRETTY_FUNCTION__);
	}
	
	assert(c);
	
	// CHANNEL LOGOS TABLE
	EpgGridChannel *egc;
	
	if (! (egc = viewsByChannelId[[c Property:kChannelId]]))
	{
		egc = [[EpgGridChannel alloc] initWithRowHeight:rowHeight channel:c delegate:self];
		
		[egc makeView];
		
		// retain the object so cellForRowAtIndexPath can use it shortly..
		viewsByChannelId[[c Property:kChannelId]] = egc;
	}
	
	// MAIN TABLE
	if ([[c Programmes] count] == 0)
	{
		// nothing to do?
		return;
	}
	
	// array of EpgGridLabels
	NSMutableArray *tmpArr = [NSMutableArray new];
	
	// programmatically make a label for each programme entry
	EpgGridLabel *egl;
	for (ArgusProgramme *p in [c Programmes])
	{
		// caching optimisation
		NSString *UniqueIdentifier = [p uniqueIdentifier];
		
		if (! (egl = labelsByProgrammeUniqueIdentifier[UniqueIdentifier]) )
		{
			egl = [[EpgGridLabel alloc] initWithRowHeight:rowHeight
												 midnight:epgStartTime
												programme:p
												 delegate:self];
			[egl makeView];
			
			//	[labelsByTGR setObject:egl forKey:egl.label.gestureRecognizers];
			labelsByProgrammeUniqueIdentifier[UniqueIdentifier] = egl;
		}
		
		[tmpArr addObject:egl];
		
		// updateColours is done in cellForRowAtIndexPath so no need to do it here
		//[egl updateColours];
	}
	
	// used in cellForRowAtIndexPath to actually draw them in
	labelsByIndexPath[@(row)] = tmpArr;
	
	[tv_chanlogos reloadData]; [tv reloadData];
}


-(void)reloadData
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[tv reloadData];
	[self updateVisibleLabels];
	[tv_chanlogos reloadData];
}
@end
