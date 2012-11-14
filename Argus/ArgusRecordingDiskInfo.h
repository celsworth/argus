//
//  ArgusRecordingDiskInfo.h
//  Argus
//
//  Created by Chris Elsworth on 12/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusBaseObject.h"

#define kArgusRecordingDisksInfoDone @"ArgusRecordingDisksInfoDone"

// an individual disk info, which can be contained in a DisksInfo
@interface ArgusRecordingDiskInfo : ArgusBaseObject

-(id)initWithDictionary:(NSDictionary *)input;

@end

// root result of GetRecordingDisksinfo, has an array of DiskInfo plus total sums
@interface ArgusRecordingDisksInfo : ArgusRecordingDiskInfo
@property (nonatomic, retain) NSMutableArray *RecordingDiskInfos;

-(id)initWithDictionary:(NSDictionary *)input;

@end