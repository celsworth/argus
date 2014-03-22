//
//  ArgusLiveStream.m
//  Argus
//
//  Created by Chris Elsworth on 10/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusLiveStream.h"

#import "AppDelegate.h"

@interface ArgusLiveStream()

// our own metadata
// this is set to YES when StopLiveStream has been sent
// then back to NO when we get confirmation.
// Status->LiveStreams uses this to update it's table accordingly
@property (nonatomic, retain) NSNumber *StoppingAsNumber;

@end


@implementation ArgusLiveStream

// pass a JSONValue decoded dictionary.
-(id)initWithDictionary:(NSDictionary *)input
{
	self = [super init];
	if (self)
	{
		if (! [super populateSelfFromDictionary:input])
			return nil;
		
		_Channel = [[ArgusChannel alloc] initWithDictionary:input[kChannel]];
		
		// our own metadata
		_StoppingAsNumber = @NO;
	}
	
	return self;
}
-(void)dealloc
{
	self.Channel = nil;
	
	//NSLog(@"%s", __PRETTY_FUNCTION__); // spammy
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setStopping:(BOOL)val
{
	self.StoppingAsNumber = @(val);
}
-(BOOL)Stopping
{
	return [self.StoppingAsNumber boolValue];
}

-(void)StopLiveStream
{
	NSString *url = [NSString stringWithFormat:@"Control/StopLiveStream"];
	
	ArgusConnectionCompletionBlock cmp = ^(NSHTTPURLResponse *response, NSData *data, NSError *error)
	{
		NSLog(@"%s", __PRETTY_FUNCTION__);
		
		self.StoppingAsNumber = @NO;
		
		// now update our LiveStreams list
		// this needs doing on the main thread, not entirely sure why
		// maybe this block's runloop is destroyed when the block ends, even though we ran this?
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[argus getLiveStreams];
		}];
		
		[OnMainThread postNotificationName:kArgusStopLiveStreamDone object:self userInfo:nil];
	};
	
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url
											 startImmediately:NO // because we need a http body, set below
												  lowPriority:NO
											  completionBlock:cmp];
	
	// request body is the live stream to stop, ie ourselves
	[c setHTTPBody:[NSJSONSerialization dataWithJSONObject:self.originalData options:0 error:nil]];
	[c enqueue];
	
	self.StoppingAsNumber = @YES;
}



@end
