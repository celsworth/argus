//
//  ArgusBaseObject.m
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusBaseObject.h"

#import "NSString+JSONDate.h"

@implementation ArgusBaseObject

-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)initWithDictionary:(NSDictionary *)input
{
	self = [super init];
	if (self)
	{
		if (! [self populateSelfFromDictionary:input])
			return nil;
	}
	return self;
}

-(BOOL)populateSelfFromDictionary:(NSDictionary *)input
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// keep a copy of the original data, for passing back out as a JSON object
	if ([input isKindOfClass:[NSDictionary class]])
		_originalData = [[NSMutableDictionary alloc] initWithDictionary:input];
	else
	{
		_originalData = nil;
		NSLog(@"%s %@ FAILED PARSING %@", __PRETTY_FUNCTION__, [self class], input);
	}
	
	return _originalData ? YES : NO;
}

-(NSString *)description
{
	return [[self originalData] description];
}

-(id)Property:(NSString *)what
{
	id ret = _originalData[what];
	
	// return nil if the object is null or NSNull, to avoid having this check everywhere in code
	if (!ret || ret == [NSNull null])
		return nil;
	
	// if they are asking for a date, return an NSDate, not an NSString
	// note these == only work because we're comparing against constants whose addresses never change
	// its a lot faster than isEqualToString and achieves the same thing
	if ([what isEqual:kStartTime] || [what isEqual:kStopTime])
		return [ret getDateFromJSON];

	if ([what isEqual:kActualStartTime] || [what isEqual:kActualStopTime] || [what isEqual:kRecordingStartTime])
		return [ret getDateFromJSON];
	
	if ([what isEqual:kStreamStartedTime] || [what isEqual:kStreamLastAliveTime])
		return [ret getDateFromJSON];
	
	if ([what isEqual:kRecordedOn])
		return [ret getDateFromJSON];

	return ret;
}
-(void)setValue:(id <NSCopying>)val forProperty:(NSString *)what
{
	_originalData[what] = val;
	//[_originalData setValue:val forKey:what];
}


@end