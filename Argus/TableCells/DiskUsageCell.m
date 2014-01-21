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

-(void)populateCellWithRecordingDiskInfo:(ArgusRecordingDiskInfo *)RecordingDiskInfo;
{
	_RecordingDiskInfo = RecordingDiskInfo;
	[self redraw];
}

-(void)redraw
{
	self.name.text = [self.RecordingDiskInfo Property:kName];
	self.name.textColor = [ArgusProgramme fgColourStd];
	
	self.size.text = [[self.RecordingDiskInfo Property:kTotalSizeBytes] humanSize];
	//size.textColor = [ArgusProgramme fgColourStd];

	self.used.text = [NSString stringWithFormat:@"%@ used",
				 [@([[self.RecordingDiskInfo Property:kTotalSizeBytes] doubleValue] - [[self.RecordingDiskInfo Property:kFreeSpaceBytes] doubleValue]) humanSize]];
	//used.textColor = [ArgusProgramme fgColourStd];

	self.free.text = [NSString stringWithFormat:@"%@ free", [[self.RecordingDiskInfo Property:kFreeSpaceBytes] humanSize]];
	//free.textColor = [ArgusProgramme fgColourStd];

	self.hd_free.text = [NSString stringWithFormat:@"%@h HD", [[self.RecordingDiskInfo Property:kFreeHoursHD] stringValue]];
	self.hd_free.textColor = [ArgusProgramme fgColourStd];

	self.sd_free.text = [NSString stringWithFormat:@"%@h SD", [[self.RecordingDiskInfo Property:kFreeHoursSD] stringValue]];
	self.sd_free.textColor = [ArgusProgramme fgColourStd];

	self.usedProgressView.progress = [[self.RecordingDiskInfo Property:kPercentageUsed] doubleValue] / 100.0;
}


@end
