//
//  EpgGridLabel.m
//  Argus
//
//  Created by Chris Elsworth on 04/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "EpgGridLabel.h"
#import "NSString+JSONDate.h"

#import "ArgusUpcomingProgramme.h"
#import "ArgusChannel.h"

@implementation EpgGridLabel
@synthesize delegate;
@synthesize Programme;
@synthesize rowHeight, midnight;
@synthesize view, label, iconView, origFrameRect;
@synthesize viewPadding;

-(id)initWithRowHeight:(NSInteger)_rowHeight midnight:(NSDate *)_midnight programme:(ArgusProgramme *)_Programme delegate:(id <EpgGridLabelDelegate>)_delegate
{
	self = [super init];
	
	rowHeight = _rowHeight;
	midnight = _midnight;
	Programme = _Programme;
	delegate = _delegate;
	
	// 3 pixels padding in each view to make labels not hug the sides of the box
	viewPadding = 3;
	
	return self;
}
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
}

-(UIView *)makeView
{
	// 2px gap at top and bottom of row
	NSInteger topAndBottomOffset = 2;

	float pps = EPG_TABLE_WIDTH / 86400.0;
	
	// calculate some sizing for this view
	
	// ArgusProgramme pre-caches StartTime and StopTime as NSDate, since they're expensive
	// to calculate, and used lots
	NSDate *StartTime = [Programme StartTime];
	NSDate *StopTime  = [Programme StopTime];
	
	NSTimeInterval duration = [StopTime timeIntervalSinceDate:StartTime];
	NSInteger offset = pps * [StartTime timeIntervalSinceDate:midnight];
	NSInteger width = (pps*duration) - 4; // 4 pixels gap to the right of each box
	
	if (offset < 0)
	{
		NSTimeInterval foo = [StartTime timeIntervalSinceDate:midnight];
		width -= (pps * abs(foo));
		offset = 0;
	}
	
	if (offset + width > EPG_TABLE_WIDTH)
	{
		width = EPG_TABLE_WIDTH - offset;
	}
	
	view = [[UIView alloc] initWithFrame:CGRectMake(offset, topAndBottomOffset, width, rowHeight - (topAndBottomOffset * 2))];
	view.alpha = 0.7;
	
	// done when we're about to display instead
	//[self updateColours];

	iconView = [[UIImageView alloc] initWithFrame:CGRectMake(width-25, topAndBottomOffset, 25, 16)];
	
	label = [[UILabel alloc] init];
	label.backgroundColor = [UIColor clearColor];
	
	// to make gesture recognisers work
	label.userInteractionEnabled = YES;
	
	[self resetLabel]; // set default size
	
	if (width > 30)
	{
		label.text = [Programme Property:kTitle];
		
		label.font = [UIFont boldSystemFontOfSize:12.0];
		label.numberOfLines = 0;
	}
	//x.adjustsFontSizeToFitWidth = YES;
	//x.minimumFontSize = 10.0;
	
	
	UITapGestureRecognizer *tgr;
	UILongPressGestureRecognizer *lpgr;
	
	tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnLabel:)];
	
	lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressOnLabel:)];
	[lpgr setMinimumPressDuration:0.5];
	
	label.gestureRecognizers = @[tgr, lpgr];

	[view addSubview:label];
	
	return view;
}



-(void)updateColours
{
	// start off with standard EPG background bluey tint colour
	UIColor *colourToSet = [ArgusProgramme bgColourEpgCell];
	
	// programmes that are on now
	// this is overridden by active recordings since it's above the next block..
	if ([Programme isOnNow])
		colourToSet = [ArgusProgramme bgColourOnNow];

	ArgusUpcomingProgramme *upc = [Programme upcomingProgramme];
	if (upc)
	{
		// display a schedule icon for upcoming programmes if we have the space to put it in
		if (view.frame.size.width > 40)
		{
			iconView.image = [upc iconImage];
			[iconView setContentMode:UIViewContentModeTopRight];
			[view addSubview:iconView];
		}
		
		/* how to use utf8 labels :)
		 UILabel *labeltest = [[UILabel alloc] initWithFrame:CGRectMake(width-15, topAndBottomOffset, width, 15)];
		 [labeltest setBackgroundColor:[UIColor clearColor]];
		 [labeltest setFont:[UIFont systemFontOfSize:10.0]];
		 labeltest.text = @"\U0001F534";
		 [view addSubview:labeltest];
		 */
		
		// set a red background for programmes that are goign to be recorded
		switch ([upc scheduleStatus])
		{
			case ArgusUpcomingProgrammeScheduleStatusRecordingScheduled:
			case ArgusUpcomingProgrammeScheduleStatusRecordingScheduledConflict:
				colourToSet = [ArgusProgramme bgColourUpcomingRec];
				break;
			
			default:
				// nothing else gets a colour so far
				break;
		}

	}
	else
	{
		iconView.image = nil;
		[iconView removeFromSuperview];
	}

	// be nice to store our colour as enum and then a condition can avoid re-setting the same colour
	view.backgroundColor = colourToSet;
	
	// foreground colour
	if ([[Programme StopTime] timeIntervalSinceNow] < 0)
		// programmes in the past
		label.textColor = [ArgusProgramme fgColourAlreadyShown];
	else
		label.textColor = [ArgusProgramme fgColourStd];
	
}


-(void)resizeLabel:(CGRect)newFrame
{
	// check that newFrame complies with our padding and doesn't exceed width of the view frame
	CGRect viewFrame = [view frame];
	CGSize viewSize = viewFrame.size;

	if (newFrame.origin.x < viewPadding)
		newFrame.origin.x = viewPadding;

	if (newFrame.origin.y < viewPadding)
		newFrame.origin.y = viewPadding;
	
	// if width+xOffset > allowable size after padding, fix it
	if (newFrame.size.width + newFrame.origin.x > viewSize.width - viewPadding)
		newFrame.size.width = viewSize.width - newFrame.origin.x - viewPadding;
	
	// same for height, though we don't usually tinker with this
	if (newFrame.size.height + newFrame.origin.y > viewSize.height - viewPadding)
		newFrame.size.height = viewSize.height - newFrame.origin.y - viewPadding;

	// apply the new frame, if it differed from the old one
	if (label.frame.origin.x != newFrame.origin.x || label.frame.origin.y != newFrame.origin.y ||
		label.frame.size.width != newFrame.size.width || label.frame.size.height != newFrame.size.height)
		[label setFrame:newFrame];
	
	//	if (label.frame.origin.x > 0)
		//		label.text = [NSString stringWithFormat:@"< %@", [Programme Title]];
}
-(void)resetLabel
{
	// reset label to original size if necessary
	CGSize viewSize = [view frame].size;
	
	CGRect newFrame = CGRectMake(viewPadding, viewPadding,
								 viewSize.width - (viewPadding*2),
								 viewSize.height - (viewPadding*2));

	if (label.frame.origin.x != newFrame.origin.x || label.frame.origin.y != newFrame.origin.y ||
		label.frame.size.width != newFrame.size.width || label.frame.size.height != newFrame.size.height)
		[label setFrame:newFrame];
	
	//	label.text = [Programme Title];

}


-(void)didLongPressOnLabel:(id)sender
{
	// only send the notification when we first detect the long press
	// not when they lift fingers off, or move fingers, etc.
	if ([sender state] == UIGestureRecognizerStateBegan)
		[delegate epgGridLabel:self receivedLongPressOn:sender];	
}

-(void)didTapOnLabel:(id)sender
{
	[delegate epgGridLabel:self receivedTapOn:sender];
}

@end
