//
//  ArgusLiveStream.m
//  Argus
//
//  Created by Chris Elsworth on 10/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusLiveStream.h"

#import "NSString+JSONDate.h"
#import "SBJson.h"

#import "AppDelegate.h"

@implementation ArgusLiveStream
@synthesize Channel;

@synthesize StoppingAsNumber;

// pass a JSONValue decoded dictionary.
-(id)initWithDictionary:(NSDictionary *)input
{
	self = [super init];
	if (self)
	{
		if (! [super populateSelfFromDictionary:input])
			return nil;

		Channel = [[ArgusChannel alloc] initWithDictionary:[input objectForKey:kChannel]];
		
		// our own metadata
		StoppingAsNumber = [NSNumber numberWithBool:NO];
	}
	
	return self;
}
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__); // spammy
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setStopping:(BOOL)val
{
	StoppingAsNumber = [NSNumber numberWithBool:val];
}
-(BOOL)Stopping
{
	return [StoppingAsNumber boolValue];
}

-(void)StopLiveStream
{
	// trigger a Program/{GuideProgramId} request to populate Description etc for this Programme
	NSString *url = [NSString stringWithFormat:@"Control/StopLiveStream"];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:NO lowPriority:NO];

	// request body is the live stream to stop, ie ourselves
	NSString *body = [self.originalData JSONRepresentation];
	[c setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	[c enqueue];
	
	StoppingAsNumber = [NSNumber numberWithBool:YES];
	
	// await notification from ArgusConnection that the request has finished
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(StopLiveStreamDone:)
												 name:kArgusConnectionDone
											   object:c];
}

-(void)StopLiveStreamDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	StoppingAsNumber = [NSNumber numberWithBool:NO];

	// now update our LiveStreams list
	[argus getLiveStreams];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusStopLiveStreamDone object:self];
}


@end
