//
//  ArgusScheduleIcons.m
//  Argus
//
//  Created by Chris Elsworth on 12/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusScheduleIcons.h"
#import "DeviceDetection.h"

static ArgusScheduleIcons *sharedArgusScheduleIcons = nil;

@implementation ArgusScheduleIcons

+(id)sharedInstance
{
	@synchronized(self)
	{
		if (!sharedArgusScheduleIcons)
			sharedArgusScheduleIcons = [self new];
	}
	return sharedArgusScheduleIcons;
}

-(id)init
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	self = [super init];
	if (self)
	{
		_spriteImage = [UIImage imageNamed:@"schedule-icons.png"];
		_spriteImageCG = [self.spriteImage CGImage];
		
		switch([DeviceDetection deviceType])
		{
			case ArgusDeviceTypeiPadSD:
			case ArgusDeviceTypeiPhoneSD:
				_scale = 1.0;
				break;
				
			case ArgusDeviceTypeiPadRetina:
			case ArgusDeviceTypeiPhoneRetina:
				_scale = 2.0;
				break;
		}
	}
	return self;
}

-(UIImage *)iconFor:(ArgusUpcomingProgramme *)UpcomingProgramme
{
	NSInteger row;
	switch ([UpcomingProgramme scheduleStatus])
	{
		case ArgusUpcomingProgrammeScheduleStatusRecordingScheduled:                row = 0; break;
		case ArgusUpcomingProgrammeScheduleStatusRecordingScheduledConflict:        row = 1; break;
		case ArgusUpcomingProgrammeScheduleStatusRecordingCancelledManually:        row = 2; break;
		case ArgusUpcomingProgrammeScheduleStatusRecordingCancelledAlreadyRecorded: row = 3; break;
		case ArgusUpcomingProgrammeScheduleStatusRecordingCancelledConflict:        row = 4; break;
			
		case ArgusUpcomingProgrammeScheduleStatusAlertScheduled: row = 5; break;
		case ArgusUpcomingProgrammeScheduleStatusAlertCancelled: row = 6; break;
			
		case ArgusUpcomingProgrammeScheduleStatusSuggestionScheduled: row = 7; break;
		case ArgusUpcomingProgrammeScheduleStatusSuggestionCancelled: row = 8; break;
	}
	
	BOOL isSeries = [[UpcomingProgramme Property:kIsPartOfSeries] boolValue];
	
	CGFloat imgH = 16, imgW = 16, seriesW = 24; // each icon in the sprite is 16x16, series are 24 wide
	
	CGFloat offsetX = (isSeries ? imgW : 0); // series icons start to the right of non-series, shift offsetX
	CGFloat offsetY = row * imgH;
	CGFloat width = isSeries ? seriesW : imgW;
	
	CGImageRef partOfImage = CGImageCreateWithImageInRect(self.spriteImageCG,
														  CGRectMake(offsetX*self.scale, offsetY*self.scale,
																	 width*self.scale, imgH*self.scale));
	UIImage *ret = [UIImage imageWithCGImage:partOfImage scale:self.scale orientation:UIImageOrientationUp];
	
	CGImageRelease(partOfImage);
	
	return ret;
}

@end
