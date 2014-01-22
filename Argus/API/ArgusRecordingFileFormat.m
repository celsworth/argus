//
//  ArgusRecordingFileFormat.m
//  Argus
//
//  Created by Chris Elsworth on 15/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusRecordingFileFormat.h"

@implementation ArgusRecordingFileFormat

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
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__); // spammy
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Scheduler/SaveRecordingFileFormat
-(void)save
{
	
	
	
}
-(void)SaveDone:(NSNotification *)notify
{
	
}


// Scheduler/DeleteRecordingFileFormat/{recordingFileFormatId}
-(void)delete
{
	
	
	
}
-(void)DeleteDone:(NSNotification *)notify
{
	
}


@end
