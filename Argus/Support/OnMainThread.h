//
//  OnMainThread.h
//  Argus
//
//  Created by Chris Elsworth on 07/01/2014.
//  Copyright (c) 2014 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnMainThread : NSObject

+(void)postNotificationName:(NSString *)notificationName object:(id)notificationSender userInfo:(NSDictionary *)userInfo;

@end