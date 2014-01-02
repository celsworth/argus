//
//  NSString+JSONDate.h
//  Argus
//
//  Created by Chris Elsworth on 02/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSONDate)

- (NSDate *) getDateFromJSON;

@end
