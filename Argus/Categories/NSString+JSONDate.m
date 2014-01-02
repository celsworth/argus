//
//  NSString+JSONDate.m
//  Argus
//
//  Created by Chris Elsworth on 02/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "NSString+JSONDate.h"

@implementation NSString (JSONDate)


- (NSDate *) getDateFromJSON
{
	NSInteger startPos, endPos;
    // Expect date in this format "/Date(1268123281843+0000)/"
    startPos = [self rangeOfString:@"("].location+1;
	NSCharacterSet *tmp = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
    endPos = [self rangeOfCharacterFromSet:tmp].location;
	
	NSRange range = NSMakeRange(startPos,endPos-startPos);
    unsigned long long milliseconds = [[self substringWithRange:range] longLongValue];
    NSTimeInterval interval = milliseconds/1000;
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

@end
