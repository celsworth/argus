//
//  ArgusCategories.h
//  Argus
//
//  Created by Chris Elsworth on 16/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ArgusGlobalDefinitions.h"

#define kArgusCategoriesDone @"kArgusCategoriesDone"


@interface ArgusCategories : NSObject


@property (nonatomic, retain) NSMutableArray *Categories;


-(void)getCategories;

@end