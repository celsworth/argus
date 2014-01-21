//
//  ArgusConnection.m
//  Argus
//
//  Created by Chris Elsworth on 02/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusConnection.h"
#import "AppDelegate.h"
#import "SimpleKeychain.h"

@interface ArgusConnection () // private properties

@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) BOOL lowPriority;

// initialised in init
@property (nonatomic, retain) NSMutableURLRequest *req;
@property (nonatomic, copy) ConnectionCompletionBlock completionBlock;

// this is set to ourselves on init and nulled when we're done
// this ensures we're not released while our connection is alive
@property (nonatomic, retain) ArgusConnection *retainSelf;

@property (nonatomic, retain) NSTimer *timeOutTimer;

// transient data related to the connection
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSURLAuthenticationChallenge *connectionChallenge;
@property (nonatomic, retain) NSMutableData *receivedData;

//@property (nonatomic, retain) NSString *jobId;

@end

// instantiated every time we make a connection to Argus. Handles all subsequent network stuff.
@implementation ArgusConnection

-(id)initWithUrl:(NSString *)url 
{
	// old style default call, expected to handle notifications
	return [self initWithUrl:url startImmediately:YES lowPriority:NO completionBlock:nil];
}
-(id)initWithUrl:(NSString *)url completionBlock:(ConnectionCompletionBlock)completionBlock
{
	// new style default call, pass a block for completion
	return [self initWithUrl:url startImmediately:YES lowPriority:NO completionBlock:completionBlock];
}

// single arg overrides
-(id)initWithUrl:(NSString *)url startImmediately:(BOOL)startImmediately completionBlock:(ConnectionCompletionBlock)completionBlock
{
	return [self initWithUrl:url startImmediately:startImmediately lowPriority:NO completionBlock:completionBlock];
}
-(id)initWithUrl:(NSString *)url lowPriority:(BOOL)lowPriority completionBlock:(ConnectionCompletionBlock)completionBlock
{
	return [self initWithUrl:url startImmediately:YES lowPriority:lowPriority completionBlock:completionBlock];
}

-(id)initWithUrl:(NSString *)url startImmediately:(BOOL)startImmediately lowPriority:(BOOL)lowPriority
{
	// being phased out..
	return [self initWithUrl:url startImmediately:startImmediately lowPriority:lowPriority completionBlock:nil];
}

// full method
-(id)initWithUrl:(NSString *)url startImmediately:(BOOL)startImmediately lowPriority:(BOOL)lowPriority
 completionBlock:(ConnectionCompletionBlock)completionBlock
{
	self = [super init];
	if (self)
	{	
		// remember these so we can restart the request if we need auth details
		_url = url;
		_lowPriority = !lowPriority;
		_completionBlock = completionBlock;
		_retainSelf = self;
		
		_req = [NSMutableURLRequest new];
		[_req setHTTPMethod:@"POST"];
		[_req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[_req setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
		[_req setTimeoutInterval:600.0]; // artificially long, we do NSTimer for timeout
		// url set in start
		
		_connection = nil;
		_receivedData = [NSMutableData new];
		
		if (startImmediately)
		{
			// connections are now started by arguscq, don't usually call -start directly
			[self enqueue];
		}
	}
	
	return self;
}

-(void)setHTTPBody:(NSData *)body
{
	[_req setHTTPBody:body];
}

// if startImmediately was false, call enqueue instead (generally after setting a body)
-(void)enqueue
{
	if (_lowPriority)
		[[[AppDelegate sharedInstance] arguscq] queueConnection:self];
	else
		[[[AppDelegate sharedInstance] arguscq] queueUrgentConnection:self];
}

-(BOOL)start
{
	if (_connection) return NO; // connection already started!
	if (!_req) return NO; // connection already finished!
	
	[_req setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [self baseURL], _url]]];

	NSLog(@"Argus %@ -start", _url);

	_httpresponse = nil;
	_error = nil;
	
	_connection = [[NSURLConnection alloc] initWithRequest:_req delegate:self];
	
	// set up our own timeout
	_timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
													 target:self
												   selector:@selector(cancel)
												   userInfo:nil
													repeats:NO];
	
	[AppDelegate requestNetworkActivityIndicator];
	
	return YES;
}
-(void)cancel
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[_timeOutTimer invalidate];
	[_connection cancel];
	_connection = nil;
	_httpresponse = nil;
	
	[AppDelegate releaseNetworkActivityIndicator];

	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusConnectionFail object:self userInfo:nil];
	
	_retainSelf = nil;
}

-(void)connection:(NSURLConnection *)conn willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
			 forAuthenticationChallenge:challenge];
		return;
	}

	//NSLog(@"willSendRequestForAuthenticationChallenge %@", challenge.protectionSpace.authenticationMethod);

	//NSLog(@"%d failures", [challenge previousFailureCount]);
	
	// keep a reference to the challenge so we can send later
	_connectionChallenge = challenge;
	
	//[SimpleKeychain delete:@"Argus_Credentials"];
	NSDictionary *auth = [SimpleKeychain load:@"Argus_Credentials"];
	if ([challenge previousFailureCount] == 0 && auth)
	{
		// on the first auth attempt, try to use saved details if we have any
		//NSLog(@"%s got stored auth details", __PRETTY_FUNCTION__);
		[_connectionChallenge.sender useCredential:[NSURLCredential credentialWithUser:auth[@"user"]
																			  password:auth[@"pass"]
																		   persistence:NSURLCredentialPersistenceForSession]
						forAuthenticationChallenge:_connectionChallenge];
		
	}
	else
	{
		//NSLog(@"%s no stored auth details", __PRETTY_FUNCTION__);
		[_connectionChallenge.sender continueWithoutCredentialForAuthenticationChallenge:_connectionChallenge];
	}
}

-(void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
	[_timeOutTimer invalidate];

	_error = error;
	
	NSLog(@"Argus %@ -error %@", _url, error);

	// nil out connection, this is basically isRunning=NO
	[_connection cancel];
	_connection = nil;
	[AppDelegate releaseNetworkActivityIndicator];

	if (self.completionBlock)
	{
		[[NSOperationQueue new] addOperationWithBlock:^{
			self.completionBlock(self->_httpresponse, nil, error);
		}];
		
		/* don't do the notification stuff below, assume the completionBlock has handled everything */
		_retainSelf = nil;
		return;
	}

	// tell someone about the failure
	NSDictionary *userInfo = @{ @"error": error };
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusConnectionFail object:self userInfo:userInfo];
	
	_retainSelf = nil;
}

-(void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
	[_timeOutTimer invalidate];

	_httpresponse = (NSHTTPURLResponse *)response;
	
	NSInteger statusCode = [_httpresponse statusCode];
	NSLog(@"Argus %@ %d", _url, statusCode);

	if (statusCode == 200)
	{
		[_receivedData setLength:0];
    }
	else
	{
		if (statusCode == 401 || statusCode == 403 || statusCode == 404)
		{
			[_connection cancel];
			_connection = nil;
			[AppDelegate releaseNetworkActivityIndicator];
			
			if (self.completionBlock)
			{
				[[NSOperationQueue new] addOperationWithBlock:^{
					self.completionBlock(self->_httpresponse, nil, nil);
				}];
				
				/* don't do the notification stuff below, assume the completionBlock has handled everything */
				_retainSelf = nil;
				return;
			}

			// tell someone about the failure
			[[NSNotificationCenter defaultCenter] postNotificationName:kArgusConnectionFail object:self userInfo:nil];
			
			_retainSelf = nil;
		}
	}
}

-(void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
	// NSLog(@"didReceiveData");
    [_receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)conn
{
	NSLog(@"Argus %@ -finish", _url);

	//NSLog(@"%@", receivedData);
	
	// nil out req so we can't be started again. this makes -start return NO
	// if we need url after this we'll have to introduce isRunning and isFinished instead
	_req = nil;
	[AppDelegate releaseNetworkActivityIndicator];

	if (self.completionBlock)
	{
		[[NSOperationQueue new] addOperationWithBlock:^{
			self.completionBlock(self->_httpresponse, self->_receivedData, nil);
		}];
		
		/* don't do the notification stuff below, assume the completionBlock has handled everything */
		_retainSelf = nil;
		return;
	}
	
	NSDictionary *info = @{ @"data": _receivedData };
	NSInteger statusCode = [_httpresponse statusCode];
	
	if (statusCode == 500)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kArgusConnectionFail object:self userInfo:info];
		return;
	}
		
	// tell all interested parties a request is done
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusConnectionDone object:self userInfo:info];
	
	_retainSelf = nil;
}

-(NSString *)baseURL
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [NSString stringWithFormat:@"https://%@:49941/ArgusTV", [defaults stringForKey:@"host_preference"]];
}

@end
