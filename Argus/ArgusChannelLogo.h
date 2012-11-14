//
//  ArgusChannelLogo.h
//  Argus
//
//  Created by Chris Elsworth on 03/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ArgusConnection.h"

#define kArgusChannelLogoDone @"ArgusChannelLogoDone"

@interface ArgusChannelLogo : NSObject
@property (nonatomic, retain) NSString *ChannelId;

@property (nonatomic, assign) float scale;

@property (nonatomic, retain) UIImage *imageWhichStopsUsCrashing;


-(id)initWithChannelId:(NSString *)incomingChannelId;

-(UIImage *)image;
-(BOOL)fetchLogoIfNewerThan:(NSDate *)modTime;

-(BOOL)createBasePath;
-(NSString *)basePath;
-(NSString *)absoluteFileForLogo;
-(NSDictionary *)statLogo;
-(NSDate *)logoModTime;
-(BOOL)saveLogoWithContents:(NSData *)data;
-(UIImage *)loadLogo;


@end
