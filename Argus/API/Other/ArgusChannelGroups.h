//
//  ArgusChannelGroups.h
//  Argus
//
//  Created by Chris Elsworth on 26/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ArgusGlobalDefinitions.h"
#import "ArgusChannelGroup.h"

#define kArgusUserDefaultsSelectedChannelGroupName @"selectedchannelgroup_name"
#define kArgusUserDefaultsSelectedChannelGroupType @"selectedchannelgroup_type"


#define kArgusChannelGroupsDone    @"ArgusChannelGroupsDone"

#define kArgusSelectedChannelGroupChanged @"ArgusSelectedChannelGroupChanged"

@interface ArgusChannelGroups : NSObject

@property (nonatomic, retain) NSMutableArray *TvEntries;
@property (nonatomic, retain) NSMutableArray *RadioEntries;

@property (nonatomic, assign) BOOL TvGroupsDone;
@property (nonatomic, assign) BOOL RadioGroupsDone;

@property (nonatomic, assign) ArgusChannelType SelectedChannelType;
@property (nonatomic, retain) ArgusChannelGroup *SelectedChannelGroup;


-(void)getChannelGroups;

@end
