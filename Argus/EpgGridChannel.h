//
//  EpgGridChannel.h
//  Argus
//
//  Created by Chris Elsworth on 06/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EpgGridDefines.h"

#import "ArgusChannel.h"


@class EpgGridChannel;
@protocol EpgGridChannelDelegate <NSObject>
-(void)epgGridChannel:(EpgGridChannel *)epgGridChannel receivedTapOn:(UITapGestureRecognizer *)recognizer;
@end

@interface EpgGridChannel : NSObject

@property (nonatomic, weak) id <EpgGridChannelDelegate> delegate;

@property (nonatomic, retain) ArgusChannel *Channel;

@property (nonatomic, retain) UIImageView *view;

@property (nonatomic, assign) NSInteger rowHeight;

-(id)initWithRowHeight:(NSInteger)_rowHeight channel:(ArgusChannel *)_channel delegate:(id <EpgGridChannelDelegate>)_delegate;

-(UIImageView *)makeView;

@end
