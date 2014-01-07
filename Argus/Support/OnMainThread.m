//
//  OnMainThread.m
//  Argus
//
//  Created by Chris Elsworth on 07/01/2014.
//  Copyright (c) 2014 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "OnMainThread.h"

// a place to put some simple calls that will be run on the main thread via dispatch_async


@implementation OnMainThread

+(void)postNotificationName:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:notificationName
															object:notificationSender
														  userInfo:userInfo];
	});
}


@end
