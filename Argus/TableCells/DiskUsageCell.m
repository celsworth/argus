//
//  DiskUsageCell.m
//  Argus
//
//  Created by Chris Elsworth on 05/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "DiskUsageCell.h"

#import "ArgusColours.h"
#import "ArgusProgramme.h" // just for colours

#import "NSNumber+humanSize.h"

@implementation DiskUsageCell
@synthesize RecordingDiskInfo;
@synthesize name, size, used, free, hd_free, sd_free, usedProgressView;


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

-(void)populateCellWithRecordingDiskInfo:(ArgusRecordingDiskInfo *)_RecordingDiskInfo;
{
	RecordingDiskInfo = _RecordingDiskInfo;
	[self redraw];
}

-(void)redraw
{
	name.text = [RecordingDiskInfo Property:kName];
	name.textColor = [ArgusProgramme fgColourStd];
	
	size.text = [[RecordingDiskInfo Property:kTotalSizeBytes] humanSize];
	//size.textColor = [ArgusProgramme fgColourStd];

	used.text = [NSString stringWithFormat:@"%@ used",
				 [@([[RecordingDiskInfo Property:kTotalSizeBytes] doubleValue] - [[RecordingDiskInfo Property:kFreeSpaceBytes] doubleValue]) humanSize]];
	//used.textColor = [ArgusProgramme fgColourStd];

	free.text = [NSString stringWithFormat:@"%@ free", [[RecordingDiskInfo Property:kFreeSpaceBytes] humanSize]];
	//free.textColor = [ArgusProgramme fgColourStd];

	hd_free.text = [NSString stringWithFormat:@"%@h HD", [[RecordingDiskInfo Property:kFreeHoursHD] stringValue]];
	hd_free.textColor = [ArgusProgramme fgColourStd];

	sd_free.text = [NSString stringWithFormat:@"%@h SD", [[RecordingDiskInfo Property:kFreeHoursSD] stringValue]];
	sd_free.textColor = [ArgusProgramme fgColourStd];

	usedProgressView.progress = [[RecordingDiskInfo Property:kPercentageUsed] doubleValue] / 100.0;
}


@end
