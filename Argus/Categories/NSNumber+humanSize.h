//
//  NSNumber+humanSize.h
//  Argus
//
//  Created by Chris Elsworth on 13/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kUnitStringBinaryUnits     = 1 << 0,
    kUnitStringOSNativeUnits   = 1 << 1,
    kUnitStringLocalizedFormat = 1 << 2
};

@interface NSNumber (humanSize)

-(NSString *)humanSize;

-(NSArray *)hmsArray;
-(NSString *)hmsString;
-(NSString *)hmsStringReadable;

-(NSString *)priorityString;

@end
