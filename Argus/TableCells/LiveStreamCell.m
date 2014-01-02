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
@synthesize LiveStream;
@synthesize channel, startTime, cardId, rtspURL;
@synthesize stoppingActivityIndicator;


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

-(void)populateCellWithLiveStream:(ArgusLiveStream *)_LiveStream
{
	LiveStream = _LiveStream;
	
	[self redraw];
}

-(void)redraw
{
	channel.text = [[LiveStream Channel] Property:kDisplayName];
	channel.textColor = [ArgusProgramme fgColourStd];

	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterLongStyle];
	[df setTimeStyle:NSDateFormatterMediumStyle];
	
	startTime.text = [df stringFromDate:[LiveStream Property:kStreamStartedTime]];
	startTime.textColor = [ArgusProgramme fgColourStd];

	rtspURL.text = [LiveStream Property:kRtspUrl];
	rtspURL.textColor = [ArgusProgramme fgColourStd];
	
	if ([LiveStream Property:kCardId])
	{
		cardId.text = [NSString stringWithFormat:@"Card #%@", [LiveStream Property:kCardId]];
		cardId.textColor = [ArgusProgramme fgColourStd];
		
	}
	
	
	if ([LiveStream Stopping])
		[stoppingActivityIndicator startAnimating];
	else
		[stoppingActivityIndicator stopAnimating];	
}

@end
