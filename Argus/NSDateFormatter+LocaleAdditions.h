//
//  NSDate+LocaleAdditions.h
//  Argus
//
//  Created by Chris Elsworth on 04/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (LocaleAdditions)

- (id)initWithPOSIXLocaleAndFormat:(NSString *)formatString;

@end
