//
//  LiveStreamCell.m
//  Argus
//
//  Created by Chris Elsworth on 05/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "LiveStreamCell.h"

#import "ArgusProgramme.h" // just for colours

#import "AppDelegate.h"

@implementation LiveStreamCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)populateCellWithLiveStream:(ArgusLiveStream *)LiveStream
{
	_LiveStream = LiveStream;
	
	[self redraw];
}

-(void)redraw
{
	self.channel.text = [[self.LiveStream Channel] Property:kDisplayName];
	self.channel.textColor = [ArgusProgramme fgColourStd];

	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateStyle:NSDateFormatterLongStyle];
	[df setTimeStyle:NSDateFormatterMediumStyle];
	
	self.startTime.text = [df stringFromDate:[self.LiveStream Property:kStreamStartedTime]];
	self.startTime.textColor = [ArgusProgramme fgColourStd];

	self.rtspURL.text = [self.LiveStream Property:kRtspUrl];
	self.rtspURL.textColor = [ArgusProgramme fgColourStd];
	
	if ([self.LiveStream Property:kCardId])
	{
		self.cardId.text = [NSString stringWithFormat:@"Card #%@", [self.LiveStream Property:kCardId]];
		self.cardId.textColor = [ArgusProgramme fgColourStd];
		
	}
	
	
	if ([self.LiveStream Stopping])
		[self.stoppingActivityIndicator startAnimating];
	else
		[self.stoppingActivityIndicator stopAnimating];
}

@end
