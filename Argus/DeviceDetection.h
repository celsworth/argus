//
//  DeviceDetection.h
//  Argus
//
//  Created by Chris Elsworth on 16/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ArgusDeviceTypeiPhoneSD     = 10,
	ArgusDeviceTypeiPhoneRetina = 11,
	ArgusDeviceTypeiPadSD       = 20,
	ArgusDeviceTypeiPadRetina   = 21,
} ArgusDeviceType;


@interface DeviceDetection : NSObject
+(ArgusDeviceType)deviceType;
@end
