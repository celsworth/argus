//
//  ProgrammeSummaryCell.m
//  Argus
//
//  Created by Chris Elsworth on 05/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ProgrammeSummaryCell.h"

#import "ArgusChannel.h"

#import "AppDelegate.h"

#import "NSDateFormatter+LocaleAdditions.h"
#import "UILabel+Alignment.h"

@implementation ProgrammeSummaryCell
@synthesize Programme, UpcomingProgramme, ActiveRecording;
@synthesize title, time, icon, priority;
@synthesize chan, chan_image;
@synthesize activity;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)populateCellWithActiveRecording:(ArgusActiveRecording *)_ActiveRecording
{
	ActiveRecording = _ActiveRecording;
	UpcomingProgramme = [ActiveRecording UpcomingProgramme];
	Programme = UpcomingProgramme;
	[self redraw];
}

-(void)populateCellWithUpcomingProgramme:(ArgusUpcomingProgramme *)_UpcomingProgramme
{
	UpcomingProgramme = _UpcomingProgramme;
	Programme = UpcomingProgramme;
	[self redraw];
}


-(void)populateCellWithProgramme:(ArgusProgramme *)_Programme
{
	Programme = _Programme;
	
	[self redraw];
}

-(void)redraw
{
	// in case we got here via a notification..
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kArgusChannelLogoDone object:[[Programme Channel] Logo]];
	
	title.text = [Programme Property:kTitle];
	
	
	UIColor *textColor;
	// is this programme in the past? we use this to grey out the text labels
	if ([[Programme Property:kStopTime] timeIntervalSinceNow] < 0)
		textColor = [ArgusProgramme fgColourAlreadyShown];
	else
		textColor = [ArgusProgramme fgColourStd];
	
	ArgusUpcomingProgramme *upc = UpcomingProgramme ? UpcomingProgramme : [Programme upcomingProgramme];
	if (upc)
	{
		icon.image = [upc iconImage];
		priority.text = [ArgusSchedule stringForPriority:[[upc Property:kPriority] intValue]];
		priority.textColor = textColor;
	}
	else
	{
		icon.image = nil;
		priority.text = @"";
	}
	
	ArgusUpcomingRecording *upcr = [upc upcomingRecording];
	if (upcr)
		self.card.text = [NSString stringWithFormat:@"Card #%@", [[upcr CardChannelAllocation] Property:kCardId]];
	else
		self.card.text = nil;
	
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterFullStyle];
	NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
	[df2 setDateStyle:NSDateFormatterNoStyle];
	[df2 setTimeStyle:NSDateFormatterShortStyle];
	time.text = [NSString stringWithFormat:@"%@, %@ - %@", [df stringFromDate:[Programme Property:kStartTime]],
				 [df2 stringFromDate:[Programme Property:kStartTime]], [df2 stringFromDate:[Programme Property:kStopTime]]];
	time.textColor = textColor;
	
	title.text = [Programme Property:kTitle];
	title.textColor = textColor;
	
	chan.text = [[Programme Channel] Property:kDisplayName];
	chan.textColor = textColor;

	UIImage *img = [[[Programme Channel] Logo] image];
	if (img)
	{
		chan_image.image = img;
	}
	else
	{
		// logo not done yet, wait for a notification and we'll load it later?
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(redraw)
													 name:kArgusChannelLogoDone
												   object:[[Programme Channel] Logo]];
		
		chan_image.image = nil;
		
		// draw a spinny for now?
	}
	
	// active recording support
	if (ActiveRecording)
	{
		if ([ActiveRecording Stopping])
			[activity startAnimating];
		else
			[activity stopAnimating];
	}
}



@end
