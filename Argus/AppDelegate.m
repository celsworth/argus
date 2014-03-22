//
//  AppDelegate.m
//  Argus
//
//  Created by Chris Elsworth on 01/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "AppDelegate.h"

#import "ArgusUpcomingProgramme.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[TestFlight takeOff:@"937054f4-277a-4121-ac3c-4082442f5367"];
	
	if (iPad())
	{
		// iPad
		_ActiveStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    }
	else
	{
		// iPhone
		_ActiveStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
	}
	
	
	// DEFAULT VALUES - these should match the Settings.bundle plists!
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
	[defaults synchronize];
	
	// GLOBAL POINTER
	argus = [Argus new];
	
	// queue up requests to Argus so we don't have 50 going at once!
	// also handles failures and stuff
	_arguscq = [ArgusConnectionQueue new];
	
	
	self.reachability = [Reachability reachabilityWithHostName:[defaults stringForKey:@"host_preference"]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)
												 name:kReachabilityChangedNotification
											   object:self.reachability];
	[self.reachability startNotifier];
	
	
	// global pointers to preferences
	dark = NO;
	autoReloadDataOn3G = YES;
	notifyForUpcomingAlerts = [defaults integerForKey:kArgusPreferenceNotifyForAlert];
	
	UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
	if (localNotification)
	{
		
	}
	
	/* reset all tableview separator insets on iOS7 back to zero */
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
		[[UITableView appearance] setSeparatorInset:UIEdgeInsetsZero];
	
	if (dark)
	{
		NSDictionary *textAttributes =
		@{
		  UITextAttributeTextColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
		  UITextAttributeTextShadowColor: [UIColor colorWithRed:128.0 green:128.0 blue:128.0 alpha:0.8],
		  };
		
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
		
		[[UISearchBar appearance] setBackgroundColor:[UIColor blackColor]];
		[[UILabel appearance] setTextColor:[UIColor whiteColor]];
		
		[[UITableViewCell appearance] setBackgroundColor:[UIColor blackColor]];
		
		
		[[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
		[[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
		
		
		[[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
	}
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// if the notification preference was changed, update all our notifications, this could include setting them or cancelling them
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// if the preference changed while we were backgrounded, we need to refresh our local notifications
	ArgusPreferenceAlertNotification newNotifyPref = [defaults integerForKey:@"notify_alert_preference"];
	if (notifyForUpcomingAlerts != newNotifyPref)
	{
		notifyForUpcomingAlerts = newNotifyPref;
		[[argus UpcomingProgrammes] redoLocalNotifications];
	}
	
	if (_refreshDataWhenForegrounded)
	{
		[argus getChannels];
		[[argus RecordingFileFormats] getRecordingFileFormats];
		[[argus UpcomingProgrammes] getUpcomingProgrammes];
	}
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	NSLog(@"%s %@", __PRETTY_FUNCTION__, notification);
	
	// don't think I need to do this?
	//[[UIApplication sharedApplication] cancelLocalNotification:notification];
	
	ArgusGuid *UpcomingProgrammeId = notification.userInfo[kArgusLocalNotificationProgrammeKey];
	
	NSLog(@"%s looking for %@", __PRETTY_FUNCTION__, UpcomingProgrammeId);
	
	[[[argus UpcomingProgrammes] UpcomingAlerts] enumerateObjectsUsingBlock:
	 ^(ArgusUpcomingProgramme *obj, NSUInteger idx, BOOL *stop)
	 {
		 if ([[obj Property:kUpcomingProgramId] isEqualToString:UpcomingProgrammeId])
		 {
			 [obj showLocalNotification];
			 *stop = YES;
		 }
	 }];
	
	
	
}

+(AppDelegate *)sharedInstance
{
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

static NSInteger networkActivityRefCount = 0;
+(void) requestNetworkActivityIndicator
{
	++networkActivityRefCount;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
+(void) releaseNetworkActivityIndicator
{
	if (--networkActivityRefCount < 0)
		networkActivityRefCount = 0;
	
	if (networkActivityRefCount == 0)
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

static NSInteger loadingSpinnerRefCount = 0;
static LoadingSpinner *globalLoadingSpinner = nil;
+(void) requestLoadingSpinner
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	if (globalLoadingSpinner == nil)
		globalLoadingSpinner = [LoadingSpinner new];
	
	if (loadingSpinnerRefCount == 0)
	{
		NSLog(@"%s", __PRETTY_FUNCTION__);
		
		[globalLoadingSpinner presentOnView:[[[[AppDelegate sharedInstance] window] rootViewController] view]];
	}
	
	++loadingSpinnerRefCount;
}
+(void) releaseLoadingSpinner
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	if (--loadingSpinnerRefCount < 0)
		loadingSpinnerRefCount = 0;
	
	if (loadingSpinnerRefCount == 0)
	{
		[globalLoadingSpinner fadeOut];
	}
}

-(void)reachabilityChanged:(NSNotification *)note
{
	Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	
	NSLog(@"%s %d", __PRETTY_FUNCTION__, [[note object] currentReachabilityStatus]);
	
}

-(BOOL)isOnWWAN
{
	NetworkStatus netStatus = [[self reachability] currentReachabilityStatus];
	switch (netStatus)
	{
		default:
			return NO;
			
		case ReachableViaWWAN:
			return YES;
			
	}
	return NO;
}

@end
