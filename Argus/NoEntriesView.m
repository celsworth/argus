//
//  NoEntriesView.m
//  Argus
//
//  Created by Chris Elsworth on 23/01/2014.
//  Copyright (c) 2014 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "NoEntriesView.h"

@interface NoEntriesView ()
@property (nonatomic, retain) UIView *view;
@end

@implementation NoEntriesView

-(id)init
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	if (self = [super init])
	{
		self.view = [[[NSBundle mainBundle] loadNibNamed:@"NoEntries" owner:self options:nil] firstObject];
	}
	return self;
}

-(void)presentOnView:(UIView *)targetView
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// this makes us fit into the parent view
	self.view.frame = targetView.bounds;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	[targetView addSubview:self.view];
	[targetView sendSubviewToBack:self.view];
}


@end
