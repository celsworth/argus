//
//  LoadingSpinner.m
//  Argus
//
//  Created by Chris Elsworth on 02/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LoadingSpinner.h"
#import "AppDelegate.h"

// private properties
@interface LoadingSpinner ()
@property (nonatomic, retain) LoadingSpinnerViewController *vc;
@end

@implementation LoadingSpinner
-(id)init
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

	self = [super init];
	if (self)
	{
		UIStoryboard *tmp = [UIStoryboard storyboardWithName:(iPad() ? @"LoadingSpinner_iPad" : @"LoadingSpinner_iPhone") bundle:nil];
		_vc = [tmp instantiateInitialViewController];
	}
	return self;
}

-(void)presentOnView:(UIView *)view
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	self.vc.view.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.5];
	
	// this makes us fit into the parent view
	self.vc.view.frame = view.bounds;
	self.vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	[view addSubview:self.vc.view];
}

-(void)setProgress:(CGFloat)pctDone
{
	self.vc.progressView.hidden = NO;
	self.vc.progressView.progress = pctDone/100.0;
}

-(void)fadeOut
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	[UIView animateWithDuration:0.1
					 animations:^{self.vc.view.backgroundColor = [UIColor clearColor];}
					 completion:^(BOOL finished) { [self.vc.view removeFromSuperview]; } ];
}

@end
