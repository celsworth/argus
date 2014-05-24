//
//  ArgusChannelGroups.m
//  Argus
//
//  Created by Chris Elsworth on 26/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusChannelGroups.h"

#import "ArgusConnection.h"

@implementation ArgusChannelGroups

-(id)init
{
	self = [super init];
	if (self)
	{
		_SelectedChannelType = ArgusChannelTypeTelevision;
		_SelectedChannelGroup = nil; // nil until we fetch them, then autoselect one
	}
	return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setSelectedChannelGroup:(ArgusChannelGroup *)newSelectedChannelGroup
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// DO NOT USE self.SelectedChannelGroup HERE
	// causes an infinite loop back into ourselves
	_SelectedChannelGroup = newSelectedChannelGroup;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusSelectedChannelGroupChanged
														object:self
													  userInfo:nil];
	
	// save as new default
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[self.SelectedChannelGroup Property:kGroupName]
				 forKey:kArgusUserDefaultsSelectedChannelGroupName];
	[defaults setObject:[self.SelectedChannelGroup Property:kChannelType]
				 forKey:kArgusUserDefaultsSelectedChannelGroupType];
}


-(void)getChannelGroups
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	ArgusConnection *c;
	
	self.TvGroupsDone = NO;
	c = [self getChannelGroupsForChannelType:ArgusChannelTypeTelevision];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(TvChannelGroupsDone:)
												 name:kArgusConnectionDone
											   object:c];
	
	self.RadioGroupsDone = NO;
	c = [self getChannelGroupsForChannelType:ArgusChannelTypeRadio];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(RadioChannelGroupsDone:)
												 name:kArgusConnectionDone
											   object:c];
	
}
-(ArgusConnection *)getChannelGroupsForChannelType:(ArgusChannelType)ChannelType
{
	NSString *url = [NSString stringWithFormat:@"Scheduler/ChannelGroups/%ld", ChannelType];
	//NSLog(@"ChannelGroups @ %@", url);
	
	return [[ArgusConnection alloc] initWithUrl:url];
}

-(NSMutableArray *)parseChannelGroupData:(NSData *)data
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	
	NSMutableArray *tmpArr = [NSMutableArray new];
	
	for (NSDictionary *d in jsonObject)
	{
		ArgusChannelGroup *t = [[ArgusChannelGroup alloc] initWithDictionary:d];
		[tmpArr addObject:t];
	}
	
	return tmpArr;
}
-(void)TvChannelGroupsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	NSData *data = [notify userInfo][@"data"];
	self.TvEntries = [self parseChannelGroupData:data];
	self.TvGroupsDone = YES;
	
	if (self.TvGroupsDone && self.RadioGroupsDone)
		[self ChannelGroupsDone];
}

-(void)RadioChannelGroupsDone:(NSNotification *)notify
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[notify object]];
	
	NSData *data = [notify userInfo][@"data"];
	self.RadioEntries = [self parseChannelGroupData:data];
	self.RadioGroupsDone = YES;
	
	if (self.TvGroupsDone && self.RadioGroupsDone)
		[self ChannelGroupsDone];
	
}

-(void)ChannelGroupsDone
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *Saved_CG_Name = [defaults stringForKey:kArgusUserDefaultsSelectedChannelGroupName];
	int32_t Saved_CG_Type = [[defaults stringForKey:kArgusUserDefaultsSelectedChannelGroupType] intValue];
	if (Saved_CG_Name)
	{
		if (!self.SelectedChannelGroup && Saved_CG_Type == ArgusChannelTypeTelevision)
		{
			for (ArgusChannelGroup *cg in self.TvEntries)
			{
				if ([[cg Property:kGroupName] isEqualToString:Saved_CG_Name])
				{
					self.SelectedChannelGroup = cg;
					break;
				}
			}
		}
		if (!self.SelectedChannelGroup && Saved_CG_Type == ArgusChannelTypeRadio)
		{
			for (ArgusChannelGroup *cg in self.RadioEntries)
			{
				if ([[cg Property:kGroupName] isEqualToString:Saved_CG_Name])
				{
					self.SelectedChannelGroup = cg;
					break;
				}
			}
		}
	}
	
	// if still not selected, select the first one
	if (! self.SelectedChannelGroup)
	{
		if (self.SelectedChannelType == ArgusChannelTypeRadio && [self.RadioEntries count])
			self.SelectedChannelGroup = self.RadioEntries[0];
		if (self.SelectedChannelType == ArgusChannelTypeTelevision && [self.TvEntries count])
			self.SelectedChannelGroup = self.TvEntries[0];
	}
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusChannelGroupsDone object:self userInfo:nil];
}



@end
