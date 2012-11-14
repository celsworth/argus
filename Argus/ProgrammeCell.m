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
@synthesize Programme;
@synthesize title, time, desc, icon;

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

-(void)populateCellWithProgramme:(ArgusProgramme *)_Programme
{
	Programme = _Programme;
	
	[self redraw];
}

-(void)redraw
{
	title.text = [Programme Property:kTitle];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] initWithPOSIXLocaleAndFormat:@"HH:mm"];
	
	UIColor *textColor;
	// is this programme in the past? we use this to grey out the text labels
	if ([[Programme Property:kStopTime] timeIntervalSinceNow] < 0)
		textColor = [ArgusProgramme fgColourAlreadyShown];
	else
		textColor = [ArgusProgramme fgColourStd];
	
	ArgusUpcomingProgramme *upc = [Programme upcomingProgramme];
	if (upc)
		icon.image = [upc iconImage];
	else
		icon.image = nil;
	
	time.text = [df stringFromDate:[Programme Property:kStartTime]];
	time.textColor = textColor;
	
	title.text = [Programme Property:kTitle];
	title.textColor = textColor;
	
	desc.text = [Programme Property:kDescription];
	desc.textColor = textColor;
	
	// debugging assistance ;)
	//	desc.backgroundColor = [UIColor redColor];
	
	// note this magic number is in heightForRow too
	[desc topAlignUsingWidth:self.frame.size.width -  (iPad() ? 129.0 : 108.0) ];
}


@end
