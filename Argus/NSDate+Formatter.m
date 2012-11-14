//
//  NSDate+Formatter.m
//  Argus
//
//  Created by Chris Elsworth on 08/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "NSDate+Formatter.h"

@implementation NSDate (Formatter)

-(NSString *)asFormat:(NSString *)fmt
{
	NSDateFormatter *df = [NSDateFormatter new];
	[df setDateFormat:fmt];
	return [df stringFromDate:self];
}


@end
