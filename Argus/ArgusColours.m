//
//  ArgusColours.m
//  Argus
//
//  Created by Chris Elsworth on 05/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusColours.h"

#import "AppDelegate.h"

@implementation ArgusColours

+(UIColor *)bgColour
{
	if (dark) return [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:1];
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
	
}

@end
