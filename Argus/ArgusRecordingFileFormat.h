//
//  ArgusRecordingFileFormat.h
//  Argus
//
//  Created by Chris Elsworth on 15/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "ArgusBaseObject.h"

#define kArgusRecordingFileFormatSaveDone   @"kArgusRecordingFileFormatSaveDone"
#define kArgusRecordingFileFormatDeleteDone @"kArgusRecordingFileFormatDeleteDone"


@interface ArgusRecordingFileFormat : ArgusBaseObject

-(id)initWithDictionary:(NSDictionary *)input;

-(void)save;
-(void)delete;


@end
