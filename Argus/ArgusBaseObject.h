//
//  ArgusBaseObject.h
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ArgusGlobalDefinitions.h"

#import "ArgusSchedules.h"


@interface ArgusBaseObject : NSObject
@property (nonatomic, retain) NSMutableDictionary *originalData;

-(id)initWithDictionary:(NSDictionary *)input;
-(BOOL)populateSelfFromDictionary:(NSDictionary *)input;

-(id)Property:(NSString *)what;
-(void)setValue:(id <NSCopying>)val forProperty:(NSString *)what;

@end