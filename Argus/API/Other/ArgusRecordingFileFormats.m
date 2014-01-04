//
//  ArgusRecordingFileFormats.m
//  Argus
//
//  Created by Chris Elsworth on 15/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusRecordingFileFormats.h"
#import "ArgusRecordingFileFormat.h"

#import "ArgusConnection.h"
#import "AppDelegate.h"

#import "JSONKit.h"

@implementation ArgusRecordingFileFormats

-(id)init
{
	self = [super init];
	if (self)
	{
	}
	return self;
}
-(void)dealloc
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)getRecordingFileFormats
{
	[AppDelegate requestLoadingSpinner];
	
	NSString *url = [NSString stringWithFormat:@"Scheduler/RecordingFileFormats"];
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	
	[[NSNotificationCenter defaultCenter] addObserverForName:kArgusConnectionDone object:c
													   queue:[NSOperationQueue mainQueue]
												  usingBlock:^(NSNotification *notify)
	{
		 NSLog(@"%s", __PRETTY_FUNCTION__);
		
		// there will be no more notifications from that object
		[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
		
		NSData *data = [notify userInfo][@"data"];
		NSArray *jsonObject = [data objectFromJSONData];
		
		NSMutableArray *tmpArr = [NSMutableArray new];
		NSMutableDictionary *tmpDict = [NSMutableDictionary new];
		
		for (NSDictionary *t in jsonObject)
		{
			//NSLog(@"%s %@", __PRETTY_FUNCTION__, t);
			
			ArgusRecordingFileFormat *r = [[ArgusRecordingFileFormat alloc] initWithDictionary:t];
			
			[tmpArr addObject:r];
			tmpDict[[r Property:kRecordingFileFormatId]] = r;
		}
		
		self.RecordingFileFormats = tmpArr;
		self.RecordingFileFormatsKeyedById = tmpDict;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kArgusRecordingFileFormatsDone
															object:self
														  userInfo:nil];
		
		[AppDelegate releaseLoadingSpinner];

	}];
	
}

@end
