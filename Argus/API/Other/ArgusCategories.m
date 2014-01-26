//
//  ArgusCategories.m
//  Argus
//
//  Created by Chris Elsworth on 16/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusCategories.h"
#import "ArgusConnection.h"

#import "AppDelegate.h"

@implementation ArgusCategories

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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)getCategories
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[AppDelegate requestLoadingSpinner];
	
	NSString *url = @"Guide/Categories";
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	
	// block-based observer, since its only used in response to this notification
	[[NSNotificationCenter defaultCenter] addObserverForName:kArgusConnectionDone object:c
													   queue:[NSOperationQueue mainQueue]
												  usingBlock:^(NSNotification *notify)
	 {
		 NSLog(@"%s", __PRETTY_FUNCTION__);
		 
		 [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
		 
		 NSData *data = [notify userInfo][@"data"];
		 NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
		 NSMutableArray *tmpArr = [NSMutableArray new];
		 
		 for (NSString *category in jsonObject)
		 {
			 [tmpArr addObject:category];
		 }
		 
		 [self setCategories:tmpArr];
		 
		 [[NSNotificationCenter defaultCenter] postNotificationName:kArgusCategoriesDone
															 object:self
														   userInfo:nil];
		 
		 [AppDelegate releaseLoadingSpinner];
	 }];
	
}

#if 0
// old way of doing it
-(void)getCategoriesDone:(NSNotification *)notify
{
	//NSLog(@"%d", [notify name] == kArgusConnectionDone);
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	NSData *data = notify.userInfo[@"data"];
	
	//NSData *data = [[notify userInfo] objectForKey:@"data"];
	NSArray *jsonObject = [data objectFromJSONData];
	
	//NSLog(@"%@", jsonObject);
	
	NSMutableArray *tmpArr = [NSMutableArray new];
	
	for (NSString *category in jsonObject)
	{
		//NSLog(@"%s %@", __PRETTY_FUNCTION__, category);
		
		[tmpArr addObject:category];
	}
	
	[self setCategories:tmpArr];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusCategoriesDone object:self userInfo:nil];
	
	[AppDelegate releaseLoadingSpinner];
}
#endif

@end