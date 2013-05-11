//
//  NSNumber+humanSize.m
//  Argus
//
//  Created by Chris Elsworth on 13/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusBaseObject.h"

#import "NSNumber+humanSize.h"

@implementation NSNumber (humanSize)

-(NSString *)humanSize
{
    static const char units[] = { '\0', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y' };
    static int maxUnits = sizeof units - 1;
	
	double bytes = [self doubleValue];
	
    int multiplier = 1024;
    int exponent = 0;
	
    while (bytes >= multiplier && exponent < maxUnits) {
        bytes /= multiplier;
        exponent++;
    }
	
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:1];
	[formatter setNumberStyle: NSNumberFormatterDecimalStyle];

    // Beware of reusing this format string. -[NSString stringWithFormat] ignores \0, *printf does not.
    return [NSString stringWithFormat:@"%@ %ciB", [formatter stringFromNumber: @(bytes)], units[exponent]];
}

-(NSArray *)hmsArray
{
	NSInteger h = 0, m = 0, s = [self intValue];
	if (s > 3599)
	{
		h = s / 3600;
		s -= h * 3600;
	}
	if (s > 59)
	{
		m = s / 60;
		s -= m * 60;
	}
	return @[@(h),
			@(m), @(s)];
}

-(NSString *)hmsString
{
	NSArray *hms = [self hmsArray];
	
	return [NSString stringWithFormat:@"%d:%02d:%02d",
	 [hms[0] intValue],
	 [hms[1] intValue],
	 [hms[2] intValue]];
}

-(NSString *)hmsStringReadable
{
	NSInteger d = 0, h = 0, m = 0, s = [self intValue];
	NSMutableArray *tmp = [NSMutableArray new];
	
	// my EPG from DVB seems to have all programmes at 1 second less than 1h, or 30m, or whatever
	// add one second if this seems to be the case, to make labels easier to read
	if (s % 60 == 59)
		s++;
	
	NSString *day = NSLocalizedString(@"day", @"singular day, used in time durations");
	NSString *days = NSLocalizedString(@"days", @"multiple days, used in time durations");
	NSString *hour = NSLocalizedString(@"hour", @"singular hour, used in time durations");
	NSString *hours = NSLocalizedString(@"hours", @"multiple hours, used in time durations");
	NSString *minute = NSLocalizedString(@"minute", @"singular minute, used in time durations");
	NSString *minutes = NSLocalizedString(@"minutes", @"multiple minutes, used in time durations");
	NSString *second = NSLocalizedString(@"second", @"singular second, used in time durations");
	NSString *seconds = NSLocalizedString(@"seconds", @"multiple seconds, used in time durations");

	if (s > 59)
	{
		if (s > 86399)
		{
			d = s / 86400;
			s -= d * 86400;
			[tmp addObject:[NSString stringWithFormat:@"%d %@", d, (d == 1 ? day : days)]];
		}
		if (s > 3599)
		{
			h = s / 3600;
			s -= h * 3600;
			[tmp addObject:[NSString stringWithFormat:@"%d %@", h, (h == 1 ? hour : hours)]];
		}
		if (s > 59)
		{
			m = s / 60;
			[tmp addObject:[NSString stringWithFormat:@"%d %@", m, (m == 1 ? minute : minutes)]];
		}
	}
	
	// only display seconds for <1m durations
	else if (s > 0)
		[tmp addObject:[NSString stringWithFormat:@"%d %@", s, (s == 1 ? second : seconds)]];

	
	return [tmp componentsJoinedByString:@" "];
}


-(NSString *)priorityString
{
	ArgusPriority priority = [self intValue];
	
	switch (priority)
	{
		case ArgusPriorityVeryLow:
			return NSLocalizedString(@"very low", @"priority rating");
			
		case ArgusPriorityLow:
			return NSLocalizedString(@"low", @"priority rating");
			
		case ArgusPriorityNormal:
			return NSLocalizedString(@"normal", @"priority rating");
			
		case ArgusPriorityHigh:
			return NSLocalizedString(@"high", @"priority rating");
			
		case ArgusPriorityVeryHigh:
			return NSLocalizedString(@"very high", @"priority rating");
	}
}


@end
