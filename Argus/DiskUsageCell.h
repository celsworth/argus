//
//  DiskUsageCell.h
//  Argus
//
//  Created by Chris Elsworth on 05/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusRecordingDiskInfo.h"

@interface DiskUsageCell : UITableViewCell

@property (nonatomic, retain) ArgusRecordingDiskInfo *RecordingDiskInfo;

@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *size;
@property (nonatomic, weak) IBOutlet UILabel *used;
@property (nonatomic, weak) IBOutlet UILabel *free;

@property (nonatomic, weak) IBOutlet UILabel *hd_free;
@property (nonatomic, weak) IBOutlet UILabel *sd_free;

@property (nonatomic, weak) IBOutlet UIProgressView *usedProgressView;

-(void)populateCellWithRecordingDiskInfo:(ArgusRecordingDiskInfo *)_RecordingDiskInfo;

@end
