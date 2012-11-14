//
//  DeviceDetection.m
//  Argus
//
//  Created by Chris Elsworth on 16/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "DeviceDetection.h"


@implementation DeviceDetection

+(ArgusDeviceType)deviceType
{
	CGFloat screenScale = [[UIScreen mainScreen] scale];
	
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		return screenScale == 2.0 ? ArgusDeviceTypeiPadRetina : ArgusDeviceTypeiPadSD;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		return screenScale == 2.0 ? ArgusDeviceTypeiPhoneRetina : ArgusDeviceTypeiPhoneSD;
	
	// failsafe default
	return ArgusDeviceTypeiPhoneSD;
}

@end
