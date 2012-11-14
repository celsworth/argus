//
//  ArgusRecordingFileFormats.h
//  Argus
//
//  Created by Chris Elsworth on 15/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kArgusRecordingFileFormatsDone @"kArgusRecordingFileFormatsDone"


@interface ArgusRecordingFileFormats : NSObject

@property (nonatomic, retain) NSMutableArray *RecordingFileFormats;
@property (nonatomic, retain) NSMutableDictionary *RecordingFileFormatsKeyedById;

-(void)getRecordingFileFormats;


@end
