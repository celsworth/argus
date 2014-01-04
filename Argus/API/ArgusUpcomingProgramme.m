//
//  ArgusUpcomingProgramme.m
//  Argus
//
//  Created by Chris Elsworth on 03/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

// extension of ArgusProgramme to contain everything relevant to an Upcoming Programme


#import "ArgusUpcomingProgramme.h"
#import "ArgusChannel.h"

#import "ArgusUpcomingRecordings.h"

#import "AppDelegate.h"

#import "NSDate+Formatter.h"

#import "DeviceDetection.h"
#import "ArgusScheduleIcons.h"

#import "JSONKit.h"

@implementation ArgusUpcomingProgramme
@synthesize ScheduleType;
@synthesize rChannel;
@synthesize isModified;
@synthesize SaveUpcomingProgrammeRequestsOutstanding;
@synthesize localNotification;

// set YES when we're waiting for a reply to the appropriate request
@synthesize IsCancelling, IsUncancelling, IsSaving;
@synthesize IsAddingToPRH, IsRemovingFromPRH;

// given an UpcomingProgramId, look up an existing ArgusUpcomingProgramme object in the UpcomingProgrammes dictionary
// this isn't keyed by UpcomingProgramId so it's an O(n) loop
+(ArgusUpcomingProgramme *)UpcomingProgrammeForUpcomingProgramId:(NSString *)UpcomingProgramId
{
	ArgusUpcomingProgramme *Programme;
	
	// O(n) lookup of the upcoming programme for this programme
	// we do this rather than store Programme in a property so that if the list of upcoming programmes is refreshed
	// (which it often is when we save changes etc), we still get the right data instead of looking at an old object
	for (NSString *uniqId in [[argus UpcomingProgrammes] UpcomingProgrammesKeyedByUniqueIdentifier])
	{
		ArgusUpcomingProgramme *t = [[argus UpcomingProgrammes] UpcomingProgrammesKeyedByUniqueIdentifier][uniqId];
		if ([[t Property:kUpcomingProgramId] isEqualToString:UpcomingProgramId])
		{
			Programme = t;
			break;
		}
	}
	
	assert(Programme);
	return Programme;
}

// stop [super initWithDictionary] being called implicitly, callers should use the init below this
-(id)initWithDictionary:(NSDictionary *)input
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(id)initWithDictionary:(NSDictionary *)input ScheduleType:(ArgusScheduleType)_ScheduleType
{
	self = [super init];
	if (self)
	{
		ScheduleType = _ScheduleType;
		
		[self populateSelfFromDictionary:input];
		IsSaving = NO;
		IsCancelling = NO;
		IsUncancelling = NO;
		
		[self setupLocalNotification];
	}
	return self;
}
-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setupLocalNotification
{
	// notifications are only relevant for alerts
	if (ScheduleType == ArgusScheduleTypeAlert)
	{
		// see if we need to set one up if the preference is on
		if (notifyForUpcomingAlerts != ArgusPreferenceAlertNotificationOff)
		{
			// notifyForUpcomingAlerts is actually an integer in minutes, dictating the advance notice
			// they want for notifications.
			NSTimeInterval preFire = -(notifyForUpcomingAlerts * 60);
			NSDate *fireDate = [[self Property:kStartTime] dateByAddingTimeInterval:preFire];
			
			// our Upcoming Programmes list includes programmes currently showing.
			// this gets annoying if we add a local notification for a programme
			// currently showing because the system will show it repeatedly.
			// don't schedule anything with a fireDate before now
			if ([fireDate timeIntervalSinceNow] < 0)
			{
				localNotification = nil;
				return;
			}
			
			NSDictionary *userInfo = @{ kArgusLocalNotificationProgrammeKey: [self Property:kUpcomingProgramId] };
			
			localNotification = [[UILocalNotification alloc] init];
						
			[localNotification setFireDate:fireDate];
			[localNotification setTimeZone:[NSTimeZone localTimeZone]];
			
			NSString *x = NSLocalizedString(@"%@ is about to start on %@",
											@"notification popup for alert (%@ are title and channel)");
			NSString *alertBody = [NSString stringWithFormat:x,
								   [self Property:kTitle], [[self Channel] Property:kDisplayName]];
			[localNotification setAlertBody:alertBody];
			[localNotification setHasAction:NO];
			[localNotification setSoundName:UILocalNotificationDefaultSoundName];
			[localNotification setUserInfo:userInfo];
			
			[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

			NSLog(@"%s ADD %@ %@", __PRETTY_FUNCTION__, [self Property:kTitle], localNotification);
		}
		else if (localNotification)
		{
			NSLog(@"%s REMOVE %@ %@", __PRETTY_FUNCTION__, [self Property:kTitle], localNotification);
			
			// remove any existing pending notification
			[[UIApplication sharedApplication] cancelLocalNotification:localNotification];
			localNotification = nil;
		}
	}
	else
		localNotification = nil; // probably not necessary
	
	NSLog(@"%s %d local notifications queued", __PRETTY_FUNCTION__, [[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
}

-(void)showLocalNotification
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// setupLocalNotification is for scheduled out-of-app alerts
	// showLocalNotification is for in-app alerts, called from didReceiveLocalNotification
		
	NSString *x = NSLocalizedString(@"%@ is about to start on %@",
									@"notification popup for alert (%@ are title and channel)");
	NSString *alertBody = [NSString stringWithFormat:x,
						   [self Property:kTitle], [[self Channel] Property:kDisplayName]];

	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert Notification"
												 message:alertBody
												delegate:nil
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
	[av show];
}

-(BOOL)populateSelfFromDictionary:(NSDictionary *)input
{
	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (! [super populateSelfFromDictionary:input])
		return NO;

	if ([input isKindOfClass:[NSDictionary class]])
	{
		isModified = NO;
		
		// UpcomingProgramme objects have a Channel sub-object
		// rChannel is alloced and retained in an UpcomingProgramme, then linked to
		// Programme.Channel weakly so uniqueIdentifier works (amongst other things)
		rChannel = [[ArgusChannel alloc] initWithDictionary:input[kChannel]];
		self.Channel = rChannel;
		
		return YES;
	}	
	return NO;
}


-(void)cancelUpcomingProgramme
{
	NSString *url = [NSString stringWithFormat:@"Scheduler/CancelUpcomingProgram/%@/%@/%@?guideProgramId=%@",
					 [self Property:kScheduleId],
					 [[self Channel] Property:kChannelId],
					 [[self Property:kStartTime] asFormat:@"yyyy-MM-dd'T'HH:mm:ss"],
					 [self Property:kGuideProgramId]];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	
	IsCancelling = YES;

	// inline block to forward on the notification when that finishes
	[[NSNotificationCenter defaultCenter] addObserverForName:kArgusConnectionDone
													  object:c
													   queue:nil
												  usingBlock:^(NSNotification *note)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[note object]];
		IsCancelling = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:kArgusCancelUpcomingProgrammeDone object:self];
	}];
	
	/* old way
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(CancelUpcomingProgrammeDone:)
												 name:kArgusConnectionDone
											   object:c];
	 */
}
/*
-(void)CancelUpcomingProgrammeDone:(NSNotification *)notify
{
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	IsCancelling = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusCancelUpcomingProgrammeDone object:self];
}
*/

-(void)uncancelUpcomingProgramme
{	
	NSString *url = [NSString stringWithFormat:@"Scheduler/UncancelUpcomingProgram/%@/%@/%@?guideProgramId=%@",
					 [self Property:kScheduleId],
					 [self.Channel Property:kChannelId],
					 [[self Property:kStartTime] asFormat:@"yyyy-MM-dd'T'HH:mm:ss"],
					 [self Property:kGuideProgramId]];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(UncancelUpcomingProgrammeDone:)
												 name:kArgusConnectionDone
											   object:c];
	
	IsUncancelling = YES;
}
-(void)UncancelUpcomingProgrammeDone:(NSNotification *)notify
{
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	IsUncancelling = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusUncancelUpcomingProgrammeDone object:self];
}

-(void)addToPreviouslyRecordedHistory
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	NSString *url = [NSString stringWithFormat:@"Control/AddToPreviouslyRecordedHistory"];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:NO lowPriority:NO];
	
	NSString *body = [self.originalData JSONString];
	
	[c setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];

	[c enqueue];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(AddToPRHDone:)
												 name:kArgusConnectionDone
											   object:c];
	IsAddingToPRH = YES;
}

-(void)AddToPRHDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];

	IsAddingToPRH = NO;

	// send our own notification
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusAddToPreviouslyRecordedHistoryDone object:self];
}

-(void)removeFromPreviouslyRecordedHistory
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	NSString *url = [NSString stringWithFormat:@"Control/RemoveFromPreviouslyRecordedHistory"];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url startImmediately:NO lowPriority:NO];
	
	NSString *body = [self.originalData JSONString];
	
	[c setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	[c enqueue];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(RemoveFromPRHDone:)
												 name:kArgusConnectionDone
											   object:c];
	IsRemovingFromPRH = YES;
}

-(void)RemoveFromPRHDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	IsRemovingFromPRH = NO;
	
	// send our own notification
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusRemoveFromPreviouslyRecordedHistoryDone object:self];
}




-(void)saveUpcomingProgramme
{
	//	NSLog(@"%@", self.originalData);
	
	// count down how many outstanding connections there are until we consider the programme saved
	SaveUpcomingProgrammeRequestsOutstanding = 3;
	
	NSString *url = [NSString stringWithFormat:@"Scheduler/SetUpcomingProgramPriority/%@/%@?priority=%@", 
					 [self Property:kUpcomingProgramId],
					 [[self Property:kStartTime] asFormat:@"yyyy-MM-dd'T'HH:mm:ss"],
					 [self Property:kPriority]];
	
	ArgusConnection *c = [[ArgusConnection alloc] initWithUrl:url];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(SaveUpcomingProgrammeElementDone:)
												 name:kArgusConnectionDone
											   object:c];
	
	
	url = [NSString stringWithFormat:@"Scheduler/SetUpcomingProgramPreRecord/%@/%@?seconds=%@",
		   [self Property:kUpcomingProgramId],
		   [[self Property:kStartTime] asFormat:@"yyyy-MM-dd'T'HH:mm:ss"],
		   [self Property:kPreRecordSeconds]];
	
	c = [[ArgusConnection alloc] initWithUrl:url];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(SaveUpcomingProgrammeElementDone:)
												 name:kArgusConnectionDone
											   object:c];
	
	
	url = [NSString stringWithFormat:@"Scheduler/SetUpcomingProgramPostRecord/%@/%@?seconds=%@",
		   [self Property:kUpcomingProgramId],
		   [[self Property:kStartTime] asFormat:@"yyyy-MM-dd'T'HH:mm:ss"],
		   [self Property:kPostRecordSeconds]];
	
	c = [[ArgusConnection alloc] initWithUrl:url];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(SaveUpcomingProgrammeElementDone:)
												 name:kArgusConnectionDone
											   object:c];
	
	IsSaving = YES;
}
-(void)SaveUpcomingProgrammeElementDone:(NSNotification *)notify
{
	//NSData *data = [[notify userInfo] objectForKey:@"data"];
	SaveUpcomingProgrammeRequestsOutstanding--;
	
	// there will be no more notifications from that object
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	if (SaveUpcomingProgrammeRequestsOutstanding == 0)
	{
		IsSaving = NO;
		isModified = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:kArgusSaveUpcomingProgrammeDone object:self];
	}
}


-(void)setPriority:(NSNumber *)val
{
	[[self originalData] setValue:val forKey:kPriority];
	isModified = YES;
}

-(void)setPreRecordSeconds:(NSNumber *)val
{
	[[self originalData] setValue:val forKey:kPreRecordSeconds];
	isModified = YES;
}
-(void)setPostRecordSeconds:(NSNumber *)val
{
	[[self originalData] setValue:val forKey:kPostRecordSeconds];
	isModified = YES;
}

-(ArgusUpcomingProgrammeScheduleStatus)scheduleStatus
{
	//NSLog(@"%s %@ %d", __PRETTY_FUNCTION__, [self Property:kTitle], ScheduleType);

	ArgusUpcomingRecording *upr = [self upcomingRecording];
		
	BOOL isCancelled = [[self Property:kIsCancelled] boolValue];
	if (upr)
	{
		// for upcoming recordings, a null CardChannelAllocation is equivalent to cancelled
		if (![upr Property:kCardChannelAllocation])
			isCancelled = YES;
		
	}
	
	//NSLog(@"%@", [self originalData]);

	switch (ScheduleType)
	{
		case ArgusScheduleTypeRecording:
			// decide cancellation reason
			if (isCancelled)
			{
				// conflict, and lost, won't be recorded
				if ([[upr Property:kConflictingPrograms] count] > 0)
					return ArgusUpcomingProgrammeScheduleStatusRecordingCancelledConflict;
				
				switch ((ArgusCancellationReason)[[self Property:kCancellationReason] intValue])
				{
					case ArgusCancellationReasonNone:
						// not supposed to happen, but it can if our UpcomingRecordings
						// and this UpcomingProgramme are desynced :(
						return ArgusUpcomingProgrammeScheduleStatusRecordingCancelledConflict;
						
					case ArgusCancellationReasonManual:
						return ArgusUpcomingProgrammeScheduleStatusRecordingCancelledManually;

					case ArgusCancellationReasonPreviouslyRecorded:
						return ArgusUpcomingProgrammeScheduleStatusRecordingCancelledAlreadyRecorded;
					
					case ArgusCancellationReasonAlreadyQueued:
						return ArgusUpcomingProgrammeScheduleStatusRecordingCancelledAlreadyRecorded;
				}
			}
			else
			{
				// conflict, but it "won" and will be recorded
				if ([[upr Property:kConflictingPrograms] count] > 0)
					return ArgusUpcomingProgrammeScheduleStatusRecordingScheduledConflict;
				
				return ArgusUpcomingProgrammeScheduleStatusRecordingScheduled;
			}
			break;
			
		case ArgusScheduleTypeAlert:
			return isCancelled ? ArgusUpcomingProgrammeScheduleStatusAlertCancelled : ArgusUpcomingProgrammeScheduleStatusAlertScheduled;
			break;

		case ArgusScheduleTypeSuggestion:
			return isCancelled ? ArgusUpcomingProgrammeScheduleStatusSuggestionCancelled : ArgusUpcomingProgrammeScheduleStatusSuggestionScheduled;
			break;
	}	
}

-(UIImage *)iconImage
{
	return [[ArgusScheduleIcons sharedInstance] iconFor:self];
}

-(ArgusUpcomingRecording *)upcomingRecording
{
	// if this upcoming programme has an associated upcoming recording, return it, else nil
	
	NSString *upcomingProgramId = [self Property:kUpcomingProgramId];
	
	//NSLog(@"%s %@", __PRETTY_FUNCTION__, upcomingProgramId);
	
	return [[argus UpcomingRecordings] UpcomingRecordingsKeyedByUpcomingProgramId][upcomingProgramId];
}


@end
