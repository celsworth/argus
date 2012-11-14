//
//  ArgusConnection.h
//  Argus
//
//  Created by Chris Elsworth on 02/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kArgusConnectionDone @"kArgusConnectionDone"
#define kArgusConnectionFail @"kArgusConnectionFail"

@interface ArgusConnection : NSObject <NSURLConnectionDelegate>


@property (nonatomic, retain) NSHTTPURLResponse *httpresponse;
@property (nonatomic, retain) NSError *error;

// simplified init that assumes startImmediately=YES and lowPriority=NO
-(id)initWithUrl:(NSString *)url;
-(id)initWithUrl:(NSString *)url startImmediately:(BOOL)startImmediately lowPriority:(BOOL)lowPriority;

-(void)setHTTPBody:(NSData *)body;

-(void)enqueue;

-(BOOL)start;
-(void)cancel;

@end
