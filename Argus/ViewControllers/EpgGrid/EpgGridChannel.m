//
//  EpgGridChannel.m
//  Argus
//
//  Created by Chris Elsworth on 06/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "EpgGridChannel.h"

@implementation EpgGridChannel
@synthesize delegate;
@synthesize view;
@synthesize rowHeight;
@synthesize Channel;

-(id)initWithRowHeight:(NSInteger)_rowHeight channel:(ArgusChannel *)_channel delegate:(id <EpgGridChannelDelegate>)_delegate
{
	self = [super init];
	if (self)
	{
		rowHeight = _rowHeight;
		Channel = _channel;
		delegate = _delegate;
	}
	return self;
}
-(void)dealloc
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIImageView *)makeView
{
	// have ourselves be notified when this channel logo (re-)loads
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadImage:)
												 name:kArgusChannelLogoDone
											   object:[Channel Logo]];
	
	view = [UIImageView new];
	
	[self addImageToView];
	
	[view setUserInteractionEnabled:YES];
	
	UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnView:)];
	[view setGestureRecognizers:@[tgr]];
	
	return view;
}
-(void)reloadImage:(NSNotification *)notify
{
	[self addImageToView];
}
-(void)addImageToView
{
	// called when a new logo is fetched for the channel
	UIImage *img = [[Channel Logo] image];
	if (img)
	{
		CGSize imgSize = [img size];
		
		NSInteger rowOffset = (rowHeight - imgSize.height) / 2; // centre-vertical-align in each row
		[view setFrame:CGRectMake(0, rowOffset, imgSize.width, imgSize.height)];
		[view setImage:img];
	}
}


-(void)didTapOnView:(id)sender
{
	[delegate epgGridChannel:self receivedTapOn:sender];
}


@end
