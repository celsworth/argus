//
//  NSDate+LocaleAdditions.m
//  Argus
//
//  Created by Chris Elsworth on 04/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "NSDateFormatter+LocaleAdditions.h"

@implementation NSDateFormatter (LocaleAdditions)

- (id)initWithPOSIXLocaleAndFormat:(NSString *)formatString {
    self = [self init];
    if (self)
	{
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [self setLocale:locale];
        [self setDateFormat:formatString];
    }
    return self;
}

@end
