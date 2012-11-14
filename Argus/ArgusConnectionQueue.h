//
//  ArgusConnectionQueue.h
//  Argus
//
//  Created by Chris Elsworth on 05/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleKeychain.h"

#import "ArgusConnection.h"

@interface ArgusConnectionQueue : NSObject <UIAlertViewDelegate>

@property (nonatomic, assign) NSInteger maxActiveConnections;

@property (assign) NSInteger activeConnectionCount;
@property (retain) NSMutableArray *queuedConnections;
@property (retain) NSMutableArray *activeConnections;

// remember if we're displaying any alert view
// so that we don't try to display more than one at once
//@property (nonatomic, assign) BOOL isAlertViewVisible;
// the ArgusConnection for which an alertView is visible
// all others get punted back into a queue
@property (nonatomic, retain) ArgusConnection *visibleConnection;

// remember alertViews so we can match them up later
@property (nonatomic, retain) UIAlertView *resetHostAlertView;
@property (nonatomic, retain) UIAlertView *connectFailedAlertView;
@property (nonatomic, retain) UIAlertView *authDetailsAlertView;


-(BOOL)queueConnection:(ArgusConnection *)c;
-(BOOL)queueUrgentConnection:(ArgusConnection *)c;

-(void)cancelConnection:(ArgusConnection *)c;
//-(void)cancelConnectionsWithJobId:(NSString *)jobId;

@end