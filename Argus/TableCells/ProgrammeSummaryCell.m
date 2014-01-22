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

-(void)populateCellWithActiveRecording:(ArgusActiveRecording *)ActiveRecording
{
	_ActiveRecording = ActiveRecording;
	_UpcomingProgramme = [ActiveRecording UpcomingProgramme];
	[self populateCellWithProgramme:self.UpcomingProgramme];
}

-(void)populateCellWithUpcomingProgramme:(ArgusUpcomingProgramme *)UpcomingProgramme
{
	_UpcomingProgramme = UpcomingProgramme;
	[self populateCellWithProgramme:UpcomingProgramme];
}


-(void)populateCellWithProgramme:(ArgusProgramme *)Programme
{
	_Programme = Programme;
	
	[self redraw];
}

-(void)redraw
{
	// in case we got here via a notification..
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kArgusChannelLogoDone object:[[self.Programme Channel] Logo]];
	
	self.title.text = [self.Programme Property:kTitle];
	
	
	UIColor *textColor;
	// is this programme in the past? we use this to grey out the text labels
	if ([self.Programme hasFinished])
		textColor = [ArgusProgramme fgColourAlreadyShown];
	else
		textColor = [ArgusProgramme fgColourStd];
	
	ArgusUpcomingProgramme *upc = self.UpcomingProgramme ? self.UpcomingProgramme : [self.Programme upcomingProgramme];
	if (upc)
	{
		self.icon.image = [upc iconImage];
		self.priority.text = [ArgusSchedule stringForPriority:[[upc Property:kPriority] intValue]];
		self.priority.textColor = textColor;
	}
	else
	{
		self.icon.image = nil;
		self.priority.text = @"";
	}
	
	ArgusUpcomingRecording *upcr = [upc upcomingRecording];
	if (upcr)
		self.card.text = [NSString stringWithFormat:@"Card #%@", [[upcr CardChannelAllocation] Property:kCardId]];
	else
		self.card.text = nil;
	
	
	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateStyle:NSDateFormatterFullStyle];
	NSDateFormatter *df2 = [NSDateFormatter new];
	[df2 setDateStyle:NSDateFormatterNoStyle];
	[df2 setTimeStyle:NSDateFormatterShortStyle];
	self.time.text = [NSString stringWithFormat:@"%@, %@ - %@", [df stringFromDate:[self.Programme Property:kStartTime]],
					  [df2 stringFromDate:[self.Programme Property:kStartTime]], [df2 stringFromDate:[self.Programme Property:kStopTime]]];
	self.time.textColor = textColor;
	
	self.title.text = [self.Programme Property:kTitle];
	self.title.textColor = textColor;
	
	self.chan.text = [[self.Programme Channel] Property:kDisplayName];
	self.chan.textColor = textColor;
	
	UIImage *img = [[[self.Programme Channel] Logo] image];
	if (img)
	{
		self.chan_image.image = img;
	}
	else
	{
		// logo not done yet, wait for a notification and we'll load it later?
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(redraw)
													 name:kArgusChannelLogoDone
												   object:[[self.Programme Channel] Logo]];
		
		self.chan_image.image = nil;
		
		// draw a spinny for now?
	}
	
	// active recording support
	if (self.ActiveRecording)
	{
		if ([self.ActiveRecording Stopping])
			[self.activity startAnimating];
		else
			[self.activity stopAnimating];
	}
}



@end
