//
//  ArgusConnection.h
//  Argus
//
//  Created by Chris Elsworth on 02/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ConnectionCompletionBlock)(NSHTTPURLResponse *, NSData *, NSError *);

#define kArgusConnectionDone @"kArgusConnectionDone"
#define kArgusConnectionFail @"kArgusConnectionFail"

@interface ArgusConnection : NSObject <NSURLConnectionDelegate>

@property (nonatomic, retain) NSHTTPURLResponse *httpresponse;
@property (nonatomic, retain) NSError *error;

// simplified inits that assumes startImmediately=YES and lowPriority=NO
-(id)initWithUrl:(NSString *)url;
-(id)initWithUrl:(NSString *)url completionBlock:(ConnectionCompletionBlock)completionBlock;

// single argument overrides
-(id)initWithUrl:(NSString *)url startImmediately:(BOOL)startImmediately completionBlock:(ConnectionCompletionBlock)completionBlock;
-(id)initWithUrl:(NSString *)url lowPriority:(BOOL)lowPriority completionBlock:(ConnectionCompletionBlock)completionBlock;

-(id)initWithUrl:(NSString *)url startImmediately:(BOOL)startImmediately lowPriority:(BOOL)lowPriority;

// full call
-(id)initWithUrl:(NSString *)url startImmediately:(BOOL)startImmediately lowPriority:(BOOL)lowPriority
 completionBlock:(ConnectionCompletionBlock)ConnectionCompletionBlock;

-(void)setHTTPBody:(NSData *)body;

-(void)enqueue;

-(BOOL)start;
-(void)cancel;

@end
