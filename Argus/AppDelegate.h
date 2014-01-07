//
//  AppDelegate.h
//  Argus
//
//  Created by Chris Elsworth on 01/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Argus.h"
#import "ArgusConnectionQueue.h"
#import "LoadingSpinner.h"

#import "OnMainThread.h"

/* API VERSION DETAILS
	49: GetRecordings* (unused)
	50: ChannelsProgams (optionally used in EPG Grid)
	51: ChannelsProgramsDetails (unused)
	??: SetRecordingFullyWatchedCount (Argus 2.0)
	60: RESTful overhaul (Argus 2.2)
 */
#define REQUIRED_API_VERSION 45

#define REQUIRED_ARGUS_VERSION @"1.6.0.2"

// preference keys
#define kArgusPreferenceNotifyForAlert @"notify_alert_preference"

#define kArgusLocalNotificationProgrammeKey  @"kArgusLocalNotificationProgrammeKey"

typedef enum {
	ArgusPreferenceAlertNotificationOff     = -1,
	ArgusPreferenceAlertNotificationAtStart =  0,
	
} ArgusPreferenceAlertNotification;

// global pointers
// the argus object is accessed *EVERYWHERE* so this just makes life easier
Argus *argus;

// globals that could eventually become preferences
BOOL dark;
BOOL autoReloadDataOn3G;
ArgusPreferenceAlertNotification notifyForUpcomingAlerts;


#define iPad()   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define iPhone() ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)


#define isOnWWAN() ([AppDelegate isOnWWAN])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, retain) UIStoryboard *ActiveStoryboard;

@property (nonatomic, retain) ArgusConnectionQueue *arguscq;

@property (nonatomic, assign) BOOL refreshDataWhenForegrounded;

+(AppDelegate *)sharedInstance;

+(void) requestNetworkActivityIndicator;
+(void) releaseNetworkActivityIndicator;

+(void) requestLoadingSpinner;
+(void) releaseLoadingSpinner;

+(BOOL)isOnWWAN;

@end

