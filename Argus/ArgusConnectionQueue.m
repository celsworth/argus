//
//  ArgusConnectionQueue.m
//  Argus
//
//  Created by Chris Elsworth on 05/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

// ArgusConnection enqueues itself into this singleton class instead of calling [start]
// this class remembers how many are ongoing and calls [start] when there's a "free slot"
// add a kArgusConnectionDone observer so we're told when it's done and can start a new one
// no need to forward notifies, ArgusConnection creator will have one already

// we handle errors too, perhaps add kArgusConnectionFail observer
// (creators don't generally do this)
// and then we can deal with timeouts, wrong username, whatever?
// we do popups (instead of ArgusConnection) then re-invoke the one that failed

#import "ArgusConnectionQueue.h"

@implementation ArgusConnectionQueue
@synthesize activeConnectionCount, maxActiveConnections;
@synthesize queuedConnections, activeConnections;

@synthesize visibleConnection;
@synthesize authDetailsAlertView, resetHostAlertView, connectFailedAlertView;

-(id)init
{
	self = [super init];
	if (self)
	{
		queuedConnections = [NSMutableArray new];
		activeConnections = [NSMutableArray new];
		
		maxActiveConnections = 5;
	}
	return self;
}

-(BOOL)queueConnection:(ArgusConnection *)c
{
	@synchronized(self)
	{
		// queuedConnections has newest at $max, oldest at 0
		[queuedConnections addObject:c];
	}
	
	// try and start immediately
	[self startNextQueuedConnection];
	
	return YES;
}
-(BOOL)queueUrgentConnection:(ArgusConnection *)c
{
	@synchronized(self)
	{
		// queuedConnections has newest at $max, oldest at 0
		// this function inserts the connection at the beginning of the queue
		[queuedConnections insertObject:c atIndex:0];
	}
	
	// try and start immediately
	[self startNextQueuedConnection];
	
	return YES;
}

-(void)cancelConnection:(ArgusConnection *)c
{
	@synchronized(self)
	{
		
		// if c is currently active, cancel it
		if ([activeConnections containsObject:c])
		{
			// ignore the inevitable kArgusConnectionFail notification
			[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:c];
			
			[c cancel];
			
			[activeConnections removeObjectIdenticalTo:c];
			activeConnectionCount--;
		}
		else
		{
			// remove from queuedArray
			[queuedConnections removeObjectIdenticalTo:c];
		}
	}
}

#if 0
-(void)cancelConnectionsWithJobId:(NSString *)jobId
{
	for (ArgusConnection *c in [queuedConnections copy])
	{
		if ([[c jobId] isEqualToString:jobId])
			[self cancelConnection:c];
	}
}
#endif

// internal functions below here..

-(void)startNextQueuedConnection
{
	@synchronized(self)
	{
		
		if ([queuedConnections count] == 0)
			// no connections to start
			return;
		
		if (activeConnectionCount == maxActiveConnections)
			// already at max
			return;
		
		// avoid spamming console too much by only printing this when we're going to do something
		NSLog(@"%s q=%d a=%d", __PRETTY_FUNCTION__, [queuedConnections count], activeConnectionCount);
		
		ArgusConnection *c = queuedConnections[0];
		
		BOOL r = [c start];
		if (r)
		{
			// return code of start tells us if it worked, the only reason it
			// won't is it's already running or already completed
			
			// now wait for it to be done, or to fail
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(handleConnectionDone:)
														 name:kArgusConnectionDone
													   object:c];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(handleConnectionFail:)
														 name:kArgusConnectionFail
													   object:c];
			
			// activeConnections has most recent at $max, oldest at 0
			[activeConnections addObject:c];
			
			activeConnectionCount++;
		}
		
		// remove from queued whether it worked or not
		[queuedConnections removeObjectIdenticalTo:c];
	}
	// loop into ourselves and see if we can start any more
	return [self startNextQueuedConnection];
	
}

#pragma mark - ArgusConnection Notification Handlers
-(void)handleConnectionDone:(NSNotification *)notify
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	ArgusConnection *c = [notify object];
	
	@synchronized(self)
	{
		activeConnectionCount--;
		// remove from activeConnections
		[activeConnections removeObjectIdenticalTo:c];
		
	}
	// remove observers for that connection
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:c];
	
	
	// and onto the next one
	[self startNextQueuedConnection];
}
-(void)handleConnectionFail:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	ArgusConnection *c = [notify object];
	
	@synchronized(self)
	{
		
		activeConnectionCount--;
		// remove from activeConnections
		[activeConnections removeObjectIdenticalTo:c];
	}
	
	// remove observers for that connection
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:c];
	
	
	// if the user is currently handling another failure, just put this back at the beginning of the queue
	if (visibleConnection)
	{
		NSLog(@"%s alertViewVisible=true", __PRETTY_FUNCTION__);
		[queuedConnections insertObject:c atIndex:0];
		return;
	}
	
	NSString *tmp;
	if ([c httpresponse])
	{
		NSLog(@"%s httpresponse", __PRETTY_FUNCTION__);
		// we got a http response
		switch ([[c httpresponse] statusCode])
		{
			case 401:
			case 403:
				[self askForAuthDetailsForConnection:c];
				// ask for auth details
				break;
				
			default:
				tmp = [[NSString alloc] initWithData:[notify userInfo][@"data"] encoding:NSASCIIStringEncoding];
				NSLog(@"HTTP Error %d: %@", [[c httpresponse] statusCode], tmp);
				break;
		}
	}
	else if ([c error])
	{
		NSLog(@"%s [c error]", __PRETTY_FUNCTION__);
		
		// didFailWithError was called
		NSError *error = [c error];
		switch([error code])
		{
			case NSURLErrorTimedOut: // don't think this will actually get called now
				[self connectFailedForConnection:c];
				break;
				
			case NSURLErrorCannotFindHost:		 
				[self resetHostForConnection:c];
				break;
				
			case NSURLErrorCannotConnectToHost:
				[self connectFailedForConnection:c];
				break;
				
			case NSURLErrorUserCancelledAuthentication:
				// don't think this gets called either, handled by 401/403 now
				[self askForAuthDetailsForConnection:c];
				break;
		}
	}
	else
	{
		// we timed out the connection ourselves
		[self connectFailedForConnection:c];
	}
	
}

#pragma mark - User Prompts
-(void)askForAuthDetailsForConnection:(ArgusConnection *)c
{
	NSString *tmp = NSLocalizedString(@"Enter Argus Credentials For",
									  @"login box title, hostname is added to the end of this");
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *host = [defaults stringForKey:@"host_preference"];
	NSString *title = [NSString stringWithFormat:@"%@ %@", tmp, host];
	
	authDetailsAlertView = [[UIAlertView alloc] initWithTitle:title
													  message:nil
													 delegate:self
											cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
											otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
	
	authDetailsAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
	
	// pre-fill username if we have it, but not password
	NSDictionary *auth = [SimpleKeychain load:@"Argus_Credentials"];
	[[authDetailsAlertView textFieldAtIndex:0] setText:auth[@"user"]];
	
	visibleConnection = c;
	
	[authDetailsAlertView show];
}


-(void)resetHostForConnection:(ArgusConnection *)c
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *host = [defaults stringForKey:@"host_preference"];
	
	NSString *title = NSLocalizedString(@"Set Argus Host/IP", nil);
	NSString *message = NSLocalizedString(@"Please enter the hostname or IP of your Argus server", nil);
	
	
	resetHostAlertView = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	
	resetHostAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	
	// pre-fill the address field if we have anything
	if (host)
		[[resetHostAlertView textFieldAtIndex:0] setText:host];
	
	visibleConnection = c;
	
	[resetHostAlertView show];
}


-(void)connectFailedForConnection:(ArgusConnection *)c
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	NSString *title = NSLocalizedString(@"Connection Failed", nil);
	
	NSString *message;
	if ([c error])
		message = [[c error] localizedDescription];
	else 
		// ArgusConnection handles timeouts differently
		message = NSLocalizedString(@"Connection timed out", nil);
	
	
	connectFailedAlertView = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
											  otherButtonTitles:NSLocalizedString(@"Retry", nil), NSLocalizedString(@"Change IP", nil), nil];
	
	visibleConnection = c;
	
	[connectFailedAlertView show];
}



#pragma mark - Alert View Delegate
-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
	if (alertView == resetHostAlertView)
	{
		NSString *host = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		return ([host length] > 0) ? YES : NO;
	}
	
	else if (alertView == authDetailsAlertView)
	{
		NSString *user = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		NSString *pass = [[alertView textFieldAtIndex:1].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if ([user length] == 0 || [pass length] == 0)
			return NO;
	}
	return YES;
}
-(void)alertViewCancel:(UIAlertView *)alertView
{
	// system cancelled our alertView
	visibleConnection = nil;
	
	
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		visibleConnection = nil;
		[self alertViewCancel:alertView];
		return;
	}
	
	if (alertView == connectFailedAlertView)
	{
		if (buttonIndex == 1)
		{
			NSLog(@"retry");
			// retry
			[queuedConnections insertObject:visibleConnection atIndex:0];
			visibleConnection = nil;
			[self startNextQueuedConnection];
		}
		else if (buttonIndex == 2)
		{
			// show Change IP alertView which will take over from us
			return [self resetHostForConnection:visibleConnection];
		}
	}
	
	else if (alertView == resetHostAlertView)
	{
		// cannot be empty thanks to alertViewShouldEnableFirstOtherButton
		NSString *entry = [[resetHostAlertView textFieldAtIndex:0] text];
		
		// set the specified host/ip in preferences, and try this request again
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:entry forKey:@"host_preference"];
		
		//NSString *host = [defaults stringForKey:@"host_preference"];
		//NSLog(@"host is now %@", host);
		
		[queuedConnections insertObject:visibleConnection atIndex:0];
		visibleConnection = nil;
		[self startNextQueuedConnection];
	}
	
	else if (alertView == authDetailsAlertView)
	{
		// cannot be empty thanks to alertViewShouldEnableFirstOtherButton
		NSString *user = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		NSString *pass = [[alertView textFieldAtIndex:1].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if (user && pass)
		{
			NSMutableDictionary *d = [NSMutableDictionary new];
			d[@"user"] = user;
			d[@"pass"] = pass;
			[SimpleKeychain save:@"Argus_Credentials" data:d];
		}
		
		// try again
		[queuedConnections insertObject:visibleConnection atIndex:0];
		visibleConnection = nil;
		[self startNextQueuedConnection];
	}
	
}

@end
