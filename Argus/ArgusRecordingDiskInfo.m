//
//  ArgusRecordingDiskInfo.m
//  Argus
//
//  Created by Chris Elsworth on 12/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusRecordingDiskInfo.h"

@implementation ArgusRecordingDiskInfo

// pass a JSONValue decoded dictionary.
-(id)initWithDictionary:(NSDictionary *)input
{
	self = [super init];
	if (self)
	{
		if (! [super populateSelfFromDictionary:input])
			return nil;
		
	}

	return self;
}

@end




@implementation ArgusRecordingDisksInfo
@synthesize RecordingDiskInfos;

// pass a JSONValue decoded dictionary.
-(id)initWithDictionary:(NSDictionary *)input
{
	self = [super initWithDictionary:input];
	if (self)
	{
		// directly from incoming object
		// nothing to do, ArgusRecordingDiskInfo does it all!
		// Name will just always be null
		
		NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity: 32];
		
		// fill in RecordingDiskInfos array with each individual disk
		for (NSDictionary *d in input[kRecordingDiskInfos])
		{
			ArgusRecordingDiskInfo *t = [[ArgusRecordingDiskInfo alloc] initWithDictionary:d];
			[tmpArr addObject:t];
		}
		RecordingDiskInfos = tmpArr;
		
	}
	
	return self;
}



@end
