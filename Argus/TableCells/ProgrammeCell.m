//
//  ProgrammeCell.m
//  Argus
//
//  Created by Chris Elsworth on 04/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

// this is used in a programme listing (list of programmes on same channel)
// so  What's On -> tap row     -> Programme List
// and EPG       -> tap channel -> Programme List


#import "ProgrammeCell.h"

#import "AppDelegate.h"

#import "NSDateFormatter+LocaleAdditions.h"
#import "UILabel+Alignment.h"

@implementation ProgrammeCell

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

-(void)populateCellWithProgramme:(ArgusProgramme *)Programme
{
	_Programme = Programme;
	
	[self redraw];
}

-(void)redraw
{
	self.title.text = [self.Programme Property:kTitle];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] initWithPOSIXLocaleAndFormat:@"HH:mm"];
	
	UIColor *textColor;
	// is this programme in the past? we use this to grey out the text labels
	if ([self.Programme hasFinished])
		textColor = [ArgusProgramme fgColourAlreadyShown];
	else
		textColor = [ArgusProgramme fgColourStd];
	
	ArgusUpcomingProgramme *upc = [self.Programme upcomingProgramme];
	if (upc)
		self.icon.image = [upc iconImage];
	else
		self.icon.image = nil;
	
	self.time.text = [df stringFromDate:[self.Programme Property:kStartTime]];
	self.time.textColor = textColor;
	
	self.title.text = [self.Programme Property:kTitle];
	self.title.textColor = textColor;
	
	self.desc.text = [self.Programme Property:kDescription];
	self.desc.textColor = textColor;
	
	[self.desc topAlign];
}


@end
